# frozen_string_literal: true

require_relative 'attr_manager'
require_relative 'errors/invalid_token_option_error'
require_relative 'helpers/attrs'
require_relative 'options'
require_relative 'token_buffer_formatter'
require_relative 'token_buffer_manager'
require_relative 'types/action_type'
require_relative 'label_token'
require_relative 'raw_token'
require_relative 'text_token'
require_relative 'var_token'

module StringCheese
  # The class that provides the main functionality: managing attributes (vars
  # and labels) and their values, as well as providing the formatted results
  class Engine
    include AttrManager
    include Helpers::Attrs
    include Options

    attr_reader :data_repository

    def initialize(attrs, options = {})
      options = ensure_options_with_defaults(options)
      self.data_repository = OpenStruct.new(buffer_manager: TokenBufferManager.new,
                                            attr_data: nil,
                                            options: {})
      data_repository.options = extend_options(options)
      unless data_repository.options.linter?
        define_singleton_method(:method_missing) do |method, *args|
          if attr_writer?(method)
            define_attr_accessor(method, args[0])
            define_attr_accessor(to_label_attr_reader(method), to_attr_reader(method))
          else
            raise ArgumentError, wrong_number_of_arguments_error(method, args.count, 1) unless args.empty? || args.count == 1

            option = args.any? ? args[0].to_sym : :nop
            data_repository.buffer_manager << TextToken.new(apply(option, method.to_s.tr('_', ' ')))
          end
          self
        end
      end
      super
    end

    def after_attr_reader_action(method, action_type, *values)
      if action_type == ActionType::ATTR_READ
        value = values.pop
        token = label_attr_reader?(method) ? LabelToken.new(method, value) \
                                           : VarToken.new(method, value)
        data_repository.buffer_manager << token
      end
      super
    end

    def after_attr_writer_action(method, action_type, *values)
      # TODO: Handle AttrType::ATTR_REMOVE || AttrType::ATTR_CHANGE
      super
    end

    def before_attr_reader_action(method, action_type, *values)
      yield true if block_given?
      super
    end

    def before_attr_writer_action(method, action_type, *values)
      yield true if block_given?
      super
    end

    def method_to_text(method)
      method.to_s.tr('_', ' ')
    end

    def raw(text)
      data_repository.buffer_manager << RawToken.new(text)
      self
    end

    def reset
      data_repository.buffer_manager.reset_buffer
    end

    # def respond_to?(symbol)
    #   if data_repository.vars.key?(symbol) || data_repository.labels.key?(symbol)
    #     return true
    #   else
    #     super
    #   end
    #   super
    # end

    # def respond_to_missing?(method_name, include_private = false)
    #  method_name.to_s.start_with?('user_') || super
    # end

    def to_s(options = {})
      return '' if data_repository.buffer_manager.empty?

      # TODO: implement these options e.g. debug?
      options = extend_options(ensure_options_with(data_repository.options, options))
      data_repository.buffer_manager.update_current!(data_repository.attr_data)
      TokenBufferFormatter.new(data_repository.buffer_manager).to_s
    end

    protected

    attr_writer :data_repository

    def apply(option, text)
      return text if option == :nop
      raise InvalidTokenOptionError(option, text) unless text.respond_to?(option)

      # TODO: Check against whitelist?
      text.send(option)
    end

    def wrong_number_of_arguments_error(method, actual_count, expected_count)
      "from string_cheese :) wrong number of arguments calling '#{method}' " \
        "(#{actual_count} for #{expected_count})"
    end
  end
end
