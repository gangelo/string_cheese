module StringCheese
  module Helpers
    module Attrs

      module_function

      def attr_reader?(method)
        method = method.to_s
        method =~ /[\w!?=]+[^=]\z/
      end

      def attr_writer?(method)
        method = method.to_s
        method =~ /[\w!?=]+[^!?=]={1}\z/
      end

      def label_attr_reader?(method)
        method = method.to_s
        method =~ /[\w!?=]+_label\z/
      end

      def label_attr_writer?(method)
        method = method.to_s
        method =~ /[\w!?=]+_label=\z/
      end

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
        var_attr_method_value_pairs.each_with_object({}) do |(key, value), hash|
          hash[to_label_attr_reader(key)] = key
        end
      end

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
