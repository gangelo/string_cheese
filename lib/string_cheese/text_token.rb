require 'string_cheese/token'
require 'string_cheese/token_type'

module StringCheese
  class TextToken < Token
    def initialize(value)
      super(:text, value, TokenType::TEXT)
    end
  end
end
