# frozen_string_literal: true

require_relative 'token'

module StringCheese
  class TokenBuffer
    def initialize
      reset_buffer
    end

    def <<(token)
      raise ArgumentError, 'Param [token] is not a Token' unless token.is_a?(Token)
      buffer << token
    end

    def [](index)
      return nil unless any?
      buffer[index]
    end

    def any?
      buffer.any?
    end

    def buffer
      @buffer
    end

    # Clears the buffer
    def clear_buffer
      self.buffer = []
    end

    alias reset_buffer clear_buffer

    def empty?
      !any?
    end

    def length
      buffer.length
    end

    alias count length

    # Returns the buffer as a string. All tokens are suffixed with a space
    # with the exception of the raw token type which removes any preceeding
    # single space character before it.
    def to_s
      results = buffer.map.with_index do |token, index|
        token_value_for(token, index)
      end
      results.join
    end

    # Updates all tokens in the buffer with the given vars and labels.
    def update!(vars, labels)
      update_buffer(vars, labels)
    end

    protected

    attr_writer :buffer

    def find(token)
      buffer.select { |buffer_token| buffer_token == token }
    end

    def next_token(current_token_buffer_index)
      next_token_buffer_index = current_token_buffer_index + 1
      return nil unless next_token_buffer_index < buffer.length
      buffer[next_token_buffer_index]
    end

    def previous_token(current_token_buffer_index)
      previous_token_buffer_index = current_token_buffer_index - 1
      return nil if previous_token_buffer_index < 0
      buffer[previous_token_buffer_index]
    end

    def token_value_for(token, token_buffer_index)
      return token.value(space: :none) if token_buffer_index == 0
      previous_token = previous_token(token_buffer_index)
      return token.value(space: :none) if previous_token.raw?
      token.raw? ? token.value(space: :none) : token.value(space: :before)
    end

    def update_buffer(vars, labels)
      buffer.each do |token|
        next unless token.var? || token.label?
        token.var? ? update_var(token, vars) : update_label(token, labels)
      end
      buffer.clone.freeze
    end

    def update_label(token, labels)
      find(token).each do |t|
        t.value = labels[token.key]
      end
    end

    def update_var(token, vars)
      find(token).each do |t|
        t.value = vars[token.key]
      end
    end
  end
end
