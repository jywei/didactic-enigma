require 'test_helper'

class Api::V1::CategoriesControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    @user = create(:user)

    content = { foo: 'bar' }.to_marshal
    $redis.set("#{$redis_key_prefix}/play:categories", content)
  end

  def test_index
    cookies['user'] = @user.access_token
    get '/api/v1/categories', params: { token: @user.access_token }
    assert_includes response.body, 'foo'
  end
end
