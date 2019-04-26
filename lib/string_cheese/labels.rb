module StringCheese
  module Labels

    module_function

    # Creates labels for the variables
    def create_labels(vars)
      vars.keys.each_with_object({}) do |key, hash|
        var_label = :"#{key}_label"
        next if label?(key) || label_exists?(var_label, vars)
        hash[var_label] = key
      end
    end

    def label_exists?(var_label, vars)
      vars.key?(var_label)
    end

    def label?(var)
      /_label\b/ =~ var ? true : false
    end

    def merge_labels(vars, var_labels)
      var_labels.merge(vars)
    end
  end
end
