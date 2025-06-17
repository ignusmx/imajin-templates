# Use official Ruby image
FROM ruby:3.2-alpine AS base

# Install system dependencies
RUN apk add --no-cache \
    build-base \
    postgresql-dev \
    sqlite-dev \
    tzdata \
    curl

# Set working directory
WORKDIR /app

# Install bundler
RUN gem install bundler

# Copy Gemfile first
COPY Gemfile ./

# Generate Gemfile.lock if it doesn't exist, then install gems
RUN bundle lock --add-platform ruby && \
    bundle config set --local deployment 'true' && \
    bundle config set --local without 'development test' && \
    bundle install

# Copy application code
COPY . .

# Create non-root user
RUN addgroup -g 1001 -S ruby && \
    adduser -S ruby -u 1001 -G ruby

# Change ownership of app directory
RUN chown -R ruby:ruby /app

# Switch to non-root user
USER ruby

# Expose port
EXPOSE 4567

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:4567/health || exit 1

# Start the application
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "4567"]

# Development stage
FROM base AS development

# Switch back to root for development dependencies
USER root

# Reset bundle config for development
RUN bundle config unset --local deployment && \
    bundle config unset --local without && \
    bundle install

# Switch back to ruby user
USER ruby

# Override command for development
CMD ["bundle", "exec", "rackup", "--host", "0.0.0.0", "--port", "4567"]

# Production stage
FROM base AS production

# Production is the default stage
CMD ["bundle", "exec", "puma", "-C", "config/puma.rb"] 