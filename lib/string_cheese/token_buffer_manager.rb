# frozen_string_literal: true

require_relative 'helpers/attrs'
require_relative 'token_buffer'

module StringCheese
  class TokenBufferManager
    include Helpers::Attrs

    attr_reader :buffer_index

    def initialize
      initialize_buffer
    end

    def <<(token)
      raise ArgumentError, 'Param [token] is not a Token' unless token.is_a?(Token)

      push_buffer unless buffer_valid?
      buffer[buffer_index] << token
    end

    def any?
      return false unless buffer_valid?

      buffer.any?
    end

    # Returns the buffer, an Array of TokenBuffers
    def buffer
      @buffer
    end

    # Clears the buffer
    def clear_buffer
      self.buffer = []
      update_buffer_index
    end

    alias initialize_buffer clear_buffer

    # Returns the buffer pointed to by #buffer_index
    def current_buffer
      buffer_valid? ? buffer[buffer_index].clone.freeze : []
    end

    def empty?
      !any?
    end

    # Saves the current buffer and pushes a new TokeBuffer onto the buffer stack
    def save_buffer
      push_buffer(TokenBuffer.new)
    end

    # Updates all tokens in the buffer with the given vars and labels.
    def update!(attrs)
      vars, labels = select_vars_and_label_attrs(attrs)
      buffer.each { |buffer| update_buffer(vars, labels, buffer) }
      buffer.clone.freeze
    end

    # Updates only the tokens in the current buffer with the given vars and labels.
    def update_current!(attrs)
      vars, labels = select_vars_and_label_attrs(attrs)
      update_buffer(vars, labels, current_buffer)
    end

    protected

    attr_writer :buffer
    attr_writer :buffer_index

    def buffer_valid?
      buffer_index >= 0
    end

    def find(token, buffer)
      buffer.select { |buffer_token| buffer_token == token }
    end

    # Pushes a <token_buffer> or a new TokenBuffer onto the buffer stack if
    # <token_buffer> is nil. The buffer index is returned.
    def push_buffer(token_buffer = nil)
      self.buffer ||= []
      self.buffer << (token_buffer || TokenBuffer.new)
      update_buffer_index
    end

    def select_vars_and_label_attrs(attrs)
      [select_var_attrs(attrs), select_label_attrs(attrs)]
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
