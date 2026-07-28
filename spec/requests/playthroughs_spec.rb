# frozen_string_literal: true

require 'rails_helper'

RSpec.describe 'Playthroughs', type: :request do
  let!(:user) { create(:authenticated_user) }

  let(:headers) do
    {
      'Content-Type' => 'application/json',
      'Authorization' => 'Bearer xxxxxxx',
    }
  end

  describe 'POST /playthroughs' do
    subject(:create_playthrough) { post playthroughs_path, headers:, params: }

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
    end
  end

  describe 'DELETE /playthroughs/:id' do
    subject(:destroy_playthrough) { delete(playthrough_path(playthrough.id), headers:) }

    context 'when authenticated' do
      before do
        stub_successful_login
      end

      context 'when the playthrough exists and belongs to the logged-in user' do
        let!(:playthrough) { create(:playthrough, user:) }

        it 'deletes the playthrough' do
          expect { destroy_playthrough }
            .to change(user.playthroughs, :count).from(1).to(0)
        end

        it 'returns status 204' do
          destroy_playthrough
          expect(response.status).to eq(204)
        end

        it 'returns no response body' do
          destroy_playthrough
          expect(response.body).not_to be_present
        end
      end

      context 'when the playthrough does not exist' do
        let(:playthrough) { double('playthrough', id: 22) }

        it "doesn't delete any playthroughs" do
          expect { destroy_playthrough }
            .not_to change(Playthrough, :count)
        end

        it 'returns status 404' do
          destroy_playthrough
          expect(response.status).to eq(404)
        end

        it "doesn't indicate whether the resource exists" do
          destroy_playthrough
          expect(response.body).to eq({ errors: ['Playthrough not found'] }.to_json)
        end
      end

      context 'when the playthrough exists but belongs to a different user' do
        let!(:playthrough) { create(:playthrough) }

        it "doesn't destroy the playthrough" do
          expect { destroy_playthrough }
            .not_to change(Playthrough, :count)
        end

        it 'returns status 404' do
          destroy_playthrough
          expect(response.status).to eq(404)
        end

        it "doesn't indicate whether the resource exists" do
          destroy_playthrough
          expect(response.body).to eq({ errors: ['Playthrough not found'] }.to_json)
        end
      end

      context 'when an unexpected error occurs' do
        let(:playthrough) { create(:playthrough, user:) }

        before do
          allow(Rails.logger).to receive(:error)

          allow_any_instance_of(Playthrough)
            .to receive(:destroy!)
                  .and_raise(StandardError.new('Oh no!'))
        end

        it 'returns status 500' do
          destroy_playthrough
          expect(response.status).to eq(500)
        end

        it 'returns the error message' do
          destroy_playthrough
          expect(response.body).to eq({ errors: ['Oh no!'] }.to_json)
        end

        it 'logs the error' do
          destroy_playthrough

          expect(Rails.logger)
            .to have_received(:error)
                  .with('An unexpected StandardError occurred: Oh no!')
        end
      end
    end

    context 'when unauthenticated' do
      let(:playthrough) { create(:playthrough, user:) }

      before do
        stub_failed_login
      end

      it 'returns status 401' do
        destroy_playthrough
        expect(response.status).to eq(401)
      end
    end
  end
end
