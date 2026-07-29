# frozen_string_literal: true

require 'rails_helper'
require 'service/internal_server_error_result'
require 'service/not_found_result'
require 'service/ok_result'
require 'service/unauthorized_result'
require 'service/unprocessable_entity_result'

RSpec.describe PlaythroughsController::UpdateService, type: :controller_service do
  subject(:perform) { described_class.new(user, playthrough.id, params).perform }

  context 'when the user is valid' do
    let!(:user) { create(:user_with_playthroughs) }

    context 'when the playthrough exists and belongs to the user' do
      let(:playthrough) { user.playthroughs.first }

      context 'when the update is successful' do
        let(:params) { { description: 'New description' } }

        it 'updates the playthrough' do
          perform
          expect(playthrough.reload.description).to eq('New description')
        end

        it 'returns a Service::OkResult' do
          expect(perform).to be_a(Service::OkResult)
        end

        it 'sets the updated playthrough as the resource body' do
          expect(perform.resource).to eq(playthrough.reload)
        end
      end

      context "when the playthrough can't be updated with the given params" do
        let(:params) { { name: user.playthroughs.last.name } }

        it "doesn't update the playthrough" do
          expect { perform }
            .not_to(change { playthrough.reload.name })
        end

        it 'returns a Service::UnprocessableEntityResult' do
          expect(perform).to be_a(Service::UnprocessableEntityResult)
        end

        it 'sets the errors' do
          expect(perform.errors).to eq(['Name must be unique'])
        end
      end
    end

    context 'when the playthrough exists but belongs to another user' do
      let(:playthrough) { create(:playthrough) }
      let(:params) { { description: 'New description' } }

      it "doesn't update the playthrough" do
        expect { perform }
          .not_to(change { playthrough.reload.description })
      end

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'sets a generic error' do
        expect(perform.errors).to eq(['Playthrough not found'])
      end
    end

    context "when the playthrough doesn't exist" do
      let(:playthrough) { double('playthrough', id: 274) }
      let(:params) { { description: 'New description' } }

      it 'returns a Service::NotFoundResult' do
        expect(perform).to be_a(Service::NotFoundResult)
      end

      it 'sets a generic error' do
        expect(perform.errors).to eq(['Playthrough not found'])
      end
    end

    context 'when there is an unexpected error' do
      let(:playthrough) { user.playthroughs.first }
      let(:params) { { description: 'New description' } }

      before do
        allow(Rails.logger).to receive(:error)

        allow_any_instance_of(Playthrough)
          .to receive(:update!).and_raise(StandardError.new('Oh no!'))
      end

      it 'returns a Service::InternalServerErrorResult' do
        expect(perform).to be_a(Service::InternalServerErrorResult)
      end

      it 'returns the error message' do
        expect(perform.errors).to eq(['StandardError: Oh no!'])
      end

      it 'logs the error' do
        perform

        expect(Rails.logger)
          .to have_received(:error)
                .with('An unexpected StandardError occurred: Oh no!')
      end
    end
  end

  context 'when the user is nil' do
    let(:user) { nil }
    let(:playthrough) { create(:playthrough) }
    let(:params) { { description: 'New description' } }

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
              .with('Unexpected state: PlaythroughsController::UpdateService was called with no logged-in user')
    end
  end
end
