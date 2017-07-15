class String
  def to_boolean
    self == 'true' ? true : false
  end

  def from_marshal
    Marshal.load self
  end

  def to_marshal
    Marshal.dump self
  end

  def from_base64
    Base64.decode64(self).from_marshal
  end
end
