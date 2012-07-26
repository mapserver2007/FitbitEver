# -*- coding: utf-8 -*-
require File.expand_path(File.dirname(__FILE__) + '/../spec/spec_helper')

describe FitbitEver, 'が実行する処理' do
  before do
    @fitbit_config = FitbitEver.fitbit_auth
    @evernote_auth_token = FitbitEver.evernote_auth
    @evernote_config = FitbitEver.evernote_config
  end
  
  let(:fitbit) {
    FitbitEver::Crawler.new(@fitbit_config["mail"], @fitbit_config["password"])
  }
  
  describe 'Fitbitのデータ取得処理' do
    it "Activityデータが取得できること" do
      data = fitbit.activity
      data["Calories"].should_not be_empty
      data["Steps"].should_not be_empty
      data["Distance"].should_not be_empty
      data["Floors Climbed"].should_not be_empty
    end
    
    it "Sleepデータが取得できること" do
      data = fitbit.sleep
      data["You went to bed at"].should_not be_empty
      data["Time to fall asleep"].should_not be_empty
      data["Times awakened"].should_not be_empty
      data["You were in bed for"].should_not be_empty
      data["Actual sleep time"].should_not be_empty
    end
  end
  
  describe "Evernoteへの投稿処理" do
    let(:evernote) { 
      FitbitEver::MyEvernote.new(@evernote_auth_token)
    }
    
    it "今日のアクティビティの登録が成功すること" do
      data = fitbit.activity.merge(fitbit.sleep)
      res = evernote.add_note(data, "Development", nil, @evernote_config["tags"])
      # notebook: Development
      res.notebookGuid.should == "2c2b6d3a-9f5a-48a2-9a40-8d617cc556d7"
      # tag: LifeLog
      res.tagGuids[0].should == "e554deb8-7777-48db-afa0-9c76d06e6d33"
      # tag: Fitbit
      res.tagGuids[1].should == "a5613bab-2298-4f52-aa55-245cb4774d39"
    end
  end
end
