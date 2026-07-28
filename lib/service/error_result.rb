# frozen_string_literal: true

module Service
  class ErrorResult
    class InvalidErrorResult < StandardError; end

    attr_reader :errors

    def initialize(errors)
      raise InvalidErrorResult.new('No error(s) passed in') if errors.blank?

      @errors = Array.wrap(errors)
    end

    def status
      raise NotImplementedError.new('ErrorResult must define #status')
    end
  end
end
