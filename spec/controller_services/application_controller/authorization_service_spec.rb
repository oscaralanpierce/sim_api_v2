# frozen_string_literal: true

require 'rails_helper'
require 'service/unauthorized_result'

RSpec.describe ApplicationController::AuthorizationService do
  describe '#perform' do
    subject(:perform) { described_class.new(controller, access_token).perform }

    let(:controller) { ApplicationController.new }
    let(:faraday_response) { instance_double(Faraday::Response, body: google_keys) }
    let(:rsa_key) { OpenSSL::PKey::RSA.generate(2048) }
    let(:jwk) { JWT::JWK::RSA.new(rsa_key, 'valid_kid') }
    let(:google_keys) { { keys: [jwk.export(include_private: false)] }.to_json }

    # JWT values
    let(:alg) { 'RS256' }
    let(:kid) { 'valid_kid' }
    let(:exp) { (DateTime.now + 5.seconds).to_i }
    let(:iat) { (DateTime.now - 5.seconds).to_i }
    let(:aud) { 'skyrim-inventory-management-v2' }
    let(:iss) { "https://securetoken.google.com/#{aud}" }
    let(:sub) { 'somestring' }
    let(:auth_time) { (DateTime.now - 10.seconds).to_i }
    let(:email) { 'someuser@gmail.com' }

    let(:jwt_payload) do
      {
        exp:,
        iat:,
        aud:,
        iss:,
        sub:,
        auth_time:,
        user_id: sub,
        email:,
        email_verified: true,
        name: 'Jane Doe',
        picture: 'https://lh3.googleusercontent.com/someuser.png',
      }
    end
    let(:access_token) { JWT.encode(jwt_payload, rsa_key, alg, { kid: }) }

    before do
      allow(controller).to receive(:current_user=).and_call_original
      allow(Faraday).to receive(:get).and_return(faraday_response)
      allow(Rails.logger).to receive(:error)
    end

    context 'when the JWT is valid' do
      context 'when a matching user exists' do
        let!(:user) { create(:authenticated_user) }

        it "doesn't create a new user" do
          expect { perform }
            .not_to change(User, :count)
        end

        it 'sets the current user' do
          perform
          expect(controller).to have_received(:current_user=).with(user)
        end

        it 'returns nil' do
          expect(perform).to be_nil
        end
      end

      context 'when no matching user exists' do
        it 'creates a new user' do
          expect { perform }
            .to change(User, :count).from(0).to(1)
        end

        it 'sets the current user' do
          perform
          expect(controller).to have_received(:current_user=).with(User.last)
        end

        it 'returns nil' do
          expect(perform).to be_nil
        end
      end
    end

    context 'when the algorithm is invalid' do
      let(:alg) { 'RS512' }

      it "doesn't set the current user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'indicates the algorithm was incorrect' do
        expect(perform.errors).to eq(['Expected a different algorithm'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('JWT::IncorrectAlgorithm while validating user access token: Expected a different algorithm')
      end
    end

    context 'when the kid is invalid' do
      let(:kid) { 'invalid_kid' }

      it "doesn't set the current user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(["Could not find public key for kid #{kid}"])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with("JWT::DecodeError while validating user access token: Could not find public key for kid #{kid}")
      end
    end

    context 'when the expiration time is invalid' do
      let(:exp) { (Time.zone.now - 1.second).to_i }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error message' do
        expect(perform.errors).to eq(['Signature has expired'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('JWT::ExpiredSignature while validating user access token: Signature has expired')
      end
    end

    context 'when the iat is in the future' do
      let(:iat) { (Time.zone.now + 5.seconds).to_i }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(['Issuing time must be in the past'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('ApplicationController::AuthorizationService::InvalidDataError while validating user access token: Issuing time must be in the past')
      end
    end

    context 'when the audience is invalid' do
      let(:aud) { 'somevalue' }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(['Invalid issuer. Expected ["https://securetoken.google.com/skyrim-inventory-management-v2"], received https://securetoken.google.com/somevalue'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('JWT::InvalidIssuerError while validating user access token: Invalid issuer. Expected ["https://securetoken.google.com/skyrim-inventory-management-v2"], received https://securetoken.google.com/somevalue')
      end
    end

    context 'when the issuer is invalid' do
      let(:iss) { 'invalidvalue' }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors)
          .to eq(['Invalid issuer. Expected ["https://securetoken.google.com/skyrim-inventory-management-v2"], received invalidvalue'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('JWT::InvalidIssuerError while validating user access token: Invalid issuer. Expected ["https://securetoken.google.com/skyrim-inventory-management-v2"], received invalidvalue')
      end
    end

    context 'when the sub is empty' do
      let(:sub) { '' }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(['Sub value is missing or blank'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('ApplicationController::AuthorizationService::InvalidDataError while validating user access token: Sub value is missing or blank')
      end
    end

    context 'when the auth_time is in the future' do
      let(:auth_time) { (Time.zone.now + 5.seconds).to_i }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(['Auth time must be in the past'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('ApplicationController::AuthorizationService::InvalidDataError while validating user access token: Auth time must be in the past')
      end
    end

    context 'when email is missing or blank' do
      let(:email) { '' }

      it "doesn't set current_user" do
        perform
        expect(controller).not_to have_received(:current_user=)
      end

      it 'returns an UnauthorizedResult' do
        expect(perform).to be_a(Service::UnauthorizedResult)
      end

      it 'sets the error' do
        expect(perform.errors).to eq(['Email is missing or blank'])
      end

      it 'logs the error' do
        perform
        expect(Rails.logger)
          .to have_received(:error)
                .with('ApplicationController::AuthorizationService::InvalidDataError while validating user access token: Email is missing or blank')
      end
    end
  end
end
