require 'string_cheese/version'
require 'string_cheese/text'

module StringCheese
  def self.create(vars, options = {})
    vars = add_with_labels(vars)
    puts vars[:osm_tenant_id_with_label]
    Text.new(OpenStruct.new(vars))
  end

  def self.add_with_labels(vars)
    vars.dup.each_key do |key|
      vars["#{key}_with_label"] = "#{key}"
    end
    vars
  end

  private_class_method :add_with_labels
end
