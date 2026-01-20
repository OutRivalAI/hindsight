# OutRival Hindsight - API Only Build
# Based on upstream vectorize-io/hindsight

FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv

# Copy dependency files
COPY hindsight-api/pyproject.toml hindsight-api/README.md ./

# Install dependencies
RUN uv sync

# Copy source code
COPY hindsight-api/hindsight_api ./hindsight_api

# Install the package
RUN uv pip install -e .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8888/health || exit 1

EXPOSE 8888

# Default environment
ENV HINDSIGHT_API_HOST=0.0.0.0
ENV HINDSIGHT_API_PORT=8888

CMD ["python", "-m", "hindsight_api.main"]
