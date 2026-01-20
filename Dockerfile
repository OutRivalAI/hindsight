# OutRival Hindsight - API Only Build
FROM python:3.11-slim

WORKDIR /app

# Install system dependencies and uv
RUN apt-get update && apt-get install -y \
    gcc \
    g++ \
    curl \
    && rm -rf /var/lib/apt/lists/* \
    && pip install --no-cache-dir uv

# Copy dependency files
COPY hindsight-api/pyproject.toml hindsight-api/README.md ./

# Remove local ML model dependencies to reduce image size (we use OpenAI)
RUN sed -i '/"sentence-transformers/d' pyproject.toml && \
    sed -i '/"transformers/d' pyproject.toml && \
    sed -i '/"torch/d' pyproject.toml

# Sync dependencies
RUN uv sync

# Copy source code
COPY hindsight-api/hindsight_api ./hindsight_api

# Install the package
RUN uv pip install -e .

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=120s --retries=3 \
    CMD curl -f http://localhost:8888/health || exit 1

EXPOSE 8888

ENV HINDSIGHT_API_HOST=0.0.0.0
ENV HINDSIGHT_API_PORT=8888
ENV PATH="/app/.venv/bin:$PATH"

CMD ["python", "-m", "hindsight_api.main"]
