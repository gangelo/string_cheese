# frozen_string_literal: true

module StringCheese
  module Options
    module Digs
      def debug?
        fetch(:debug, false)
      end

      def labels?
        fetch(:labels, false)
      end

      def linter?
        fetch(:linter, false)
      end
    end

    module_function

    def default_options
      { debug: false, labels: true, label_suffix: '_label', linter: false }
    end

    def ensure_options(options)
      options = options.clone unless options.nil?
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
      return options if options.is_a?(Digs)

      options.extend(Digs)
    end
  end
end
