module WorkingHours
  module CoreExt
    module Fixnum

      def working
        WorkingHours::DurationProxy.new(self)
      end

    end
  end
end

Fixnum.send(:include, WorkingHours::CoreExt::Fixnum)
