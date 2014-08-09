require 'spec_helper'

describe WorkingHours::Computation do
  include WorkingHours::Computation

  describe '.advance_to_working_time' do
    it 'jumps non-working day' do
      WorkingHours::Config.holidays = [Date.new(2014, 5, 1)]
      expect(advance_to_working_time(Time.utc(2014, 5, 1, 12, 0))).to eq(Time.utc(2014, 5, 2, 9, 0))
      expect(advance_to_working_time(Time.utc(2014, 6, 1, 12, 0))).to eq(Time.utc(2014, 6, 2, 9, 0))
    end

    it 'returns self during working hours' do
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 9, 0))).to eq(Time.utc(2014, 4, 7, 9, 0))
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 16, 59))).to eq(Time.utc(2014, 4, 7, 16, 59))
    end

    it 'jumps outside working hours' do
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 8, 59))).to eq(Time.utc(2014, 4, 7, 9, 0))
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 17, 0))).to eq(Time.utc(2014, 4, 8, 9, 0))
    end

    it 'move between timespans' do
      WorkingHours::Config.working_hours = {mon: {'07:00' => '12:00', '13:00' => '18:00'}}
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 11, 59))).to eq(Time.utc(2014, 4, 7, 11, 59))
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 12, 0))).to eq(Time.utc(2014, 4, 7, 13, 0))
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 12, 59))).to eq(Time.utc(2014, 4, 7, 13, 0))
      expect(advance_to_working_time(Time.utc(2014, 4, 7, 13, 0))).to eq(Time.utc(2014, 4, 7, 13, 0))
    end

    it 'works with any timezone (consider config in same timezone)' do
      time_with_zone = Time.utc(2014, 4, 7, 0, 0).in_time_zone(ActiveSupport::TimeZone['Tokyo'])
      expect(advance_to_working_time(time_with_zone)).to eq(time_with_zone)
      expect(advance_to_working_time(Time.new(2014, 4, 7, 17, 0, 0 , "+05:00"))).to eq(Time.new(2014, 4, 8, 9, 0, 0 , "+05:00"))
    end
  end

  describe '.working_day?' do
    it 'returns true on working day' do
      expect(working_day?(Date.new(2014, 4, 7))).to be(true)
    end

    it 'skips holidays' do
      WorkingHours::Config.holidays = [Date.new(2014, 5, 1)]
      expect(working_day?(Date.new(2014, 5, 1))).to be(false)
    end

    it 'skips non working days' do
      expect(working_day?(Date.new(2014, 4, 6))).to be(false)
    end
  end

  describe '.in_working_hours?' do
    it 'returns false in non-working day' do
      WorkingHours::Config.holidays = [Date.new(2014, 5, 1)]
      expect(in_working_hours?(Time.utc(2014, 5, 1, 12, 0))).to be(false)
      expect(in_working_hours?(Time.utc(2014, 6, 1, 12, 0))).to be(false)
    end

    it 'returns true during working hours' do
      expect(in_working_hours?(Time.utc(2014, 4, 7, 9, 0))).to be(true)
      expect(in_working_hours?(Time.utc(2014, 4, 7, 16, 59))).to be(true)
    end

    it 'returns false outside working hours' do
      expect(in_working_hours?(Time.utc(2014, 4, 7, 8, 59))).to be(false)
      expect(in_working_hours?(Time.utc(2014, 4, 7, 17, 0))).to be(false)
    end

    it 'works with multiple timespan' do
      WorkingHours::Config.working_hours = {mon: {'07:00' => '12:00', '13:00' => '18:00'}}
      expect(in_working_hours?(Time.utc(2014, 4, 7, 11, 59))).to be(true)
      expect(in_working_hours?(Time.utc(2014, 4, 7, 12, 0))).to be(false)
      expect(in_working_hours?(Time.utc(2014, 4, 7, 12, 59))).to be(false)
      expect(in_working_hours?(Time.utc(2014, 4, 7, 13, 0))).to be(true)
    end

    it 'works with any timezone' do
      time_with_zone = Time.utc(2014, 4, 7, 0, 0).in_time_zone(ActiveSupport::TimeZone['Tokyo'])
      # Monday 00:00 am UTC is 09:00 am Tokyo, working time !
      expect(in_working_hours?(time_with_zone)).to be(true)
    end
  end
end