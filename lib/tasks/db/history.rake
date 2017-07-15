namespace :db do
  task history: :environment do
    # Setup
    time        = Time.now
    backup_time = time - 1.week
    time_s      = time.strftime("%Y%m%d%H%M%S")
    # production
    username    = ActiveRecord::Base.connection_config[:username]
    password    = ActiveRecord::Base.connection_config[:password]
    database    = ActiveRecord::Base.connection_config[:database]
    host        = ActiveRecord::Base.connection_config[:host]

    # host        = Rails.env.production? ? 'bkd2.cithujepeaxe.ap-northeast-1.rds.amazonaws.com' : 'localhost'
    # host        = "afu.cd75gda2paem.ap-northeast-1.rds.amazonaws.com"

    # local
    # username    = 'root'
    # password    = 'fancyboy888'
    # database    = 'afu3_development'
    # host        = "afu-dev.cd75gda2paem.ap-northeast-1.rds.amazonaws.com"
    filename    = "#{Rails.root}/afu_history_#{time_s}.sql"

    # gz          = "#{filename}.gz"
    options     = "--skip-add-drop-table --skip-add-locks --no-create-info"
    tables      = %w(matches offers offer_parlays offer_asians offer_positions offer_settings)
    classes     = [Match, Offer, Offer::Parlay, Offer::Asian, Offer::Position, Offer::Setting]
    query       = "created_at < '#{backup_time.utc.strftime("%Y-%m-%d %H:%M:%S")}'"
    success     = []

    # Backup
    tables.each do |table|
      concat  = File.file?(filename) ? ">>" : ">"
      success << system("mysqldump -u #{username} -p#{password} -h #{host} #{database} #{table} #{concat} #{filename} --where=\"#{query}\" #{options}")
    end
    unless File.file?(filename) && success.all? {|s| s == true }
      # notifier.ping("mysqldump歷史資料匯出失敗：#{time_s}")
      abort
    end

    # Compress
    # puts "Compressing"
    # success << system("gzip -9 #{filename}")
    # unless File.file?(gz) && success.all? {|s| s == true }
    #   notifier.ping("gzip壓縮失敗：#{time_s}")
    #   abort
    # end

    # Upload
    # puts "Uploading"
    # success << system("aws s3 cp #{gz} s3://bkd-backup/allreal/history/")
    # files = `aws s3 ls s3://bkd-backup/allreal/history/ | grep #{time_s}`
    # if files.blank?
    #   notifier.ping("歷史資料上傳至S3失敗：#{time_s}")
    #   abort
    # end

    # Delete
    classes.each do |klass|
      puts "Cleaning up class: #{klass}"
      klass.where("created_at < ?", backup_time).delete_all
    end
    puts "Cleaning up tmp files"

    # FileUtils.rm(gz)
    # notifier.ping("歷史資料匯出完成： `s3://bkd-backup/allreal/history/allreal_#{time_s}.sql.gz`")
  end
end
