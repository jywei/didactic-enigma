require 'csv'

module Info
  module AllotterCategory
    class << self
      def default_allotter(user_id)
        if User.find(user_id).operator?
          [
            %w(soccer 足球), %w(basketball 籃球), %w(else 其他), %w(us_baseball 美棒), %w(jp_baseball 日棒),
            %w(tw_baseball 中華職棒), %w(else_baseball 其他棒球), ['us football', '美式足球'], %w(icehockey 冰球), %w(lottery 彩球),
            %w(index 指數), %w(tennis 網球), %w(cricket 板球), %w(volleyball 排球), %w(handball 手球),
            %w(pool 撞球), %w(racing 賽馬/賽狗), ['rugby union', '橄欖球'], %w(test 測試)
          ].each do |category|
            User::Allotter.create(
              {
                name:    category[0],
                name_ch: category[1],
                user_id: user_id,
                oppo:    1.00
              }
            )
          end
        else
          upline_user_id = User.find(user_id).bank_id
          upline_user_allotters_records = User::Allotter.where(user_id: upline_user_id)
          idd = upline_user_allotters_records.last.id
          query = "INSERT INTO user_allotters(`user_id`, `oppo`, `name`, `name_ch`, `created_at`, `updated_at`) VALUES "
          upline_user_allotters_records.each do |record|
            value = "(#{user_id}, \'#{record.oppo}\', \'#{record.name}\', \'#{record.name_ch}\', \'#{Time.now.strftime("%FT%T")}\', \'#{Time.now.strftime("%FT%T")}\')"
            value += ", " if record.id != idd
            query += value
          end
          ActiveRecord::Base.connection.execute(query)
        end
      end

      def default_setting(user_id)
        if User.find(user_id).operator?
          CSV.foreach('lib/csv/rebate_setting.csv').each do |row|
            User::Setting.create(
              {
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
            )
          end
        else
          upline_user_id = User.find(user_id).bank_id
          upline_user_setting_records = User::Setting.where(user_id: upline_user_id)
          idd = upline_user_setting_records.last.id
          query = "INSERT INTO user_settings(`user_id`, `sport_id`, `rebate`, `offer_quota`, `match_quota`, `created_at`, `updated_at`, `name`, `otname`, `ot_id`, `name_ch`, `offer_name`, `halves`, `category_id`) VALUES "
          upline_user_setting_records.each do |record|
            offer_name = record.offer_name.nil? ? "NULL, " : "\'#{record.offer_name}\', "
            halves = record.halves.nil? ? "NULL, " : "\'#{record.halves}\', "
            value = "(#{user_id}, #{record.sport_id || 'NULL'}, #{record.rebate}, #{record.offer_quota}, #{record.match_quota}, \'#{Time.now.strftime("%FT%T")}\', \'#{Time.now.strftime("%FT%T")}\', \'#{record.name}\', \'#{record.otname}\', #{record.ot_id}, \'#{record.name_ch}\', " + offer_name + halves + "#{record.category_id || 'NULL'})"
            value += ", " if record.id != idd
            query += value
          end
          ActiveRecord::Base.connection.execute(query)
        end
      end
    end # << self
  end
end
