require 'working_hours/duration'

module WorkingHours
  module CoreExt
    module DateAndTime

      def +(other)
        if (other.is_a?(WorkingHours::Duration))
          other.since(self)
        else
          super(other)
        end
      end

      def -(other)
        if (other.is_a?(WorkingHours::Duration))
          other.until(self)
        else
          super(other)
        end
      end

    end
  end
end

class Date
  prepend WorkingHours::CoreExt::DateAndTime
end

class DateTime
  prepend WorkingHours::CoreExt::DateAndTime
end

class Time
  prepend WorkingHours::CoreExt::DateAndTime
end

class ActiveSupport::TimeWithZone
  prepend WorkingHours::CoreExt::DateAndTime
end