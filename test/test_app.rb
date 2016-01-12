require 'minitest/autorun'
require 'mechanize'

class TestApp < Minitest::Test
  i_suck_and_my_tests_are_order_dependent!

  def setup

    @a = Mechanize.new do |agent|
      agent.user_agent = (Mechanize::AGENT_ALIASES.keys - ['Mechanize']).sample
      agent.agent.http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    end

    @ajax_headers = { 'X-Requested-With' => 'XMLHttpRequest', 'Content-Type' => 'application/json; charset=utf-8', 'Accept' => 'application/json, text/javascript, */*'}
    @login_page = @a.get('https://mya.dom.com/')
    @links = ['/billing/billing', '/usage/dailyenergyusage']

    login_form = @login_page.forms.first #.form_with(:action => '/residential/dominion-virginia-power/sign-in')
    login_form.field_with(name: 'USER').value = ENV['DOM_USER']
    login_form.field_with(name: 'PASSWORD').value = ENV['DOM_PASS']

    assert login_form.field_with(name: 'USER').class.eql?(Mechanize::Form::Text), "No input called 'user' found"
    assert login_form.field_with(name: 'PASSWORD').class.eql?(Mechanize::Form::Field), "No input called 'password' found"

    #@profile_page = login_form.submit(login_form.buttons.first) #@a.submit(login_form, login_form.buttons.first)
    @a.submit(login_form, login_form.buttons.first)
  end

  def test_login_page
    skip("skipping since in setup")
    login_form = @login_page.forms.first #.form_with(:action => '/residential/dominion-virginia-power/sign-in')
    login_form.field_with(name: 'USER').value = ENV['DOM_USER']
    login_form.field_with(name: 'PASSWORD').value = ENV['DOM_PASS']

    assert login_form.field_with(name: 'USER').class.eql?(Mechanize::Form::Text), "No input called 'user' found"
    assert login_form.field_with(name: 'PASSWORD').class.eql?(Mechanize::Form::Field), "No input called 'password' found"

    #@profile_page = login_form.submit(login_form.buttons.first) #@a.submit(login_form, login_form.buttons.first)
    @a.submit(login_form, login_form.buttons.first)
  end

  def test_profile_page
    @profile_page = @a.get('https://mya.dom.com/')
    links = @profile_page.links.map{|link| link if @links.include? link.href }.compact!
    assert links.size == 4, "links not found"
    if @profile_page.body.include? 'Please try again'
      puts "login failed"
    else
      #puts @profile_page.search("*[text() = 'Account Number:']")
    end
  end

  def test_billing_page
    @billing_page = @a.get('https://mya.dom.com/billing/ViewBilling', @ajax_headers)
    table = @billing_page.search("table#billHistoryTable")
    assert table.css('tr > th')[0].text == 'Bill Date', 'billing table did not load'
  end

  def test_energy_usage
    @energy_usage = @a.get('https://mya.dom.com/usage/ViewPastEnergyUsage', @ajax_headers)
    table = @energy_usage.search('table#paymentsTable')
    assert table.css('tr > th')[0].text == 'Meter Read Date', 'Past Enenergy Usage Page did not load'
    #nodes = @energy_usage.search("*[text() = 'Next Meter Read Date']")
    nodes = @energy_usage.search("*[text() = 'Next Meter Read Date']")
    puts nodes.first.parent.parent.to_s
    puts nodes.first.parent.parent.next
  end


end

