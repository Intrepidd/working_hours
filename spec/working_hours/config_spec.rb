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

    it 'is thread safe' do
      expect {
        Thread.new {
          WorkingHours::Config.working_hours = {}
        }.join
      }.not_to change { WorkingHours::Config.working_hours }
    end

    it 'is fiber safe' do
      expect {
        Fiber.new {
          WorkingHours::Config.working_hours = {}
        }.resume
      }.not_to change { WorkingHours::Config.working_hours }
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

    describe 'validation' do
      it 'rejects other type than array' do
        expect {
          WorkingHours::Config.holidays = {}
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid type for holidays: Hash - must be Array")
      end

      it 'rejects invalid day' do
        expect {
          WorkingHours::Config.holidays = [Date.today, 42]
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid holiday: 42 - must be Date")
      end
    end
  end

  describe '#time_zone' do
    let (:config) { WorkingHours::Config.time_zone }

    it 'defaults to local time zone' do
      expect(config).to eq(Time.zone)
    end

    it 'should accept a String' do
      WorkingHours::Config.time_zone = 'Tokyo'
      expect(config).to eq(ActiveSupport::TimeZone['Tokyo'])
    end

    it 'should accept a TimeZone' do
      WorkingHours::Config.time_zone = ActiveSupport::TimeZone['Tokyo']
      expect(config).to eq(ActiveSupport::TimeZone['Tokyo'])
    end

    describe 'validation' do
      it 'rejects invalid types' do
        expect {
          WorkingHours::Config.time_zone = 02
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid time zone: 2 - must be String or ActiveSupport::TimeZone")
      end

      it 'rejects unknown time zone' do
        expect {
          WorkingHours::Config.time_zone = 'Bordeaux'
        }.to raise_error(WorkingHours::InvalidConfiguration, "Unknown time zone: Bordeaux")
      end
    end
  end
  
end
