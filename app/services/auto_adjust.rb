class AutoAdjust # value downward only
  # params: target_id, sport_name, ot_id, target_column, adj_amount
  def initialize(params)
    @sport_name         = params[:sport_name]
    @ot_id              = params[:ot_id].to_i
    @target_column      = params[:target_column].to_sym
    @target             = User.find(params[:target_id].to_i)
    @adj_amount         = params[:adj_amount].to_f
    table_type          = params[:table_type].to_sym
    @if_table_allotter  = if table_type == :allotters
                            true
                          elsif table_type == :settings
                            false
                          end
  end

  # :allotter, :setting
  def adjust
    if @if_table_allotter
      User::Allotter.where(id: affected_record).update_all(@target_column => @adj_amount)
    else
      User::Setting.where(id: affected_record).update_all(@target_column => @adj_amount)
    end
  end

  # :allotter, :setting
  def affected_record
    if @if_table_allotter
      filter_column(User::Allotter.where(name: @sport_name, user_id: @target.all_downlines).pluck(:id, @target_column))
    else
      filter_column(User::Setting.where(name: @sport_name, ot_id: @ot_id, user_id: @target.all_downlines).pluck(:id, @target_column))
    end
  end

  def filter_column(arr)
    arr.map { |id, value| id if value.to_f > @adj_amount }
  end

end
