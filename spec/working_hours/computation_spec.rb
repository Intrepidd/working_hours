require 'spec_helper'

describe WorkingHours::Computation do
  include WorkingHours::Computation

  describe '#add_days' do
    it 'can add working days to date' do
      date = Date.new(1991, 11, 15) #Friday
      expect(add_days(date, 2)).to eq(Date.new(1991, 11, 19)) # Tuesday
    end

    it 'can substract working days from date' do
      date = Date.new(1991, 11, 15) #Friday
      expect(add_days(date, -7)).to eq(Date.new(1991, 11, 6)) # Wednesday
    end

    it 'can add working days to time' do
      time = Time.local(1991, 11, 15, 14, 00, 42)
      expect(add_days(time, 1)).to eq(Time.local(1991, 11, 18, 14, 00, 42)) # Monday
    end

    it 'can add working days to ActiveSupport::TimeWithZone' do
      time = Time.utc(1991, 11, 15, 14, 00, 42)
      time_monday = Time.utc(1991, 11, 18, 14, 00, 42)
      time_with_zone = ActiveSupport::TimeWithZone.new(time, 'Tokyo')
      expect(add_days(time_with_zone, 1)).to eq(ActiveSupport::TimeWithZone.new(time_monday, 'Tokyo'))
    end

    it 'skips non worked days' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.working_hours = {mon: {'09:00' => '17:00'}, wed: {'09:00' => '17:00'}}
      expect(add_days(time, 1)).to eq(Date.new(2014, 4, 9)) # Wednesday
    end

    it 'skips holidays' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.holidays = [Date.new(2014, 4, 8)] # Tuesday
      expect(add_days(time, 1)).to eq(Date.new(2014, 4, 9)) # Wednesday
    end

    it 'skips holidays and non worked days' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.holidays = [Date.new(2014, 4, 9)] # Wednesday
      WorkingHours::Config.working_hours = {mon: {'09:00' => '17:00'}, wed: {'09:00' => '17:00'}}
      expect(add_days(time, 3)).to eq(Date.new(2014, 4, 21))
    end

    it 'accepts time given from any time zone' do
      time = Time.utc(1991, 11, 14, 21, 0, 0) # Thursday 21 pm UTC
      WorkingHours::Config.time_zone = 'Tokyo' # But we are at tokyo, so it's already Friday 6 am
      monday = Time.new(1991, 11, 18, 6, 0, 0, "+09:00") # so one working day later, we are monday (Tokyo)
      expect(add_days(time, 1)).to eq(monday)
    end
  end

  describe '#add_hours' do
    it 'adds working hours' do
      time = Time.utc(1991, 11, 15, 14, 00, 42) # Friday
      expect(add_hours(time, 2)).to eq(Time.utc(1991, 11, 15, 16, 00, 42))
    end

    it 'can substract working hours' do
      time = Time.utc(1991, 11, 18, 14, 00, 42) # Monday
      expect(add_hours(time, -7)).to eq(Time.utc(1991, 11, 15, 15, 00, 42)) # Friday
    end

    it 'accepts time given from any time zone' do
      time = Time.utc(1991, 11, 15, 7, 0, 0) # Friday 7 am UTC
      WorkingHours::Config.time_zone = 'Tokyo' # But we are at tokyo, so it's already 4 pm
      monday = Time.new(1991, 11, 18, 11, 0, 0, "+09:00") # so 3 working hours later, we are monday (Tokyo)
      expect(add_hours(time, 3)).to eq(monday)
    end

    it 'moves correctly with multiple timespans' do
      WorkingHours::Config.working_hours = {mon: {'07:00' => '12:00', '13:00' => '18:00'}}
      time = Time.utc(1991, 11, 11, 5) # Monday 6 am UTC
      expect(add_hours(time, 6)).to eq(Time.utc(1991, 11, 11, 14))
    end
  end

  describe '#add_minutes' do
    it 'adds working minutes' do
      time = Time.utc(1991, 11, 15, 16, 30, 42) # Friday
      expect(add_minutes(time, 45)).to eq(Time.utc(1991, 11, 18, 9, 15, 42))
    end
  end

  describe '#add_seconds' do
    it 'adds working seconds' do
      time = Time.utc(1991, 11, 15, 16, 59, 42) # Friday
      expect(add_seconds(time, 120)).to eq(Time.utc(1991, 11, 18, 9, 1, 42))
    end
  end

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

    it 'works with any input timezone (converts to config)' do
      # Monday 0 am (-09:00) is 9am in UTC time, working time!
      expect(advance_to_working_time(Time.new(2014, 4, 7, 0, 0, 0 , "-09:00"))).to eq(Time.utc(2014, 4, 7, 9))
      expect(advance_to_working_time(Time.new(2014, 4, 7, 22, 0, 0 , "+02:00"))).to eq(Time.utc(2014, 4, 8, 9))
    end
  end

  describe '.return_to_working_time' do
    it 'jumps non-working day' do
      WorkingHours::Config.holidays = [Date.new(2014, 5, 1)]
      expect(return_to_working_time(Time.utc(2014, 5, 1, 12, 0))).to eq(Time.utc(2014, 4, 30, 17))
      expect(return_to_working_time(Time.utc(2014, 6, 1, 12, 0))).to eq(Time.utc(2014, 5, 30, 17))
    end

    it 'returns self during working hours' do
      expect(return_to_working_time(Time.utc(2014, 4, 7, 9, 1))).to eq(Time.utc(2014, 4, 7, 9, 1))
      expect(return_to_working_time(Time.utc(2014, 4, 7, 17, 0))).to eq(Time.utc(2014, 4, 7, 17, 0))
    end

    it 'jumps outside working hours' do
      expect(return_to_working_time(Time.utc(2014, 4, 7, 17, 1))).to eq(Time.utc(2014, 4, 7, 17, 0))
      expect(return_to_working_time(Time.utc(2014, 4, 8, 9, 0))).to eq(Time.utc(2014, 4, 7, 17, 0))
    end

    it 'move between timespans' do
      WorkingHours::Config.working_hours = {mon: {'07:00' => '12:00', '13:00' => '18:00'}}
      expect(return_to_working_time(Time.utc(2014, 4, 7, 13, 1))).to eq(Time.utc(2014, 4, 7, 13, 1))
      expect(return_to_working_time(Time.utc(2014, 4, 7, 13, 0))).to eq(Time.utc(2014, 4, 7, 12, 0))
      expect(return_to_working_time(Time.utc(2014, 4, 7, 12, 1))).to eq(Time.utc(2014, 4, 7, 12, 0))
      expect(return_to_working_time(Time.utc(2014, 4, 7, 12, 0))).to eq(Time.utc(2014, 4, 7, 12, 0))
    end

    it 'works with any input timezone (converts to config)' do
      # Monday 1 am (-09:00) is 10am in UTC time, working time!
      expect(return_to_working_time(Time.new(2014, 4, 7, 1, 0, 0 , "-09:00"))).to eq(Time.utc(2014, 4, 7, 10))
      expect(return_to_working_time(Time.new(2014, 4, 7, 22, 0, 0 , "+02:00"))).to eq(Time.utc(2014, 4, 7, 17))
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
      # Monday 00:00 am UTC is 09:00 am Tokyo, working time !
      WorkingHours::Config.time_zone = 'Tokyo'
      expect(in_working_hours?(Time.utc(2014, 4, 7, 0, 0))).to be(true)
    end
  end
end