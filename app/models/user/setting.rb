class User::Setting < ApplicationRecord
  belongs_to :user

  class << self
    def create_default(user_id)
      Info::AllotterCategory.default_setting(user_id)  #.each { |user_ot_default| create(user_ot_default) }
    end

    def rebates
      order(user_id: :desc).pluck(:rebate).map(&:to_f)
    end

    def update_settings(params)
      target_id     = params[:target_id].to_i
      name          = params[:sport_name]
      ot_id         = params[:ot_id].to_i
      target_column = params[:target_column]
      adj_amount    = params[:adj_amount].to_f
      user_id       = params[:user_id].to_i
      if find_by(user_id: user_id, name: name, ot_id: ot_id)[target_column].to_f < adj_amount
        false
      else
        transaction do
          find_by(user_id: target_id, ot_id: ot_id, name: name).update_attributes(target_column => adj_amount)
          AutoAdjust.new(params).adjust
        end
        true
      end
    rescue
      false
    end

    # target_id int, rebate_type bool(true: return_all, false: return_none)
    def update_rebate(self_id, target_id, rebate_type)
      if rebate_type
        sql_arr = ["update user_settings t inner join user_settings o on (t.name = o.name and t.ot_id = o.ot_id ) set t.offer_quota = o.offer_quota, t.rebate = o.rebate, t.match_quota = o.match_quota where t.user_id = ? and o.user_id = ?", connection.quote(target_id), connection.quote(self_id)]
        update_sql = send(:sanitize_sql, sql_arr)
        connection.execute(update_sql)
      else
        target = User.find(target_id)
        where(user_id: target.all_downlines.push(target_id)).update_all(rebate: 0)
      end
    end
  end # self

  def update_relations
    self.offer_name  = case ot_id
                       when 1
                         "point"
                       when 2
                         "ou"
                       when 3
                         "ml"
                       when 4
                         "odd_even"
                       when 15
                         "one_win"
                       when 16
                         "three_way"
                       end
    self.halves      = "ht" if self.name.include?('ht')
    self.category_id = case name_ch
                       when '美棒'
                         723
                       when '美棒半場'
                         723
                       when '日職'
                         799
                       when '日職半場'
                         799
                       when '中華職棒'
                         1283
                       when '中職半場'
                         1283
                       when '美式足球'
                         724
                       end
    self.sport_id    = case name
                       when "soccer"
                         75
                       when "basketball"
                         77
                       when "ht_basketball"
                         77
                       when "us_baseball"
                         81
                       when "ht_us_baseball"
                         81
                       when "jp_baseball"
                         81
                       when "ht_jp_baseball"
                         81
                       when "tw_baseball"
                         81
                       when "ht_tw_baseball"
                         81
                       when "else_baseball"
                         81
                       when "us football"
                         80
                       when "tennis"
                         79
                       when "cricket"
                         88
                       when "volleyball"
                         87
                       when "handball"
                         82
                       when "pool"
                         143
                       when "icehockey"
                         76
                       when "rugby union"
                         78
                       when "ht_soccer"
                         75
                       end
    save!
  end
end
