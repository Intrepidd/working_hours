require 'spec_helper'

describe WorkingHours::CoreExt::DateAndTime do
  let(:duration) { 5.working.days }

  describe 'operator +' do
    it 'works with Time objects' do
      time = Time.now
      expect(duration).to receive(:add_days).with(time, 5)
      time + duration
    end

    it 'works with Date objects' do
      date = Date.today
      expect(duration).to receive(:add_days).with(date, 5)
      date + duration
    end

    it 'works with DateTime objects' do
      date_time = DateTime.now
      expect(duration).to receive(:add_days).with(date_time, 5)
      date_time + duration
    end

    it 'works with ActiveSupport::TimeWithZone' do
      time = Time.now.in_time_zone('Tokyo')
      expect(duration).to receive(:add_days).with(time, 5)
      time + duration
    end

    it "doesn't break original operator" do
      time = Time.now
      expect(duration).not_to receive(:add_days)
      expect(time + 3600).to eq(time + 1.hour)
    end
  end

  describe 'operator -' do
    it 'works with Time objects' do
      time = Time.now
      expect(duration).to receive(:add_days).with(time, -5)
      time - duration
    end

    it 'works with Date objects' do
      date = Date.today
      expect(duration).to receive(:add_days).with(date, -5)
      date - duration
    end

    it 'works with DateTime objects' do
      date_time = DateTime.now
      expect(duration).to receive(:add_days).with(date_time, -5)
      date_time - duration
    end

    it 'works with ActiveSupport::TimeWithZone' do
      time = Time.now.in_time_zone('Tokyo')
      expect(duration).to receive(:add_days).with(time, -5)
      time - duration
    end

    it "doesn't break original operator" do
      time = Time.now
      expect(duration).not_to receive(:add_days)
      expect(time - 3600).to eq(time - 1.hour)
    end
  end
end
