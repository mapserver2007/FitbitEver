# -*- coding: utf-8 -*-
require 'fitbit'
require 'evernote'

module FitbitEver
  VERSION = '0.0.1'
  
  class << self
    # 設定のロード
    def load_config(path)
      p File.exists?(path)
      p path
      File.exists?(path) ? YAML.load_file(path) : ENV
    end
    
    # clockwork実行時間設定
    def clock_time
      path = File.dirname(__FILE__) + "/../config/clock.yml"
      load_config(path)["schedule"]
    end
    
    # Fitbit設定
    def fitbit_auth
      path = File.dirname(__FILE__) + "/../config/fitbit.auth.yml"
      YAML.load_file(path)
    end
    
    # Evernote設定
    def evernote_config
      path = File.dirname(__FILE__) + "/../config/evernote.yml"
      load_config(path)
    end
    
    # Evernote認証情報
    def evernote_auth_token
      path = File.dirname(__FILE__) + "/../config/evernote.auth.yml"
      load_config(path)["auth_token"]
    end
    
    def run
      fa = fitbit_auth
      ec = evernote_config
      fitbit = FitbitEver::Crawler.new(fa["mail"], fa["password"])
      data = fitbit.activity.merge(fitbit.sleep)
      evernote = FitbitEver::MyEvernote.new(evernote_auth_token)
      evernote.add_note(data, ec["notebook"], ec["stack"], ec["tags"])
    end
  end
end
