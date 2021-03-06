# frozen_string_literal: true

require 'rails_helper'

describe 'Aliquots API', with: :api_v2 do
  context 'with multiple aliquots' do
    before do
      create_list(:aliquot, 5)
    end

    it 'sends a list of aliquots' do
      api_get '/api/v2/aliquots'
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(5)
    end

    # Check filters, ESPECIALLY if they aren't simple attribute filters
  end

  context 'with a aliquot' do
    let(:resource_model) { create :aliquot }

    it 'sends an individual aliquot' do
      api_get "/api/v2/aliquots/#{resource_model.id}"
      expect(response).to have_http_status(:success)
      expect(json.dig('data', 'type')).to eq('aliquots')
    end

    # let(:payload) do
    #   {
    #     'data' => {
    #       'id' => resource_model.id,
    #       'type' => 'aliquot',
    #       'attributes' => {
    #         # Set new attributes
    #       }
    #     }
    #   }
    # end

    # # Remove if immutable
    # it 'allows update of a aliquot' do
    #   api_patch "/api/v2/aliquot/#{resource_model.id}", payload
    #   expect(response).to have_http_status(:success)
    #   expect(json.dig('data', 'type')).to eq('aliquot')
    #   # Double check at least one of the attributes
    #   # eg. expect(json.dig('data', 'attributes', 'state')).to eq('started')
    # end
  end
end
