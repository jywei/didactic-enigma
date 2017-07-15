module Cache
  class MatchNotFound < Exception
    def initialize(msg="")
      super(msg)
    end
  end
end
