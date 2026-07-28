# frozen_string_literal: true

require 'service/created_result'
require 'service/internal_server_error_result'
require 'service/unauthorized_result'
require 'service/unprocessable_entity_result'

class PlaythroughsController < ApplicationController
  class CreateService
    def initialize(user, params)
      @user = user
      @params = params
    end

    def perform
      if !user.is_a?(User)
        Rails.logger.error('Unexpected state: PlaythroughsController::CreateService called with no logged-in user')

        return Service::UnauthorizedResult.new({ error: 'User must be logged in' })
      end

      playthrough = user.playthroughs.new(params)

      if playthrough.save
        Service::CreatedResult.new(resource: playthrough)
      else
        Service::UnprocessableEntityResult.new(errors: playthrough.errors_array)
      end
    rescue StandardError => e
      Rails.logger.error("An unexpected #{e.class} occurred: #{e.message}")

      Service::InternalServerErrorResult.new(error: e.message)
    end

    private

    attr_reader :user, :params
  end
end
