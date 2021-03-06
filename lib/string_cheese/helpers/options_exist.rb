# frozen_string_literal: true

require_relative '../options'

module StringCheese
  module Helpers
    # Provides methods to determine whether or not options exist in the
    # current receiver. The options checked are #options and
    # #data_repository.options
    module OptionsExist
      def current_options
        return nil unless options_exist?

        respond_to?(:options) ? options : data_repository.options
      end

      def options_exist?
        @options_exist ||= respond_to?(:options) && \
                           options.is_a?(Options::Digs) ||
                           respond_to?(:data_repository) && \
                           data_repository.respond_to?(:options) && \
                           data_repository.options.is_a?(Options::Digs)
      end
    end
  end
end
