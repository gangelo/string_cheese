# frozen_string_literal: true

require_relative 'token'
require_relative 'token_type'

module StringCheese
  class TextToken < Token
    def initialize(value)
      super(:text, value, TokenType::TEXT)
    end
  end
end
