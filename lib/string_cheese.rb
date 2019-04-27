require 'string_cheese/version'
require 'string_cheese/engine'
#require 'string_cheese/labels'

module StringCheese
  extend Labels

  def self.create(vars, options = {})
    #labels = labels_create(vars)
    #create_engine(labels_merge(vars, labels), options)
    create_engine(vars, options)
  end

  def self.create_engine(vars, options = {})
    #Engine.new(OpenStruct.new(vars), options)
    Engine.new(vars, options)
  end

  private_class_method :create_engine
end
