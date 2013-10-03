require 'bundler/capistrano'

set :application, "asfx"
set :user, "ibr"
set :group, "ibr"
set :repository,  "https://github.com/resure/asfx.git"
set :deploy_to, "/home/#{user}/#{application}"
set :scm, :git
set :branch, "master"
set :use_sudo, false
set :rails_env, "production"
set :deploy_via, :copy
set :copy_dir, "/home/#{user}/tmp"
set :remote_copy_dir, "/tmp"
#set :ssh_options, { :forward_agent => true, :port => 4321 }
set :keep_releases, 5
set :normalize_asset_timestamps, false
default_run_options[:pty] = true
server "asfx.net", :app, :web, :db, :primary => true
set :default_environment, {
   'PATH' => "/home/ibr/.rbenv/shims:$PATH"
}

namespace :deploy do
  task :start do ; end
  task :stop do ; end

  desc "Symlink shared config files"
  task :symlink_config_files do
    run "ln -nfs #{shared_path}/config/database.yml #{release_path}/config/database.yml"
  end

  # NOTE: I don't use this anymore, but this is how I used to do it.
  desc "Precompile assets after deploy"
  task :precompile_assets do
    run <<-CMD
      cd #{ current_path } &&
      #{ try_sudo } bundle exec rake assets:precompile RAILS_ENV=#{ rails_env }
    CMD
  end

  desc "Restart applicaiton"
  task :restart do
    run "#{ try_sudo } touch #{ File.join(current_path, 'tmp', 'restart.txt') }"
  end
end

after "deploy", "deploy:symlink_config_files"
after "deploy", "deploy:restart"
after "deploy", "deploy:precompile_assets"
after "deploy", "deploy:cleanup"

