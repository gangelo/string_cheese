# frozen_string_literal: true

require_relative 'token'
require_relative 'token_type'

module StringCheese
  class RawToken < Token
    def initialize(value, options = [])
      super(:raw, value, TokenType::RAW, options)
    end

    def value(options = { space: :none })
      super
    end
  end
end
