namespace :backend do
  task rdoc: :environment do
    comment %{ Removing outdated documentation. }
    run :remote do
      command %{ rm -rf #{fetch(:current_path)}/public/rdoc }
    end
    comment %{ Copying documentation. It may take a while. }
    run :local do
      command %{ scp -rp ./public/rdoc ubuntu@#{fetch(:domain)}:/#{fetch(:current_path)}/public/rdoc }
    end
  end

  task :bundle do
    case fetch(:project)
    when 'afu', 'resque', 'resque_2'
      command %{ #{fetch(:backend_dir)} bundle install }
    when 'worker'
      command %{ #{fetch(:odds_service_dir)} bundle install }
    end
  end

  namespace :db do
    task :migrate do
      case fetch(:project)
      when 'afu'
        command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake db:migrate }
      when 'worker'
        command %{ #{fetch(:odds_service_dir)} ENV=development bundle exec rake db:migrate }
      end
    end
  end

  namespace :assets do
    task :precompile do
      command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake assets:clobber }
      command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake assets:precompile }
    end
  end

  namespace :server do
    task :restart do
      command %{ sudo service nginx restart }
      command %{
        sudo service unicorn_afu stop
        sleep 2
        sudo service unicorn_afu start
      }
    end
  end

  namespace :cable do
    task :restart do
      run :remote do
        comment %{ Restarting standalone ActionCable Server }
        command %{
          sudo service unicorn_cable stop
          sleep 2
          sudo service unicorn_cable start
        }
      end
    end
  end

  namespace :worker do
    task :kill do
      run :remote do
        comment %{ Killing Worker Processes }
        command %{ ps ax | grep daemons | grep -v grep | awk '{print "kill -9 " $1}' | sh }
      end
    end

    namespace :broadcast do
      task :start do
        run :remote do
          comment %{ Restarting Worker Process 'broadcast_1' }
          command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:broadcast }
          # comment %{ Restarting Worker Process 'broadcast_2' }
          # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:broadcast }
        end
      end
    end

    task :start do
      run :remote do
        # comment %{ Restarting Worker Process 'log' }
        # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:log }
        # comment %{ Restarting Worker Process 'offer' 1 }
        # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:offer }
        # comment %{ Restarting Worker Process 'offer' 2 }
        # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:offer }
        # comment %{ Restarting Worker Process 'offer' 3 }
        # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:offer }
        comment %{ Restarting Worker Process 'match' }
        command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:match }
        # comment %{ Restarting Worker Process 'variant_offers' }
        # command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:variant_offer }
        comment %{ Restarting Worker Process 'cache' }
        command %{ #{fetch(:backend_dir)} RAILS_ENV=production bundle exec rake worker:runner:cache }
      end
    end
  end

end
