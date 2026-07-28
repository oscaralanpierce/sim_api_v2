# frozen_string_literal: true

require 'rails_helper'
require 'service/internal_server_error_result'
require 'service/ok_result'
require 'service/unauthorized_result'

RSpec.describe PlaythroughsController::IndexService, type: :controller_service do
  subject(:perform) { described_class.new(user).perform }

  context 'when the user has no playthroughs' do
    let!(:user) { create(:user) }

    it 'returns a Service::OkResult' do
      expect(perform).to be_a(Service::OkResult)
    end

    it 'sets the resource to an empty collection' do
      expect(perform.resource).to eq([])
    end
  end

  context 'when the user has playthroughs' do
    let!(:user) { create(:user_with_playthroughs, playthrough_count: 4) }

    before do
      # Change order so this one is most recently updated
      user.playthroughs[2].touch
    end

    it 'returns a Service::OkResult' do
      expect(perform).to be_a(Service::OkResult)
    end

    it 'returns the most-recently-updated playthroughs first' do
      expect(perform.resource).to eq(user.playthroughs.order(updated_at: :desc))
    end
  end

  context 'when there is an unexpected error' do
    let!(:user) { create(:user) }

    before do
      allow(Rails.logger).to receive(:error)

      allow_any_instance_of(User)
        .to receive(:playthroughs).and_raise(StandardError.new('Something went wrong'))
    end

    it 'returns a Service::InternalServerErrorResult' do
      expect(perform).to be_a(Service::InternalServerErrorResult)
    end

    it 'sets the error' do
      expect(perform.errors).to eq(['StandardError: Something went wrong'])
    end

    it 'logs the error' do
      perform

      expect(Rails.logger)
        .to have_received(:error)
              .with('An unexpected StandardError occurred: Something went wrong')
    end
  end

  context 'when the user is nil' do
    let(:user) { nil }

    before do
      allow(Rails.logger).to receive(:error)
    end

    it 'returns a Service::UnauthorizedResult' do
      expect(perform).to be_a(Service::UnauthorizedResult)
    end

    it 'logs the error' do
      perform

      expect(Rails.logger)
        .to have_received(:error)
              .with('Unexpected state: PlaythroughsController::IndexService called with no logged-in user')
    end
  end
end
