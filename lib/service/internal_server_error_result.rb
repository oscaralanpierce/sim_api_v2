# frozen_string_literal: true

require 'service/error_result'

module Service
  class InternalServerErrorResult < ErrorResult
    def status
      :internal_server_error
    end
  end
end
