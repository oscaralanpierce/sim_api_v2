# frozen_string_literal: true

require 'service/internal_server_error_result'
require 'service/no_content_result'
require 'service/not_found_result'
require 'service/unauthorized_result'

class PlaythroughsController < ApplicationController
  class DestroyService
    def initialize(user, playthrough_id)
      @user = user
      @playthrough_id = playthrough_id
    end

    def perform
      return log_and_return_unauthorized unless user.is_a?(User)

      playthrough.destroy!
      Service::NoContentResult.new
    rescue ActiveRecord::RecordNotFound
      Service::NotFoundResult.new('Playthrough not found')
    rescue StandardError => e
      Rails.logger.error("An unexpected #{e.class} occurred: #{e.message}")

      Service::InternalServerErrorResult.new("#{e.class}: #{e.message}")
    end

    private

    attr_reader :user, :playthrough_id

    def playthrough
      @playthrough ||= user.playthroughs.find(playthrough_id)
    end

    def log_and_return_unauthorized
      Rails.logger.error('Unexpected state: PlaythroughsController::DestroyService called with no logged-in user')

      Service::UnauthorizedResult.new
    end
  end
end
