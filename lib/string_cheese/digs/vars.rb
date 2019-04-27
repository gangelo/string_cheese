require_relative '../vars'

module StringCheese
  module Digs
    module Vars
      extend StringCheese::Vars

      def remove_and_return_labels(options = { labels: true })
        Vars.send(:remove_and_return_labels, self, options)
      end
    end
  end
end
