# frozen_string_literal: true

require 'service/internal_server_error_result'
require 'service/not_found_result'
require 'service/ok_result'
require 'service/unauthorized_result'
require 'service/unprocessable_entity_result'

class PlaythroughsController < ApplicationController
  class UpdateService
    def initialize(user, playthrough_id, params)
      @user = user
      @playthrough_id = playthrough_id
      @params = params
    end

    def perform
      return log_and_return_unauthorized unless user.is_a?(User)

      playthrough.update!(params)
      Service::OkResult.new(playthrough)
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new('Playthrough not found')
    rescue ActiveRecord::RecordInvalid
      Service::UnprocessableEntityResult.new(playthrough.errors_array)
    rescue StandardError => e
      Rails.logger.error("An unexpected #{e.class} occurred: #{e.message}")

      Service::InternalServerErrorResult.new("#{e.class}: #{e.message}")
    end

    private

    attr_reader :user, :playthrough_id, :params

    def playthrough
      @playthrough ||= user.playthroughs.find(playthrough_id)
    end

    def log_and_return_unauthorized
      Rails.logger.error('Unexpected state: PlaythroughsController::UpdateService was called with no logged-in user')

      Service::UnauthorizedResult.new
    end
  end
end
