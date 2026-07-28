# frozen_string_literal: true

require 'rails_helper'

RSpec.describe Playthrough, type: :model do
  describe 'validations' do
    subject(:validate) { playthrough.validate }

    let(:playthrough) { build(:playthrough) }

    it 'must have a unique name per user ID' do
      existing_playthrough = create(:playthrough)
      playthrough.user = existing_playthrough.user
      playthrough.name = existing_playthrough.name
      validate

      expect(playthrough.errors[:name]).to include 'must be unique'
    end

    it "can have the same name as another user's playthrough" do
      existing_playthrough = create(:playthrough)
      playthrough.name = existing_playthrough.name

      expect(playthrough).to be_valid
    end
  end

  describe 'name generation' do
    context 'when the name is set to a valid value' do
      let(:playthrough) { create(:playthrough, name: 'new game') }

      it 'keeps the name assigned' do
        expect(playthrough.name).to eq('new game')
      end
    end

    context 'when the name has leading or trailing whitespace' do
      let(:playthrough) { create(:playthrough, name: "\t\nnew game  ") }

      it 'strips the whitespace' do
        expect(playthrough.name).to eq('new game')
      end
    end

    context 'when the name is blank' do
      context 'when there are no other playthroughs' do
        let(:user) { create(:user) }

        it 'sets the name to "My Playthrough 1"' do
          playthrough = described_class.create!(user:)

          expect(playthrough.name).to eq('My Playthrough 1')
        end
      end

      context 'when there are no playthroughs with a number of at least 0' do
        let!(:existing_playthrough) { create(:playthrough, name: 'My Playthrough -1') }

        it 'sets the name to "My Playthrough 1"' do
          playthrough = described_class.create!(user: existing_playthrough.user)

          expect(playthrough.name).to eq('My Playthrough 1')
        end
      end

      context 'when there are playthroughs with a number higher than 0' do
        let(:user) { create(:user) }

        before do
          # Should only apply to playthroughs belonging to the same user
          create(:playthrough, name: 'My Playthrough 8')

          create(:playthrough, user:, name: 'My Playthrough -2')
          create(:playthrough, user:, name: 'My Playthrough 1')
          create(:playthrough, user:, name: 'My Playthrough 7')
        end

        it 'sets the name to the next highest integer' do
          playthrough = described_class.create!(user:)

          expect(playthrough.name).to eq('My Playthrough 8')
        end
      end

      describe 'edge cases' do
        it 'is case-sensitive' do
          existing_playthrough = create(:playthrough, name: 'my playthrough 2')
          playthrough = described_class.create!(user: existing_playthrough.user)

          expect(playthrough.name).to eq('My Playthrough 1')
        end

        it "doesn't consider playthroughs with additional characters in their names" do
          existing_playthrough = create(:playthrough, name: 'My Playthrough  2')
          playthrough = described_class.create!(user: existing_playthrough.user)

          expect(playthrough.name).to eq('My Playthrough 1')
        end

        it "doesn't consider playthroughs with a decimal value in their names" do
          existing_playthrough = create(:playthrough, name: 'My Playthrough 2.0')
          playthrough = described_class.create!(user: existing_playthrough.user)

          expect(playthrough.name).to eq('My Playthrough 1')
        end

        it 'replaces an all-whitespace name' do
          playthrough = described_class.create!(user: create(:user), name: '   ')

          expect(playthrough.name).to eq('My Playthrough 1')
        end
      end
    end
  end
end
