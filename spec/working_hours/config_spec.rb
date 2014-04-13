require 'spec_helper'

describe WorkingHours::Config do

  before :each do
    WorkingHours::Config.reset!
  end


  describe '#working_hours' do

    let(:config) { WorkingHours::Config.working_hours }

    it 'has a default config' do
      config.should be_kind_of(Hash)
    end

    it 'should have a key for each week day' do
      [:mon, :tue, :wed, :thu, :fri].each do |d|
        config[d].should be_kind_of(Array)
      end
    end

    it 'should be changeable' do
      time_sheet = {:mon => ['08:00', '14:00']}
      WorkingHours::Config.working_hours = time_sheet
      config.should == time_sheet
    end

  end

  describe '#holidays' do
    let (:config) { WorkingHours::Config.holidays }

    it 'has a default config' do
      config.should == []
    end

    it 'should be changeable' do
      WorkingHours::Config.holidays = [Date.today]
      config.should == [Date.today]
    end
  end

end
