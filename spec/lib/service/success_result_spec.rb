# frozen_string_literal: true

require 'service/success_result'

RSpec.describe Service::SuccessResult do
  it 'includes the resource passed in' do
    result = described_class.new('foo')

    expect(result.resource).to eq('foo')
  end

  describe '#status' do
    it 'raises a NotImplementedError' do
      result = described_class.new

      expect { result.status }
        .to raise_error(NotImplementedError)
    end
  end
end
