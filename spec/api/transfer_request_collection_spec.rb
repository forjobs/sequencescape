require 'rails_helper'
require 'shared_contexts/limber_shared_context'

describe '/api/1/transfer_request_collection' do
  include_context 'a limber target plate with submissions'

  subject { '/api/1/transfer_request_collection' }

  let(:authorised_app) { create :api_application }

  let(:asset) { create :tagged_well }
  let(:target_asset) { create :empty_library_tube }
  let(:user) { create :user }

  context '#post' do
    let(:payload) do
      %{{
        "transfer_request_collection":{
          "user": "#{user.uuid}",
          "transfer_requests": [
            {"source_asset":"#{asset.uuid}", "target_asset": "#{target_asset.uuid}"}
          ]
        }
      }}
    end

    let(:response_body) {
      %{{
        "transfer_request_collection": {
          "actions": {},
          "transfer_requests": {
            "size": 1,
            "actions": {}
          },
          "user": {
            "uuid": "#{user.uuid}",
            "actions": {}
          }
        }
      }}
    }
    let(:response_code) { 201 }

    it 'supports resource creation' do
      api_request :post, subject, payload
      expect(JSON.parse(response.body)).to include_json(JSON.parse(response_body))
      expect(status).to eq(response_code)
    end
  end
end
