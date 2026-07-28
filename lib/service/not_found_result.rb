# frozen_string_literal: true

require 'service/error_result'

module Service
  class NotFoundResult < ErrorResult
    def status
      :not_found
    end
  end
end
