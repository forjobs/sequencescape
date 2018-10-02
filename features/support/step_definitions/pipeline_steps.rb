Given /^I have a pipeline called "([^\"]*)"$/ do |name|
  request_type = FactoryBot.create :request_type
  pipeline = FactoryBot.create :pipeline, name: name, request_types: [request_type]
  pipeline.workflow.update_attributes!(item_limit: 8)
  task = FactoryBot.create :task, name: 'Task1', workflow: pipeline.workflow
end

Given /^I have a batch in "([^\"]*)"$/ do |pipeline|
  step %Q{I have a "pending" batch in "#{pipeline}"}
end

Given /^I have a "([^\"]*)" batch in "([^\"]*)"$/ do |state, pipeline|
  @batch = FactoryBot.create :batch, pipeline: Pipeline.find_by(name: pipeline), state: state, production_state: nil
end

Given /^I have a control called "([^\"]*)" for "([^\"]*)"$/ do |name, pipeline_name|
  control = FactoryBot.create :control, name: name, pipeline: Pipeline.find_by(name: pipeline_name)
end

def pipeline_name_to_asset_type(pipeline_name)
  return :sample_tube if pipeline_name.downcase.include?('library preparation')
  return :well if pipeline_name.downcase.include?('from strip-tubes')
  :library_tube
end

def create_request_for_pipeline(pipeline_name, options = {})
  pipeline = Pipeline.find_by(name: pipeline_name) or raise StandardError, "Cannot find pipeline #{pipeline_name.inspect}"
  request_metadata = FactoryBot.create :"request_metadata_for_#{pipeline.request_types.first.key}"
  request_parameters = options.merge(request_type: pipeline.request_types.last, asset: FactoryBot.create(pipeline_name_to_asset_type(pipeline_name)), request_metadata: request_metadata)
  FactoryBot.create(:request_with_submission, request_parameters).tap do |request|
    request.asset.update_attributes!(barcode: request.asset.id % 9999999)
    request.asset.create_scanned_into_lab_event!(content: '2018-01-01')
  end
end

Given /^I have a request for "([^\"]*)"$/ do |pipeline_name|
  create_request_for_pipeline(pipeline_name)
end

Given /^I on batch page$/ do
  visit "/batches/#{Batch.last.id}"
end

When /^I check request "(\d+)" for pipeline "([^"]+)"/ do |request_number, pipeline_name|
  # TODO: find the request checkboxes in the current page (by name "request_... ") so we don't need
  # do give the pipelin name
  request_number = request_number.to_i
  pipeline = Pipeline.find_by(name: pipeline_name)

  request = pipeline.requests.inbox[request_number - 1]
  check("request_#{request.id}")
end

Then /^the requests from "([^\"]+)" batches should not be in the inbox$/ do |name|
  pipeline = Pipeline.find_by(name: name) or raise StandardError, "Cannot find pipeline #{name.inspect}"
  raise StandardError, "There are no batches in #{name.inspect}" if pipeline.batches.empty?
  pipeline.batches.each do |batch|
    batch.requests.each do |request|
      assert page.has_no_xpath?("//*[@id='request_#{request.id}']")
    end
  end
end

Given /^the maximum batch size for the pipeline "([^\"]+)" is (\d+)$/ do |name, max_size|
  pipeline = Pipeline.find_by(name: name) or raise StandardError, "Cannot find pipeline #{name.inspect}"
  pipeline.update_attributes!(max_size: max_size.to_i)
end

Given /^the pipeline "([^\"]+)" accepts "([^\"]+)" requests$/ do |pipeline_name, request_name|
  pipeline     = Pipeline.find_by(name: pipeline_name) or raise StandardError, "Cannot find pipeline #{pipeline_name.inspect}"
  request_type = RequestType.find_by(name: request_name) or raise StandardError, "Cannot find request type #{request_name.inspect}"
  pipeline.update_attributes!(request_types: [request_type])
end

Given /^the last request is in the "([^\"]+)" state$/ do |state|
  Request.last.update_attributes!(state: state)
end
