require 'csv'



namespace :user do
  require "#{Rails.root}/app/services/ancestor_update"

  task rename_setting: :environment do
    # => 更換原本用csv產出的user setting
    User::Setting.where(name_ch: "籃球半場").update_all(name: "ht_basketball")
    User::Setting.where(name_ch: "美棒").update_all(name: "us_baseball")
    User::Setting.where(name_ch: "美棒半場").update_all(name: "ht_us_baseball")
    User::Setting.where(name_ch: "日職").update_all(name: "jp_baseball")
    User::Setting.where(name_ch: "日職半場").update_all(name: "ht_jp_baseball")
    User::Setting.where(name_ch: "中華職棒").update_all(name: "tw_baseball")
    User::Setting.where(name_ch: "中職半場").update_all(name: "ht_tw_baseball")
    User::Setting.where(name_ch: "其他棒球").update_all(name: "else_baseball")
    User::Setting.where(name_ch: "美式足球").update_all(name: "us football")
    User::Setting.where(name_ch: "排球").update_all(name: "volleyball")
  end

  task rugby_and_icehockey: :environment do

    user_idz = User::Setting.distinct.pluck(:user_id)
    user_idz.each do |user_id|
      CSV.foreach('lib/csv/rebate_setting_icehockey_rugby.csv').map do |row|
        setting = {
                    user_id:     user_id,
                    name:        row[1],
                    name_ch:     row[0],
                    rebate:      row[4].to_i,
                    offer_quota: row[6].to_i,
                    match_quota: row[5].to_i,
                    otname:      row[3],
                    ot_id:       row[2].to_i,
                    sport_id:    row[7].to_i,
                    offer_name:  row[8],
                    halves:      row[9],
                    category_id: row[10].to_i
                  }
        User::Setting.create(setting)
      end
    end
  end

  task update_soccer_patch: :environment do
    user_idz = User::Setting.distinct.pluck(:user_id)
    user_idz.each do |user_id|
      CSV.foreach('lib/csv/soccer_patch.csv').map do |row|
        setting = {
                    user_id:     user_id,
                    name:        row[1],
                    name_ch:     row[0],
                    rebate:      row[4].to_i,
                    offer_quota: row[6].to_i,
                    match_quota: row[5].to_i,
                    otname:      row[3],
                    ot_id:       row[2].to_i,
                    sport_id:    row[7].to_i,
                    offer_name:  row[8],
                    halves:      row[9],
                    category_id: row[10].to_i
                  }
        User::Setting.create(setting)
      end
    end
  end

  task tier_eight_user_default_setting: :environment do
    user_idz = User.where(tier: 8).pluck(:id)
    settingz = User::Setting.order('user_id').pluck(:user_id).uniq
    user_setting = user_idz.select{|set|
      !settingz.include?(set)
    }
    user_setting.each do |user_id|
      User::Setting.create_default(user_id)
    end
  end

  task setting_update: :environment do # don't use it easily, it's very slow
    user_settings = User::Setting.all
    user_settings.each do |user_setting|
      user_setting.update_relations
    end
  end

  task modify_parlay: :environment do
    User::Setting.where(ot_id: 11).update_all(rebate: 500)
  end

  task delete_duplicate_setting: :environment do
    User::Setting.where.not(id: User::Setting.group(:user_id, :name, :ot_id).pluck('min(user_settings.id)')).delete_all
  end

  task add_member_to_user_ancestor: :environment do
    users = User::Ancestor.where(member: nil)
    users.each do |user|
      user_id = user.user_id
      user.update_attributes(member: user_id)
    end
  end

  include AncestorUpdate
  desc "fix user ancestor setting rule"
  task all_user_ancestor_setting: :environment do
    ancestors = User::Ancestor.pluck(:user_id)
    users = User.where(tier: (0..7).to_a).where.not(id: ancestors)
    users.each do |user|
      update_ancestors(user)
      puts "#{user.username} ancestor already create"
    end
  end

end
