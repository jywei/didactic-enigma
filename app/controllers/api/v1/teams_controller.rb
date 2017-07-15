class Api::V1::TeamsController < Api::V1::ApplicationController
  before_action :init_response, :check_admin
  skip_before_action :verify_token

  api :GET, '/teams', "比賽隊伍列表"
  # TODO 補上API文件
  def index
    @response.message = "成功"
    @response.succeed
    @response.data[:teams] =
      if params[:category_id].present?
        Team.team_data(params[:category_id])
      elsif params[:search].present?
        Team.search_data(params[:search])
      else
        Team.limit_data
      end
    render json: @response
  end

  api :POST, '/teams', "更新比賽隊伍顯示名稱"
  # TODO 補上API文件
  def update
    @response.message =
      if params[:name].blank?
        @response.validated
        '傳入資訊不可空白'
      else
        @response.succeed
        Team.find(params[:id]).update_column(:name_cn, params[:name])
        '更新成功'
      end
    render json: @response
  end

  private

    def check_admin
      if !current_user
        @response.message = "使用者未登入"
        render json: @response
      else
        admin = current_user.class_to_admin
        if !(admin.is_a? Admin) || !admin.check_competence(self.class.name, @_action_name)
          @response.message = "無操控權限"
          render json: @response
        end
      end
    end

    def init_response
      @response = Response.new
    end
end
