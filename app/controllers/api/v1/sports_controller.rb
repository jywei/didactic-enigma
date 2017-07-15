class Api::V1::SportsController < Api::V1::ApplicationController
  before_action :init_response, only: :update
  skip_before_action :verify_token

  api :GET, "/sports", "所有運動項目"
  formats ['json']
  example '"/api/v1/sports"'
  example '
  [
    {
    "name": "足球",
    "sport_id": 75
    },
    {
      "name": "冰球",
      "sport_id": 76
    },
    {
      "name": "籃球",
      "sport_id": 77
    },
    {
      "name": "橄欖球",
      "sport_id": 78
    },
    {
      "name": "網球",
      "sport_id": 79
    },
    {
      "name": "美式足球",
      "sport_id": 80
    },
    {
      "name": "棒球",
      "sport_id": 81
    },
    {
      "name": "排球",
      "sport_id": 87
    },
    {
      "name": "測試",
      "sport_id": 335
    }
  ]
  '
  def index
    sports = Sport.active.map do |sport|
      {
        name:     sport.display_name || sport.name,
        sport_id: sport.id
      }
    end

    render json: sports
  end

  def update
    @response.message =
      if params[:name].nil?
        @response.validated
        '傳入資訊不可空白'
      elsif current_user.nil?
        '使用者未登入'
      elsif !current_user.is_admin?
        '無操控權限'
      elsif (sport = Sport.find_by(leader_spid: params[:id])).nil?
        '無此筆資料'
      else
        if sport.update_attributes(display_name: params[:name])
          Cache::Category.update_cache("sport", sport.leader_spid, params[:name])
          @response.succeed
          '成功'
        else
          @response.data = sport.errors.full_messages
          '失敗'
        end
      end
    render json: @response
  end

  private

    def init_response
      @response = Response.new
    end
end
