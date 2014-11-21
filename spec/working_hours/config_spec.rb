require 'spec_helper'
require 'rspec-api-matchers'

describe WorkingHours::Config do

  describe '.working_hours' do

    let(:config) { WorkingHours::Config.working_hours }

    it 'has a default config' do
      expect(config).to be_kind_of(Hash)
    end

    it 'sorts the config hash' do
      include RSpecApi::Matchers::Sort
      not_sorted_hash = {
        :tue => {'13:00' => '17:00', '09:00' => '12:00'},
        :wed => {'09:00' => '12:00', '13:00' => '17:00'},
        :thu => {'09:00' => '12:00', '13:00' => '17:00'},
        :fri => {'13:00' => '17:00', '09:00' => '12:00'},
        :sat => {'10:00' => '15:00'}
      }
      sorted_hash = {
        :tue => {'09:00' => '12:00', '13:00' => '17:00'},
        :wed => {'09:00' => '12:00', '13:00' => '17:00'},
        :thu => {'09:00' => '12:00', '13:00' => '17:00'},
        :fri => {'09:00' => '12:00', '13:00' => '17:00'},
        :sat => {'10:00' => '15:00'}
      }
      WorkingHours::Config.working_hours = not_sorted_hash
      expect(sorted_hash).to eql WorkingHours::Config.working_hours
    end

    it 'is thread safe' do
      expect {
        Thread.new {
          WorkingHours::Config.working_hours = {:mon => {'08:00' => '14:00'}}
        }.join
      }.not_to change { WorkingHours::Config.working_hours }
    end

    it 'is fiber safe' do
      expect {
        Fiber.new {
          WorkingHours::Config.working_hours = {:mon => {'08:00' => '14:00'}}
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

    it "recomputes precompiled when modified" do
      time_sheet = {:mon => {'08:00' => '14:00'}}
      WorkingHours::Config.working_hours = time_sheet
      expect {
        WorkingHours::Config.working_hours[:tue] = {'08:00' => '14:00'}
      }.to change { WorkingHours::Config.precompiled[:working_hours][2] }
      expect {
        WorkingHours::Config.working_hours[:mon]['08:00'] = '15:00'
      }.to change { WorkingHours::Config.precompiled[:working_hours][1] }
    end

    describe 'validations' do
      it 'rejects empty hash' do
        expect {
          WorkingHours::Config.working_hours = {}
        }.to raise_error(WorkingHours::InvalidConfiguration, "No working hours given")
      end

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

      it 'rejects empty range' do
        expect {
          WorkingHours::Config.working_hours = {:mon => {}}
        }.to raise_error(WorkingHours::InvalidConfiguration, "No working hours given for day `mon`")
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

      it 'does not reject out-of-order, non-overlapping ranges' do
        expect {
          WorkingHours::Config.working_hours = {:mon => {'10:00' => '11:00', '08:00' => '09:00'}}
        }.not_to raise_error
      end
    end
  end

  describe '.holidays' do
    let (:config) { WorkingHours::Config.holidays }

    it 'has a default config' do
      expect(config).to eq([])
    end

    it 'should be changeable' do
      WorkingHours::Config.holidays = [Date.today]
      expect(config).to eq([Date.today])
    end

    it "recomputes precompiled when modified" do
      expect {
        WorkingHours::Config.holidays << Date.today
      }.to change { WorkingHours::Config.precompiled[:holidays] }.by(Set.new([Date.today]))
    end

    describe 'validation' do
      it 'rejects types that cannot be converted into an array' do
        expect {
          WorkingHours::Config.holidays = Object.new
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid type for holidays: Object - must act like an array")
      end

      it 'rejects invalid day' do
        expect {
          WorkingHours::Config.holidays = [Date.today, 42]
        }.to raise_error(WorkingHours::InvalidConfiguration, "Invalid holiday: 42 - must be Date")
      end
    end
  end

  describe '.time_zone' do
    let (:config) { WorkingHours::Config.time_zone }

    it 'defaults to UTC' do
      expect(config).to eq(ActiveSupport::TimeZone['UTC'])
    end

    it 'should accept a String' do
      WorkingHours::Config.time_zone = 'Tokyo'
      expect(config).to eq(ActiveSupport::TimeZone['Tokyo'])
    end

    it 'should accept a TimeZone' do
      WorkingHours::Config.time_zone = ActiveSupport::TimeZone['Tokyo']
      expect(config).to eq(ActiveSupport::TimeZone['Tokyo'])
    end

    it "recomputes precompiled when modified" do
      expect {
        WorkingHours::Config.time_zone.instance_variable_set(:@name, 'Bordeaux')
      }.to change { WorkingHours::Config.time_zone.name }.from('UTC').to('Bordeaux')
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

  describe '.precompiled' do
    subject { WorkingHours::Config.precompiled }

    it 'computes an optimized version' do
      expect(subject).to eq({
          :working_hours => [nil, {32400=>61200}, {32400=>61200}, {32400=>61200}, {32400=>61200}, {32400=>61200}],
          :holidays => Set.new([]),
          :time_zone => ActiveSupport::TimeZone['UTC']
        })
    end

    it 'changes if working_hours changes' do
      expect {
        WorkingHours::Config.working_hours = {:mon => {'08:00' => '14:00'}}
      }.to change {
        WorkingHours::Config.precompiled[:working_hours]
      }.from(
        [nil, {32400=>61200}, {32400=>61200}, {32400=>61200}, {32400=>61200}, {32400=>61200}]
      ).to(
        [nil, {28800=>50400}]
      )
    end

    it 'changes if time_zone changes' do
      expect {
        WorkingHours::Config.time_zone = 'Tokyo'
      }.to change {
        WorkingHours::Config.precompiled[:time_zone]
      }.from(ActiveSupport::TimeZone['UTC']).to(ActiveSupport::TimeZone['Tokyo'])
    end

    it 'changes if holidays changes' do
      expect {
        WorkingHours::Config.holidays = [Date.new(2014, 8, 1), Date.new(2014, 7, 1)]
      }.to change {
        WorkingHours::Config.precompiled[:holidays]
      }.from(Set.new([])).to(Set.new([Date.new(2014, 8, 1), Date.new(2014, 7, 1)]))
    end

    it 'changes if config is reset' do
      WorkingHours::Config.time_zone = 'Tokyo'
      expect {
        WorkingHours::Config.reset!
      }.to change {
        WorkingHours::Config.precompiled[:time_zone]
      }.from(ActiveSupport::TimeZone['Tokyo']).to(ActiveSupport::TimeZone['UTC'])
    end

    it 'is computed only once' do
      precompiled = WorkingHours::Config.precompiled
      3.times { WorkingHours::Config.precompiled }
      expect(WorkingHours::Config.precompiled).to be(precompiled)
    end
  end
end
