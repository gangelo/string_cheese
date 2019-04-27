require 'string_cheese/token'
require 'string_cheese/token_type'

module StringCheese
  class RawToken < Token
    def initialize(value)
      super(:raw, value, TokenType::RAW)
    end
  end
end
