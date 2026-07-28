# frozen_string_literal: true

require 'service/error_result'

RSpec.describe Service::ErrorResult do
  it 'includes an error' do
    result = described_class.new('Oh no')

    expect(result.errors).to eq(['Oh no'])
  end

  it 'includes an errors array' do
    result = described_class.new(['Oh no', 'Good heavens'])

    expect(result.errors).to eq(['Oh no', 'Good heavens'])
  end

  it 'must include errors' do
    expect { described_class.new(nil) }
      .to raise_error(described_class::InvalidErrorResult)
  end

  it "doesn't define a status" do
    result = described_class.new('Oh no')

    expect { result.status }
      .to raise_error(NotImplementedError)
  end
end
