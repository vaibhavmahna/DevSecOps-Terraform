import os
from pathlib import Path
from typing import Literal

from fastapi import FastAPI, HTTPException
from fastapi.responses import FileResponse
from fastapi.staticfiles import StaticFiles
from pydantic import BaseModel, Field

import tools

STATIC_DIR = Path(__file__).parent / "static"
MAX_TEXT = 65536  # 64 KB cap on any text input

app = FastAPI(title="plx-devtools", docs_url="/api/docs", redoc_url=None)
app.mount("/static", StaticFiles(directory=STATIC_DIR), name="static")


class PasswordRequest(BaseModel):
    length: int = Field(20, ge=8, le=128)
    upper: bool = True
    lower: bool = True
    digits: bool = True
    symbols: bool = True


class TokenRequest(BaseModel):
    bytes: int = Field(32, ge=8, le=128)
    format: Literal["hex", "urlsafe"] = "hex"


class HashRequest(BaseModel):
    text: str = Field(max_length=MAX_TEXT)
    algorithm: Literal["md5", "sha1", "sha256", "sha512"] = "sha256"


class Base64Request(BaseModel):
    text: str = Field(max_length=MAX_TEXT)
    mode: Literal["encode", "decode"] = "encode"
    urlsafe: bool = False


class CidrRequest(BaseModel):
    cidr: str = Field(max_length=64)
    split_prefix: int | None = Field(None, ge=1, le=32)


class CronRequest(BaseModel):
    expression: str = Field(max_length=200)


def run(fn, *args, **kwargs):
    """Turn a tool's ValueError into a 400 with a readable message."""
    try:
        return fn(*args, **kwargs)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))


@app.get("/", include_in_schema=False)
def index():
    return FileResponse(STATIC_DIR / "index.html")


@app.get("/healthz")
def health():
    return {"status": "ok"}


@app.get("/api/info")
def info():
    return {
        "app": "plx-devtools",
        "environment": os.getenv("APP_ENV", "local"),
        "version": os.getenv("APP_VERSION", "dev"),
    }


@app.post("/api/password")
def password(req: PasswordRequest):
    return {"password": run(tools.generate_password, req.length, req.upper,
                            req.lower, req.digits, req.symbols)}


@app.post("/api/token")
def token(req: TokenRequest):
    return {"token": run(tools.generate_token, req.bytes, req.format)}


@app.post("/api/hash")
def hash_(req: HashRequest):
    return {"algorithm": req.algorithm, "hash": run(tools.hash_text, req.text, req.algorithm)}


@app.post("/api/base64")
def b64(req: Base64Request):
    fn = tools.base64_encode if req.mode == "encode" else tools.base64_decode
    return {"result": run(fn, req.text, req.urlsafe)}


@app.post("/api/cidr")
def cidr(req: CidrRequest):
    return run(tools.cidr_info, req.cidr, req.split_prefix)


@app.post("/api/cron")
def cron(req: CronRequest):
    return run(tools.explain_cron, req.expression)
