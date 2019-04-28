require 'string_cheese/token'

module StringCheese
  class Buffer
    attr_reader :buffer_index

    def initialize
      reset_buffer
    end

    def <<(token)
      raise ArgumentError unless token.is_a?(Token)
      self.buffer << token
    end

    def any?
      buffer.any?
    end

    def clear_buffer
      self.buffer = []
      update_buffer_index
    end

    alias_method :reset_buffer, :clear_buffer

    # Returns the portion of the buffer starting at the buffer element
    # pointed to by #buffer_index
    def current_buffer
      buffer.slice(buffer_index, buffer.length - buffer_index).clone
    end

    def empty?
      !any?
    end

    def to_s
      results = buffer.map do |token|
                  case
                  when token.raw?
                    "\b#{token.value}"
                  when token.var?
                    "[#{token.value}] "
                  else
                    "#{token.value} "
                  end
                end.join.strip
      results.gsub(/\s\x08/, '')
    end

    def update_current_buffer!(vars, labels)
      current_buffer.each do |token|
        next unless token.var? || token.label?
        token.var? ? update_var(token, current_buffer, vars) : update_label(token, current_buffer, labels)
      end
      update_buffer_index
      current_buffer
    end

    protected

    attr_accessor :buffer
    attr_writer :buffer_index

    def find(token, buffer)
      buffer.select { |buffer_token| buffer_token == token }
    end

    # Sets the buffer index beyond the end of the array.
    def update_buffer_index
      self.buffer_index =  buffer.length
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


