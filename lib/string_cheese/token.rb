require_relative 'token_type'

module StringCheese
  class Token
    attr_reader :key, :token_type

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

    def value(options = { space: :before })
      case options[:space]
      when :after
        "#{@value} "
      when :before
        " #{@value}"
      else
        @value
      end
    end

    def value=(value)
      value = remove_utf_8_invalid_byte_sequence(value) if value.is_a?(String)
      @value = value
    end

    def var?
      token_type == TokenType::VAR
    end

    protected

    attr_writer :key, :token_type

    def remove_utf_8_invalid_byte_sequence(string, replace = '<invalid utf-8 sequence>')
      return string if string.nil? || string.empty?
      string.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: replace)
    end
  end
end
