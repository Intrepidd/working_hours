require 'spec_helper'

describe WorkingHours::CoreExt::Fixnum do

  describe '#working' do
    it 'returns a DurationProxy' do
      proxy = 42.working
      proxy.should be_kind_of(WorkingHours::DurationProxy)
      proxy.value.should == 42
    end
  end

end
