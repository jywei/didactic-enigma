namespace :git do
  task :submodules do
    run :local do
      command %{ git pull }
      command %{ echo '' > commits.txt }
      %w(frontend backend orderbot odds_service).each do |dir|
        command %{ cd #{dir} && git pull }
        command %{ echo #{dir} >> ../commits.txt }
        command %{ git log | grep 'commit' | head -n 1 >> ../commits.txt }
        command %{ cd .. }
        command %{ git add #{dir} }
      end
      command %{ git add commits.txt }
      command %{ git commit -m "update submodules" }
      command %{ git push }
    end
  end

  task :fetch_repo do
    deploy do
      invoke :'git:clone'
      on :launch do
        invoke :'env:setup:links'
        invoke :'env:setup:tmp'
      end
      on :clean do
        invoke :'deploy:cleanup'
      end
    end
  end
end
