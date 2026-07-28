# frozen_string_literal: true

module Service
  class ErrorResult
    class InvalidErrorResult < StandardError; end

    attr_reader :errors

    def initialize(options = {})
      raise InvalidErrorResult.new('No error(s) passed in') unless options[:error].present? || options[:errors].present?

      @errors = options[:errors] || []
      @errors << options[:error] if options.has_key?(:error)
      @errors.flatten!
    end

    def status
      raise NotImplementedError.new('ErrorResult must define #status')
    end
  end
end
