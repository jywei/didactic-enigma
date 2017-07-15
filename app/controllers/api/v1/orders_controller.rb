class Api::V1::OrdersController < Api::V1::ApplicationController
  api :GET, 'orders/history', ""
  # TODO 補上API文件
  def history
    order_data = if current_user
      Order.history
    else
      "User not signed in."
    end
    render json: {
      code: 1,
      data: order_data
    }
  rescue => e
    Rails.logger.info(e)
    render json: {
      code: 0
    }
  end
end
