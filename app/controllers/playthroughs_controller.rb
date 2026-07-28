# frozen_string_literal: true

require 'controller/response'

class PlaythroughsController < ApplicationController
  def create
    result = CreateService.new(current_user, playthrough_params).perform

    ::Controller::Response.new(self, result).execute
  end

  private

  def playthrough_params
    params.fetch(:playthrough, {}).permit(:name, :description)
  end
end
