# frozen_string_literal: true

require 'rails_helper'
require 'service/internal_server_error_result'
require 'service/no_content_result'
require 'service/not_found_result'
require 'service/unauthorized_result'

RSpec.describe PlaythroughsController::DestroyService, type: :controller_service do
  subject(:perform) { described_class.new(user, playthrough.id).perform }

  let(:user) { create(:user) }

  context 'when no user is passed in' do
    let(:user) { nil }
    let!(:playthrough) { create(:playthrough) }

    before do
      allow(Rails.logger).to receive(:error)
    end

    it "doesn't delete a playthrough" do
      expect { perform }
        .not_to change(Playthrough, :count)
    end

    it 'returns a Service::UnauthorizedResult' do
      expect(perform).to be_a(Service::UnauthorizedResult)
    end

    it 'logs the error' do
      perform
      expect(Rails.logger)
        .to have_received(:error)
              .with('Unexpected state: PlaythroughsController::DestroyService called with no logged-in user')
    end
  end

  context 'when the playthrough exists and belongs to the given user' do
    let!(:playthrough) { create(:playthrough, user:) }

    it 'deletes the playthrough' do
      expect { perform }
        .to change(user.playthroughs, :count).from(1).to(0)
    end

    it 'returns a Service::NoContentResult' do
      expect(perform).to be_a(Service::NoContentResult)
    end

    it 'sets the resource to nil' do
      expect(perform.resource).to be_nil
    end
  end

  context "when the playthrough exists but doesn't belong to the given user" do
    let!(:playthrough) { create(:playthrough) }

    it "doesn't delete the playthrough" do
      expect { perform }
        .not_to change(Playthrough, :count)
    end

    it 'returns a Service::NotFoundResult' do
      expect(perform).to be_a(Service::NotFoundResult)
    end

    it 'does not indicate that the resource exists' do
      expect(perform.errors).to eq(['Playthrough not found'])
    end
  end

  context "when the playthrough doesn't exist" do
    let(:playthrough) { double('playthrough', id: 20) }

    it 'returns a Service::NotFoundResult' do
      expect(perform).to be_a(Service::NotFoundResult)
    end

    it "doesn't indicate whether the resource exists" do
      expect(perform.errors).to eq(['Playthrough not found'])
    end
  end

  context 'when there is an unexpected error' do
    let!(:playthrough) { create(:playthrough, user:) }

    before do
      allow(Rails.logger).to receive(:error)

      allow_any_instance_of(Playthrough)
        .to receive(:destroy!)
              .and_raise(StandardError.new('Oh no!'))
    end

    it 'returns an InternalServerErrorResult' do
      expect(perform).to be_a(Service::InternalServerErrorResult)
    end

    it 'returns the error message' do
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
