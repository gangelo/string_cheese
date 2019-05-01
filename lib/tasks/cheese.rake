# frozen_string_literal: true

require 'rake'
require 'pry'

desc 'Play with string_cheese from irb'
task :create do
  require 'colorize'
  require 'irb'
  require 'string_cheese'

  vars = {
    var_1: 1,
    var_2: 2,
    version: StringCheese::VERSION
  }
  string_cheese = StringCheese.create(vars)
=begin
  puts string_cheese
    .Running.StringCheese.version_label(:capitalize).version
    .from_irb.raw('...').to_s.cyan
  string_cheese.reset
  puts string_cheese
    .Use.raw(': ')
    .engine.raw(' = ').StringCheese.raw('.').create
    .raw('(')
    .raw('{')
    .var_1_label.raw(': ').var_1
    .raw(', ')
    .var_2_label.raw(': ').var_2
    .raw('}')
    .raw(')').to_s.cyan
=end

  puts 'engine = StringCheese.create({var_1: 1, var_2: 2})'.cyan
  puts "Don't forget to require 'pry'!".red

  # Run it!
  exec 'irb  -I lib -r string_cheese.rb'
end
