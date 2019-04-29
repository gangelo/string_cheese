# frozen_string_literal: true

module StringCheese
  class InvalidTokenOptionError < StandardError
    attr_accessor :option
    attr_accessor :object

    def initialize(option, object = nil)
      self.option = option
      self.object = object
      super(format_message)
    end

    protected

    def format_message
      message = ''
      message << "Option [:#{option}] is invalid for the Object type"
      message << " [#{object.class.name}]" unless object.nil?
    end
  end
end
