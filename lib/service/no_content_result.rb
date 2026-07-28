# frozen_string_literal: true

require 'service/success_result'

module Service
  class NoContentResult < SuccessResult
    def initialize(_resource = nil)
      super(nil)
    end

    def status
      :no_content
    end
  end
end
