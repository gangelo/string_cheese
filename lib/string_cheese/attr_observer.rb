# frozen_string_literal: true

require_relative 'types/action_type'

module StringCheese
  module AttrObserver
    def after_attr_reader_action(method, action_type, *values)
      puts "after attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      # If the reader value is being read, return self so that we can continue
      # any chaining that is going on. Any other action, simply return the
      # value.
      action_type == ActionType::ATTR_READ ? self : values
    end

    def after_attr_writer_action(method, action_type, *values)
      puts "after attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      # If the writer value is being written, return the value; otherwise,
      # return self so that we can continue any chaining that is going on.
      action_type == ActionType::ATTR_WRITE ? values[0] : self
    end

    def before_attr_reader_action(method, action_type, *values)
      puts "before attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      self
    end

    def before_attr_writer_action(method, action_type, *values)
      puts "before attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      self
    end
  end
end
