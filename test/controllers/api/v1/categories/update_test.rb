require 'test_helper'

class Api::V1::CategoriesControllerUpdateTest < ActionDispatch::IntegrationTest
  def setup
    @user      = create(:user)
    @category  = create(:category, :nba)
    @category2 = create(:category, :mlb)
    data = Marshal.dump(
      {
        unselected: Cache::Category.all,
        selected: []
      }
    )
    $redis.set("#{$redis_key_prefix}/play:categories", data)
  end

  def test_update
    cookies['user'] = @user.access_token

    assert_equal Cache::Category.selected[0][:sub][0][:name], @category.name

    patch "/api/v1/categories/#{@category.id}", params: { name: "aniki" }
    get "/api/v1/categories"

    assert_equal @category.reload.display_name, 'aniki'
    assert_equal response.parsed_body['selected'][0]['sub'][0]['name'], 'aniki'

    patch "/api/v1/categories/#{@category2.id}", params: { name: "fuck_david" }
    get "/api/v1/categories"

    assert_equal @category2.reload.display_name, 'fuck_david'
    assert_equal response.parsed_body['selected'][1]['sub'][0]['name'], 'fuck_david'
  end
end
