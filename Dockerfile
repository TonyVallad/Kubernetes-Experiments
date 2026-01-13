FROM python:3.12-slim

WORKDIR /app

# Install uv
COPY --from=ghcr.io/astral-sh/uv:latest /uv /usr/local/bin/uv

# Copy dependency files
COPY pyproject.toml ./

# Generate lockfile and install dependencies using uv
RUN uv lock && uv sync --frozen

# Copy application code
COPY main.py ./

# Expose port 80
EXPOSE 80

# Run the application using uv
CMD ["uv", "run", "python", "main.py"]
