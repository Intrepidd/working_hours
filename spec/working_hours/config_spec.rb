require 'spec_helper'

describe WorkingHours::Config do

  before :each do
    WorkingHours::Config.reset!
  end

  describe '#working_hours' do

    let(:config) { WorkingHours::Config.working_hours }

    it 'has a default config' do
      expect(config).to be_kind_of(Hash)
    end

    it 'should have a key for each week day' do
      [:mon, :tue, :wed, :thu, :fri].each do |d|
        expect(config[d]).to be_kind_of(Array)
      end
    end

    it 'should be changeable' do
      time_sheet = {:mon => ['08:00', '14:00']}
      WorkingHours::Config.working_hours = time_sheet
      expect(config).to eq(time_sheet)
    end

    it 'should support multiple timespan per day'
    it 'should validate invalid entries'
    it 'should warn on extraneous keys'
    it 'should support midnight at start'
    it 'should support midnight at end'

  end

  describe '#holidays' do
    let (:config) { WorkingHours::Config.holidays }

    it 'has a default config' do
      expect(config).to eq([])
    end

    it 'should be changeable' do
      WorkingHours::Config.holidays = [Date.today]
      expect(config).to eq([Date.today])
    end
  end

  describe '#time_zone' do

    it 'should accept a custom timezone (string)'
    it 'should accept a custom timezone (TimeZone)'
    it 'defaults to Time.zone'

  end

end
