require 'string_cheese/token'
require 'string_cheese/token_type'

module StringCheese
  class RawToken < Token
    def initialize(value)
      super(:raw, value, TokenType::RAW)
    end

    def value(options = { space: :none })
      case options[:space]
      when :after
        "#{@value} "
      when :before
        " #{@value}"
      else
        @value
      end
    end
  end
end
