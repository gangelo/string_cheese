# frozen_string_literal: true

require_relative 'option_digs'

module StringCheese
  module Options
    module_function

    def default_options
      { debug: false, labels: true, label_suffix: '_label', linter: false }
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
      return options if options.is_a?(OptionDigs)

      options.extend(OptionDigs)
    end
  end
end
