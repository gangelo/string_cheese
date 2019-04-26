require 'string_cheese/version'
require 'string_cheese/engine'
require 'string_cheese/var_labels'

module StringCheese
  extend VarLabels

  def self.create(vars, options = {})
    var_labels = var_labels_create(vars)
    create_engine(var_labels_merge(vars, var_labels), options)
  end

  def self.create_engine(vars, options = {})
    Engine.new(OpenStruct.new(vars), options)
  end

  private_class_method :create_engine
end
