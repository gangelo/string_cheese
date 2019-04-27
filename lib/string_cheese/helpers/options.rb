require_relative '../digs'

module StringCheese
  module Helpers
    module Options
      module_function

      def extend_options(options)
        return options if options.is_a?(Digs::Options)
        options.extend(Digs::Options)
      end
    end
  end
end
