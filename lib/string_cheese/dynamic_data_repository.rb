require 'ostruct'
require_relative 'helpers/attrs'
require_relative 'helpers/Hash'
require_relative 'types/action_type'

module StringCheese
  module DynamicDataRepository
    include StringCheese::Helpers::Attrs
    include StringCheese::Helpers::Hash

    def initialize(attrs, options = {})
      self.data_repository = OpenStruct.new
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
      add_observer(self)
    end

    # Adds an observer to be notified whenever attribute actions occur
    def add_observer(subscriber)
      observers << subscriber
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

    # Use this method to select label attribute keys from the given Hash
    def select_label_attrs(method_value_pairs)
      method_value_pairs.each_with_object({}) do |(key, value), hash|
        hash[key] = value if label_attr_reader?(key)
      end
    end

    # Use this method to select var attribute keys from the given Hash
    def select_var_attrs(method_value_pairs)
      method_value_pairs.each_with_object({}) do |(key, value), hash|
        hash[key] = value if var_attr_reader?(key)
      end
    end

    # private_class_methods

     def attr_reader_callback(method, value)
      notify_observers(method, value, ActionType::READ)
    end

    def attr_writer_callback(method, value)
      notify_observers(method, value, ActionType::WRITE)
    end

    def data_repository=(value)
      @data_repository = value
    end

    def data_repository
      @data_repository
    end

    def define_attr_reader(method, value, &block)
      raise ArgumentError, "Param [method] is not an attr_reader (#{method})" \
        unless attr_reader?(method)
      return if data_repository.respond_to?(method)
      self.data_repository[method] = value
      define_singleton_method(method) do |*args|
        value = data_repository[method]
        attr_reader_callback(method, value)
      end
    end

    def define_attr_writer(method, &block)
      raise ArgumentError, "Param [method] is not an attr_writer (#{method})" \
        unless attr_writer?(method)
      return if data_repository.respond_to?(method)
      define_singleton_method(method) do |*args|
        method = to_attr_reader(method)
        value = data_repository[method] = args[0]
        attr_writer_callback(method, value)
      end
    end

    def notify_observers(method, value, action_type)
      observers.each do |observer|
        raise "Subscriber [#{observer.class.name}] must define callback method #attr_action" \
          unless observer.respond_to?(:attr_action)
        observer.attr_action(method, value, action_type)
      end
    end

    def observers
      @observers ||= []
    end

    #def respond_to_missing?(method, include_private = false)
    #  data_repository.respond_to?(method) || super
    #end
  end
end
