class Api::V1::AdminsController < Api::V1::ApplicationController
  before_action :init_response
  before_action :check_admin

  def index
    @response.message = "成功"
    @response.succeed
    @response.data[:admins] = Admin.all_admin_profile
    render json: @response
  end

  def create
    @response.message =
      if check_parameters('create', params) == false
        @response.validated
        '傳入資訊不可空白'
      else
        admin = Admin.new(username: params[:username], encrypted_password: params[:password], is_admin: true)
        if admin.save
          @response.succeed
          "成功"
        else
          @response.data[:error_message] = admin.errors.full_messages.to_s
          "失敗"
        end
      end
    render json: @response
  end

  def update
    @response.message =
      if check_parameters('update', params) == false
        @response.validated
        '傳入資訊不可空白'
      elsif (admin = Admin.find_by(id: params[:target_id])).nil?
        '找不到使用者'
      else
        if admin.update_attributes(update_parameter)
          @response.succeed
          "成功"
        else
          @response.data[:error_message] = admin.errors.full_messages.to_s
          "失敗"
        end
      end
    render json: @response
  end

  def destroy
    @response.message =
      if check_parameters('destroy', params) == false
        @response.validated
        '傳入資訊不可空白'
      elsif (admin = Admin.find_by(id: params[:target_id])).nil?
        '找不到使用者'
      else
        @response.succeed
        admin.delete
        "成功"
      end
    render json: @response
  end

  def role_index
    @response.message       = '成功'
    @response.data['roles'] = Role.info
    @response.succeed
    render json: @response
  end

  def show_roles
    @response.message =
      if (admin = Admin.find_by(id: params[:id])).nil?
        '找不到使用者'
      else
        @response.succeed
        @response.data['roles'] = admin.roles.info
        '成功'
      end
    render json: @response
  end

  def add_role
    @response.message =
      if check_parameters('add_role', params) == false
        @response.validated
        '傳入資訊不可空白'
      elsif Role.find_by(id: params[:role_id]).nil?
        '無此筆資料'
      elsif (admin = Admin.find_by(id: params[:target_id])).nil?
        '找不到使用者'
      else
        @response.succeed
        admin.add_role(params[:role_id])
        '成功'
      end
    render json: @response
  end

  def remove_role
    @response.message =
      if check_parameters('remove_role', params) == false
        '傳入資訊不可空白'
      elsif Role.find_by(id: params[:role_id]).nil?
        '無此筆資料'
      elsif (admin = Admin.find_by(id: params[:target_id])).nil?
        '找不到使用者'
      else
        @response.succeed
        admin.remove_role(params[:role_id])
        '成功'
      end
    render json: @response
  end

  private

    def init_response
      @response = Response.new
    end

    def check_admin
      admin = current_user.class_to_admin
      if !(admin.is_a? Admin) || !admin.check_competence(self.class.name, @_action_name)
        @response.message = "無操控權限"
        render json: @response
      end
    end

    def check_parameters(action, params)
      case action
      when 'create'
        params[:username] || params[:password] ? true : false
      when 'update'
        params[:target_id] || params[:password] ? true : false
      when 'destroy'
        params[:target_id] ? true : false
      when 'add_role'
        params[:target_id] || params[:role_id] ? true : false
      when 'remove_role'
        params[:target_id] || params[:role_id] ? true : false
      end
    end

    def update_parameter
      params.permit(:password)
    end
end
