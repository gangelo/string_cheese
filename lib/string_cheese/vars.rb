require_relative 'helpers'

module StringCheese
  module Vars
    Options = StringCheese::Helpers::Options
    Labels = StringCheese::Labels

    module_function

    def vars(vars)
      vars.select { |key, _value| !Labels.label?(key) }
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
      return vars, labels
    end
  end
end
