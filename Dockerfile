FROM python:3.12-slim

ENV PYTHONUNBUFFERED=1 \
    PIP_NO_CACHE_DIR=1 \
    HF_HOME=/opt/hf-cache

WORKDIR /app

# CPU-only torch keeps the image small
RUN pip install torch --index-url https://download.pytorch.org/whl/cpu

COPY requirements-deploy.txt .
RUN pip install -r requirements-deploy.txt

# Bake the embedding model into the image so startup needs no internet
RUN python -c "from sentence_transformers import SentenceTransformer; SentenceTransformer('all-MiniLM-L6-v2')"
ENV HF_HUB_OFFLINE=1 TRANSFORMERS_OFFLINE=1

COPY . .

# Render injects $PORT; default 8000 elsewhere
CMD ["sh", "-c", "uvicorn app.main:app --host 0.0.0.0 --port ${PORT:-8000}"]
