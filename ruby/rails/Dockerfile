# syntax = docker/dockerfile:1

# Make sure RUBY_VERSION matches the Ruby version in .ruby-version and Gemfile
ARG RUBY_VERSION=3.2.8
FROM ruby:$RUBY_VERSION-slim as base

# Rails app lives here
WORKDIR /app

# Set production environment
ENV RAILS_ENV="production" \
    BUNDLE_DEPLOYMENT="1" \
    BUNDLE_PATH="/usr/local/bundle" \
    BUNDLE_WITHOUT="development:test"

# Install base packages
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        curl \
        libpq5 \
        libvips \
        && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Create rails user
RUN useradd rails --create-home --shell /bin/bash

# Development stage
FROM base as development

# Set development environment
ENV RAILS_ENV="development" \
    BUNDLE_DEPLOYMENT="" \
    BUNDLE_WITHOUT=""

# Install packages needed for development
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libvips \
        pkg-config \
        libyaml-dev \
        nodejs \
        npm \
        watchman \
        bash \
        vim \
        && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times (if available)
RUN bundle exec bootsnap precompile --gemfile || true
RUN bundle exec bootsnap precompile app/ lib/ || true

# Change ownership to rails user
RUN chown -R rails:rails /app

# Switch to rails user
USER rails:rails

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Start development server
CMD ["bin/rails", "server", "-b", "0.0.0.0"]

# Build stage for production
FROM base as build

# Install packages needed to build gems
RUN apt-get update -qq && \
    apt-get install --no-install-recommends -y \
        build-essential \
        git \
        libpq-dev \
        libvips \
        pkg-config \
        libyaml-dev \
        nodejs \
        npm \
        && rm -rf /var/lib/apt/lists /var/cache/apt/archives

# Install application gems
COPY Gemfile Gemfile.lock ./
RUN bundle install && \
    rm -rf ~/.bundle/ "${BUNDLE_PATH}"/ruby/*/cache "${BUNDLE_PATH}"/ruby/*/bundler/gems/*/.git && \
    bundle exec bootsnap precompile --gemfile

# Copy application code
COPY . .

# Precompile bootsnap code for faster boot times
RUN bundle exec bootsnap precompile app/ lib/

# Precompile assets (if using asset pipeline)
RUN SECRET_KEY_BASE_DUMMY=1 bin/rails assets:precompile

# Final production stage
FROM base as production

# Copy built artifacts: gems, application
COPY --from=build /usr/local/bundle /usr/local/bundle
COPY --from=build /app /app

# Change ownership to rails user
RUN chown -R rails:rails /app

# Switch to rails user for security
USER rails:rails

# Expose port 3000
EXPOSE 3000

# Health check
HEALTHCHECK --interval=30s --timeout=10s --start-period=5s --retries=3 \
    CMD curl -f http://localhost:3000/health || exit 1

# Entrypoint prepares the database and handles graceful shutdown
ENTRYPOINT ["/app/bin/docker-entrypoint"]

# Start Rails server
CMD ["bin/rails", "server", "-b", "0.0.0.0"]
