# frozen_string_literal: true

require_relative 'string_cheese/engine'
require_relative 'string_cheese/helpers/hash'
require_relative 'string_cheese/options'
require_relative 'string_cheese/version'

module StringCheese
  extend Helpers::Hash
  extend Options

  def self.create(attrs = {}, options = {})
    create_engine(attrs, options)
  end

  def self.create_with_debug(attrs = {}, options = {})
    options = ensure_options_with(options, debug: true)
    create_engine(attrs, options)
  end

  # Creates an engine with the linter enabled. This
  # basically removes the method_missing override so that
  # any errors encountered will not be affected by this
  # override.
  def self.create_with_linter(attrs, options = {})
    options = ensure_options_with(options, linter: true)
    create_engine(attrs, options)
  end

  # Private class methods

  def self.create_engine(attrs, options = {})
    attrs = ensure_hash(attrs)
    options = ensure_options_with_defaults(options)
    Engine.new(attrs, options)
  end

  private_class_method :create_engine
end
