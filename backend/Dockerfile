FROM python:3.11-slim

WORKDIR /app

# Install system dependencies
RUN apt-get update && apt-get install -y \
    postgresql-client \
    && rm -rf /var/lib/apt/lists/*

# Copy requirements
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt

# Copy application
COPY . .

# Railway will set PORT environment variable
ENV PORT=8000

# Run migrations and start app
CMD alembic upgrade head && uvicorn main:app --host 0.0.0.0 --port ${PORT}