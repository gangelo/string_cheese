module StringCheese
  module VarLabels

    module_function

    def var_label?(var)
      /_label\b/ =~ var ? true : false
    end

    # Creates labels for the variables
    def var_labels_create(vars)
      vars.keys.each_with_object({}) do |var, hash|
        if var_label = var_label_for(var)
          next if var_label_exists?(var_label, vars)
          hash[var_label] = var
        end
      end
    end

    def var_label_exists?(var_label, vars)
      vars.key?(var_label)
    end

    def var_label_for(var)
      return nil if var_label?(var)
      :"#{var}_label"
    end

    def var_labels_merge(vars, var_labels)
      var_labels.merge(vars)
    end
  end
end
