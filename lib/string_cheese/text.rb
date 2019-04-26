require 'ostruct'

module StringCheese
  class Text
    attr_reader :vars

    def initialize(vars)
      self.vars = vars
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

    def to_s
      replaced_text = text.dup
      vars.each_pair { |var, val| replaced_text.gsub!(/\b#{var}\b/, "[#{val}]") }
      replaced_text
    end

    protected

    attr_writer :vars
    attr_accessor :text

    def append(text)
      text = text.strip
      self.text = self.text.empty? ? text : "#{self.text} #{text}"
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
