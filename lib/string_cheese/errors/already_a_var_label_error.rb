# frozen_string_literal: true

module StringCheese
  class AlreadyAVarLabelError < StandardError
    attr_accessor :var

    def initialize(var = nil)
      self.var = var
      super(var.nil? ? 'already a var label' : "Var [#{var}] is already a var label")
    end
  end
end
