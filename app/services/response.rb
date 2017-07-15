class Response
  attr_reader :code, :data
  attr_accessor :message, :action

  def initialize(action = '')
    @code = 0
    @data = {}
    @action = action
    @message = ''
  end

  def failed
    @code = 0
  end

  def succeed
    @code = 1
  end

  def validated
    @code = 2
  end

  def incorrected
    @code = 8
  end

  def set_column(key, value)
    @data[key.to_sym] = value
  end

  def to_render
    {
      code: @code,
      data: @data,
      message: @message,
      action: @action
    }
  end
end
