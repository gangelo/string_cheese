require_relative '../digs'

module StringCheese
  module Helpers
    module Labels
      module_function

      def extend_labels(labels)
        return labels if labels.is_a?(Digs::Labels)
        labels.extend(Digs::Labels)
      end
    end
  end
end
