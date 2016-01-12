#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'
require 'highline'

cli = HighLine.new
user = cli.ask "Dominion Power User Name:" || ENV['DOM_USER']
pass = cli.ask "Dominion Power Password:" || ENV['DOM_PASS']

a = Mechanize.new
a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

a.get('https://www.dom.com/residential/dominion-virginia-power/sign-in') do |page|

  profile_page = page.form_with(:action => '/residential/dominion-virginia-power/sign-in') do |f|
    f.user = user
    f.password = pass
  end.click_button

  #billing_page = a.click(profile_page.link_with(:text => 'Billing'))
  puts profile_page.links.to_yaml
  detailed_energy_usage_page = a.click(profile_page.link_with(text: 'Detailed Energy Usage')) do |p|

  end
end
