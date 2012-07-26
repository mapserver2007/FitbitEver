require 'rspec'
require 'yaml'
require File.dirname(__FILE__) + "/../lib/fitbit"
require File.dirname(__FILE__) + "/../lib/evernote"

module FitbitEver
  class << self
    def fitbit_auth
      path = File.dirname(__FILE__) + "/../config/fitbit.auth.yml"
      YAML.load_file(path)
    end
    
    def evernote_auth
      path = File.dirname(__FILE__) + "/../config/evernote.auth.yml"
      YAML.load_file(path)["auth_token"]
    end
    
    def evernote_config
      path = File.dirname(__FILE__) + "/../config/evernote.yml"
      YAML.load_file(path)
    end
  end
end