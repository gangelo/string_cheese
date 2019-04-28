# frozen_string_literal: true

module StringCheese
  module Vars
    Options = StringCheese::Options
    Labels = StringCheese::Labels

    def extract_labels!(options = { labels: true })
      Vars.send(:extract_labels, self, options)
    end

    module_function

    def ensure_vars(vars)
      vars || {}
    end

    # Splits up vars and labels into separate Hashes.
    # If the labels option is true (labels: true),
    # any var that does not have a label (<var>_label)
    # will have one automatically created. If the
    # labels option is false, only labels currently
    # in the vars Hash will be used.
    def extract_labels(vars, options = { labels: true })
      Options.extend_options(options)
      labels = vars.dup.each_pair.each_with_object({}) do |key_value_pair, hash|
        key, value = key_value_pair
        if Labels.label?(key)
          hash[key] = value
          vars.delete(key)
        elsif options.labels?
          label = Labels.label_for(key)
          hash[label] = key
        end
      end
      [vars, labels]
    end

    def extend_vars(vars)
      vars = ensure_vars(vars)
      return vars if vars.is_a?(StringCheese::Vars)

      vars.extend(StringCheese::Vars)
    end
  end
end
