class DateTime
  def self.mil(modifier = 0)
    (now + modifier.seconds).strftime('%Q').to_i
  end
end
