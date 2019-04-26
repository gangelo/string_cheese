require 'string_cheese/version'
require 'string_cheese/text'

module StringCheese
  def self.create(vars, options = {})
    var_labels = create_labels(vars)
    create_engine(merge_labels(vars, var_labels), options)
  end

  def self.create_engine(vars, options = {})
    Text.new(OpenStruct.new(vars), options)
  end

  def self.create_labels(vars)
    vars.keys.each_with_object({}) do |key, hash|
      var_label = :"#{key}_label"
      next if label?(key) || exists?(var_label, vars)
      hash[var_label] = key
    end
  end

  def self.exists?(var_label, vars)
    vars.key?(var_label)
  end

  def self.label?(var)
    /_label\b/ =~ var
  end

  def self.merge_labels(vars, var_labels)
    var_labels.merge(vars)
  end

  private_class_method :create_engine
  private_class_method :create_labels
  private_class_method :exists?
  private_class_method :merge_labels
end
