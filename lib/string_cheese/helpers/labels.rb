require_relative '../digs'

module StringCheese
  module Helpers
    module Labels
      module_function

      def ensure_labels(labels)
        labels || {}
      end

      def extend_labels(labels)
        labels = ensure_labels(labels)
        return labels if labels.is_a?(Digs::Labels)
        labels.extend(Digs::Labels)
      end
    end
  end
end
