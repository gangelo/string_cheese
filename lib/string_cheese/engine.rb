# frozen_string_literal: true

require 'ostruct'
require_relative 'token_buffer_manager'
require_relative 'errors/invalid_token_option_error'
require_relative 'helpers/labels'
require_relative 'options'
require_relative 'label_token'
require_relative 'labels'
require_relative 'raw_token'
require_relative 'text_token'
require_relative 'var_token'
require_relative 'vars'

module StringCheese
  class Engine
    include StringCheese::Vars
    include StringCheese::Labels
    include StringCheese::Helpers::Labels
    include StringCheese::Options

    attr_reader :data

    def initialize(vars, options = {})
      vars = ensure_vars(vars)
      options = ensure_options_with_defaults(options)
      self.data = OpenStruct.new(buffer: TokenBufferManager.new, vars: {}, labels: {}, options: {})
      data.options = extend_options(options.dup)
      data.vars = extend_vars(vars.dup)
      _, labels = data.vars.extract_labels!(options)
      data.labels = extend_labels(labels)
    end

    # Check to see if [method] is an attribute of [vars];
    # if it is, append the value. If [method] is not
    # an attribute of [vars], append [method] to [text]
    def method_missing(method, *args, &block)
      if data.options.linter?
        super
        return
      end

      if data.labels.key?(method)
        data.buffer << LabelToken.new(method, method.to_s, args)
        return self
      end

      if data.vars.key?(method)
        data.buffer << VarToken.new(method, method.to_s, args)
        return self
      end

      if attr_writer?(method)
        method = ensure_attr_reader(method)
        target = label?(method) ? data.labels : data.vars
        target[method] = args[0]
      else
        raise ArgumentError, wrong_number_of_arguments_error(method, args.count, 1) unless args.empty? || args.count == 1

        option = args.any? ? args[0].to_sym : :nop
        data.buffer << TextToken.new(apply(option, method.to_s.tr('_', ' ')))
      end
      self
    end

    def raw(text)
      data.buffer << RawToken.new(text)
      self
    end

    def reset
      data.buffer.reset_buffer
    end

    def respond_to?(symbol)
      super.respond_to?(symbol) ||
        data.vars.key?(symbol) ||
        data.labels.key?(symbol)
    end

    def to_s(options = {})
      return '' if data.buffer.empty?

      # TODO: implement these options e.g. debug?
      options = extend_options(ensure_options_with(data.options, options))
      data.buffer.update_current!(data.vars, data.labels)
      data.buffer.to_s
    end

    protected

    attr_writer :data
    attr_accessor :text

    def apply(option, text)
      return text if option == :nop
      raise InvalidTokeOptionError(option, text) unless text.respond_to?(option)

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
