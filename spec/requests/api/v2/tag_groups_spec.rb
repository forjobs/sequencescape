# frozen_string_literal: true

require 'rails_helper'

describe 'TagGroups API', with: :api_v2 do
  context 'with multiple TagGroups' do
    before do
      create_list(:tag_group, 5)
      # Invisible tag groups should be hidden
      create_list(:tag_group, 2, visible: false)
    end

    it 'sends a list of tag_groups' do
      api_get '/api/v2/tag_groups'
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(5)
    end

    # Check filters, ESPECIALLY if they aren't simple attribute filters
  end

  context 'with a TagGroup' do
    let(:resource_model) { create :tag_group }

    let(:payload) do
      {
        'data' => {
          'id' => resource_model.id,
          'type' => 'tag_groups',
          'attributes' => {
            # Set new attributes
          }
        }
      }
    end

    it 'sends an individual TagGroup' do
      api_get "/api/v2/tag_groups/#{resource_model.id}"
      expect(response).to have_http_status(:success)
      expect(json.dig('data', 'type')).to eq('tag_groups')
    end
  end
end
