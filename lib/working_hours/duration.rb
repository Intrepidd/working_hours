require 'date'
require 'working_hours/computation'

module WorkingHours
  class Duration
    include Computation

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
      unless other.respond_to?(:in_time_zone)
        raise TypeError.new("Can't convert #{other.class} to a time")
      end
      send("add_#{@kind}", other, @value)
    end

    def from_now
      self + Time.now
    end

    private

    def add_days origin, days
      time = origin.in_time_zone(config[:time_zone])
      while days > 0
        time += 1.day
        days -= 1 if working_day?(time)
      end
      convert_to_original_format time, origin
    end

    def add_hours origin, hours
      add_minutes origin, hours*60
    end

    def add_minutes origin, minutes
      add_seconds origin, minutes*60
    end

    def add_seconds origin, seconds
      time = origin.in_time_zone(config[:time_zone])
      while seconds > 0
        # roll to next business period
        time = advance_to_working_time(time)
        # look at working ranges
        time_in_day = time.seconds_since_midnight
        config[:working_hours][time.wday].each do |from, to|
          if time_in_day >= from and time_in_day < to
            # take all we can
            take = [to - time_in_day, seconds].min
            # advance time
            time += take
            # decrease seconds
            seconds -= take
          end
        end
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
  end
end
