module StringCheese
  module Labels

    module_function

    def label?(var)
      /_label\b/ =~ var ? true : false
    end

    def label_exists?(label, vars)
      vars.key?(label)
    end

    def label_for(var)
      return nil if label?(var)
      :"#{var}_label"
    end

    def labels(vars)
      vars.select { |key, _value| label?(key) }
    end

    # Creates labels for the variables
    def labels_create(vars)
      vars.keys.each_with_object({}) do |var, hash|
        if label = label_for(var)
          next if label_exists?(label, vars)
          hash[label] = var
        end
      end
    end

    def labels_merge(vars, labels)
      labels.merge(vars)
    end
  end
end