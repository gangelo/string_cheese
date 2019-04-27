require 'string_cheese/token'
require 'string_cheese/token_type'

module StringCheese
  class LabelToken < Token
    def initialize(key, value)
      super(key, value, TokenType::LABEL)
    end
  end
end
