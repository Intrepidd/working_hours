require 'spec_helper'
require 'active_support/all'

describe WorkingHours::Duration do

  before :each do
    WorkingHours::Config.reset!
  end

  describe '#initialize' do
    it 'is initialized with a number and a type' do
      duration = WorkingHours::Duration.new(5, :days)
      duration.value.should == 5
      duration.kind.should == :days
    end

    it 'should work with days' do
      duration = WorkingHours::Duration.new(42, :days)
      duration.kind.should == :days
    end

    it 'should work with hours' do
      duration = WorkingHours::Duration.new(42, :hours)
      duration.kind.should == :hours
    end

    it 'should work with minutes' do
      duration = WorkingHours::Duration.new(42, :minutes)
      duration.kind.should == :minutes
    end

    it 'should not work with anything else' do
      expect {
        duration = WorkingHours::Duration.new(42, :foo)
      }.to raise_error WorkingHours::UnknownDuration
    end
  end

  describe '#seconds' do
    it 'returns the number of seconds in a day period' do
      42.working.days.seconds.should == 42 * 24 * 3600
    end

    it 'returns the number of seconds in a hour period' do
      42.working.hours.seconds.should == 42 * 3600
    end

    it 'returns the number of seconds in a minute period' do
      42.working.minutes.seconds.should == 42 * 60
    end
  end

  describe 'addition' do
    context 'business days' do
      it 'can add any date to a business days duration' do
        date = Date.new(1991, 11, 15) #Friday
        (2.working.days + date).should == Date.new(1991, 11, 19) # Tuesday
      end

      it 'can add any time to a business days duration' do
        time = Time.local(1991, 11, 15, 14, 00, 42)
        (1.working.days + time).should == Time.local(1991, 11, 18, 14, 00, 42) # Monday
      end

      it 'can add any ActiveSupport::TimeWithZone to a business days duration' do
        time = Time.utc(1991, 11, 15, 14, 00, 42)
        time_monday = Time.utc(1991, 11, 18, 14, 00, 42)
        time_with_zone = ActiveSupport::TimeWithZone.new(time, ActiveSupport::TimeZone.new('Paris'))
        (1.working.days + time_with_zone).should == ActiveSupport::TimeWithZone.new(time_monday, ActiveSupport::TimeZone.new('Paris'))
      end

      it 'skips non worked days' do
        time = Date.new(2014, 4, 7) # Monday
        WorkingHours::Config.working_hours.delete(:tue)
        (1.working.days + time).should == Date.new(2014, 4, 9) # Wednesday
      end

      it 'skips holidays' do
        time = Date.new(2014, 4, 7) # Monday
        WorkingHours::Config.holidays << Date.new(2014, 4, 8)
        (1.working.days + time).should == Date.new(2014, 4, 9) # Wednesday
      end

      it 'skips holidays and non worked days' do
        time = Date.new(2014, 4, 7) # Monday
        WorkingHours::Config.holidays << Date.new(2014, 4, 9)
        WorkingHours::Config.working_hours.delete(:tue)
        (7.working.days + time).should == Date.new(2014, 4, 21)
      end
    end
  end
end
