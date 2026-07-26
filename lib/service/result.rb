# frozen_string_literal: true

module Service
  class Result
    attr_reader :resource, :errors

    def initialize(options = {})
      @errors = []

      options.each do |key, value|
        if key == :resource
          @resource = value
        elsif key == :errors
          @errors = value.flatten
        elsif key == :error
          @errors = [value].flatten
        end
      end
    end

    def status
      raise NotImplementedError
    end
  end
end
