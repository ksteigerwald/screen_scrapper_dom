#!/usr/bin/env ruby

require 'rubygems'
require 'mechanize'

a = Mechanize.new
a.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE

a.get('https://www.dom.com/residential/dominion-virginia-power/sign-in') do |page|

  profile_page = page.form_with(:action => '/residential/dominion-virginia-power/sign-in') do |f|
    f.user = ARGV[0]
    f.password = ARGV[1]
  end.click_button

  puts profile_page.to_yaml
end
