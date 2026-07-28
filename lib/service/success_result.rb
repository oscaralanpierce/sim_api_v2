# frozen_string_literal: true

module Service
  class SuccessResult
    attr_reader :resource

    def initialize(resource = nil)
      @resource = resource
    end

    def status
      raise NotImplementedError.new('SuccessResult must define #status')
    end
  end
end
