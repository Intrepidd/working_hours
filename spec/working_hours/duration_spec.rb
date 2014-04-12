require 'spec_helper'

describe WorkingHours::Duration do
  describe '#initialize' do
    it 'is initialized with a number and a type' do
      duration = WorkingHours::Duration.new(5, :months)
      duration.value.should == 5
      duration.kind.should == :months
    end

    it 'should work with years' do
      duration = WorkingHours::Duration.new(42, :years)
      duration.kind.should == :years
    end

    it 'should work with months' do
      duration = WorkingHours::Duration.new(42, :months)
      duration.kind.should == :months
    end

    it 'should work with weeks' do
      duration = WorkingHours::Duration.new(42, :weeks)
      duration.kind.should == :weeks
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
end
