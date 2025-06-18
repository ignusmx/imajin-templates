# Multi-stage Dockerfile for Sinatra API
FROM ruby:3.2-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    redis \
    tzdata \
    curl \
    git \
    bash

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Development stage
FROM base AS development

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install all gems (including development and test)
RUN bundle config set --local deployment 'false' && \
    bundle config set --local without '' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Create non-root user for development
RUN addgroup -g 1001 -S sinatra && \
    adduser -S sinatra -u 1001 -G sinatra

# Change ownership of app directory
RUN chown -R sinatra:sinatra /app

# Switch to non-root user
USER sinatra

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start the application with auto-reload for development
CMD ["bundle", "exec", "rerun", "--", "rackup", "--host", "0.0.0.0", "--port", "3000"]

# Build stage
FROM base AS build

# Copy Gemfile and Gemfile.lock
COPY Gemfile Gemfile.lock ./

# Install only production gems
RUN bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install --jobs 4 --retry 3

# Copy application code
COPY . .

# Clean up unnecessary files
RUN rm -rf \
    spec/ \
    tmp/ \
    log/* \
    .git/ \
    .github/ \
    docs/ \
    scripts/ \
    README.md \
    .env.example

# Production stage
FROM ruby:3.2-alpine AS production

# Install runtime dependencies
RUN apk add --no-cache \
    postgresql-client \
    redis \
    tzdata \
    curl \
    bash

# Set working directory
WORKDIR /app

# Copy bundler configuration and gems from build stage
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app .

# Create non-root user
RUN addgroup -g 1001 -S sinatra && \
    adduser -S sinatra -u 1001 -G sinatra

# Create necessary directories
RUN mkdir -p tmp log && \
    chown -R sinatra:sinatra /app

# Switch to non-root user
USER sinatra

# Expose port
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start the application
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"] 