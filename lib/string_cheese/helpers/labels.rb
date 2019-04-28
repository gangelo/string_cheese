# frozen_string_literal: true

require_relative '../labels'

module StringCheese
  module Helpers
    module Labels
      module_function

      def ensure_labels(labels)
        labels || {}
      end

      def extend_labels(labels)
        labels = ensure_labels(labels)
        return labels if labels.is_a?(StringCheese::Labels)

        labels.extend(StringCheese::Labels)
      end
    end
  end
end
