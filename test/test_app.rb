require 'minitest/autorun'
require 'mechanize'

class TestApp < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def setup
    @a = Mechanize.new do |agent|
      agent.user_agent = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end
    puts @a.user_agent

    @login_page = @a.get('https://mya.dom.com/')
    @links = ['/billing/billing', '/usage/dailyenergyusage']
  end

  def test_login_page

    login_form = @login_page.forms.first #.form_with(:action => '/residential/dominion-virginia-power/sign-in')
    login_form.field_with(name: 'USER').value = ENV['DOM_USER']
    login_form.field_with(name: 'PASSWORD').value = ENV['DOM_PASS']

    puts login_form.to_yaml

    assert login_form.field_with(name: 'USER').class.eql?(Mechanize::Form::Text), "No input called 'user' found"
    assert login_form.field_with(name: 'PASSWORD').class.eql?(Mechanize::Form::Field), "No input called 'password' found"

    #@profile_page = login_form.submit(login_form.buttons.first) #@a.submit(login_form, login_form.buttons.first)
    @a.submit(login_form, login_form.buttons.first)
    @profile_page = @a.get('https://mya.dom.com/')
    puts @profile_page.content

    if @profile_page.body.include? 'Please try again'
      puts "login failed"
    else
      puts @profile_page.search("*[text() = 'Please try again']").to_yaml
    end
  end

  def test_profile_page
    #refute_empty @profile_page.search("*[text() = 'Account Number:']"), "login failed"

  end
end

