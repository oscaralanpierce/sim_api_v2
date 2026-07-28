# frozen_string_literal: true

require 'service/no_content_result'

RSpec.describe Service::NoContentResult do
  subject(:result) { described_class.new('something') }

  it "doesn't set a resource" do
    expect(result.resource).to be_nil
  end

  describe '#status' do
    it 'is :no_content' do
      expect(result.status).to eq(:no_content)
    end
  end
end
