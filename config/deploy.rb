load 'lib/deploy_app.rb'
$:.unshift(File.expand_path('./lib', ENV['rvm_path']))
require "rvm/capistrano"

set :rvm_ruby_string, 'ruby-1.9.2-p290@raor'
set :rvm_type, :user
set :application, "raor"
set :repository,  "git://cloud.healthetechs.com/raor.git"
set :rails_env, 'production'
set :scm, :git  # override default of subversion
set :branch, 'master'
set :use_sudo, false
set :user, 'apache'
set :git_enable_submodules, true
set :ssh_options, {:forward_agent => true}
set :default_run_options, {:shell => "sh -l"}
set :rake, "bundle exec rake"
set :deploy_via, :remote_cache
set :root_path, "/var/www"


# If you aren't deploying to /u/apps/#{application} on the target
# servers (which is the default), you can specify the actual location
# via the :deploy_to variable:
set :deploy_to, "#{root_path}/#{application}"

# Unicorn configuration
set :unicorn_binary, "unicorn_rails"
set :unicorn_config, "#{current_path}/config/unicorn.rb"
set :unicorn_pid, "#{current_path}/tmp/pids/unicorn.pid"

set :production_hosts do
  `dig -tAXFR healthetechs.com | grep production | grep A | awk '{ print $1 }'`.split("\n").map do |record|
    record.strip[0..-2]
  end
end

set :database_hosts do
  `dig -tAXFR healthetechs.com | grep database | grep A | awk '{ print $1 }'`.split("\n").map do |record|
    record.strip[0..-2]
  end
end

#set :staging_hosts do
#  `dig -tAXFR healthetechs.com | grep staging | grep A | awk '{ print $1 }'`.split("\n").map do |record|
#    record.strip[0..-2]
#  end
#end

task :production do
  role :app, *production_hosts 
  role :db, "#{production_hosts[0]}", :primary => true
end

task :staging do
  role :app, *staging_hosts
  role :db, *staging_hosts, :primary => true
end
 
# Setup dependencies
after 'deploy', 'app:symlinks'
after 'app:symlinks', 'app:bundle_rsync'
after 'app:bundle_rsync', 'app:bundle_install'
after "deploy", "deploy:cleanup"

namespace :deploy do
  # Overriding the built-in task to add our rollback actions
  task :default, :roles => [:app, :web, :jobs] do
    unless rails_env == "test"
      transaction {
        update
        restart
      }
    end
  end

  desc "unicorn start"
  task :start, :roles => [:app, :web] do
    run "cd #{current_path}; bundle exec #{unicorn_binary} --daemonize --env production -c #{unicorn_config}"
  end

  desc "unicorn restart"
  task :restart, :roles => [:app, :web] do 
    begin
      run "kill -s USR2 `cat #{unicorn_pid}`"
    rescue Capistrano::CommandError => e
      puts "Rescue: #{e.class} #{e.message}"
      puts "Rescue: It appears that unicorn is not running, starting ..."
      run "sh #{current_path}/config/kill_server_processes unicorn"
      run "cd #{current_path}; bundle exec #{unicorn_binary} --daemonize --env production -c #{unicorn_config}"
    end
  end
end

before 'deploy:migrate', 'app:update_databases'
before 'deploy:migrate', 'app:symlinks'
before 'deploy:migrate', 'app:bundle_rsync'
after 'deploy:migrate', :seed
after 'deploy:migrations', :seed
desc "seed. for seed-fu"
task :seed, :roles => :db, :only => {:primary => true} do 
  run "cd #{current_path}; #{rake} db:seed RAILS_ENV=#{rails_env}"
end

# useful for testing on_rollback actions
task :raise_exc do
  raise "STOP STOP STOP"
end
