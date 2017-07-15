namespace :worker do
  desc "stop worker"
  task stop: :environment do
    command %{ cd "#{fetch(:shared_path)}/pids" && kill -9 $(cat odd_production.pid) && rm -rf odd_production.pid }
    command %{ cd "#{fetch(:shared_path)}/pids" && kill -9 $(cat odd_stage.pid) && rm -rf odd_stage.pid }
  end

  task :start do
    comment %{ Ready to Start odd service }
    command %{
      #{fetch(:odds_serivce_dir)} ruby daemon.rb start -- -e production
      sleep 1
      mv "#{fetch(:current_path)}/odds_service/start.rb.pid" "#{fetch(:shared_path)}/pids/odd_production.pid"

      sleep 1

      #{fetch(:odds_serivce_dir)} ruby daemon.rb start -- -e stage
      sleep 1
      mv "#{fetch(:current_path)}/odds_service/start.rb.pid" "#{fetch(:shared_path)}/pids/odd_stage.pid"
    }
  end
end
