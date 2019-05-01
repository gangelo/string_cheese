module StringCheese
  module Helpers
    module Attrs

      module_function

      #
      # Generic idenification

      def attr_reader?(method)
        method = method.to_s
        method =~ /[\w!?=]+[^=]\z/
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
        "#{method}_label"
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
