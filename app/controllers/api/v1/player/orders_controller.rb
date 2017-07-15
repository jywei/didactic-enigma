class Api::V1::Player::OrdersController < Api::V1::ApplicationController
  api :GET, '/player/orders/recent', "使用者歷史注單"
  param :settle, String, "是否取得已派彩比賽的數據", required: false
  param :page, String, "頁數限制"
  param :per, String, "筆數限制"
  formats ['json']
  example '"/api/v1/player/orders/recent?settle=true&per=20&page=1"'
  example '
  {
    "user": "bot02",
    "code": 1,
    "data": [
      {
        "id": 219,
        "amount": 1000,
        "prize": 961,
        "items": [
          {
            "id": 559,
            "category": "NBA",
            "h": "OklahomaCityThunder",
            "a": "明尼蘇達木狼",
            "target": "h",
            "odd": 0.961,
            "head": "10.5",
            "proportion": 0,
            "offer_name": "讓分",
            "halves": "全場",
            "match_start_time": "12/26 09:00"
          }
        ],
        "order_at": "12/30 15:22",
        "result_at": "01/02 03:04",
        "effective_amount": 0,
        "stake": 961,
        "remaining_quota": null,
        "sport_id": null
      }
    ]
  }
  '
  param_group :user_authentication, ::Api::V1::ApplicationController
  def recent
    render json: {
      user: current_user.username,
      code: 1,
      data: recent_orders,
      count: orders.count
    }
  end

  protected

    def orders
      @orders ||= current_user.orders.settled(params[:settle])
    end

    def recent_orders
      orders.paginate(params[:page] || 1, params[:per] || 20).recent
    end

end
