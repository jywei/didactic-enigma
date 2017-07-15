class UserReport
  class << self
    Lang = {
      en: 0,
      ch: 1
    }

    def member_amount_sum(heir, user_ids, arr)
      if heir.player?
        arr.select{ |result| result.user_id == heir.id }
      else
        arr.select{ |result| user_ids.include?(result.user_id) }
      end.map(&:member).sum.to_f
    end

    def downline_names
      [
        ['admin',             '管理者'],
        ['moderator',         '版主'],
        ['supervisor',        '大總監'],
        ['director',          '總監'],
        ['major_shareholder', '大股東'],
        ['shareholder',       '股東'],
        ['general_agent',     '總代理'],
        ['agent',             '代理'],
        ['member',            '會員']
      ]
    end

    def downline_lang_chart
      Hash[downline_names]
    end

    def tier_name(tier, language)
      downline_names[tier..-1].map { |m| m[Lang[language]] }
    end

    def names(language = :en)
      downline_names.map { |names| names[Lang[language]] }
    end

    def downlines(heir, vigorish_shares, total_profits, unsplit_stake, downline_user_ids)
      tier_names = UserReport.tier_name(heir.tier, :en)
      tier_names.each_with_index.map do |name, index|
        if name == 'member'
        {
          name: '會員',
          vigorish: member_amount_sum(heir, downline_user_ids, vigorish_shares),
          result: member_amount_sum(heir, downline_user_ids, total_profits)
        }
        else
        {
          name: UserReport.downline_names[(heir.tier+index)][Lang[:ch]],
          vigorish: vigorish_shares.map(&:"#{tier_names[index]}").sum.to_f,
          unsplit_stake: unsplit_stake,
          result: total_profits.map(&:"#{tier_names[index]}").sum.to_f
        }
        end
      end #each_with_index
    end #downlines
  end #class

  def initialize(params)
    @params       = params
    @user         = User.find(params[:id])
    @heirs        = User.where(bank_id: params[:id])
    @filter       = filter_params(params)
    @allotters    = User::Allotter.where(user_id: @heirs.pluck(:id)).to_a
    @downline_ids = @user.downline_user_ids
    @all_ancestor = @user.downline_users.member
    @orders       = Order.includes(:items).where(user_id: @downline_ids)
    @all_vigorish = VigorishShare.where(user_id: @downline_ids)
    @all_profit   = TotalProfit.where(user_id: @downline_ids)
  end

  def serialize
    return params_filter unless params_valid?
    {
      name: @user.downline_names(:ch),
      total: report,
      sports: sport_data
    }
  end

  def params_filter
    {
      code: 2,
      message: @messages
    }
  end

  def params_valid?
    @messages = []
    @messages << "找不到對應ID #{params[:id]} 的user" if @user.nil?
    @messages << "未帶入sport_id參數" if @sport_ids.blank?
    @messages << "未帶入type_id參數" if @type_ids.blank?
    @messages << "未帶入start_time或end_time參數" if @time.blank?
    @message.blank?
  end

  def vigorish_shares(order_ids)
    @all_vigorish.select{ |vigorish| vigorish.order_id.in? order_ids }
  end

  def total_profits(order_ids)
    @all_profit.select{ |profit| profit.order_id.in? order_ids }
  end

  def sport_data
    return [] unless @params[:sport_id].present?
    sportname = Sport.to_dict
    sport_ids = @sport_ids
    sport_ids.map { |sport|
      @sport_ids = sport
      sport_element(sportname[sport], report)
    }.compact
  end

  def report
    @heirs.map do |heir|
      downline_ids = select_ancestor(heir).pluck(:user_id).uniq
      element(heir, orders_by(downline_ids), downline_ids)
    end
  end

  def orders_by(downline_ids)
    @orders.select do |order|
      order.report_filter(@sport_ids, @type_ids, @time) &&
      (order.user_id.in? downline_ids)
    end
  end

  def element(heir, orders, downline_ids)
    split_orders   = orders.try(:select) { |order| order.vigorish_split == true }
    unsplit_orders = orders.try(:select) { |order| order.vigorish_split == nil }
    order_ids      = split_orders.pluck(:id)
    vigorish       = vigorish_shares(order_ids)
    unsplit_stake  = split_orders.try(:pluck, :stake).try(:sum).to_f + vigorish.try(:pluck, :total_vigorish).try(:sum).to_f
    {
      id:                 heir.id,
      name:               heir.username,
      allotters:          allotters_report(heir.id),
      orders_count:       split_orders.count,
      amount:             split_orders.map(&:amount).sum,
      valid_amount:       split_orders.map(&:valid_amount).sum.to_f,
      unposted_amount:    unsplit_orders.map(&:amount).sum,
      downline:           UserReport.downlines(heir, vigorish_shares(order_ids), total_profits(order_ids), unsplit_stake, downline_ids)
    }
  end

  def sport_element(sport_name, element)
    {
      name: sport_name,
      element: element
    }
  end

  def select_ancestor(user)
    @all_ancestor.select{ |ancestor| ancestor["#{user.title}"] == user.id }
  end

  def filter_params(params)
    @sport_ids = params[:sport_id].present? ? params[:sport_id].split(",") : nil
    @type_ids  = params[:type_id].present? ? params[:type_id].split(",") : nil
    @time      = params[:start_date].present? ? Time.parse(params[:start_date])..Time.parse(params[:end_date]) : nil
  end

  def allotters_report(id)
    @allotters.select{ |allotter| allotter.user_id == id }.reduce({}){ |report, allotter|
      report[allotter.name_ch] = allotter.oppo.to_f
      report
    }
  end

end
