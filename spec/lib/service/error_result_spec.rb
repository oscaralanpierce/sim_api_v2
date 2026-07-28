# frozen_string_literal: true

require 'service/error_result'

RSpec.describe Service::ErrorResult do
  it 'includes an error' do
    result = described_class.new(error: 'Oh no')

    expect(result.errors).to eq(['Oh no'])
  end

  it 'includes an errors array' do
    result = described_class.new(errors: ['Oh no', 'Good heavens'])

    expect(result.errors).to eq(['Oh no', 'Good heavens'])
  end

  it 'incorporates an error into the array if both are given' do
    result = described_class.new(errors: ['Good heavens'], error: 'Oh no')

    expect(result.errors).to eq(['Good heavens', 'Oh no'])
  end

  it 'must include errors' do
    expect { described_class.new }
      .to raise_error(described_class::InvalidErrorResult)
  end

  it "doesn't define a status" do
    result = described_class.new(error: 'Oh no')

    expect { result.status }
      .to raise_error(NotImplementedError)
  end
end
