# frozen_string_literal: true

require_relative 'string_cheese/engine'
require_relative 'string_cheese/options'
require_relative 'string_cheese/version'

module StringCheese
  extend Options

  def self.create(vars, options = {})
    create_engine(vars, options)
  end

  def self.create_with_debug(vars, options = {})
    options = ensure_options_with(options, debug: true)
    create_engine(vars, options)
  end

  # Creates an engine with the linter enabled. This
  # basically removes the method_missing override so that
  # any errors encountered will not be affected by this
  # override.
  def self.create_with_linter(vars, options = {})
    options = ensure_options_with(options, linter: true)
    create_engine(vars, options)
  end

  # Private class methods

  def self.create_engine(vars, options = {})
    vars ||= {}
    options = ensure_options_with_defaults(options)
    Engine.new(vars, options)
  end

  private_class_method :create_engine
end
