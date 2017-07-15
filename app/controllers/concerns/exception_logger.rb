module ExceptionLogger
  def rescue_to_log
    begin
      yield
    rescue => e
      begin
        user_id = current_user.try(:id)
      rescue
        user_id = nil
      end
      uuid = request.env['action_dispatch.request_id']
      Rails.logger.info("Creating error log")
      log = Log::Error.create!(
        name:      e.class.name,
        user_id:   user_id,
        path:      request.env["ORIGINAL_FULLPATH"],
        uuid:      uuid,
        message:   e.message,
        params:    params.to_h,
        backtrace: e.backtrace,
        data:      ""
      )
      Rails.logger.info("Log::Error record created as ID ##{log.try(:id)}")
      Rails.logger.info("#{e.class} #{e.message} #{e.backtrace}")
      render json: {
        code: 9,
        message: "Internal server error",
        data: []
      }
    end
  end
end
