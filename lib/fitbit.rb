# -*- coding: utf-8 -*-
require 'mechanize'
require 'active_support'
require 'active_support/time'
require 'active_support/core_ext'

module FitbitEver
  class Crawler
    LOGIN_URL = 'https://www.fitbit.com/login'
    ACTIVITY_URL = 'http://www.fitbit.com/activities'
    SLEEP_URL = 'http://www.fitbit.com/sleep'
    CERT_PATH = '../config/fitbit.cer'
    
    def initialize(mail, password)
      @mail = mail
      @password = password
      @activity_url = ACTIVITY_URL + get_date
      @sleep_url = SLEEP_URL + get_date
      @agent = login
    end
    
    def get_date
      yday = 24.hours.ago
      "/%s/%02d/%02d" % [yday.year, yday.month, yday.day]
    end
    
    def login
      agent = Mechanize.new
      agent.read_timeout = 30
      agent.user_agent_alias = "Windows IE 8"
      agent.ca_file = CERT_PATH
      login_page = agent.get(LOGIN_URL)
      form = login_page.form_with(:name => "login")
      form.field_with(:name => "email") {|field| field.value = @mail}
      form.field_with(:name => "password") {|field| field.value = @password}
      form.click_button
      agent.submit(form)
      agent
    end
    
    def activity
      data = {}
      (@agent.get(@activity_url)/'div[id="dailyTotals"]/div/div[class="total"]').each do |content|
        kind = content.search('div[class="substance"]').text.strip
        amount = content.search('div[class="amount"]').text.strip
        data[kind] = amount
      end
      data
    end
    
    def sleep
      data = {}
      (@agent.get(@sleep_url)/'ul[id="sleepSummary"]/li').each do |content|
        elem = content.search('span')
        kind = elem[0].text.strip
        amount = elem[1].text.strip
        data[kind] = amount
      end
      amount = (@agent.get(@sleep_url)/'div[id="sleepIndicator"]/span/span').text.strip
      kind = "Your sleep efficiency"
      data[kind] = amount
      data
    end
  end
end
