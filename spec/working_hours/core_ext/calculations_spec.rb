require 'spec_helper'

describe 'WorkingHours CoreExt calculations' do
  context 'Additions and substractions' do
    it 'works with Time objects' do
      duration = 5.working.days
      time = Time.now
      expect(duration).to receive(:+).with(time)
      expect(duration).to receive(:-).with(time)
      time + duration
      time - duration
    end

    it 'works with Date objects' do
      duration = 5.working.days
      time = Date.new(2014, 01, 01)
      expect(duration).to receive(:+).with(time)
      expect(duration).to receive(:-).with(time)
      time + duration
      time - duration
    end

    it 'works with DateTime objects' do
      duration = 5.working.days
      time = DateTime.new(2014, 01, 01)
      expect(duration).to receive(:+).with(time)
      expect(duration).to receive(:-).with(time)
      time + duration
      time - duration
    end
  end
end
