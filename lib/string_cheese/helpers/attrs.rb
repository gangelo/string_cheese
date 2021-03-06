# frozen_string_literal: true

module StringCheese
  module Helpers
    # Provides a set of methods to allow for identification of attribute
    # types (i.e. readers, writers labels, vars, etc.) and conversion of one
    # attribute type to another
    module Attrs

      # Returns true if <method> has an associated attr_accessor sybling
      # method defined on the receiver.
      #
      # @param method [Symbol] the method whose sybling is to be returned.
      #
      # @return [Boolean] whether or not the sybing method is defined.
      #
      # @example
      #
      # class Klass
      #   include StringCheese::Helpers::Attrs
      #
      #   attr_reader :test_1
      #   attr_writer :test_2
      #   attr_accessor :test_3
      # end
      #
      # klass = Klass.new
      # klass.attr_accessor_sybling?(:test_1) # => false
      # klass.attr_accessor_sybling?(:test_2) # => false
      # klass.attr_accessor_sybling?(:test_3) # => true
      # klass.attr_accessor_sybling?(:test_3) # => true
      #
      def attr_accessor_sybling?(method)
        attr_accessor_sybling = attr_reader?(method) ? to_attr_writer(method) \
                                                     : to_attr_reader(method)
        respond_to?(attr_accessor_sybling)
      end

      module_function

      #
      # Generic idenification

      def attr_reader?(method)
        method = method.to_s
        method =~ /[\w!?=]+[^=]\z/
      end

      # Returns the name of the attr_accessor sybling method associated with
      # <method>. Neither <method> nor <sybling> are checked to ensure they are
      # defined on the receiver.
      #
      # @param method [Symbol] the method whose sybling is to be returned.
      #
      # @return [Symbol] the sybling method.
      #
      # @example
      #
      # Attrs.attr_accessor_sybling(:test=) # => :test
      # Attrs.attr_accessor_sybling(:test) # => :test=
      #
      def attr_accessor_sybling(method)
        attr_reader?(method) ? to_attr_writer(method) : to_attr_reader(method)
      end

      def attr_writer?(method)
        method = method.to_s
        method =~ /[\w!?=]+[^!?=]={1}\z/
      end

      #
      # Label identification

      def label_attr_reader?(method)
        method = method.to_s
        method =~ /[\w!?=]+_label\z/
      end

      def label_attr_writer?(method)
        method = method.to_s
        method =~ /[\w!?=]+_label=\z/
      end

      #
      # Selection

      # Use this method to select label attribute keys from the given Hash.
      #
      # For example, given the following Hash:
      #
      # { var_1: 1, var_2: 2,
      #   var_1_label: :var_1,
      #   var_2_label: 'Custom Var 2 Label' }
      #
      # The following would be returned:
      #
      # { var_1_label: :var_1,
      #   var_2_label: 'Custom Var 2 Label' }
      #
      def select_label_attrs(method_value_pairs)
        raise ArgumentError, 'Param [method_value_pairs] does not respond_to? :to_h' \
          unless method_value_pairs.respond_to?(:to_h)

        method_value_pairs = method_value_pairs.to_h unless method_value_pairs.is_a?(Hash)
        method_value_pairs.each_with_object({}) do |(key, value), hash|
          hash[key] = value if label_attr_reader?(key)
        end
      end

      # Use this method to select var attribute keys from the given Hash.
      #
      # For example, given the following Hash:
      #
      # { var_1: 1, var_2: 2,
      #   var_1_label: :var_1,
      #   var_2_label: 'Custom Var 2 Label' }
      #
      # The following would be returned:
      #
      # { var_1: 1,
      #   var_2: 2 }
      #
      def select_var_attrs(method_value_pairs)
        raise ArgumentError, 'Param [method_value_pairs] does not respond_to? :to_h' \
          unless method_value_pairs.respond_to?(:to_h)

        method_value_pairs = method_value_pairs.to_h unless method_value_pairs.is_a?(Hash)
        method_value_pairs.each_with_object({}) do |(key, value), hash|
          hash[key] = value if var_attr_reader?(key)
        end
      end

      #
      # Conversion

      def to_attr_reader(method)
        return method if attr_reader?(method)

        method.to_s[0...-1].to_sym
      end

      def to_attr_writer(method)
        return method if attr_writer?(method)

        :"#{method}="
      end

      def to_label_attr_reader(method)
        method = to_attr_reader(method)
        :"#{method}_label"
      end

      # Returns a Hash of label attr readers for the given var attr readers.
      # This method WILL NOT WORK correctly if anything other than label
      # attr reader keys are passed.
      def to_label_attr_readers(var_attr_method_value_pairs)
        var_attr_method_value_pairs.each_with_object({}) do |(key, _value), hash|
          hash[to_label_attr_reader(key)] = key
        end
      end

      #
      # Var identification

      def var_attr_reader?(method)
        method = method.to_s
        attr_reader?(method) && !label_attr_reader?(method)
      end

      def var_attr_writer?(method)
        method = method.to_s
        attr_writer?(method) && !label_attr_writer?(method)
      end
    end
  end
end
