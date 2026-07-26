# frozen_string_literal: true

module Controller
  class Response
    def initialize(controller, result, options = {})
      @controller = controller
      @result = result
      @options = options
    end

    def execute
      if result.errors.blank? && result.resource.nil?
        controller.head result.status
      elsif result.errors.blank?
        controller.render json: result.resource, status: result.status
      else
        controller.render json: { errors: result.errors }, status: result.status
      end
    end

    private

    attr_reader :controller, :result, :options
  end
end
