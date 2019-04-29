# frozen_string_literal: true

require_relative 'token'

module StringCheese
  class Buffer
    attr_reader :buffer_index

    def initialize
      reset_buffer
    end

    def <<(token)
      raise ArgumentError, 'Param [token] is not a Token' unless token.is_a?(Token)
      buffer << token
    end

    def any?
      buffer.any?
    end

    # Clears the buffer
    def clear_buffer
      self.buffer = []
      update_buffer_index
    end

    alias reset_buffer clear_buffer

    # Returns the portion of the buffer starting at the buffer element
    # pointed to by #buffer_index
    def current_buffer
      buffer.slice(buffer_index, buffer.length - buffer_index).clone.freeze
    end

    def empty?
      !any?
    end

    # Returns the buffer as a string. All tokens are suffixed with a space
    # with the exception of the raw token type which removes any preceeding
    # single space character before it.
    def to_s
      results = buffer.map.with_index do |token, index|
        token_value_for(token, index, buffer)
      end
      results.join
    end

    # Updates all tokens in the buffer with the given vars and labels.
    def update!(vars, labels)
      update_buffer(vars, labels, buffer)
    end

    # Updates only the tokens in the current buffer with the given vars and labels.
    def update_current!(vars, labels)
      update_buffer(vars, labels, current_buffer)
    end

    protected

    attr_accessor :buffer
    attr_writer :buffer_index

    def find(token, buffer)
      buffer.select { |buffer_token| buffer_token == token }
    end

    def next_token(current_token_buffer_index, buffer)
      next_token_buffer_index = current_token_buffer_index + 1
      return nil unless next_token_buffer_index < buffer.length

      buffer[next_token_buffer_index]
    end

    def previous_token(current_token_buffer_index, buffer)
      previous_token_buffer_index = current_token_buffer_index - 1
      return nil if previous_token_buffer_index < 0

      buffer[previous_token_buffer_index]
    end

    def token_value_for(token, token_buffer_index, buffer)
      return token.value(space: :none) if token_buffer_index == 0

      previous_token = previous_token(token_buffer_index, buffer)
      return token.value(space: :none) if previous_token.raw?

      token.raw? ? token.value(space: :none) : token.value(space: :before)
    end

    def update_buffer(vars, labels, buffer)
      buffer.each do |token|
        next unless token.var? || token.label?
        token.var? ? update_var(token, buffer, vars) : update_label(token, buffer, labels)
      end
      buffer.clone.freeze
    end

    # Sets the buffer index beyond the end of the array.
    def update_buffer_index
      self.buffer_index = buffer.length
    end

    def update_label(token, buffer, labels)
      find(token, buffer).each do |t|
        t.value = labels[token.key]
      end
    end

    def update_var(token, buffer, vars)
      find(token, buffer).each do |t|
        t.value = vars[token.key]
      end
    end
  end
end
