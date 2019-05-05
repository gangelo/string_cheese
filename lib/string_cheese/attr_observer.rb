# frozen_string_literal: true

require_relative 'helpers/options_exist'
require_relative 'types/action_type'

module StringCheese
  # Provides callback methods for attribute observers
  module AttrObserver
    include Helpers::OptionsExist

    # Observer update method called after an attr_reader action takes place
    def after_attr_reader_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "after attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      # If the reader value is being read, return self so that we can continue
      # any chaining that is going on. Any other action, simply return the
      # value.
      action_type == ActionType::ATTR_READ ? self : values
    end

    # Observer update method called after an attr_writer action takes place
    def after_attr_writer_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "after attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      # If the writer value is being written, return the value; otherwise,
      # return self so that we can continue any chaining that is going on.
      action_type == ActionType::ATTR_WRITE ? values[0] : self
    end

    # Observer update method called before an attr_reader action is to take
    # place
    def before_attr_reader_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "before attr_reader action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      self
    end

    # Observer update method called before an attr_writer action is to take
    # place
    def before_attr_writer_action(method, action_type, *values)
      if options_exist? && current_options.debug?
        puts "before attr_writer action method: :#{method}, action: #{action_type}, values: #{values}"
      end
      self
    end
  end
end
