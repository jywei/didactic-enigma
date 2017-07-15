namespace :redis do
  task :redirect do
    `ssh -f -N -L6377:afu-dev.yarbxk.0001.apne1.cache.amazonaws.com:6379 ubuntu@52.192.16.215`
  end
end
