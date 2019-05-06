module StringCheese
  # Error to raise to indicate that a method cannot be used
  class CantTouchThisError < StandardError
    attr_accessor :method

    def initialize(method)
      self.method = method
      super(format_message)
    end

    protected

    def format_message
      message = ''
      message << "The method [:#{method}] is reserved and cannot be used!"
    end
  end
end
