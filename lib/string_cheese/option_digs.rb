# frozen_string_literal: true

module StringCheese
  module OptionDigs
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
