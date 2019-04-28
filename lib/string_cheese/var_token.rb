require_relative 'token'
require_relative 'token_type'

module StringCheese
  class VarToken < Token
    def initialize(key, value)
      super(key, value, TokenType::VAR)
    end
  end
end
