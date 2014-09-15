require 'active_support/all'
require 'working_hours/config'

module WorkingHours
  module Computation

    def add_days origin, days
      time = in_config_zone(origin)
      while days > 0
        time += 1.day
        days -= 1 if working_day?(time)
      end
      while days < 0
        time -= 1.day
        days += 1 if working_day?(time)
      end
      convert_to_original_format time, origin
    end

    def add_hours origin, hours
      add_minutes origin, hours * 60
    end

    def add_minutes origin, minutes
      add_seconds origin, minutes * 60
    end

    def add_seconds origin, seconds
      time = in_config_zone(origin).round
      config = wh_config
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
      while seconds < 0
        # roll to previous business period
        time = return_to_working_time(time)
        # look at working ranges
        time_in_day = time.seconds_since_midnight
        config[:working_hours][time.wday].reverse_each do |from, to|
          if time_in_day > from and time_in_day <= to
            # take all we can
            take = [time_in_day - from, -seconds].min
            # advance time
            time -= take
            # decrease seconds
            seconds += take
          end
        end
      end
      convert_to_original_format time, origin
    end

    def advance_to_working_time time
      time = in_config_zone(time).round
      config = wh_config
      loop do
        # skip holidays and weekends
        while not working_day?(time)
          time = (time + 1.day).beginning_of_day
        end
        # find first working range after time
        time_in_day = time.seconds_since_midnight
        (config[:working_hours][time.wday] || {}).each do |from, to|
          return time if time_in_day >= from and time_in_day < to
          return time + (from - time_in_day) if from >= time_in_day
        end
        # if none is found, go to next day and loop
        time = (time + 1.day).beginning_of_day
      end
    end

    def return_to_working_time time
      time = in_config_zone(time).round
      config = wh_config
      loop do
        # skip holidays and weekends
        while not working_day?(time)
          time = (time - 1.day).end_of_day
        end
        # find last working range before time
        time_in_day = time.seconds_since_midnight
        (config[:working_hours][time.wday] || {}).reverse_each do |from, to|
          # round is used to suppress miliseconds hack from `end_of_day`
          return time.round if time_in_day > from and time_in_day <= to
          return (time - (time_in_day - to)).round if to <= time_in_day
        end
        # if none is found, go to previous day and loop
        time = (time - 1.day).end_of_day
      end
    end

    def working_day? time
      time = in_config_zone(time)
      config = wh_config
      config[:working_hours][time.wday].present? and not config[:holidays].include?(time.to_date)
    end

    def in_working_hours? time
      time = in_config_zone(time)
      return false if not working_day?(time)
      time_in_day = time.seconds_since_midnight
      wh_config[:working_hours][time.wday].each do |from, to|
        return true if time_in_day >= from and time_in_day < to
      end
      false
    end

    def working_days_between from, to
      if to < from
        -working_days_between(to, from)
      else
        from = in_config_zone(from)
        to = in_config_zone(to)
        days = 0
        while from.to_date < to.to_date
          from += 1.day
          days += 1 if working_day?(from)
        end
        days
      end
    end

    def working_time_between from, to
      if to < from
        -working_time_between(to, from)
      else
        from = advance_to_working_time(in_config_zone(from))
        to = in_config_zone(to).round
        distance = 0
        config = wh_config
        while from < to
          # look at working ranges
          time_in_day = from.seconds_since_midnight
          config[:working_hours][from.wday].each do |begins, ends|
            if time_in_day >= begins and time_in_day < ends
              # take all we can
              take = [ends - time_in_day, to - from].min
              # advance time
              from += take
              # increase counter
              distance += take
            end
          end
          # roll to next business period
          from = advance_to_working_time(from)
        end
        distance
      end
    end

    private

    def wh_config
      WorkingHours::Config.precompiled
    end

    # fix for ActiveRecord < 4, doesn't implement in_time_zone for Date
    def in_config_zone time
      if time.respond_to? :in_time_zone
        time.in_time_zone(wh_config[:time_zone])
      elsif time.is_a? Date
        wh_config[:time_zone].local(time.year, time.month, time.day)
      else
        raise TypeError.new("Can't convert #{time.class} to a Time")
      end
    end

    def convert_to_original_format time, original
      case original
      when Date then time.to_date
      when DateTime then time.to_datetime
      when Time then time.to_time
      else time
      end
    end

  end
end
