# frozen_string_literal: true

require_relative 'token_buffer'

module StringCheese
  class TokenBufferManager
    attr_reader :buffer_index

    def initialize
      reset_buffer
    end

    def <<(token)
      raise ArgumentError, 'Param [token] is not a Token' unless token.is_a?(Token)

      push_token_buffer unless buffer_valid?
      buffer[buffer_index] << token
    end

    def any?
      return false unless buffer_valid?

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
      buffer_valid? ? buffer[buffer_index].buffer.clone.freeze : []
    end

    def empty?
      !any?
    end

    # Returns the buffer as a string. All tokens are suffixed with a space
    # with the exception of the raw token type which removes any preceeding
    # single space character before it.
    def to_s
      results = buffer.each_with_index do |token_buffer, buffer_index|
        results = token_buffer.buffer.map.with_index do |token, token_index|
          token_value_for(token, buffer_index, token_index)
        end
        results.join
      end
      results.join
    end

    # Updates all tokens in the buffer with the given vars and labels.
    def update!(vars, labels)
      buffer.each { |buffer| update_buffer(vars, labels, buffer) }
      buffer.clone.freeze
    end

    # Updates only the tokens in the current buffer with the given vars and labels.
    def update_current!(vars, labels)
      update_buffer(vars, labels, current_buffer)
    end

    protected

    attr_accessor :buffer
    attr_writer :buffer_index

    def buffer_valid?
      buffer_index >= 0
    end

    def find(token, buffer)
      buffer.select { |buffer_token| buffer_token == token }
    end

    def previous_token(buffer_index, token_index)
      # rubocop:disable Metrics/LineLength
      previous_buffer_indicies(buffer_index, token_index) do |prev_buffer_index, prev_token_index|
        return buffer[prev_buffer_index][prev_token_index]
      end
      # rubocop:enable Metrics/LineLength
      nil
    end

    def previous_buffer_indicies(buffer_index, token_index)
      # Return nil, nil, if we are at the begining of the first buffer; we
      # can't move back any further
      return if buffer_index.zero? && token_index.zero?

      # If our prev_token_index is >= zero, we know we can find a previous
      # token within the same buffer; simply return the current buffer_index
      # and the prev_token_index
      if token_index - 1 >= 0
        yield buffer_index, token_index - 1
        return
      end
      # If we get here, we know that token_index is equal to 0, so we know that
      # the previous token_index would be equal to -1. This means we need to
      # traverse backwards to the prevoius buffer, and send the token_index of
      # the last token in the previous buffer.
      # binding.pry if buffer_index == 2 && token_index == 0
      buffer_index -= 1
      yield buffer_index, buffer[buffer_index].length - 1
    end

    def push_token_buffer
      self.buffer ||= []
      self.buffer << TokenBuffer.new
      update_buffer_index
    end

    def token_value_for(token, buffer_index, token_index)
      return token.value(space: :none) if token_index.zero?

      previous_token = previous_token(buffer_index, token_index)
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

    # points to the active buffer
    def update_buffer_index
      self.buffer_index = buffer.length - 1
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
