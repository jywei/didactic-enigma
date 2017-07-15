class Api::V1::Users::ProfilesController < Api::V1::UsersController
  before_action :init_response, :check_permission


  api :PATCH, '/users/profiles', "更新user profile"
  # params: {
  #   user_profile: {
  #     xxxx:
  #   }
  # }
  def update
    @response.message =
      message = profile_check(params)
      if message != "CORRECT"
        message
      else
        @profile = User::Profile.find_by(user_id: params[:user_profile][:target_id])
        if @profile.update_attributes!(profile_params)
          @response.succeed
          '更新成功'
        else
          @response.validated
          '請確認欄位正確'
        end
      end
    render json: @response.to_render
  end


  api :GET, '/users/profiles', "顯示 user profile"
  # 目前少了驗證，可能可以看到非下線的profile
  # params: {
  #   target_id:45
  # }
  def show
    target_user = User.find(params[:target_id])
    profile = User::Profile.find_by(user_id: params[:target_id])

    @response.message =
      if profile && target_user
        @response.succeed
        @response.set_column(:user_profile, profile)
        @response.set_column(:user, target_user.username)
        "OK"
      else
        "找無資訊"
      end
    render json: @response.to_render
  end

private

  def init_response
    @response = Response.new
  end

  def check_permission
    # 如果是update=>外面有一層user_profile
    # 如果是show=>因為是get，參數要攤平，只需要target_id
    if params[:user_profile].present?
      render json: { code: 0, data: [], message: "請確認權限" } unless same_ancestor?(params[:user_profile][:target_id])
    elsif params[:target_id].present?
      render json: { code: 0, data: [], message: "請確認權限" } unless same_ancestor?(params[:target_id])
    else
      render json: { code: 0, data: [], message: "參數錯誤" }
    end
  end

  def profile_params
    params.require(:user_profile).permit(:nickname, :note, :quota, :delay_original, :delay_running, :parlay, :status, :accessable, :user_id)
  end
end
