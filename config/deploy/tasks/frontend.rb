namespace :frontend do
  task :install do
    command %{ source /home/ubuntu/.nvm/nvm.sh }
    command %{ echo "Using nodeJS `node -v`" }
    command %{ #{fetch(:frontend_dir)} npm install gulp }
    command %{ #{fetch(:frontend_dir)} npm install }
  end

  task :build do
    command %{ #{fetch(:frontend_dir)} gulp build_production }
  end

  namespace :node do
    task :backup do
      command %{ cp -a #{fetch(:current_path)}/frontend/node_modules #{fetch(:shared_path)} }
    end

    task :restore do
      command %{ cp -a #{fetch(:shared_path)}/node_modules #{fetch(:current_path)}/frontend }
    end
  end
end

