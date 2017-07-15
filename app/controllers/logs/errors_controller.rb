class Logs::ErrorsController < ApplicationController
  def index
    @recent = Log::Error.with_data.where(archive: false).stack
    @logs   = Log::Error.with_data.where(archive: true).limit(500).stack
  end

  def show
    @log = Log::Error.find(params[:id])
  end

  def archive
    Log::Error.all.update_all(archive: true)
    redirect_to "/logs/errors"
  end
end
