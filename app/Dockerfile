FROM python:3.12-slim

WORKDIR /app

COPY flaskapp/requirements.txt /app/requirements.txt
RUN pip install --no-cache-dir -r /app/requirements.txt

COPY flaskapp /app/flaskapp
WORKDIR /app/flaskapp

EXPOSE 8080

# OpenTelemetry env defaults (Collector service name will be set via Helm)
ENV OTEL_EXPORTER_OTLP_PROTOCOL=grpc \
    OTEL_TRACES_EXPORTER=otlp \
    OTEL_METRICS_EXPORTER=none \
    OTEL_LOGS_EXPORTER=none

# Run via gunicorn + auto-instrumentation wrapper
CMD ["opentelemetry-instrument", "gunicorn", "-b", "0.0.0.0:8080", "app:app", "--workers", "2", "--threads", "4"]
