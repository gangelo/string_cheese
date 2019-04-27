require 'ostruct'
require 'string_cheese/buffer'
require 'string_cheese/digs'
require 'string_cheese/helpers'
require 'string_cheese/label_token'
require 'string_cheese/raw_token'
require 'string_cheese/text_token'
require 'string_cheese/var_token'
require 'string_cheese/token_type'
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
      self.data = OpenStruct.new({ buffer: Buffer.new, vars: {}, labels: {}, options: {} })
      self.data.options = extend_options(options.dup)
      self.data.vars = extend_vars(vars.dup)
      _, labels = self.data.vars.extract_labels!(options)
      self.data.labels = extend_labels(labels)
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
        data.buffer << LabelToken.new(method, apply(:nop, method.to_s))
        return self
      end

      if data.vars.has_key?(method)
        data.buffer << VarToken.new(method, apply(:nop, method.to_s))
        return self
      end

      if attr_writer?(method)
        method = ensure_attr_reader(method)
        target = label?(method) ? data.labels : data.vars
        target[method] = args[0]
      else
        raise ArgumentError, wrong_number_of_arguments_error(method, args.count, 1) unless args.empty? || args.count == 1
        option = args.any? ? args[0].to_sym : :nop
        data.buffer << TextToken.new(apply(option, method.to_s.gsub('_', ' ')))
      end
      self
    end

    def raw(text)
      data.buffer << RawToken.new(text)
      self
    end

    def respond_to?(symbol)
      super.respond_to?(symbol) ||
        data.vars.has_key?(symbol) ||
        data.labels.has_key?(symbol)
    end

    def to_s(options = {})
      return '' if data.buffer.empty?
      options = extend_options(ensure_options_with(data.options, options))
      data.buffer.update_current_buffer!(data.vars, data.labels)
      data.buffer.to_s
    end

    protected

    attr_writer :data
    attr_accessor :text

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
