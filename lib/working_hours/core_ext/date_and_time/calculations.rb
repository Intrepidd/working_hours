module WorkingHours
  module CoreExt
    module Calculations

      def +(other)
        if (other.is_a?(WorkingHours::Duration))
          other + self
        else
          super(other)
        end
      end

      def -(other)
        if (other.is_a?(WorkingHours::Duration))
          other - self
        else
          super(other)
        end
      end

    end
  end
end
