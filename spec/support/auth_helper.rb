# frozen_string_literal: true

require 'rspec/mocks'

module AuthHelper
  include RSpec::Mocks

  USER_DATA = JSON.parse(
    File.read(
      Rails.root.join('spec', 'support', 'fixtures', 'auth', 'google_auth_payload.json'),
    ),
  )

  def stub_successful_login
    allow(JWT).to receive(:decode).and_return(
      [
        USER_DATA.merge({
          'iat' => Time.now.to_i - 60,
          'exp' => Time.now.to_i + 60,
          'auth_time' => Time.now.to_i - 60,
        }),
      ],
    )
  end

  def stub_failed_login
    allow(JWT).to receive(:decode).and_raise(JWT::DecodeError.new('Womp womp'))
  end
end
