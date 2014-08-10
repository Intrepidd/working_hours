require 'spec_helper'

describe WorkingHours::Duration do

  describe '#initialize' do
    it 'is initialized with a number and a type' do
      duration = WorkingHours::Duration.new(5, :days)
      expect(duration.value).to eq(5)
      expect(duration.kind).to eq(:days)
    end

    it 'should work with days' do
      duration = WorkingHours::Duration.new(42, :days)
      expect(duration.kind).to eq(:days)
    end

    it 'should work with hours' do
      duration = WorkingHours::Duration.new(42, :hours)
      expect(duration.kind).to eq(:hours)
    end

    it 'should work with minutes' do
      duration = WorkingHours::Duration.new(42, :minutes)
      expect(duration.kind).to eq(:minutes)
    end

    it 'should not work with anything else' do
      expect {
        duration = WorkingHours::Duration.new(42, :foo)
      }.to raise_error WorkingHours::UnknownDuration
    end
  end

  # describe '#seconds' do
  #   it 'returns the number of seconds in a day period' do
  #     expect(42.working.days.seconds).to eq(42 * 24 * 3600)
  #   end

  #   it 'returns the number of seconds in a hour period' do
  #     expect(42.working.hours.seconds).to eq(42 * 3600)
  #   end

  #   it 'returns the number of seconds in a minute period' do
  #     expect(42.working.minutes.seconds).to eq(42 * 60)
  #   end
  # end

  describe '#add_days' do
    it 'can add any date to a working days duration' do
      date = Date.new(1991, 11, 15) #Friday
      expect(2.working.days + date).to eq(Date.new(1991, 11, 19)) # Tuesday
    end

    it 'can add any time to a working days duration' do
      time = Time.local(1991, 11, 15, 14, 00, 42)
      expect(1.working.days + time).to eq(Time.local(1991, 11, 18, 14, 00, 42)) # Monday
    end

    it 'can add any ActiveSupport::TimeWithZone to a working days duration' do
      time = Time.utc(1991, 11, 15, 14, 00, 42)
      time_monday = Time.utc(1991, 11, 18, 14, 00, 42)
      time_with_zone = ActiveSupport::TimeWithZone.new(time, 'Tokyo')
      expect(1.working.days + time_with_zone).to eq(ActiveSupport::TimeWithZone.new(time_monday, 'Tokyo'))
    end

    it 'skips non worked days' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.working_hours = {mon: {'09:00' => '17:00'}, wed: {'09:00' => '17:00'}}
      expect(1.working.days + time).to eq(Date.new(2014, 4, 9)) # Wednesday
    end

    it 'skips holidays' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.holidays = [Date.new(2014, 4, 8)] # Tuesday
      expect(1.working.days + time).to eq(Date.new(2014, 4, 9)) # Wednesday
    end

    it 'skips holidays and non worked days' do
      time = Date.new(2014, 4, 7) # Monday
      WorkingHours::Config.holidays = [Date.new(2014, 4, 9)] # Wednesday
      WorkingHours::Config.working_hours = {mon: {'09:00' => '17:00'}, wed: {'09:00' => '17:00'}}
      expect(3.working.days + time).to eq(Date.new(2014, 4, 21))
    end

    it 'accepts time given from any time zone' do
      time = Time.utc(1991, 11, 14, 21, 0, 0) # Thursday 21 pm UTC
      WorkingHours::Config.time_zone = 'Tokyo' # But we are at tokyo, so it's already Friday 6 am
      monday = Time.new(1991, 11, 18, 6, 0, 0, "+09:00") # so one working day later, we are monday (Tokyo)
      expect(1.working.days + time).to eq(monday)
    end

    it 'works with Time + duration'
    it 'works with Date + duration'
    it 'works with DateTime + duration'
    it 'works with TimeWithZone + duration'

  end

  describe '#add_seconds' do
    it 'can add working hours' do
      time = Time.utc(1991, 11, 15, 14, 00, 42) # Friday
      expect(2.working.hours + time).to eq(Time.utc(1991, 11, 15, 16, 00, 42))
    end

    it 'can add working minutes' do
      time = Time.utc(1991, 11, 15, 16, 30, 42) # Friday
      expect(45.working.minutes + time).to eq(Time.utc(1991, 11, 18, 9, 15, 42))
    end

    it 'can add working seconds' do
      time = Time.utc(1991, 11, 15, 16, 59, 42) # Friday
      expect(120.working.seconds + time).to eq(Time.utc(1991, 11, 18, 9, 1, 42))
    end

    it 'accepts time given from any time zone' do
      time = Time.utc(1991, 11, 15, 7, 0, 0) # Friday 7 am UTC
      WorkingHours::Config.time_zone = 'Tokyo' # But we are at tokyo, so it's already 4 pm
      monday = Time.new(1991, 11, 18, 11, 0, 0, "+09:00") # so 3 working hours later, we are monday (Tokyo)
      expect(3.working.hours + time).to eq(monday)
    end

    it 'works with Time + duration'
    it 'works with DateTime + duration'
    it 'works with TimeWithZone + duration'
  end

  describe 'substraction' do
    pending
  end

  describe '#from_now' do
    it "performs addition with Time.now" do
      Timecop.freeze(Time.utc(1991, 11, 15, 21)) # we are Friday 21 pm UTC
      expect(1.working.day.from_now).to eq(Time.utc(1991, 11, 18, 21))
    end
  end

  describe '#ago' do
    pending
  end

end
