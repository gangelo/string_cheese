require 'ostruct'
require 'string_cheese/digs'
require 'string_cheese/helpers'
require 'string_cheese/labels'
require 'string_cheese/vars'

module StringCheese
  class Engine
    include StringCheese::Vars
    include StringCheese::Labels
    include StringCheese::Helpers::Labels
    include StringCheese::Helpers::Options
    include StringCheese::Helpers::Vars

    attr_reader :data

    def initialize(vars, options = {})
      vars = ensure_vars(vars)
      options = ensure_options_with_defaults(options)
      self.data = OpenStruct.new({ vars: {}, labels: {}, options: {} })
      self.data.options = extend_options(options.dup)
      self.data.vars = extend_vars(vars.dup)
      _, labels = self.data.vars.extract_labels!(options)
      self.data.labels = extend_labels(labels)
      clear
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
      if self.data.options.linter?
        super
        return
      end

      if data.labels.has_key?(method)
        append(apply(:nop, method.to_s))
        return self
      end

      if data.vars.has_key?(method)
        append(apply(:nop, method.to_s))
        return self
      end

      if attr_writer?(method)
        method = ensure_attr_reader(method)
        target = label?(method) ? data.label : data.vars
        target[method] = args[0]
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
      super.respond_to?(symbol) ||
        data.vars.has_key?(symbol) ||
        data.labels.has_key?(symbol)
    end

    def to_s(options = {})
      options = extend_options(ensure_options_with(data.options, options))
      replaced_text = text
      vars = data.vars
      labels = data.labels

      puts options if options.debug?
      puts replaced_text if options.debug?

      # Replace the vars...
      vars.each_pair do |var, val|
        replacement_text = "[#{val}]"
        puts "Would replace #{var} with #{replacement_text}" if options.debug?
        replaced_text.gsub!(/\b#{var}\b/, replacement_text) if options.replace_vars?
      end

      # Replace the variable labels...
      labels.each_pair do |var, val|
        replacement_text = val.to_s
        puts "Would replace #{var} with #{replacement_text}" if options.debug?
        replaced_text.gsub!(/\b#{var}\b/, replacement_text) if options.replace_vars?
      end
      replaced_text
    end

    protected

    attr_writer :data
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
      # TODO: Check against whitelist?
      text.send(option)
    end

    # TODO: Make this regex confirm to ruby allowable method names
    def attr_writer?(method)
      /[a-zA-Z0-9](=)$/ === method
    end

    def ensure_attr_reader(method)
      method = method.to_s
      :"#{method.gsub!(/=$/, '')}"
    end

    def wrong_number_of_arguments_error(method, actual_count, expected_count)
      "from string_cheese :) wrong number of arguments calling '#{method}' " \
        "(#{actual_count} for #{expected_count})"
    end
  end
end
