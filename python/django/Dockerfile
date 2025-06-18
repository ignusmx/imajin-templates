# Development stage
FROM python:3.11-alpine AS development

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies
RUN apk add --no-cache \
    gcc \
    musl-dev \
    postgresql-dev \
    libffi-dev \
    build-base \
    curl \
    nodejs \
    npm \
    netcat-openbsd

# Install uv
RUN pip install uv

# Create non-root user and group
RUN addgroup -S djangogroup && adduser -S djangouser -G djangogroup

# Set work directory and grant ownership to non-root user
WORKDIR /app
RUN chown djangouser:djangogroup /app

# Switch to non-root user
USER djangouser

# Copy project files (now as the correct user)
COPY . .

# Install Python dependencies
# This creates a .venv in /app, now owned by djangouser
RUN uv venv && \
    uv sync --dev

# Install Node.js dependencies and Tailwind CSS
RUN npm install

# Set default environment variables for build
ENV DATABASE_URL=sqlite:///tmp/build.db \
    REDIS_URL=redis://localhost:6379/0 \
    SECRET_KEY=build-secret-key

# Create necessary directories
RUN mkdir -p logs staticfiles mediafiles

# Collect static files
RUN uv run python manage.py collectstatic --noinput --settings=config.settings.local

# Expose port (can be done as non-root user)
EXPOSE 3000

# Health check
# Note: The healthcheck command now runs as djangouser.
# We need to add curl to the image to make this work.
# It's already installed in the base image dependencies.
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health/ || exit 1

# Command to run the application
CMD ["uv", "run", "python", "manage.py", "runserver", "0.0.0.0:3000"]

# Production stage
FROM python:3.11-alpine AS production

# Set environment variables
ENV PYTHONDONTWRITEBYTECODE=1 \
    PYTHONUNBUFFERED=1 \
    PIP_DISABLE_PIP_VERSION_CHECK=1 \
    PIP_NO_CACHE_DIR=1

# Install system dependencies for production
RUN apk add --no-cache \
    postgresql-client \
    libpq \
    curl \
    nodejs \
    npm \
    netcat-openbsd

# Install uv
RUN pip install uv

# Create non-root user and group
RUN addgroup -S djangogroup && adduser -S djangouser -G djangogroup

# Set work directory and grant ownership
WORKDIR /app
RUN chown djangouser:djangogroup /app

# Switch to non-root user
USER djangouser

# Copy project files
COPY . .

# Install Python dependencies (production only)
RUN uv venv && \
    uv sync --no-dev

# Install Node.js dependencies
RUN npm ci --only=production

# Set default environment variables for build
ENV DATABASE_URL=sqlite:///tmp/build.db \
    REDIS_URL=redis://localhost:6379/0 \
    SECRET_KEY=build-secret-key

# Create necessary directories
RUN mkdir -p logs staticfiles mediafiles

# Build frontend assets
RUN npm run build

# Collect static files
RUN uv run python manage.py collectstatic --noinput --settings=config.settings.production

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=40s --retries=3 \
    CMD curl -f http://localhost:3000/health/ || exit 1

# Command to run the application
CMD ["uv", "run", "gunicorn", "config.wsgi:application", "--bind", "0.0.0.0:3000", "--workers", "4", "--timeout", "120"] 