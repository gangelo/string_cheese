# frozen_string_literal: true

module StringCheese
  module Helpers
    # Provides methods for manipulating Hash objects
    module Hash
      module_function

      def ensure_hash(object)
        raise ArgumentError, 'Param [object] does not respond_to? #to_h' \
          unless object.respond_to?(:to_h)

        object.is_a?(Hash) ? object : object.to_h
      end
    end
  end
end
