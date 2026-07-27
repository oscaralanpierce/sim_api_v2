# frozen_string_literal: true

FactoryBot.define do
  factory :playthrough do
    user

    sequence(:name) {|n| "My Fabulous Playthrough #{n}" }
  end
end
