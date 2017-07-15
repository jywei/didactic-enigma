class Api::V1::PositionsController < Api::V1::ApplicationController
  skip_before_action :verify_token
  before_action :init_response

  api :GET, "/positions", "部位表總表"
  # TODO: 補上API文件
  def index
    id = params[:sport_id] || Sport.find_by_leader_spid(888).id
    render json: Match::Open.query_positions(sport_id: id, type_id: 1)
  end

  api :GET, "/positions/warning_log", "警告紀錄"
  # TODO: 補上API文件
  def warning_log
    @response.message =
      if check_parameter('warning_log', params) == false
        '傳入資訊不可空白'
      elsif !current_user.is_admin?
        "玩家無權限"
      else
        filter_params(params)
        @response.data["warning_log"] = Log::Position::Warning.position_log_warning_filter(@match_ids, @sport_ids, @category_ids, @create_time, @match_time)
        @response.succeed
        "成功"
      end

    render json: @response.to_render
  end

  private

  def filter_params(params)
    params        = params.with_indifferent_access
    @sport_ids    = params[:sport_id].present? ? params[:sport_id].split(",") : nil
    @match_ids    = params[:match_id].present? ? params[:match_id].split(",") : nil
    @category_ids = params[:category_id].present? ? params[:category_id].split(",") : nil
    @create_time  = params[:created_start_date].present? ? Time.parse(params[:created_start_date])..Time.parse(params[:created_end_date]) : nil
    @match_time   = params[:match_start_date].present? ? Time.parse(params[:match_start_date])..Time.parse(params[:match_end_date]) : nil
  end

  def init_response
    @response = Response.new
  end

  def check_parameter(action, params)
    case action
    when 'warning_log'
      params[:sport_id] && params[:match_id] && params[:category_id] && params[:created_start_date] && params[:created_end_date] && params[:match_start_date] && params[:match_end_date] ? true : false
    end
  end

  # params = {
  #   sport_id: "77",
  #   match_id: "450",
  #   category_id: "55628"
  # }
end
