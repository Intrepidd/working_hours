require 'spec_helper'

describe WorkingHours::DurationProxy do
  describe '#initialize' do
    it 'is constructed with a value' do
      proxy = WorkingHours::DurationProxy.new(42)
      proxy.value.should == 42
    end
  end

  context 'proxy methods' do

    before do
      @proxy = WorkingHours::DurationProxy.new(42)
    end

    WorkingHours::Duration::SUPPORTED_KINDS.each do |kind|
      describe "##{kind}" do
        it 'should return a duration object' do
          duration = @proxy.send(kind)
          duration.value.should == 42
          duration.kind.should == kind
        end
      end
    end
  end
end
