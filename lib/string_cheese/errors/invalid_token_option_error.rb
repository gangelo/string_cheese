module StringCheese
  # Error to raise to indicate an invalid token option
  class InvalidTokenOptionError < StandardError
    attr_accessor :option
    attr_accessor :klass_object

    def initialize(option, klass_object = nil)
      self.option = option
      self.klass_object = klass_object
      super(format_message)
    end

    protected

    def format_message
      message = ''
      message << "Option [:#{option}] is invalid for the Object type"
      message << " [#{klass_object.class.name}]" unless klass_object.nil?
    end
  end
end
