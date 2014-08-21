require 'spec_helper'

describe WorkingHours do

  describe '.working_days_between' do
    it 'returns 0 if same date' do
      expect( # friday
        WorkingHours.working_days_between(Date.new(1991, 11, 15), Date.new(1991, 11, 15))
      ).to eq(0)
    end

    it 'returns 0 if time in same day' do
      expect( # friday
        WorkingHours.working_days_between(Time.utc(1991, 11, 15, 8), Time.utc(1991, 11, 15, 4))
      ).to eq(0)
    end

    it 'counts working days' do
      expect( # friday to friday
        WorkingHours.working_days_between(Date.new(1991, 11, 15), Date.new(1991, 11, 22))
      ).to eq(5)
    end

    it 'returns negative if params are reversed' do
      expect( # friday to friday
        WorkingHours.working_days_between(Date.new(1991, 11, 22), Date.new(1991, 11, 15))
      ).to eq(-5)
    end

    context 'consider time at end of day' do
      it 'returns 0 from friday to saturday' do
        expect( # friday to saturday
          WorkingHours.working_days_between(Date.new(1991, 11, 15), Date.new(1991, 11, 16))
        ).to eq(0)
      end

      it 'returns 1 from sunday to monday' do
        expect( # sunday to monday
          WorkingHours.working_days_between(Date.new(1991, 11, 17), Date.new(1991, 11, 18))
        ).to eq(1)
      end
    end
  end

end