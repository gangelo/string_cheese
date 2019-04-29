# frozen_string_literal: true

require_relative 'token'
require_relative 'token_type'

module StringCheese
  class TextToken < Token
    def initialize(value, options = [])
      super(:text, value, TokenType::TEXT, options)
    end
  end
end
