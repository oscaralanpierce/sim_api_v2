# frozen_string_literal: true

require 'service/error_result'

module Controller
  class Response
    def initialize(controller, result, options = {})
      @controller = controller
      @result = result
      @options = options
    end

    def execute
      if result.is_a?(Service::ErrorResult)
        controller.render json: { errors: result.errors }, status: result.status
      elsif result.resource.nil?
        controller.head result.status
      else
        controller.render json: result.resource, status: result.status
      end
    end

    private

    attr_reader :controller, :result, :options
  end
end
