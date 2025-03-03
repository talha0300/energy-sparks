# Puma can serve each request in a thread from an internal thread pool.
# The `threads` method setting takes two numbers: a minimum and maximum.
# Any libraries that use thread pools should be configured to match
# the maximum value specified for Puma. Default is set to 5 threads for minimum
# and maximum; this matches the default thread size of Active Record.
max_threads_count = ENV.fetch("RAILS_MAX_THREADS") { 5 }
min_threads_count = ENV.fetch("RAILS_MIN_THREADS") { max_threads_count }
threads min_threads_count, max_threads_count

# Specifies the `port` that Puma will listen on to receive requests; default is 3000.
#
#Note: ElasticBeanstalk uses 5000 by default
#https://docs.aws.amazon.com/elasticbeanstalk/latest/dg/platforms-linux-extend.html
#port        ENV.fetch("PORT") { 3000 }

# Specifies the `environment` that Puma will run in.
#
#environment ENV.fetch("RAILS_ENV") { "development" }

# Specifies the number of `workers` to boot in clustered mode.
# Workers are forked webserver processes. If using threads and workers together
# the concurrency of the application would be max `threads` * `workers`.
# Workers do not work on JRuby or Windows (both of which do not support
# processes).
#
# workers ENV.fetch("WEB_CONCURRENCY") { 2 }
#Following is used in/opt/elasticbeanstalk/config/private/pumaconf.rb
#workers %x(grep -c processor /proc/cpuinfo)
workers 2

# Use the `preload_app!` method when specifying a `workers` number.
# This directive tells Puma to first boot the application and load code
# before forking the application. This takes advantage of Copy On Write
# process behavior so workers use less memory.
preload_app!

# Allow puma to be restarted by `rails restart` command.
plugin :tmp_restart

#Taken from /opt/elasticbeanstalk/config/private/pumaconf.rb
if ENV["RAILS_ENV"] == "production"
 directory '/var/app/current'
 bind 'unix:///var/run/puma/my_app.sock'
 stdout_redirect '/var/log/puma/puma.log', '/var/log/puma/puma.log', true
end

if ENV["RAILS_ENV"] != 'production'
  before_fork do
    GoodJob.shutdown
  end

  on_worker_boot do
    GoodJob.restart
  end

  on_worker_shutdown do
    GoodJob.shutdown
  end
end