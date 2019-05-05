# frozen_string_literal: true

require 'ostruct'
require_relative 'attr_observer'
require_relative 'helpers/attrs'
require_relative 'helpers/Hash'
require_relative 'types/action_type'

module StringCheese
  # Provides functionality and management of dynamically created attributes
  # (methods). Attributes are created and added to the current receiver and
  # recorded in required attribute data repository called
  # #data_repository.attr_data.
  module AttrManager
    include AttrObserver
    include Helpers::Attrs
    include Helpers::Hash

    def initialize(attrs, _options = {})
      # Check for #data_repository and #data_repository.attr_data
      raise "[#{self.class.name}] must define #data_repository" unless respond_to?(:data_repository)
      raise "[#{self.class.name}] must define #data_repository.attr_data" unless data_repository.respond_to?(:attr_data)
      raise "[#{self.class.name}] must define callback method #after_attr_reader_action" \
        unless respond_to?(:after_attr_reader_action)
      raise "[#{self.class.name}] must define callback method #after_attr_writer_action" \
        unless respond_to?(:after_attr_writer_action)
      raise "[#{self.class.name}] must define callback method #before_attr_reader_action" \
        unless respond_to?(:before_attr_reader_action)
      raise "[#{self.class.name}] must define callback method #before_attr_writer_action" \
        unless respond_to?(:before_attr_writer_action)

      data_repository.attr_data = OpenStruct.new
      attrs = ensure_hash(attrs)
      var_attrs = select_var_attrs(attrs)
      define_attr_accessors(var_attrs)
      # Create our label attrs first, this allows any <var>_label named attrs
      # to exist before we attempt to create attr labels from the var attrs.
      # This will allow label attrs explicitly passed to use to be used, rather
      # than the auto-generated label attrs created in the next call to
      # define_attr_accessors.
      define_attr_accessors(select_label_attrs(attrs)) # if options.labels?
      define_attr_accessors(to_label_attr_readers(var_attrs)) # if options.labels?
    end

    # Defines the equivalent of attr_accessor for the given method and assigns
    # the value of <value> to the attribute
    def define_attr_accessor(method, value = nil)
      define_attr_reader(to_attr_reader(method), value)
      define_attr_writer(to_attr_writer(method))
    end

    # Defines attr_accessors for the given key/value pairs passed as an Array
    def define_attr_accessors(method_value_pairs)
      method_value_pairs.each_pair do |method, value|
        define_attr_accessor(method, value)
      end
    end

    def define_attr_reader(method, value)
      raise ArgumentError, "Param [method] is not an attr_reader (#{method})" \
        unless attr_reader?(method)
      return if data_repository.attr_data.respond_to?(method)

      data_repository.attr_data[method] = value
      before_attr_reader_action(method, ActionType::ATTR_ADD, value)
      define_singleton_method(method) do |*_args|
        before_attr_reader_action(method, ActionType::ATTR_READ, value)
        value = data_repository.attr_data[method]
        after_attr_reader_action(method, ActionType::ATTR_READ, value)
      end
      after_attr_reader_action(method, ActionType::ATTR_ADD, value)
    end

    def define_attr_writer(method)
      raise ArgumentError, "Param [method] is not an attr_writer (#{method})" \
        unless attr_writer?(method)
      # Note: the below guard will always return true if an attr_reader
      # already exists. This is because when adding a symbol to an OpenStruct,
      # the attr_writer is already created. Since we must add our attr_writer
      # to the current class, do not check the OpenStruct (data_repository.attr_data)
      # for respond_to?; rather, check at the class level.
      # return if data_repository.attr_data.respond_to?(method)
      return if respond_to?(method)

      before_attr_writer_action(method, ActionType::ATTR_ADD)
      define_singleton_method(method) do |*args|
        method = to_attr_reader(method)
        before_attr_writer_action(method, ActionType::ATTR_WRITE, data_repository.attr_data[method])
        value = data_repository.attr_data[method] = args[0]
        after_attr_writer_action(method, ActionType::ATTR_WRITE, value)
      end
      after_attr_writer_action(method, ActionType::ATTR_ADD)
    end

    # def respond_to?(symbol)
    # end

    # def respond_to_missing?(method, include_private = false)
    #  data_repository.attr_data.respond_to?(method) || super
    # end

    protected :after_attr_reader_action, \
              :after_attr_writer_action, \
              :before_attr_reader_action, \
              :before_attr_writer_action, \
              :define_attr_reader, :define_attr_writer
  end
end
