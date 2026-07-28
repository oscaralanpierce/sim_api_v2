# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Playthroughs', type: :request do
  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx',
    }
  end

  describe 'POST /playthroughs' do
    subject(:create_playthrough) { post '/playthroughs', headers:, params: }

    let!(:user) { create(:authenticated_user) }

    context 'when authenticated' do
      before do
        stub_successful_login
      end

      context 'when successful' do
        let(:params) { { playthrough: {} }.to_json }

        it 'creates a playthrough' do
          expect { create_playthrough }
            .to change(user.playthroughs, :count).from(0).to(1)
        end

        it 'returns status 201' do
          create_playthrough
          expect(response.status).to eq(201)
        end

        it 'returns the playthrough' do
          create_playthrough
          expect(response.body).to eq(user.playthroughs.last.to_json)
        end
      end

      context 'when there is a validation error' do
        let(:params) { { playthrough: { name: 'Dark Elf 1' } }.to_json }

        before do
          create(:playthrough, user:, name: 'Dark Elf 1')
        end

        it "doesn't create a playthrough" do
          expect { create_playthrough }
            .not_to change(Playthrough, :count)
        end

        it 'returns status 422' do
          create_playthrough
          expect(response.status).to eq(422)
        end

        it 'returns the errors' do
          create_playthrough
          expect(response.body).to eq({ errors: ['Name must be unique'] }.to_json)
        end
      end

      context 'when there is an unexpected error' do
        let(:params) { { playthrough: {} }.to_json }

        before do
          allow(Rails.logger).to receive(:error)

          allow_any_instance_of(Playthrough)
            .to receive(:save)
                  .and_raise(StandardError.new('Something went horribly wrong.'))
        end

        it 'returns status 500' do
          create_playthrough
          expect(response.status).to eq(500)
        end

        it 'logs the error' do
          create_playthrough
          expect(Rails.logger)
            .to have_received(:error)
                  .with('An unexpected StandardError occurred: Something went horribly wrong.')
        end
      end
    end

    context 'when not authenticated' do
      let(:params) { { playthrough: {} }.to_json }

      before do
        stub_failed_login
      end

      it "doesn't create a playthrough" do
        expect { create_playthrough }
          .not_to change(Playthrough, :count)
      end

      it 'returns status 401' do
        create_playthrough
        expect(response.status).to eq(401)
      end

      it 'describes the error' do
        create_playthrough
        expect(response.body).to eq({ errors: ['Authorization failed'] }.to_json)
      end
    end
  end
end
