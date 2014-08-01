require 'spec_helper'

describe WorkingHours::DurationProxy do
  describe '#initialize' do
    it 'is constructed with a value' do
      proxy = WorkingHours::DurationProxy.new(42)
      expect(proxy.value).to eq(42)
    end
  end

  context 'proxy methods' do

    let(:proxy) { WorkingHours::DurationProxy.new(42) }

    WorkingHours::Duration::SUPPORTED_KINDS.each do |kind|
      describe "##{kind}" do
        it 'should return a duration object' do
          duration = proxy.send(kind)
          expect(duration.value).to eq(42)
          expect(duration.kind).to eq(kind)
        end
      end
    end
  end
end
