# frozen_string_literal: true

require_relative 'helpers/options_exist'
require_relative 'types/action_type'

module StringCheese
  module AttrObserver
    include Helpers::OptionsExist

    def after_attr_reader_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "after attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      # If the reader value is being read, return self so that we can continue
      # any chaining that is going on. Any other action, simply return the
      # value.
      action_type == ActionType::ATTR_READ ? self : values
    end

    def after_attr_writer_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "after attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      # If the writer value is being written, return the value; otherwise,
      # return self so that we can continue any chaining that is going on.
      action_type == ActionType::ATTR_WRITE ? values[0] : self
    end

    def before_attr_reader_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "before attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      self
    end

    def before_attr_writer_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "before attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      self
    end
  end
end
