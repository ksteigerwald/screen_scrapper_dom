#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'highline'
# Bill information needed includes:
#   - usage (kWh),
#   - bill amount ($),
#   - service start date,
#   - and service end date (also sometimes referred to as the meter read dates),
#   bill due date that can be found under "Analyze Energy Usage"

cli = HighLine.new
user = cli.ask "Dominion Power User Name:" || ENV['DOM_USER']
pass = cli.ask "Dominion Power Password:" || ENV['DOM_PASS']

ajax_headers = { 'X-Requested-With' => 'XMLHttpRequest',
                 'Content-Type' => 'application/json; charset=utf-8',
                 'Accept' => 'application/json, text/javascript, */*'}

agent = Mechanize.new do |a|
  a.user_agent = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
  a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
end

agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

a.get('https://mya.dom.com/') do |page|

  login_form.field_with(name: 'USER').value = user || ENV['DOM_USER']
  login_form.field_with(name: 'PASSWORD').value = password || ENV['DOM_PASS']

  agent.submit(login_form, login_form.buttons.first)

  @profile_page = @a.get('https://mya.dom.com/')
  @billing_page = @a.get('https://mya.dom.com/billing/ViewBilling', ajax_headers)

end
