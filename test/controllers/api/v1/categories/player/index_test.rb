require 'test_helper'

class Api::V1::Player::CategoriesControllerIndexTest < ActionDispatch::IntegrationTest
  def setup
    categories = {
      'unselected' => 'foo',
      'selected' => 'bar'
    }
    $redis.set("#{$redis_key_prefix}/play:categories", Marshal.dump(categories))
  end

  # def test_index
  #   get '/api/v1/player/categories'
  #   refute_includes response.body, 'foo'
  #   assert_includes response.body, 'bar'
  # end
  #
  # def test_index_empty
  #   $redis.del("#{$redis_key_prefix}/play:categories")
  #   get '/api/v1/player/categories'
  #   refute_includes response.body, 'foo'
  #   refute_includes response.body, 'bar'
  # end
end
