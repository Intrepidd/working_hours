require 'spec_helper'

describe WorkingHours::Duration do
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
end
