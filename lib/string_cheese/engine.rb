require 'ostruct'
require 'string_cheese/digs/options'
require 'string_cheese/digs/options'
require 'string_cheese/digs/labels'
require 'string_cheese/digs/vars'
require 'string_cheese/labels'
require 'string_cheese/vars'

module StringCheese
  class Engine
    include StringCheese::Vars
    include StringCheese::Labels

    attr_reader :_

    def initialize(vars, options = {})
      self._ = OpenStruct.new({ vars: {}, labels: {}, options: {} })
      initialize_options(options)
      initialize_vars(vars)
      initialize_labels(vars) if _.options.labels?
      clear
    end

    def initialize_options(options)
      _.options = options.dup
      _.options.extend(Digs::Options)
    end

    def initialize_vars(vars)
      _.vars = vars.dup
      _.vars.extend(Digs::Vars)
    end

    def initialize_labels(vars)
      _.labels = create_labels(vars.dup)
      binding.pry
      _.labels.extend(Digs::Labels)
    end

    # Clears the text and initializes it with [text]
    def clear(text = nil)
      self.text = text || ''
      self
    end

    # Check to see if [method] is an attribute of [vars];
    # if it is, append the value. If [method] is not
    # an attribute of [vars], append [method] to [text]
    def method_missing(method, *args, &block)
      if vars.respond_to?(method)
        # If the method is an attr_writer, update the value in vars; otherwise,
        # return the method name; this is later replaced when to_s is called.
        if attr_writer?(method)
          vars.send(method, *args, &block)
        else
          append(apply(:nop, method.to_s))
        end
      elsif attr_writer?(method)
        vars.send(method, *args, &block)
      else
        raise ArgumentError, wrong_number_of_arguments_error(method, args.count, 1) unless args.empty? || args.count == 1
        option = args.any? ? args[0].to_sym : :nop
        append(apply(option, method.to_s.gsub('_', ' ')))
      end
      self
    end

    def raw(text)
      append_raw(text)
      self
    end

    def respond_to?(symbol)
      return true if super.respond_to?(symbol)
      vars.respond_to?(symbol)
    end

    def _to_s(options = { replace_vars: true, debug: false })
      replaced_text = text
      vars.each_pair do |var, val|
        replacement_text = Varlabels.label?(var) ? "#{val}" : "[#{val}]"
        puts "Would replace #{var} with #{replacement_text}" if options[:debug]
        replaced_text.gsub!(/\b#{var}\b/, replacement_text) if options[:replace_vars]
      end
      replaced_text
    end

    def to_s(options = { replace_vars: true, debug: false })
      replaced_text = text
      vars = Vars.vars(vars.to_h)
      labels = Varlabels.labels(vars.to_h)

      # Replace the vars...
      vars.each_pair do |var, val|
        replacement_text = "[#{val}]"
        puts "Would replace #{var} with #{replacement_text}" if options[:debug]
        replaced_text.gsub!(/\b#{var}\b/, replacement_text) if options[:replace_vars]
      end

      # Replace the variable labels...
      labels.each_pair do |var, val|
        replacement_text = val
        puts "Would replace #{var} with #{replacement_text}" if options[:debug]
        replaced_text.gsub!(/\b#{var}\b/, replacement_text) if options[:replace_vars]
      end
      replaced_text
    end

    protected

    attr_writer :_
    attr_accessor :text

    def append(text)
      text = text.strip
      self.text = self.text.empty? ? text : "#{self.text} #{text}"
    end

    def append_raw(text)
      self.text = self.text.empty? ? text : "#{self.text}#{text}"
    end

    def apply(option, text)
      return text if option == :nop
      # TODO: Check against whitelist
      text.send(option)
    end

    def attr_writer?(method)
      /[a-zA-Z](=)$/ === method
    end

    def wrong_number_of_arguments_error(method, actual_count, expected_count)
      "wrong number of arguments calling '#{method}' " \
        "(#{actual_count} for #{expected_count})"
    end
  end
end
