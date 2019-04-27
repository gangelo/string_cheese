module StringCheese
  module Digs
    module Options
      def debug?
        fetch(:debug, false)
      end

      def labels?
        fetch(:labels, false)
      end

      def linter?
        fetch(:linter, false)
      end

      def replace_vars?
        fetch(:replace_vars, true)
      end
    end
  end
end
