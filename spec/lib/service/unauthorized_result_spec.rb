# frozen_string_literal: true

require 'service/unauthorized_result'

RSpec.describe Service::UnauthorizedResult do
  subject(:result) { described_class.new(options) }

  let(:options) { { error: 'This should be generic' } }

  describe 'setting errors' do
    it 'ignores passed-in options and sets a generic error message' do
      expect(result.errors).to eq(['Authorization failed'])
    end
  end

  describe '#status' do
    it 'is :unauthorized' do
      expect(result.status).to eq(:unauthorized)
    end
  end
end
