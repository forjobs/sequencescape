# frozen_string_literal: true

require 'rails_helper'

describe 'WorkOrders API', with: :api_v2 do
  context 'with multiple requests' do
    let(:our_request_type) { create :request_type }
    let(:other_request_type) { create :request_type }
    let(:our_work_order_type) { create :work_order_type, name: our_request_type.key }
    let(:other_work_order_type) { create :work_order_type, name: other_request_type.key }
    before do
      [
        { work_order_type: our_work_order_type, request_type: our_request_type, state: 'pending' },
        { work_order_type: our_work_order_type, request_type: our_request_type, state: 'pending' },
        { work_order_type: our_work_order_type, request_type: our_request_type, state: 'started' },
        { work_order_type: other_work_order_type, request_type: other_request_type, state: 'pending' },
        { work_order_type: other_work_order_type, request_type: other_request_type, state: 'started' }
      ].map do |options|
        wot = options.delete(:work_order_type)
        create(:work_order, requests: [create(:library_request, options)], work_order_type: wot)
      end
    end

    it 'sends a list of work_orders' do
      api_get '/api/v2/work-orders'
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(5)
    end

    it 'allows filtering of work_orders by state' do
      api_get '/api/v2/work-orders?filter[state]=pending'
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(3)
    end

    it 'allows filtering of work_orders by order type' do
      api_get "/api/v2/work-orders?filter[order-type]=#{our_request_type.key}"
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(3)
    end

    it 'allows filtering of work_orders by order type and state' do
      api_get "/api/v2/work-orders?filter[order-type]=#{our_request_type.key}&filter[state]=pending"
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['data'].length).to eq(2)
    end
  end

  context 'with relationships' do
    let(:study) { create :study }
    let(:well) { create :untagged_well }
    let(:sample) { well.samples.first }

    before do
      request = create :library_request, initial_study: study, asset: well, project: nil
      create :work_order, requests: [request]
    end

    let(:expected_includes) do
      # Note, we don't test the actual resource content here.
      [
        { 'type' => 'studies', 'id' => study.id.to_s },
        { 'type' => 'wells', 'id' => well.id.to_s },
        { 'type' => 'samples', 'id' => sample.id.to_s }
      ]
    end

    it 'can inline all necessary information' do
      api_get '/api/v2/work-orders?include=study,samples,project,source-receptacle'
      # test for the 200 status-code
      expect(response).to have_http_status(:success)
      # check to make sure the right amount of messages are returned
      expect(json['included']).to include_json(expected_includes)
    end
  end

  context 'with a request' do
    let(:requests) { create_list :library_request, 2 }
    let(:work_order) { create :work_order, requests: requests }

    it 'sends an individual work_order' do
      api_get "/api/v2/work-orders/#{work_order.id}"
      expect(response).to have_http_status(:success)
      expect(json.dig('data', 'type')).to eq('work-orders')
    end

    let(:payload) do
      {
        'data' => {
          'id' => work_order.id,
          'type' => 'work-orders',
          'attributes' => {
            'state' => 'started',
            'at-risk' => true
          }
        }
      }
    end

    it 'allows update of a work order' do
      api_patch "/api/v2/work-orders/#{work_order.id}", payload
      expect(response).to have_http_status(:success)
      expect(json.dig('data', 'type')).to eq('work-orders')
      expect(json.dig('data', 'attributes', 'state')).to eq('started')
    end
  end
end
