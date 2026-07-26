# frozen_string_literal: true

require 'service/unauthorized_result'

class ApplicationController < ActionController::API
  class AuthorizationService
    class InvalidDataError < StandardError; end

    FIREBASE_PROJECT_ID = 'skyrim-inventory-management-v2'
    GOOGLE_PUBLIC_KEYS_URI = 'https://www.googleapis.com/robot/v1/metadata/x509/securetoken@system.gserviceaccount.com'
    JWT_ALG = %w[RS256].freeze

    def initialize(controller, access_token)
      @controller = controller
      @access_token = access_token
    end

    def perform
      user_data = validate_token!

      controller.current_user = User.create_or_update_from_google!(user_data)

      nil
    rescue JWT::DecodeError, InvalidDataError => e
      Rails.logger.error("#{e.class} while validating user access token: #{e.message}")
      Service::UnauthorizedResult.new(error: e.message)
    end

    private

    attr_reader :controller, :access_token

    def google_jwks
      JSON.parse(
        Faraday
          .get(GOOGLE_PUBLIC_KEYS_URI, headers: { 'Content-Type' => 'application/json' })
          .body,
      )
    end

    def jwks_loader(options)
      @cached_keys = nil if options[:kid_not_found]
      @jwks_loader ||= JWT::JWK::Set.new(google_jwks)
    end

    def validate_token!
      decoded_token = JWT.decode(
        access_token,
        nil,
        true,
        algorithms: JWT_ALG,
        jwks: ->(options) { jwks_loader(options) },
        iss: "https://securetoken.google.com/#{FIREBASE_PROJECT_ID}",
        verify_iss: true,
        aud: FIREBASE_PROJECT_ID,
        verify_aud: true,
      )

      user_data = decoded_token[0]

      raise InvalidDataError.new('Issuing time must be in the past') if user_data['iat'] >= Time.now.to_i
      raise InvalidDataError.new('Auth time must be in the past') if user_data['auth_time'] >= Time.now.to_i
      raise InvalidDataError.new('Sub value is missing or blank') if user_data['sub'].blank?
      raise InvalidDataError.new('Email is missing or blank') if user_data['email'].blank?

      user_data
    end
  end
end
