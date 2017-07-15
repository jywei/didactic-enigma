require 'pry-byebug'
require 'mina/multistage'
require 'mina/bundler'
require 'mina/rails'
require 'mina/git'
require 'mina/rbenv'  # for rbenv support. (http://rbenv.org)

Dir[File.expand_path("../deploy/tasks", __FILE__) + "/*.rb"].each {|file| require file }

# Git 設定
set :repository, 'git@gitlab.jibako.com:bkd_tool/afu_backend.git'
set :branch, 'master'

# 正式機的路徑設定
set :releases_path, -> { "#{fetch(:deploy_to)}/releases" }
set :shared_path, -> { "#{fetch(:deploy_to)}/shared" }
set :current_path, -> { "#{fetch(:deploy_to)}/current" }
#set :frontend_dir, -> { "cd #{fetch(:current_path)}/frontend && " }
set :backend_dir, -> { "cd #{fetch(:current_path)} && " }
set :tmp_path, -> { "#{fetch(:deploy_to)}/tmp" }
#set :odds_service_dir, -> { "cd #{fetch(:current_path)}/odds_service && " }
set :shared_dirs, ["config", "log", "pids", "sockets"]

# Rails 專用檔案
set :key_files, ["database.yml", "secrets.yml"]

# 其他設定
set :user, 'ubuntu'
set :port, '22'
set :forward_agent, true
# 我們資料夾有點大，太多會爆，保留三個版本即可
set :keep_releases, 3

desc "主要佈署指令"
task deploy: %i(environment git:fetch_repo) do
#task :deploy do
  case fetch(:project)
  # 控台server
  when 'afu'
    invoke :'deploy:afu'
  # 與TX溝通的server
  when 'worker'
    invoke :'deploy:worker'
  # 處理tx工作用server
  when 'resque', 'resque_2'
    invoke :'deploy:resque'
  end
end

namespace :deploy do
  desc "Deploys afu server."
  task :afu do
    run :remote do
      # 使用slack發送訊息到#afu-server頻道準備要佈署了
      invoke :'env:slack:notify'
      # Rails設定，那些你知道的
      invoke :'backend:bundle'
      invoke :'backend:db:migrate'
      invoke :'backend:assets:precompile'
      # Mina佈署完後把暫存檔砍了
      invoke :'deploy:cleanup'
      # server重開
      invoke :'backend:server:restart'
      # 正在執行的正式機worker process全砍了
      invoke :'backend:worker:kill'
      # 正式機worker啟動
      invoke :'backend:worker:broadcast:start'
    end
  end

  desc "Deploys resque worker."
  task :resque do
    run :remote do
      invoke :'backend:bundle'
      invoke :'backend:db:migrate'
      invoke :'deploy:cleanup'
      # 目前rescue_2這台server不跑Ruby相關的worker
      if fetch(:project) == 'resque'
        invoke :'backend:worker:kill'
        invoke :'backend:worker:start'
      end
    end
  end

end

desc "讀取Ruby"
task :environment do
  invoke :'rbenv:load'
end
