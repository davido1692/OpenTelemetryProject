FROM python:3.12-slim

WORKDIR /app

# Copy requirements FIRST (better layer caching)
COPY flaskapp/requirements.txt /app/requirements.txt

# Install deps + setuptools (fixes pkg_resources error)
RUN pip install --no-cache-dir -U pip setuptools wheel \
    && pip install --no-cache-dir -r /app/requirements.txt

# Copy application code
COPY flaskapp /app/flaskapp
WORKDIR /app/flaskapp

EXPOSE 8080

ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_TRACES_EXPORTER=otlp \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none

CMD ["gunicorn", "-b", "0.0.0.0:8080", "app:app", "--workers", "2", "--threads", "4"]
