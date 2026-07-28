# frozen_string_literal: true

require 'service/success_result'

module Service
  class CreatedResult < SuccessResult
    def status
      :created
    end
  end
end
