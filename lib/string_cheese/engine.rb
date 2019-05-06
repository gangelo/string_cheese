# frozen_string_literal: true

require 'ostruct'

#require_relative 'attr_manager'
require_relative 'errors/cant_touch_this_error'
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
    #include AttrManager
    include Helpers::Attrs
    include Options

    attr_reader :data_repository

    def initialize(attrs, options = {})
      options = ensure_options_with_defaults(options)

      self.data_repository = OpenStruct.new

      # Create our label attrs first so that they won't get overwritten in
      # the subsequent step when we auto-create label attrs for var attrs...
      select_label_attrs(attrs).each_pair { |attr, value| new_attr_accessor!(attr, value) }
      select_var_attrs(attrs).each_pair do |attr, value|
        new_attr_accessor!(attr, value)
        # Creates a label for the above var attr just created
        new_attr_accessor!(to_label_attr_reader(attr), attr)
      end

      self.data_repository.buffer_manager = TokenBufferManager.new
      self.data_repository.attr_data = nil
      self.data_repository.options = {}
      data_repository.options = extend_options(options)
    end

    def clear
      modifiable?[:buffer_manager].clear_buffer
    end

    def update_attr(name, value)
      token = label_attr_reader?(name) ? LabelToken.new(name, value) \
                                       : VarToken.new(name, value)
      modifiable?[:buffer_manager] << token
    end

    def new_attr_accessor!(name, value = nil)
      name = name.to_sym
      unless singleton_class.method_defined?(name)
        define_singleton_method(name) do
          update_attr(name, @data_repository[name])
          self
        end
        define_singleton_method("#{name}=") do |value|
          modifiable?[name] = value
          update_attr(name, value)
        end
        modifiable?[name] = value
      end
      name
    end
    private :new_attr_accessor!

    def modifiable?
      begin
        @modifiable = true
      rescue
        exception_class = defined?(FrozenError) ? FrozenError : RuntimeError
        raise exception_class, "can't modify frozen #{self.class}", caller(3)
      end
      @data_repository
    end
    private :modifiable?

    alias modifiable modifiable?
    protected :modifiable

    def respond_to_missing?(mid, include_private = false)
      mname = mid.to_s.chomp('=').to_sym
      @data_repository.respond_to?(mname) || super
    end

    def method_missing(mid, *args)
      len = args.length
      if mname = mid[/.*(?==\z)/m]
        mname = mname.to_sym
        # Code to add attrs...
        # This code adds attrs if the method encountered is an attr_writer
        if len != 1
          raise ArgumentError, "wrong number of arguments (#{len} for 1)", caller(1)
        end
        modifiable?[new_attr_accessor!(mname)] = args[0]
        modifiable?[new_attr_accessor!(to_label_attr_reader(mname))] = mname \
          unless label_attr_reader?(mname)
      elsif len == 0 # and /\A[a-z_]\w*\z/ =~ mid #
        if @data_repository.respond_to?(mid)
          new_attr_accessor!(mid) unless frozen?
          # gma @data_repository[mid]
        else
          # This code handles any attr_reader methods that are not defined, and
          # will be treated as text; for example, :Hello_World # => Hello World
          raise ArgumentError, wrong_number_of_arguments_error(mid, args.count, 1) unless args.empty? || args.count == 1

          option = args.any? ? args[0].to_sym : :nop
          modifiable?[:buffer_manager] << TextToken.new(apply(option, mid.to_s.tr('_', ' ')))
        end
        # Return self for chaining
        self
      else
        begin
          super
        rescue NoMethodError => err
          err.backtrace.shift
          raise
        end
      end
    end

    # def after_attr_reader_action(method, action_type, *values)
    #   if action_type == ActionType::ATTR_READ
    #     value = values.pop
    #     token = label_attr_reader?(method) ? LabelToken.new(method, value) \
    #                                        : VarToken.new(method, value)
    #     data_repository.buffer_manager << token
    #   end
    #   super
    # end

    # def after_attr_writer_action(method, action_type, *values)
    #   # TODO: Handle AttrType::ATTR_REMOVE || AttrType::ATTR_CHANGE
    #   super
    # end

    # def before_attr_reader_action(method, action_type, *values)
    #   yield if block_given?
    #   super
    # end

    # def before_attr_writer_action(method, action_type, *values)
    #   #if self.__reserved__.respond_to?(method)
    #   #  action_type & (ActionType::ATTR_ADD | ActionType::ATTR_CHANGE)
    #   #end
    #   yield if block_given?
    #   super
    # end

    def method_to_text(method)
      method.to_s.tr('_', ' ')
    end

    def raw(text)
      modifiable?[:buffer_manager] << RawToken.new(text)
      self
    end

    # def respond_to?(symbol)
    #   self.__reserved__.include?(symbol) || super
    # #   if data_repository.vars.key?(symbol) || data_repository.labels.key?(symbol)
    # #     return true
    # #   else
    # #     super
    # #   end
    # #   super
    # end

    # def respond_to_missing?(method, include_private = false)
    #   !self.__reserved__.include?(method) || super
    # #  method.to_s.start_with?('user_') || super
    # end

    def to_s(options = {})
      return '' if data_repository.buffer_manager.empty?

      # TODO: implement these options e.g. debug?
      options = extend_options(ensure_options_with(data_repository.options, options))
      attr_data = data_repository.to_h.select do |key, _value|
        key != :buffer_manager && key != :options && key != :attr_data
      end
      data_repository.buffer_manager.update_current!(attr_data)
      #data_repository.buffer_manager.update_current!(data_repository.attr_data)
      TokenBufferFormatter.new(data_repository.buffer_manager).to_s
    end

    protected

    # attr_accessor :__reserved__
    # attr_accessor :__skip_method_missing__
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
