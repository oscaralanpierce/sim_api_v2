# frozen_string_literal: true

FactoryBot.define do
  factory(:user) do
    sequence(:uid) {|n| "foobar#{n}" }
    sequence(:email) {|n| "foo#{n}@example.com" }
    display_name { 'Jane Doe' }
  end
end
