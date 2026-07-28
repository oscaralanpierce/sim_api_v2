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

    factory :user_with_playthroughs do
      transient do
        playthrough_count { 2 }
      end

      after(:create) do |user, evaluator|
        create_list(:playthrough, evaluator.playthrough_count, user:)
      end

      factory :authenticated_user_with_playthroughs do
        uid { 'somestring' }
        email { 'someuser@gmail.com' }
      end
    end
  end
end
