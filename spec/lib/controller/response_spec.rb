# frozen_string_literal: true

require 'controller/response'
require 'rails_helper'
require 'service/not_found_result'
require 'service/ok_result'

class TestController < ApplicationController; end

RSpec.describe Controller::Response do
  describe '#execute' do
    subject(:execute) { described_class.new(controller, result, options).execute }

    context 'when the result has no resource and errors are empty' do
      let(:controller) { instance_double(TestController, head: nil) }
      let(:options) { {} }
      let(:result) { Service::NoContentResult.new(resource: nil) }

      it 'returns the status with no response body' do
        execute
        expect(controller).to have_received(:head).with(:no_content)
      end
    end

    context 'when the resource is present but empty' do
      let(:controller) { instance_double(TestController, render: nil) }
      let(:options) { {} }
      let(:result) { Service::OkResult.new(resource: []) }

      it 'returns the empty resource' do
        execute
        expect(controller).to have_received(:render).with(json: [], status: :ok)
      end
    end

    context 'when there is a resource' do
      let(:controller) { instance_double(TestController, render: nil) }
      let(:options) { {} }
      let(:result) { Service::OkResult.new(resource:) }

      let(:resource) do
        {
          id: 927,
          uid: 'janedoe26',
          email: 'jane.doe@gmail.com',
          created_at: Time.zone.now - 2.days,
          updated_at: Time.zone.now,
        }
      end

      it 'renders the resource with the result status' do
        execute
        expect(controller).to have_received(:render).with(json: resource, status: :ok)
      end
    end

    context 'when there are errors' do
      let(:controller) { instance_double(TestController, render: nil) }
      let(:error) { 'Not Found' }
      let(:options) { {} }
      let(:result) { Service::NotFoundResult.new(error:) }

      it 'renders the errors with the result status' do
        execute
        expect(controller).to have_received(:render).with(json: { errors: [error] }, status: :not_found)
      end
    end
  end
end
