require 'test_helper'

class Api::V1::UsersControllerSignUpTest < ActionDispatch::IntegrationTest
  def setup
    db = ActiveRecord::Base.connection
    db.execute(File.read("db/fakers/users.sql"))
    db.execute(File.read("db/fakers/user_settings.sql"))
    db.execute(File.read("db/fakers/user_allotters.sql"))
    @user = User.find(50)
    @params = {
      username:       'fooo',
      password:       '123456',
      bank_id:        @user.id,
      identity:       "normal",
      user_profile: {
        nickname:       'shane',
        note:           'yeeeeeee',
        quota:          100,
        delay_original: 0,
        delay_running:  0,
        parlay:         10,
        status:         "正常",
        accessable:     1
      }
    }
  end

  def test_username_repeat
    get '/api/v1/users/username_repeat', params: { username: 'JohnCena' }
    assert_equal false, response.parsed_body['data']['duplicate_name']

    get '/api/v1/users/username_repeat', params: { username: 'level1' }
    assert_equal true,  response.parsed_body['data']['duplicate_name']
  end

  def test_sign_up_success
    cookies['user'] = @user.access_token
    post '/api/v1/sign_up', params: @params
    assert_equal   10,    User.count
    assert_equal    1,    User::Profile.count
    assert_equal    5,    response.parsed_body['data']['user'].length
  end

  def test_sign_up_failed
    cookies['user'] = @user.access_token
    @params[:user_profile][:delay_original] = 5
    post '/api/v1/sign_up', params: @params
    assert_equal    9,    User.count
    assert_equal    0,    User::Profile.count
    assert_equal    "延遲秒數設定錯誤", response.parsed_body['message']
    assert_equal    0,    response.parsed_body['code']
  end



  def test_new_user_allotter_and_setting
    @new_member =      User.last
    @user_id =         @user.id
    @new_user_id =     @new_member.id
    agent_one_rebate = User::Setting.find_by(name: "icehockey", ot_id: 15, user_id: @user_id).rebate
    member_rebate =    User::Setting.find_by(name: "icehockey", ot_id: 15, user_id: @new_user_id).rebate
    member_allotter =  User::Allotter.find_by(name: "icehockey", user_id: @new_user_id)
    assert_equal agent_one_rebate, member_rebate
    assert_equal nil,              member_allotter
  end

  def test_sign_in
    user = create(:user)
    post '/api/v1/sign_in', params: { username: 'foo' }
    assert_equal 0, response.parsed_body['code']
    assert_equal '帳號或密碼不可空白', response.parsed_body['message']

    post '/api/v1/sign_in', params: { username: 'fuck', password: 'shit' }
    assert_equal 0, response.parsed_body['code']
    assert_equal '找不到使用者', response.parsed_body['message']

    post '/api/v1/sign_in', params: { username: user.username, password: user.encrypted_password }
    assert_equal 1, response.parsed_body['code']
    assert_equal '登入成功', response.parsed_body['message']
  end
end
