# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:uid) {|n| "foobar#{n}" }
    sequence(:email) {|n| "foo#{n}@example.com" }
    display_name { 'Jane Doe' }
    photo_url { 'https://lh3.googleusercontent.com/a/userprofilephotourl' }

    # This is intended to be used with the AuthHelper methods
    # in /spec/support/auth_helper.rb
    factory :authenticated_user do
      uid { 'somestring' }
      email { 'someuser@gmail.com' }
    end
  end
end
