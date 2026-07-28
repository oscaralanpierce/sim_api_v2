# frozen_string_literal: true

require 'service/error_result'

module Service
  class UnprocessableEntityResult < ErrorResult
    def status
      :unprocessable_entity
    end
  end
end
