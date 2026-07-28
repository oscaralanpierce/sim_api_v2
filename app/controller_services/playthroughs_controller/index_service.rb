# frozen_string_literal: true

require 'service/internal_server_error_result'
require 'service/ok_result'
require 'service/unauthorized_result'

class PlaythroughsController < ApplicationController
  class IndexService
    def initialize(user)
      @user = user
    end

    def perform
      return log_and_return_unauthorized unless user.is_a?(User)

      Service::OkResult.new(user.playthroughs.index_order)
    rescue StandardError => e
      Rails.logger.error("An unexpected #{e.class} occurred: #{e.message}")

      Service::InternalServerErrorResult.new("#{e.class}: #{e.message}")
    end

    private

    attr_reader :user

    def log_and_return_unauthorized
      Rails.logger.error('Unexpected state: PlaythroughsController::IndexService called with no logged-in user')

      Service::UnauthorizedResult.new
    end
  end
end
