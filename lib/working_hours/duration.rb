require 'date'

module WorkingHours
  class Duration

      attr_accessor :value, :kind

      SUPPORTED_KINDS = [:days, :hours, :minutes]

      def initialize(value, kind)
        raise WorkingHours::UnknownDuration unless SUPPORTED_KINDS.include?(kind)
        @value = value
        @kind = kind
      end

      def seconds
        case @kind
        when :days
          @value * 24 * 3600
        when :hours
          @value * 3600
        when :minutes
          @value * 60
        else
          raise UnknowDuration
        end
      end

      def +(other)
        unless other.kind_of?(Time) || other.kind_of?(Date)
          raise TypeError.new("Can't convert #{other.class} to a time")
        end
        send("add_#{@kind}", other)
      end

      private

      def config
        WorkingHours::Config
      end

      def add_days(other)
        days_to_add = @value
        current_day = DateTime.parse(other.to_s)
        while days_to_add > 0
          current_day += 1
          day_of_week = current_day.strftime('%a').downcase.to_sym
          days_to_add -= 1 unless !config.working_hours.key?(day_of_week) || config.holidays.include?(current_day.to_date)
        end
        other.class.parse(current_day.to_s)
      end

  end
end
