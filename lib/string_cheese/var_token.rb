# frozen_string_literal: true

require_relative 'token'
require_relative 'token_type'

module StringCheese
  class VarToken < Token
    def initialize(key, value, options = [])
      super(key, value, TokenType::VAR, options)
    end
  end
end
