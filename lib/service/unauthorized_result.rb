# frozen_string_literal: true

require 'service/error_result'

module Service
  class UnauthorizedResult < ErrorResult
    UNAUTHORIZED_MESSAGE = 'Authorization failed'

    def initialize(_options = {})
      super(error: UNAUTHORIZED_MESSAGE)
    end

    def status
      :unauthorized
    end
  end
end
