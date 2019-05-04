# frozen_string_literal: true

require_relative 'options'

module StringCheese
  class TokenBufferFormatter
    include Options

    def initialize(token_buffer_manager, options = {})
      raise ArgumentError, 'Param [token_buffer_manager] cannot be nil' \
        if token_buffer_manager.nil?

      self.options = extend_options(ensure_options_with_defaults(options))
      self.token_buffer_manager = token_buffer_manager
    end

    # Returns the buffer as a string. All tokens are suffixed with a space
    # with the exception of the raw token type which removes any preceeding
    # single space character before it.
    def to_s
      # results = buffer.each_with_index do |token_buffer, buffer_index|
      #   results = token_buffer.map.with_index do |token, token_index|
      #     token_value_for(token, buffer_index, token_index)
      #   end
      #   results.join
      # end
      # results.join
      buffer.each_with_index.map do |token_buffer, buffer_index|
        token_buffer.map.with_index do |token, token_index|
          token_value_for(token, buffer_index, token_index)
        end.join
      end.join
    end

    protected

    attr_accessor :options
    attr_accessor :token_buffer_manager

    def buffer
      token_buffer_manager.buffer
    end

    def indicies_valid?(buffer_index, token_index)
      return false if buffer_index < 0 || token_index < 0
      return false if buffer.nil? || buffer.empty?
      return false unless buffer_index < buffer.length

      token_index < buffer[buffer_index].length
    end

    def previous_token(buffer_index, token_index)
      return nil unless indicies_valid?(buffer_index, token_index)

      # rubocop:disable Metrics/LineLength
      previous_buffer_indicies(buffer_index, token_index) do |prev_buffer_index, prev_token_index|
        return buffer[prev_buffer_index][prev_token_index]
      end
      # rubocop:enable Metrics/LineLength
      nil
    end

    def previous_buffer_indicies(buffer_index, token_index)
      # Do not yield, if we are at the begining of the first buffer; we
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
      # traverse backwards to the previous buffer, and send the token_index of
      # the last token in the previous buffer.
      buffer_index -= 1
      yield buffer_index, buffer[buffer_index].length - 1
    end

    def token_value_for(token, buffer_index, token_index)
      return token.value(space: :none) if buffer_index.zero? && token_index.zero?

      previous_token = previous_token(buffer_index, token_index)
      return token.value(space: :none) if previous_token.raw?

      token.raw? ? token.value(space: :none) : token.value(space: :before)
    end
  end
end
