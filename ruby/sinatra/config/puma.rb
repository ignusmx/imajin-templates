# Puma configuration file for Sinatra API

# The directory to operate out of
directory '/app'

# Set the environment in which the rack's app will run
environment ENV.fetch('RACK_ENV', 'development')

# Daemonize the server into the background
# daemonize

# Store the pid of the server in the file at "path"
# pidfile '/app/tmp/pids/puma.pid'

# Use "path" as the file to store the server info state
# state_path '/app/tmp/pids/puma.state'

# Redirect STDOUT and STDERR to files
# stdout_redirect '/app/log/puma.stdout.log', '/app/log/puma.stderr.log'

# Disable request logging
# quiet

# Configure "min" to be the minimum number of threads to use to answer
# requests and "max" the maximum
min_threads_count = ENV.fetch('PUMA_MIN_THREADS', 5).to_i
max_threads_count = ENV.fetch('PUMA_MAX_THREADS', 5).to_i
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests
port ENV.fetch('PORT', 3000)

# Specifies the `environment` that Puma will run in
environment ENV.fetch('RACK_ENV', 'development')

# Specifies the number of `workers` to boot in clustered mode
# Workers are forked webrick processes for handling requests
workers ENV.fetch('WEB_CONCURRENCY', 2).to_i

# Use the `preload_app!` method when specifying a `workers` number
# This directive tells Puma to first boot the application and load code
# before forking the application
preload_app!

# Allow puma to be restarted by `rails restart` command
plugin :tmp_restart

# Bind the server to "url"
bind "tcp://0.0.0.0:#{ENV.fetch('PORT', 3000)}"

# Code to run before doing a restart
before_fork do
  DB.disconnect if defined?(DB)
end

# Code to run in a worker before it forks
on_worker_boot do
  # Worker specific setup for Rails 4.1+
  # See: https://devcenter.heroku.com/articles/deploying-rails-applications-with-the-puma-web-server#on-worker-boot
  DB.test_connection if defined?(DB)
end 