# frozen_string_literal: true

require 'rails_helper'
require 'service/created_result'
require 'service/internal_server_error_result'
require 'service/unauthorized_result'
require 'service/unprocessable_entity_result'

RSpec.describe PlaythroughsController::CreateService, type: :controller_service do
  subject(:perform) { described_class.new(user, params).perform }

  let(:user) { create(:user) }

  context 'when params are valid' do
    let(:params) { { name: 'Dark Elf 1', description: 'My first playthrough as a Dunmer' } }

    it 'creates a playthrough for the given user' do
      expect { perform }
        .to change(user.playthroughs, :count).from(0).to(1)
    end

    it 'sets the correct values', :aggregate_failures do
      perform
      playthrough = user.playthroughs.last

      expect(playthrough.name).to eq('Dark Elf 1')
      expect(playthrough.description).to eq('My first playthrough as a Dunmer')
    end

    it 'returns a Service::CreatedResult' do
      expect(perform).to be_a(Service::CreatedResult)
    end

    it 'sets the playthrough as the resource' do
      expect(perform.resource).to eq(user.playthroughs.last)
    end
  end

  context 'when there is a validation error' do
    let(:params) { { name: 'Dark Elf 1' } }

    before do
      create(:playthrough, user:, name: params[:name])
    end

    it "doesn't create a playthrough" do
      expect { perform }
        .not_to change(user.playthroughs, :count)
    end

    it 'returns a Service::UnprocessableEntityResult' do
      expect(perform).to be_a(Service::UnprocessableEntityResult)
    end

    it 'returns the validation errors' do
      expect(perform.errors).to eq(['Name must be unique'])
    end
  end

  context 'when no user is passed in' do
    let(:user) { nil }
    let(:params) { {} }

    before do
      allow(Rails.logger).to receive(:error)
    end

    it "doesn't create a playthrough" do
      expect { perform }
        .not_to change(Playthrough, :count)
    end

    it 'returns a Service::UnauthorizedResult' do
      expect(perform).to be_a(Service::UnauthorizedResult)
    end

    it 'sets an error message' do
      expect(perform.errors).to eq(['User must be logged in'])
    end

    it 'logs an error' do
      perform
      expect(Rails.logger)
        .to have_received(:error)
              .with('Unexpected state: PlaythroughsController::CreateService called with no logged-in user')
    end
  end

  context 'when there is an unexpected error' do
    let(:params) { {} }

    before do
      allow(Rails.logger).to receive(:error)

      allow_any_instance_of(Playthrough)
        .to receive(:save)
              .and_raise(StandardError.new('Oh no!'))
    end

    it 'returns a Service::InternalServerError result' do
      expect(perform).to be_a(Service::InternalServerErrorResult)
    end

    it 'sets the error message' do
      expect(perform.errors).to eq(['Oh no!'])
    end

    it 'logs the error' do
      perform
      expect(Rails.logger)
        .to have_received(:error)
              .with('An unexpected StandardError occurred: Oh no!')
    end
  end
end
