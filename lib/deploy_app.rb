namespace :app do
  desc "we need a database. this helps with that."
  task :symlinks, :roles => [:app, :web, :jobs] do 
    run "ln -fs #{shared_path}/database.yml #{release_path}/config/database.yml"
    run "ln -fs #{shared_path}/omniauth.yml #{release_path}/config/omniauth.yml"
    run "ln -fs #{shared_path}/vendor/cache #{release_path}/vendor/cache"

    run "mkdir #{release_path}/tmp/cache"
  end

  desc "run bundle package and rsync to production"
  task :bundle_rsync, :roles => [:app, :web, :jobs] do
    `bundle package`
    `scp ./vendor/cache/*.gem oneadmin@cloud.healthetechs.com:/var/lib/one/gems/raor/`
    run "cd #{shared_path}/vendor/cache; rsync -auH rsync://cloud.healthetechs.com/gems/raor/* .;"
  end

  desc "run bundle install for gem dependencies"
  task :bundle_install, :roles => [:app, :web, :jobs] do
    if rails_env == "test"
      run "cd #{current_path}; bundle install --deployment --without tools development"
    else
      run "cd #{current_path}; bundle install --deployment --without test development cucumber tools"
    end
  end

  desc "update database.yml with current database host"
  task :update_databases, :roles => [:app, :web, :jobs] do
   run "cd #{shared_path}; sed -i '/host:/ c\\  host: #{database_hosts[0]}' database.yml;" 
  end
end
