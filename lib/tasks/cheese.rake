require 'rake'
require 'pry'

desc 'Play with string_cheese from irb'
task :create do
  require 'colorize'
  require 'irb'
  require 'string_cheese'

  vars = {
         version: StringCheese::VERSION,
         }
  string_cheese = StringCheese.create(vars)

  puts string_cheese
         .Running.StringCheese.version_label(:capitalize).version
         .from_irb.raw('...').to_s.cyan
binding.pry
  string_cheese.reset

  #exec 'irb  -I lib -r string_cheese.rb'
end