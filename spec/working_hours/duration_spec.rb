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

    it 'should work with seconds' do
      duration = WorkingHours::Duration.new(42, :seconds)
      expect(duration.kind).to eq(:seconds)
    end

    it 'should not work with anything else' do
      expect {
        duration = WorkingHours::Duration.new(42, :foo)
      }.to raise_error WorkingHours::UnknownDuration
    end
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
