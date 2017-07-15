module Operation
  class Base
    # For testing purpose
    def self.test(args)
      new(args.to_base64).operate!
    end
  end
end
