# frozen_string_literal: true

require 'rails_helper'

RSpec.describe User, type: :model do
  describe 'validations' do
    subject(:validate) { user.validate }

    let(:user) { build(:user) }

    it 'is valid with required attributes defined' do
      expect(user).to be_valid
    end

    it 'is invalid without a uid' do
      user.uid = nil
      validate

      expect(user.errors[:uid]).to include "can't be blank"
    end

    it 'is invalid with a non-unique uid' do
      existing_user = create(:user)
      user.uid = existing_user.uid
      validate

      expect(user.errors[:uid]).to include 'must be unique'
    end

    it 'is invalid without an email' do
      user.email = nil
      validate

      expect(user.errors[:email]).to include "can't be blank"
    end

    it 'is invalid with a duplicate email' do
      existing_user = create(:user)
      user.email = existing_user.email
      validate

      expect(user.errors[:email]).to include 'must be unique'
    end
  end

  describe '::create_or_update_from_google!' do
    subject(:create_or_update_from_google) { described_class.create_or_update_from_google!(google_data) }

    let(:google_data) { JSON.parse(File.read(Rails.root.join('spec', 'support', 'fixtures', 'auth', 'google_auth_payload.json'))) }

    context 'when there is no existing user' do
      it 'creates a new user with values from the Google JWT' do
        expect { create_or_update_from_google }
          .to change(described_class, :count).from(0).to(1)
      end

      it 'populates the user profile with the correct values', :aggregate_failures do
        create_or_update_from_google
        user = described_class.last
        expect(user.uid).to eq('somestring')
        expect(user.email).to eq('someuser@gmail.com')
        expect(user.display_name).to eq('Jane Doe')
        expect(user.photo_url).to eq('https://lh3.googleusercontent.com/a/userprofilephotourl')
      end
    end

    context 'when there is a user with the same uid' do
      context 'when data values have changed' do
        let!(:user) { create(:user, uid: google_data['sub'], email: 'differentemail@gmail.com') }

        it 'updates the user data' do
          create_or_update_from_google

          expect(user.reload.email).to eq('someuser@gmail.com')
        end
      end

      context 'when data values have not changed' do
        let!(:user) { create(:authenticated_user) }

        it 'returns the user' do
          expect(create_or_update_from_google).to eq(user)
        end
      end
    end
  end
end
