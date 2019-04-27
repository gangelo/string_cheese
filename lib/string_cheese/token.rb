require 'string_cheese/token_type'

module StringCheese
  class Token
    attr_reader :key, :token_type
    attr_accessor :value

    def initialize(key, value, token_type)
      self.key = key
      self.value = value
      self.token_type = token_type
    end

    def ==(token)
      return false if token.nil?
      self.key == token.key && self.token_type == token.token_type
    end

    def label?
      token_type == TokenType::LABEL
    end

    def raw?
      token_type == TokenType::RAW
    end

    def text?
      token_type == TokenType::TEXT
    end

    def update_value(value)
      self.value = value
    end

    def var?
      token_type == TokenType::VAR
    end

    protected

    attr_writer :key, :token_type
  end
end
