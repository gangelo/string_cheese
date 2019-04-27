require_relative '../digs'

module StringCheese
  module Helpers
    module Vars
      module_function

      def ensure_vars(vars)
        vars || {}
      end

      def extend_vars(vars)
        vars = ensure_vars(vars)
        return vars if vars.is_a?(Digs::Vars)
        vars.extend(Digs::Vars)
      end
    end
  end
end
