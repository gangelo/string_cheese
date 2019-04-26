require 'string_cheese/version'
require 'string_cheese/engine'
require 'string_cheese/labels'

module StringCheese
  extend Labels

  def self.create(vars, options = {})
    var_labels = create_labels(vars)
    create_engine(merge_labels(vars, var_labels), options)
  end

  def self.create_engine(vars, options = {})
    Engine.new(OpenStruct.new(vars), options)
  end

  private_class_method :create_engine
end
