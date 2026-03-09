# Puma configuration for production deployment
# This file is optimized for containerized production environments

# The `threads` method setting takes two numbers: a minimum and maximum.
# Configure thread pool to handle concurrent requests efficiently
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests
port ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
environment ENV.fetch("RAILS_ENV") { "production" }

# Specifies the `pidfile` that Puma will use.
pidfile ENV.fetch("PIDFILE") { "tmp/pids/server.pid" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked web server processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
#
# For production, enable multiple workers to take advantage of multiple CPU cores
# Recommended: Number of CPU cores or slightly less
workers ENV.fetch("WEB_CONCURRENCY") { 2 }

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

# Configure graceful shutdown
# Puma will wait for requests to finish before shutting down
on_worker_boot do
  ActiveRecord::Base.establish_connection if defined?(ActiveRecord)
end

# Verifies that all workers have checked in to the master process within
# the given timeout. If not the worker process will be restarted.
worker_timeout 30

# Change to match your CPU count
worker_shutdown_timeout 30

# Configure the minimum number of threads to use to answer requests
# and maximum number of threads to use to answer requests.
# This is the default and should be fine for most applications.
on_restart do
  puts 'Refreshing Gemfile'
  ENV["BUNDLE_GEMFILE"] = "/app/Gemfile"
end

# Puma can bind to a tcp socket or a unix socket
# For containerized environments, TCP is typically preferred
bind "tcp://0.0.0.0:#{ENV.fetch('PORT') { 3000 }}"

# Use json format for easier parsing in log aggregation systems
log_formatter do |str|
  "[#{Process.pid}] #{str}"
end

# Log to stdout for container log aggregation
stdout_redirect nil, nil, true

# Increase backlog for better handling of traffic spikes
# (useful when running behind a load balancer)
queue_requests false

