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
        expect(config[d]).to be_kind_of(Hash)
      end
    end

    it 'should be changeable' do
      time_sheet = {:mon => {'08:00' => '14:00'}}
      WorkingHours::Config.working_hours = time_sheet
      expect(config).to eq(time_sheet)
    end

    it 'should support multiple timespan per day' do
      time_sheet = {:mon => {'08:00' => '12:00', '14:00' => '18:00'}}
      WorkingHours::Config.working_hours = time_sheet
      expect(config).to eq(time_sheet)
    end

    it 'should support midnight at start'
    it 'should support midnight at end'

    describe 'validation' do
      it 'rejects invalid day' do
        expect {
          WorkingHours::Config.working_hours = {:mon => 1, 'tuesday' => 2, 'wed' => 3}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid day identifier(s): tuesday, wed - must be 3 letter symbols")
      end

      it 'rejects other type than hash' do
        expect {
          WorkingHours::Config.working_hours = {:mon => []}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid type for `mon`: Array - must be Hash")
      end

      it 'rejects invalid time format' do
        expect {
          WorkingHours::Config.working_hours = {:mon => {'8:0' => '12:00'}}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid time: 8:0 - must be 'HH:MM'")

        expect {
          WorkingHours::Config.working_hours = {:mon => {'08:00' => '24:00'}}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid time: 24:00 - must be 'HH:MM'")
      end

      it 'rejects invalid range' do
        expect {
          WorkingHours::Config.working_hours = {:mon => {'12:30' => '12:00'}}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid range: 12:30 => 12:00 - ends before it starts")
      end

      it 'rejects overlapping range' do
        expect {
          WorkingHours::Config.working_hours = {:mon => {'08:00' => '13:00', '12:00' => '18:00'}}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid range: 12:00 => 18:00 - overlaps previous range")
      end
    end
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
