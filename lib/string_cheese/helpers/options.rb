require_relative '../digs'

module StringCheese
  module Helpers
    module Options
      module_function

      def default_options
        { debug: false, labels: true, linter: false }
      end

      def ensure_options(options)
        options || {}
      end

      def ensure_options_with(options, with)
        options = ensure_options(options)
        options.merge(with)
      end

      def ensure_options_with_defaults(options)
        options = ensure_options(options)
        default_options.merge(options)
      end

      def extend_options(options)
        options = ensure_options(options)
        return options if options.is_a?(Digs::Options)
        options.extend(Digs::Options)
      end
    end
  end
end