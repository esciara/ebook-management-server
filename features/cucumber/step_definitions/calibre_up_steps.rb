# encoding: UTF-8
require 'faraday'
require 'socket'

Given(/^the url of Calibre's home page$/) do
  # the following code is really awful and really need to find out how to change it.
  @local_ip = '192.168.33.40'
  @url = "http://#{@local_ip}:8080"
end

When(/^a web user browses to the url$/) do
  connection = Faraday.new(:url => @url) do |faraday|
    faraday.adapter Faraday.default_adapter
  end
  @response = connection.get('/')
end

Then(/^the connection should be successful$/) do
  @response.success?.should be_true
end

Then(/^the page status should be OK$/) do
  @response.status.should == 200
end

Then(/^the page should have the title "(.*?)"$/) do |title|
  page_title = @response.body.match(/<title>(.*?)<\/title>/)[1]
  expect(page_title).to match(title)
end
