# config/unicorn.rb
# Unicorn configuration for TaskFlow
# Used in production via Capistrano deployment

# ---- Paths ----
app_dir   = File.expand_path('../../', __FILE__)
shared_dir = "#{app_dir}/shared"

# ---- Worker processes ----
# A good rule of thumb: 2–4 workers per CPU core
# Adjust based on your server's RAM (each worker ~150–300MB)
worker_processes Integer(ENV.fetch('WEB_CONCURRENCY', 3))

# ---- Socket / binding ----
# Using a Unix socket is faster than TCP for nginx <-> unicorn communication
listen "#{shared_dir}/tmp/sockets/unicorn.sock", backlog: 64

# Alternatively, bind to a TCP port (uncomment if not using nginx socket):
# listen 8080, tcp_nopush: true

# ---- Timeouts ----
# Kill and restart a worker if a request takes longer than 30s
timeout 30

# ---- PID file ----
pid "#{shared_dir}/tmp/pids/unicorn.pid"

# ---- Logging ----
stderr_path "#{shared_dir}/log/unicorn.stderr.log"
stdout_path "#{shared_dir}/log/unicorn.stdout.log"

# ---- Preload app ----
# Loads the app before forking workers. Saves RAM via copy-on-write.
# Requires reconnecting DB after fork (see after_fork below).
preload_app true

# ---- GC tuning ----
GC.respond_to?(:copy_on_write_friendly=) && GC.copy_on_write_friendly = true

# ---- Hooks ----
before_fork do |server, worker|
  # Disconnect from DB in master before forking to avoid connection sharing
  defined?(ActiveRecord::Base) && ActiveRecord::Base.connection.disconnect!

  # Quit old master process during zero-downtime restarts (USR2 signal)
  old_pid = "#{server.config[:pid]}.oldbin"
  if old_pid != server.pid
    begin
      sig = (worker.nr + 1) >= server.worker_processes ? :QUIT : :TTOU
      Process.kill(sig, File.read(old_pid).to_i)
    rescue Errno::ENOENT, Errno::ESRCH
      # Old master already gone — no action needed
    end
  end
end

after_fork do |server, worker|
  # Re-establish DB connection in each worker after fork
  defined?(ActiveRecord::Base) && ActiveRecord::Base.establish_connection
end