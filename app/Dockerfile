# -----------------------------------------------------------------------------
# Stage 1: Builder
# Install dependencies in an isolated stage so the final image stays small.
# -----------------------------------------------------------------------------
FROM python:3.12-slim AS builder

# Create a non-root user for the build stage
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --no-create-home appuser

WORKDIR /build

# Copy and install dependencies first (Docker layer cache benefit)
COPY requirements.txt .

RUN pip install --no-cache-dir --upgrade pip && \
    pip install --no-cache-dir --prefix=/install -r requirements.txt

# -----------------------------------------------------------------------------
# Stage 2: Production
# Only copy what is needed to run the application.
# -----------------------------------------------------------------------------
FROM python:3.12-slim AS production

# Security: create a dedicated non-root user
RUN groupadd --gid 1001 appgroup && \
    useradd --uid 1001 --gid appgroup --no-create-home --shell /bin/false appuser

# Copy installed packages from builder
COPY --from=builder /install /usr/local

WORKDIR /app

# Copy application source
COPY src/app.py .

# Set ownership to the non-root user
RUN chown -R appuser:appgroup /app

# Switch to non-root user
USER appuser

# Environment defaults (overridden at runtime by Docker / EC2 user-data)
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    APP_PORT=5000 \
    ENVIRONMENT=production \
    APP_VERSION=1.0.0

EXPOSE 5000

# Docker health check — Docker marks the container unhealthy if /health
# stops returning 200, triggering a restart when combined with restart policy.
HEALTHCHECK --interval=30s --timeout=10s --start-period=15s --retries=3 \
    CMD python -c "import urllib.request; urllib.request.urlopen('http://localhost:5000/health')" || exit 1

# Production WSGI server — gunicorn is more robust than Flask dev server
CMD ["gunicorn", \
     "--bind", "0.0.0.0:5000", \
     "--workers", "2", \
     "--timeout", "60", \
     "--access-logfile", "-", \
     "--error-logfile", "-", \
     "app:app"]