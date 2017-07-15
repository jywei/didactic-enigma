class Api::V1::UsersController < Api::V1::ApplicationController
  include AncestorUpdate
  before_action :init_response
  skip_before_action :verify_token, only: %i(sign_in sign_up username_repeat)

  def sign_in
    @response.message =
      if !check_parameter('sign_in', params)
        '帳號或密碼不可空白'
      elsif (user = User.find_by(username: params[:username], encrypted_password: params[:password])).nil?
        '找不到使用者'
      else
        user.refresh_token
        @response.succeed; @response.set_column(:user, id: user.id, name: user.username, quota: 94_879_453, identity: user.identity, tier: user.tier, token: user.access_token)
        # 踢人
        # ActionCable.server.broadcast "user_#{ActionCable.server.connections.first.client_identifier}", {action: 'authentication', msg: "outdated"}
        '登入成功'
      end

    render json: @response.to_render
  end

  def sign_up
    # apiRoute: '/api/v1/sign_up?',
                  # method: 'POST',

                  # params: {
                  #           username: id,
                  #           password: pw,

                  #            user_profile: {
                  #              xxx: ...
                  #            }
                  #         }
    # Content-Type: application/json
    @response.message =
      if !check_parameter('sign_up', params)
        @response.validated
        '帳號或密碼不可空白'
      elsif User.find_by(username: params[:username])
        @response.validated
        '使用者名稱重複'
      elsif !check_parameter('user_profile', params)
        @response.validated
        '使用者設定資訊未填'
      else
        message = profile_check(params)
        if message != "CORRECT"
          message
        else
          user = current_user.create_user(params)

         #update_ancestors(user) if user.tier == 8
          update_ancestors(user)
          user_profile = User::Profile.find_by(user_id: user.id)
          @response.succeed
          @response.set_column(:user, id: user.id, name: user.username, bank_id: user.bank_id, token: user.access_token, updated_at: user_profile.updated_at)
          '註冊成功'
        end
      end

    render json: @response.to_render
  end

  api :GET, "/user_settings", "顯示使用者設定"
  # TODO 補上API文件
  def settings
    @response.message =
      if !check_parameter('get_settings_allotters', params)
        @response.validated
        '使用者ID不可空白'
      elsif User.find_by(id: params[:target_id]).nil?
        '找不到使用者'
      elsif !same_ancestor?(params[:target_id])
        '目標非直屬下限'
      else
        # bank = User.find_by(id: params[:user_id])
        # user = bank if user.nil?
        @response.succeed
        @response.set_column(:user_id, params[:target_id])
        @response.set_column(:settings, arrange_rebate(User::Setting.where(user_id: params[:target_id].to_i)))
        # @response.set_column(:user, id: user.id, username: user.username, total_quota: user.total_quota)
        # @response.set_column(:downlines,
        #                      (bank.downlines.pluck(:id, :username).map { |u| { id: u[0], username: u[1] } }).insert(0, id: user.id, username: user.username))
        '成功'
      end

    render json: @response.to_render
  end

  api :POST, "/user_settings/return_all_rebate", "全退水"
  def return_all_rebate
    @response.message =
      if !check_parameter('auto_adjust', params)
        @response.validated
        '使用者ID不可空白'
      elsif User.find_by(id: params[:target_id]).nil?
        '找不到使用者'
      elsif !same_ancestor?(params[:target_id])
        '目標非直屬下限'
      else
        if User::Setting.update_rebate(current_user.id.to_i, params[:target_id].to_i, true)
          @response.succeed
          @response.set_column(:user_id, params[:target_id])
          @response.set_column(:settings, arrange_rebate(User::Setting.where(user_id: params[:target_id].to_i)))
        end
      end
    render json: @response.to_render
  end

  api :POST, "/user_settings/return_none_rebate", "全不退水"
  def return_none_rebate
    @response.message =
      if !check_parameter('auto_adjust', params)
        @response.validated
        '使用者ID不可空白'
      elsif User.find_by(id: params[:target_id]).nil?
        '找不到使用者'
      elsif !same_ancestor?(params[:target_id])
        '目標非直屬下限'
      else
        if User::Setting.update_rebate(current_user.id.to_i, params[:target_id].to_i, false)
          @response.succeed
          @response.set_column(:user_id, params[:target_id])
          @response.set_column(:settings, arrange_rebate(User::Setting.where(user_id: params[:target_id].to_i)))
        end
      end
    render json: @response.to_render
  end

  api :POST, "/users/validation_auto_adjust", "檢查自動下壓"
  def validation_auto_adjust
    @response.message =
      if !check_parameter('auto_adjust', params)
        @response.validated
        '傳入資訊不可空白'
      else
        auto_adjust = AutoAdjust.new(params).affected_record.size
        @response.succeed
        "#{auto_adjust}"
      end
    render json: @response.to_render
  end

  def allotters
    @response.message =
      if !check_parameter('get_settings_allotters', params)
        @response.validated
        '使用者ID不可空白'
      elsif User.find_by(id: params[:target_id]).nil?
        '找不到使用者'
      elsif !same_ancestor?(params[:target_id])
        '目標非直屬下限'
      elsif current_user.player?
        '玩家無權限'
      else
        @response.succeed
        @response.set_column(:user_id, params[:target_id])
        @response.set_column(:allotters, arrange_allotter(params[:target_id].to_i))
        '成功'
      end

    render json: @response.to_render
  end

  # params:{ target_id, table_type, target_column, sport_name, ot_id, adj_amount }
  api :PATCH, "/users/settings", "更新使用者設定"
  # TODO 補上API文件
  def update_setting
    params[:user_id] = current_user.id
    target_id = params[:target_id].to_i
    @response.message =
      if !check_parameter('auto_adjust', params)
        @response.validated
        '傳入資訊不可空白'
      elsif User.find_by(id: target_id).nil?
        '找不到修改使用者'
      elsif current_user.player?
        '玩家無權限'
      elsif !same_ancestor?(target_id)
        '欲更改非直接下線'
      elsif User::Setting.update_settings(params)
        @response.succeed
        '更新成功'
      else
        "設定值不可小於自身原值或資料錯誤"
      end

    render json: @response.to_render
  end

  # params:{ target_id, table_type, target_column, sport_name, ot_id, adj_amount }
  api :PATCH, "/users/allotters", "更新使用者佔成設定"
  # TODO 補上API文件
  def update_allotters
    params[:user_id] = current_user.id
    target_id = params[:target_id].to_i
    @response.message =
      if !check_parameter('auto_adjust', params)
        @response.validated
        '傳入資訊不可空白'
      elsif User.find_by(id: target_id).nil?
        '找不到修改使用者'
      elsif current_user.player?
        '玩家無權限'
      elsif !same_ancestor?(target_id)
        '欲更改非直接下線'
      elsif User::Allotter.update_allotters(params)
        @response.succeed
        "更新成功"
      else
        "設定值不可小於自身原值或資料錯誤"
      end
    render json: @response.to_render
  end

  def update_password
    @response.message =
      if !check_parameter('update_password', params)
        @response.validated
        '傳入資訊不可空白'
      elsif current_user.nil?
        '找不到修改使用者'
      else
        current_user.update_attributes(encrypted_password: password_params)
        @response.succeed
        '更新成功'
      end

    render json: @response.to_render
  end
  # params[:id] && params[:target_id] && params[:category_name] && params[:value] ? true : false

  # route api/v1/users/:id/reports?sport_id=75&type_id=1,2,3,4&start_date=...&end_date=...
  # return unless member_report?
  api :PATCH, "users/:id/reports", "顯示使用者分層報表"
  # TODO 補上API文件
  def reports
    @response.message =
      if !same_ancestor?(params[:id])
        "無權限訪問"
      elsif current_user.player?
        "玩家無權限"
      else
        @response.succeed
        @response.data["report"] =
          if User.find(params[:id]).player?
            MemberReport.new(params).serialize
          else
            UserReport.new(params).serialize
          end
        "成功"
      end
    render json: @response.to_render
  end

  def statistic_reports
    render json: current_user.statistic_reports
  end

  def downline_list
    ancestor_ids = current_user.downline_users.pluck("#{UserReport.names[params[:tier].to_i]}").compact.uniq
    @response.data["downline_list"] = current_user.downline_list(ancestor_ids)
    @response.succeed

    render json: @response.to_render
  end

  def downline_profile
    @response.message =
      if check_parameter('downline_profile', params) == false
        @response.validated
        '傳入資訊不可空白'
      elsif current_user.player?
        "玩家無權限"
      else
        @response.set_column(:downlines, arrange_downline_profile(params[:target_id]))
        @response.succeed
        "成功"
      end

    render json: @response.to_render
  end

  def username_repeat
    @response.set_column(:duplicate_name, User.exists?(username: params[:username]))
    @response.succeed
    render json: @response.to_render
  end

  protected

  def same_ancestor?(target_id)
    current_user.report_accessible?(target_id.to_i)
  end

  def profile_check(params)
    param = params[:user_profile]
    if param[:delay_original].to_i > 4 || param[:delay_running].to_i > 4
      "延遲秒數設定錯誤"
    elsif param[:parlay].to_i > 10
      "串關上限錯誤"
    else
      "CORRECT"
    end
  end

  private

  def init_response
    @response = Response.new
  end

  def arrange_rebate(settings)
    user_setting = {}
    settings.each do |user_record|
      next if user_record.name.nil?
      user_setting[user_record.name.to_sym] = { name_ch: user_record.name_ch, otname: [], content: { rebate: [], offer_quota: [], match_quota: [] } } unless user_setting.include? user_record.name.to_sym
      user_setting[user_record.name.to_sym][:otname] << user_record.otname
      user_setting[user_record.name.to_sym][:content][:rebate] << { ot_id: user_record.ot_id, value: user_record.rebate }
      user_setting[user_record.name.to_sym][:content][:match_quota] << { ot_id: user_record.ot_id, value: user_record.match_quota }
      user_setting[user_record.name.to_sym][:content][:offer_quota] << { ot_id: user_record.ot_id, value: user_record.offer_quota }
    end
    user_setting
  end

  def arrange_allotter(user_id)
    User::Allotter.where(user_id: user_id).map { |allotter| { name: allotter.name, name_ch: allotter.name_ch, oppo: (allotter.oppo).to_f } }
  end

  def arrange_downline_profile(target_id)
    downline_profile = {}
    users     = User.where(bank_id: target_id).select(:id, :username, :created_at, :tier)
    ancestors = User.find(target_id).downline_users
    ids       = users.pluck(:id)
    profiles  = User::Profile.where(user_id: ids).select(:nickname, :quota, :current_quota, :status, :user_id)
    allotters = User::Allotter.where(user_id: ids).select(:user_id, :oppo, :name, :name_ch)
    downline_profile['users']     = users
    downline_profile['profiles']  = profiles
    downline_profile['allotters'] = allotters
    downline_profile['else']      = []
    users.each do |user|
      downline_profile['else'] << {
        'user_id'        => user.id,
        'downline_count' => ancestors.downlines_count(ancestors, user).size
      }
    end
    downline_profile
  end

  def check_parameter(action, params)
    case action
    when 'sign_in', 'sign_up'
      params[:username] && params[:password] ? true : false
    when 'get_settings_allotters'
      params[:target_id] ? true : false
    when 'auto_adjust'
      params[:target_id] && params[:table_type] && params[:target_column] && params[:sport_name] && params[:ot_id] && params[:adj_amount] ? true : false
    when 'update_password'
      params[:password] ? true : false
    when 'user_profile'
      params[:user_profile][:delay_original] && params[:user_profile][:delay_running] && params[:user_profile][:parlay] ? true : false
    when 'downline_profile'
      params[:target_id] ? true : false
    end
  end

  def arrange_allotter(user_id)
    User::Allotter.where(user_id: user_id).map { |allotter| { name: allotter.name, name_ch: allotter.name_ch, oppo: allotter.oppo.to_f } }
  end

  def password_params
    params.require(:password)
  end

end
