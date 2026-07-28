# frozen_string_literal: true

require 'service/ok_result'

RSpec.describe Service::OkResult do
  subject(:result) { described_class.new(resource) }

  let(:resource) { { foo: 'bar' } }

  describe '#resource' do
    it 'is set to the resource passed in' do
      expect(result.resource).to eq(resource)
    end
  end

  describe '#status' do
    it 'is :ok' do
      expect(result.status).to eq(:ok)
    end
  end
end
