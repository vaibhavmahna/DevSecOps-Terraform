import hashlib
import os
from pathlib import Path
from typing import Literal

# Send request traces to Application Insights when Azure provides a
# connection string. Must run before FastAPI is imported so it can be
# auto-instrumented. Health probes are skipped to keep ingestion near zero.
TELEMETRY = bool(os.getenv("APPLICATIONINSIGHTS_CONNECTION_STRING"))
if TELEMETRY:
    os.environ.setdefault("OTEL_PYTHON_FASTAPI_EXCLUDED_URLS", "healthz")
    from azure.monitor.opentelemetry import configure_azure_monitor

    configure_azure_monitor()

from fastapi import FastAPI, HTTPException  # noqa: E402
from fastapi.responses import FileResponse  # noqa: E402
from fastapi.staticfiles import StaticFiles  # noqa: E402
from pydantic import BaseModel, Field  # noqa: E402

import tools  # noqa: E402

STATIC_DIR = Path(__file__).parent / "static"
MAX_TEXT = 65536  # 64 KB cap on any text input

# Injected by Container Apps from Key Vault (via the app's managed identity).
# Only a short hash is ever exposed, never the value itself.
_signing_key = os.getenv("SIGNING_KEY", "")
KEY_FINGERPRINT = hashlib.sha256(_signing_key.encode()).hexdigest()[:8] if _signing_key else None

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
        "key_vault": {"connected": KEY_FINGERPRINT is not None, "fingerprint": KEY_FINGERPRINT},
        "telemetry": TELEMETRY,
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
