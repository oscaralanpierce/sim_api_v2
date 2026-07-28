# frozen_string_literal: true

require 'service/success_result'

module Service
  class OkResult < SuccessResult
    def status
      :ok
    end
  end
end
