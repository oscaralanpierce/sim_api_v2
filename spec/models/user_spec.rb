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
end
