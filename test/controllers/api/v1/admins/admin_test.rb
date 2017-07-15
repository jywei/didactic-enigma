require 'test_helper'

class Api::V1::AdminsControllerTest < ActionDispatch::IntegrationTest
  def setup
    create(:user, :admin, :with_admin_roles)
    @admin = Admin.first
    create(:user, :admin)
    @admin2 = Admin.last
    @user   = create(:user)
    @role   = create(:role, controller: "fuck_david", action: "aniki")
  end

  def log_in(user)
    cookies['user'] = user.access_token
  end

  def admin_action(action, params = nil)
    case action
    when 'index'
      get "/api/v1/admin/index"
    when 'create'
      post "/api/v1/admin/create", params: params
    when 'update'
      patch '/api/v1/admin/update', params: params
    when 'delete'
      delete '/api/v1/admin/delete', params: params
    end
    @info = response.parsed_body
  end

  def test_admin_index
    log_in(@admin)
    admin_action('index')
    admin = Admin.first
    data  = @info['data']['admins'][0]
    assert_equal @info['message'], '成功'
    assert_equal data['username'], admin.username
    assert_equal data['created_at'].to_time, admin.created_at
  end

  def test_admin_create
    log_in(@admin)
    current_count = Admin.count
    admin_action('create', { username: "fuck_david", password: "aniki" })
    assert_equal @info['message'], '成功'
    assert_equal Admin.count, current_count + 1
    assert_equal Admin.last.username, "fuck_david"
  end

  def test_admin_update
    log_in(@admin)
    admin_action('update', { target_id: @admin2.id, password: "aniki" })
    assert_equal @info['message'], '成功'
    assert_equal @admin2.reload.password, "aniki"
  end

  def test_admin_delete
    log_in(@admin)
    admin_action('delete', { target_id: @admin2.id })
    assert_equal @info['message'], '成功'
    assert_equal Admin.find_by(id: @admin2), nil
  end

  def test_admin_failed
    [@user, @admin2].each do |user|
      log_in(user)
      %w(index create update delete).each do |action|
        admin_action(action, { target_id: @admin2.id, password: "aniki" })
        assert_equal @info['message'], '無操控權限'
      end
    end

    log_in(@admin)
    %w(create update delete).each do |action|
      admin_action(action)
      assert_equal @info['message'], '傳入資訊不可空白'
    end

    %w(update delete).each do |action|
      admin_action(action, { target_id: 0, password: "aniki" })
      assert_equal @info['message'], '找不到使用者'
    end
  end

  def test_add_role
    log_in(@admin)
    assert_empty @admin2.roles

    post "/api/v1/admin/add_role", params: { target_id: @admin2.id, role_id: @role.id }
    assert_includes @admin2.roles, @role

    post '/api/v1/admin/remove_role', params: { target_id: @admin2.id, role_id: @role.id }
    refute_includes @admin2.roles, @role
  end
end
