class Hash
  def keep(*keys)
    each_with_object({}) do |pair, result|
      result[pair[0]] = pair[1] if keys.include?(pair[0])
    end
  end

  def to_match_open
    Match::Open.new(self)
  end

  def from_marshal
    Marshal.load self
  end

  def to_marshal
    Marshal.dump self
  end

  def to_base64
    Base64.encode64(Marshal.dump(self))
  end

  def keep_random(num)
    ks = keys[0..(num - 1)]
    each_with_object({}) do |obj, result|
      result[obj[0]] = obj[1] if ks.include?(obj[0])
    end
  end

  # for testing purpose
  def test
    Operation::Odd.new(self.to_base64).operate!
  end
end
