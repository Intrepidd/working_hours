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

    # def seconds
    #   case @kind
    #   when :days
    #     @value * 24 * 3600
    #   when :hours
    #     @value * 3600
    #   when :minutes
    #     @value * 60
    #   else
    #     raise UnknowDuration
    #   end
    # end

    def +(other)
      unless other.kind_of?(Time) || other.kind_of?(Date)
        raise TypeError.new("Can't convert #{other.class} to a time")
      end
      send("add_#{@kind}", other)
    end

    def from_now
      self + Time.now
    end

    private

    def config
      WorkingHours::Config
    end

    def add_days origin
      days_to_add = @value
      time = origin.in_time_zone(config.time_zone)
      while days_to_add > 0
        time += 1.day
        days_to_add -= 1 unless skip_day?(time)
      end
      convert_to_original_format time, origin
    end

    def convert_to_original_format time, original
      case original
      when Date then time.to_date
      when DateTime then time.to_datetime
      else time
      end
    end

    def skip_day?(day)
      day_of_week = day.strftime('%a').downcase.to_sym
      !config.working_hours.key?(day_of_week) || config.holidays.include?(day.to_date)
    end
  end
end
