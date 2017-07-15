namespace :env do
  namespace :slack do
    task :notify do
      command %{ ruby "#{fetch(:deploy_to)}/shared/config/notifier.rb" }
    end
  end

  namespace :setup do
    desc "Initialize afu directory struct"
    task afu: :environment do
      invoke :'env:setup:release'
    end

    desc "Initialize worker directory struct"
    task worker: :environment do
      invoke :'env:setup:release'
    end

    task :tmp do
      command %{ mkdir -p "#{fetch(:deploy_to)}/tmp/" }
      command %{ touch "#{fetch(:deploy_to)}/tmp/restart.txt" }
    end

    task :release do
      comment %{Setting up #{fetch(:deploy_to)}}
      command %{mkdir -p "#{fetch(:deploy_to)}" }
      command %{mkdir -p "#{fetch(:releases_path)}"}
      command %{mkdir -p "#{fetch(:shared_path)}"}

      in_path "#{fetch(:shared_path)}" do
        fetch(:shared_dirs, []).each do |linked_dir|
          command %{mkdir -p "#{fetch(:shared_path)}/#{linked_dir}"}
        end

        fetch(:key_files, []).each do |linked_file|
          command %{touch "#{fetch(:shared_path)}/config/#{linked_file}" }
        end
      end

      command %{if [ -x "$(command -v tree)" ]; then tree -d -L 2 "#{fetch(:deploy_to)}"; else ls -al "#{fetch(:deploy_to)}"; fi}

      invoke :ssh_keyscan_repo
    end

    task :links do
      case fetch(:project)
      # if fetch(:project) == "afu"
      when 'afu', 'resque'
        command %{ ln -fs "#{fetch(:shared_path)}/config/afu_secrets.yml" "#{fetch(:current_path)}/config/secrets.yml" }
        command %{ ln -fs "#{fetch(:shared_path)}/config/afu_database.yml" "#{fetch(:current_path)}/config/database.yml" }
      when 'worker'
        # command %{ ln -fs "#{fetch(:shared_path)}/config/odds_setting.yml" "#{fetch(:current_path)}/odds_service/config/setting.yml" }
        # command %{ ln -fs "#{fetch(:shared_path)}/config/odds_database.yml" "#{fetch(:current_path)}/odds_service/config/database.yml" }
      end
    end
  end
end

