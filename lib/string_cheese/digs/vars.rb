require_relative '../vars'

module StringCheese
  module Digs
    module Vars
      extend StringCheese::Vars

      def extract_labels!(options = { labels: true })
        Vars.send(:extract_labels, self, options)
      end
    end
  end
end
