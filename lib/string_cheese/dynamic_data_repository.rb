require 'ostruct'
require_relative 'helpers/attrs'
require_relative 'helpers/Hash'
require_relative 'types/action_type'

module StringCheese
  module DynamicDataRepository
    include StringCheese::Helpers::Attrs
    include StringCheese::Helpers::Hash

    attr_accessor :data_repository, :observer

    def initialize(attrs, options = {})
      add_observer(self)
      raise "[#{self.class.name}] must define callback method #attr_reader_action" \
        unless self.respond_to?(:attr_reader_action)
      raise "[#{self.class.name}] must define callback method #attr_writer_action" \
        unless self.respond_to?(:attr_writer_action)
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
    end

    # Adds an observer to be notified whenever attribute actions occur
    def add_observer(subscriber)
      self.observer = subscriber
    end

    # def data_repository=(value)
    #   @data_repository = value
    # end

    # def data_repository
    #   @data_repository
    # end

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

    def define_attr_reader(method, value, &block)
      raise ArgumentError, "Param [method] is not an attr_reader (#{method})" \
        unless attr_reader?(method)
      return if data_repository.respond_to?(method)
      data_repository[method] = value
      notify_observer(method, ActionType::ATTR_ADDED, value)
      define_singleton_method(method) do |*args|
        value = data_repository[method]
        notify_observer(method, ActionType::ATTR_READ, value)
      end
    end

    def define_attr_writer(method, &block)
      raise ArgumentError, "Param [method] is not an attr_writer (#{method})" \
        unless attr_writer?(method)
      # Note: the below guard will always return true if an attr_reader
      # already exists. This is because when adding a symbol to an OpenStruct,
      # the attr_writer is already created. Since we must add our attr_writer
      # to the current class, do not check the OpenStruct (data_repository)
      # for respond_to?; rather, check at the class level.
      # return if data_repository.respond_to?(method)
      return if respond_to?(method)
      notify_observer(method, ActionType::ATTR_ADDED)
      define_singleton_method(method) do |*args|
        method = to_attr_reader(method)
        value = data_repository[method] = args[0]
        notify_observer(method, ActionType::ATTR_WRITTEN, value)
      end
    end

    def notify_observer(method, action_type, *values)
      if attr_writer?(method)
        observer.attr_writer_action(method, action_type, *values)
      else
        observer.attr_reader_action(method, action_type, *values)
      end
    end

    #def respond_to?(symbol)
    #end

    #def respond_to_missing?(method, include_private = false)
    #  data_repository.respond_to?(method) || super
    #end

    protected :add_observer, :data_repository, :data_repository=, \
                         :define_attr_reader, :define_attr_writer, \
                         :notify_observer, :observer, :observer=
  end
end
