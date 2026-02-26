# config/deploy.rb
# Main Capistrano deployment configuration for TaskFlow

lock '~> 3.19'

# ---- Application ----
set :application, 'taskflow'
set :repo_url,    'git@github.com:Fanon-hub/requirement.git'

# ---- rbenv ----
set :rbenv_type,        :user
set :rbenv_ruby,        File.read('.ruby-version').strip rescue '3.1.6'
set :rbenv_prefix,      "RBENV_ROOT=#{fetch(:rbenv_path)} RBENV_VERSION=#{fetch(:rbenv_ruby)} #{fetch(:rbenv_path)}/bin/rbenv exec"
set :rbenv_path,        '$HOME/.rbenv'

# ---- Deploy settings ----
set :deploy_to,    '/var/www/taskflow'
set :branch,       ENV.fetch('BRANCH', 'main')
set :deploy_via,   :remote_cache
set :keep_releases, 5

# ---- Linked files (shared between releases) ----
# These files must exist in shared/ on the server before first deploy
append :linked_files,
  'config/database.yml',
  'config/master.key',
  '.env'

# ---- Linked directories (shared between releases) ----
append :linked_dirs,
  'log',
  'tmp/pids',
  'tmp/cache',
  'tmp/sockets',
  'vendor/bundle',
  'public/system',
  'public/uploads'

# ---- Bundler ----
set :bundle_path,         -> { shared_path.join('vendor/bundle') }
set :bundle_without,      %w[development test].join(' ')
set :bundle_flags,        '--deployment --quiet'

# ---- Asset pipeline ----
set :assets_prefix,       'assets'
set :normalize_asset_timestamps, %w[public/images public/javascripts public/stylesheets]

# ---- Unicorn ----
set :unicorn_config_path, -> { current_path.join('config/unicorn.rb') }
set :unicorn_pid,         -> { shared_path.join('tmp/pids/unicorn.pid') }
set :unicorn_restart_sleep_time, 3

# ---- Capistrano output ----
set :format,        :airbrussh
set :format_options, command_output: true, log_file: 'log/capistrano.log', color: :auto, truncate: :auto
set :log_level,     :info
set :pty,           true

# ---- SCM ----
set :scm,     :git
set :git_strategy, Capistrano::Git::DefaultStrategy

# ---- Hooks ----
namespace :deploy do
  after  :finishing,    'deploy:cleanup'
  after  :publishing,   'unicorn:restart'

  desc 'Restart application (zero-downtime via USR2)'
  task :restart do
    invoke 'unicorn:restart'
  end

  desc 'Start application'
  task :start do
    invoke 'unicorn:start'
  end

  desc 'Stop application'
  task :stop do
    invoke 'unicorn:stop'
  end
end