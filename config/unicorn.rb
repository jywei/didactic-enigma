# set path to application
app_dir = '/var/www/afu-backend'
# shared_dir = "#{app_dir}/shared"
working_directory "#{app_dir}/current"

# Set unicorn options
worker_processes 2
preload_app true
timeout 60

# Set up socket location
listen "#{app_dir}/tmp/unicorn.sock", backlog: 64

# Logging
stderr_path "#{app_dir}/tmp/unicorn.stderr.log"
stdout_path "#{app_dir}/tmp/unicorn.stdout.log"

# Set master PID location
pid '/tmp/unicorn.pid'
