# frozen_string_literal: true

require_relative 'errors/invalid_token_option_error'
require_relative 'token_type'

module StringCheese
  class Token
    attr_reader :key, :options, :token_type

    # Note: options are applied in the order they are given
    def initialize(key, value, token_type, options)
      self.key = key
      self.value = value
      self.token_type = token_type
      self.options = options
    end

    def ==(token)
      return false if token.nil?

      key == token.key && token_type == token.token_type
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

    # Returns the token key, value pair as a Hash.
    def to_h(options = { space: :none })
      Hash[key, value(options)]
    end

    def value(options = { space: :before })
      value = @value
      if block_given?
        value = yield value, self.options
      end
      self.options.each do |option|
        next if option == :nop
        # Raise an error if the value does not respond to the option
        raise InvalidTokeOptionError(option, value) unless value.respond_to?(option)
        # Execute the option and return whatever result the call produces. Some
        # calls may not produce anything, so make the assignment of the call
        # result to the value conditional. This may not be the desired result;
        # however, the consumer of this gem needs to be aware of what's going on
        # here. If special processing is necessary, use a block.
        result = value.send(option)
        value = result unless result.nil?
      end
      value = case options[:space]
              when :after
                "#{value} "
              when :before
                " #{value}"
              else
                value
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

    attr_writer :key, :options, :token_type

    def remove_utf_8_invalid_byte_sequence(string, replace = '<invalid utf-8 sequence>')
      return string if string.nil? || string.empty?
      string.encode('UTF-8', 'binary', invalid: :replace, undef: :replace, replace: replace)
    end
  end
end
