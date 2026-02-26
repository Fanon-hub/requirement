
worker_processes Integer(ENV.fetch('WEB_CONCURRENCY', 3))

# Bind to the port Heroku provides
listen ENV.fetch('PORT') { 3000 }, tcp_nopush: true

timeout 30

# PID file in Heroku writable /tmp
pid "/tmp/unicorn.pid"

# Logging to stdout/stderr so Heroku picks it up
stderr_path "/dev/stderr"
stdout_path "/dev/stdout"

preload_app true

GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

before_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!
end

after_fork do |server, worker|
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end