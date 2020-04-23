# frozen_string_literal: true

# IMPORTANT: This file is generated by cucumber-rails - edit at your own peril.
# It is recommended to regenerate this file in the future when you upgrade to a
# newer version of cucumber-rails. Consider adding your own code to a new file
# instead of editing this one. Cucumber will automatically load all features/**/*.rb
# files.

require 'uri'
require 'cgi'
require_relative '../paths'
require 'webmock/cucumber'
WebMock.disable_net_connect!(allow_localhost: true)

module WithinHelpers
  def with_scope(locator)
    locator ? within(locator) { yield } : yield
  end
end
World(WithinHelpers)

Given /^(?:|I )am on (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )go to (.+)$/ do |page_name|
  visit path_to(page_name)
end

When /^(?:|I )press "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  with_scope(selector) do
    click_button(button)
  end
end

When /^(?:|I )press the first "([^"]*)"(?: within "([^"]*)")?$/ do |button, selector|
  with_scope(selector) do
    first(:button, button).click
  end
end

When /^(?:|I )follow "([^"]*)"(?: within "([^"]*)")?$/ do |link, selector|
  with_scope(selector) do
    click_link(link)
  end
end

When(/^(?:|I )fill in "([^"]*)" with "([^"]*)"(?: within "([^"]*)")?$/) do |field, value, selector|
  with_scope(selector) do
    fill_in(field, with: value)
  end
end

When(/^(?:|I )fill in "([^"]*)" with the file "([^"]*)"(?: within "([^"]*)")?$/) do |field, value, selector|
  with_scope(selector) do
    attach_file(field, value)
  end
end

# Use this to fill in an entire form with data from a table. Example:
#
#   step fill in the following:
#     | Account Number | 5002       |
#     | Expiry date    | 2009-11-01 |
#     | Note           | Nice guy   |
#     | Wants Email?   |            |
#
# TODO: Add support for checkbox, select og option
# based on naming conventions.
#
When(/^(?:|I )fill in the following(?: within "([^"]*)")?:$/) do |selector, fields|
  selector ||= 'body'
  with_scope(selector) do
    fields.rows_hash.each do |name, value|
      step %Q{I fill in "#{name}" with "#{value}"}
    end
  end
end

When /^(?:|I )select "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    select(value, from: field)
  end
end

When /^(?:|I )choose "([^"]*)" from "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, _selector|
  within_fieldset(field) do
    choose(value, allow_label_click: true)
  end
end

When /^(?:|I )select "([^"]*)" from the first "([^"]*)"(?: within "([^"]*)")?$/ do |value, field, selector|
  with_scope(selector) do
    first(:select, field).select(value)
  end
end

When /^(?:|I )check (the invisible )?"([^"]*)"(?: within "([^"]*)")?$/ do |invisible, field, selector|
  visible = invisible != 'the invisible '
  with_scope(selector) do
    check(field, visible: visible)
  end
end

When /^(?:|I )uncheck "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    uncheck(field)
  end
end

When /^(?:|I )choose "([^"]*)"(?: within "([^"]*)")?$/ do |field, selector|
  with_scope(selector) do
    choose(field)
  end
end

When /^(?:|I )attach the file "([^\"]*)" to "([^\"]*)"(?: within "([^\"]*)")?$/ do |path, field, selector|
  with_scope(selector) do
    attach_file(field, path)
  end
end

Then /^(?:|I )should see "([^\"]*)"(?: within "([^\"]*)")?$/ do |text, selector|
  begin
    with_scope(selector) do
      assert page.has_content?(text), "Could not see #{text} on page (#{page.text})."
    end
  rescue => e
    filename = SecureRandom.uuid
    page.save_screenshot("#{filename}.png")
    raise e
  end
end

Then /^(?:|I )should not see "([^"]*)"(?: within "([^"]*)")?$/ do |text, selector|
  with_scope(selector) do
    assert page.has_no_content?(text)
  end
end

Then /^(?:|I )should not see \/([^\/]*)\/(?: within "([^\"]*)")?$/ do |regexp, selector|
  regexp = Regexp.new(regexp)
  with_scope(selector) do
    assert page.has_no_xpath?('//*', text: regexp)
  end
end

Then /^the "([^"]*)" field(?: within "([^"]*)")? should contain "([^"]*)"$/ do |field, selector, value|
  with_scope(selector) do
    field = find_field(field)
    field_value = field.tag_name == 'textarea' ? field.text : field.value
    assert_match(/#{value}/, field_value)
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should be checked$/ do |label, selector|
  with_scope(selector) do
    assert find_field(label).checked?
  end
end

Then /^the "([^"]*)" checkbox(?: within "([^"]*)")? should not be checked$/ do |label, selector|
  with_scope(selector) do
    assert_not find_field(label).checked?
  end
end

Then /^(?:|I )should be on (.+)$/ do |page_name|
  current_path = URI.parse(current_url).path
  assert_equal path_to(page_name), current_path
end

Then /^show me the page$/ do
  # We don't use save_and_open_source as
  # it passes the source through Nokogiri
  # first and passes it out as xml.
  # require 'capybara/util/save_and_open_page'
  Capybara.save_and_open_page("tmp/#{Time.zone.now.strftime('%Y%m%d%H%M%S')}.htm")
end

Given /^the "([^\"]*)" field is hidden$/ do |field_name|
  assert find_field(field_name, visible: false).visible? == false
end

Given /^I drag "(.*?)" to "(.*?)"$/ do |source, target|
  find(source).drag_to(find(target))
end

When /^I refresh the page$/ do
  visit page.driver.browser.current_url
end

Then /^Pmb is down$/ do
  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_96plate_label_template_code39")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_raise(Errno::ECONNREFUSED)
  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_1dtube_label_template")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_raise(Errno::ECONNREFUSED)
  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_384plate_label_template")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_raise(Errno::ECONNREFUSED)
end

Then /^Pmb has the required label templates$/ do
  body = '{"data":[{"id":"1"}]}'

  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_96plate_label_template")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_return(status: 200, body: body)

  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_1dtube_label_template")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_return(status: 200, body: body)

  stub_request(:get, "#{LabelPrinter::PmbClient.label_templates_filter_url}sqsc_384plate_label_template")
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_return(status: 200, body: body)
end

Then /^Pmb is up and running$/ do
  stub_request(:post, LabelPrinter::PmbClient.print_job_url)
    .with(headers: LabelPrinter::PmbClient.headers)
    .to_return(status: 200, headers: LabelPrinter::PmbClient.headers)
end

When 'I click the header {string}' do |text|
  find('th', text: text).click
end
