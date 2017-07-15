class Api::V1::Player::CategoriesController < Api::V1::ApplicationController
  skip_before_action :verify_token

  api :GET, '/player/categories', "顯示目前有比賽場次的體育和聯盟項目"
  def index
    # render json: Cache::Category.selected
    render json: Cache::Category.with_matches
  end
end
