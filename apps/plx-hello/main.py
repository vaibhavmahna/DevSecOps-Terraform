import os

from fastapi import FastAPI

app = FastAPI(title="plx-hello")


@app.get("/")
def root():
    return {
        "app": "plx-hello",
        "environment": os.getenv("APP_ENV", "local"),
        "version": os.getenv("APP_VERSION", "dev"),
    }


@app.get("/healthz")
def health():
    return {"status": "ok"}
