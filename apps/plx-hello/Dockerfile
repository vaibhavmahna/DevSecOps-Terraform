# ---- Stage 1: install dependencies ----
FROM python:3.12-slim AS build

WORKDIR /app

# Copy only the dependency list first, so this layer stays cached until
# requirements.txt changes - editing main.py won't reinstall packages.
COPY requirements.txt .
RUN pip install --no-cache-dir --prefix=/install -r requirements.txt

# ---- Stage 2: runtime image (the only stage that ships) ----
FROM python:3.12-slim

# Unbuffered output so logs reach `docker logs` / Azure immediately.
ENV PYTHONUNBUFFERED=1 \
    PYTHONDONTWRITEBYTECODE=1

WORKDIR /app

COPY --from=build /install /usr/local
COPY main.py .

# Run as an unprivileged user, never root.
RUN useradd --create-home --uid 10001 appuser
USER 10001

EXPOSE 8000

ENTRYPOINT ["uvicorn"]
CMD ["main:app", "--host", "0.0.0.0", "--port", "8000"]
