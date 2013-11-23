#
# Support scaffolding for the example test.
# Replace with your own.
#

When(/^I open "(.*?)"$/) do |url|
  browser.goto url
end

require 'watir-webdriver'

def browser
  $browser ||= Watir::Browser.new :chrome
end


