class Api::V1::GroupsController < Api::V1::ApplicationController
  skip_before_action :verify_token

  api :GET, '/groups', "子聯盟列表"
  param :search, String, "欲搜尋的字串"
  formats ['json']
  example '"/api/v1/groups?search=歐洲聯賽"'
  example '
  {
    "code": 1,
    "data": [
      {
        "id": 2,
        "name": "歐洲聯賽冠軍盃",
        "display_name": "歐洲聯賽冠軍盃"
      }
    ]
  }
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def index
    groups = if current_user
      Group.search_data(params[:search])
    else
      "User not logged in."
    end
    code = current_user ? 1 : 0
    render json: {
      code: code,
      data: groups
    }
  end

  api :POST, '/groups', "更新子聯盟顯示名稱"
  param :name, String, "更新的名稱"
  param :id, String, "更新的子聯盟id"
  formats ['json']
  example '"/api/v1/groups?id=2&name=歐洲聯賽冠軍盃"'
  example '
  {
    code: 1,
    message: "更新成功"
  }
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def update
    message = if params[:name].blank?
      '傳入資訊不可空白'
    else
      Group.find(params[:id]).update_column(:display_name, params[:name])
      '更新成功'
    end
    code = params[:name].blank?? 0 : 1
    render json: {
      code: code,
      message: message
    }
  end
end
