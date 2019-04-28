# frozen_string_literal: true

require_relative 'token'
require_relative 'token_type'

module StringCheese
  class LabelToken < Token
    def initialize(key, value)
      super(key, value, TokenType::LABEL)
    end
  end
end
