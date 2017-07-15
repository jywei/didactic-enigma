class Pushes::LogsController < ApplicationController
  def show
    @log  = Log::Push.find(params[:id])
    uuid  = @log.uuid
    @logs = Log::Push.where(uuid: uuid).where.not(id: params[:id])
  end

  def uuid
    uuid = params[:uuid]
    @log  = Log::Push.where(uuid: uuid).first
    if @log.nil?
      render json: "Log with UUID #{uuid} not found"
      return
    end
    @logs = Log::Push.where(uuid: uuid).where.not(id: @log.id)
    render :show
  end
end
