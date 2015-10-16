require 'active_support/all'
require 'working_hours/config'

module WorkingHours
  module Computation

    def add_days origin, days, config: nil
      config ||= wh_config
      time = in_config_zone(origin, config: config)
      while days > 0
        time += 1.day
        days -= 1 if working_day?(time, config: config)
      end
      while days < 0
        time -= 1.day
        days += 1 if working_day?(time, config: config)
      end
      convert_to_original_format time, origin
    end

    def add_hours origin, hours, config: nil
      config ||= wh_config
      add_minutes origin, hours * 60, config: config
    end

    def add_minutes origin, minutes, config: nil
      config ||= wh_config
      add_seconds origin, minutes * 60, config: config
    end

    def add_seconds origin, seconds, config: nil
      config ||= wh_config
      time = in_config_zone(origin, config: config).round
      while seconds > 0
        # roll to next business period
        time = advance_to_working_time(time, config: config)
        # look at working ranges
        time_in_day = time.seconds_since_midnight
        config[:working_hours][time.wday].each do |from, to|
          if time_in_day >= from and time_in_day < to
            # take all we can
            take = [to - time_in_day, seconds].min.round
            # advance time
            time += take
            # decrease seconds
            seconds -= take
          end
        end
      end
      while seconds < 0
        # roll to previous business period
        time = return_to_exact_working_time(time, config: config)
        # look at working ranges
        time_in_day = time.seconds_since_midnight
        config[:working_hours][time.wday].reverse_each do |from, to|
          if time_in_day > from and time_in_day <= to
            # take all we can
            take = [time_in_day - from, -seconds].min.round
            # advance time
            time -= take
            # decrease seconds
            seconds += take
          end
        end
      end
      convert_to_original_format(time.round, origin)
    end

    def advance_to_working_time time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config).round
      loop do
        # skip holidays and weekends
        while not working_day?(time, config: config)
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

    def advance_to_closing_time time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config).round
      loop do
        # skip holidays and weekends
        while not working_day?(time, config: config)
          time = (time + 1.day).beginning_of_day
        end
        # find next working range after time
        time_in_day = time.seconds_since_midnight
        time = time.beginning_of_day
        (config[:working_hours][time.wday] || {}).each do |from, to|
          return time + to if time_in_day >= from and time_in_day < to
          return time + to if from >= time_in_day
        end
        # if none is found, go to next day and loop
        time = time + 1.day
      end
    end

    def next_working_time time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config).round
      loop do
        # skip holidays and weekends
        while not working_day?(time, config: config)
          time = (time + 1.day).beginning_of_day
        end
        # find next working range after time
        time_in_day = time.seconds_since_midnight
        time = time.beginning_of_day
        (config[:working_hours][time.wday] || {}).each do |from, to|
          # skip this slot if it's the first
          if time_in_day >= from and time_in_day < to
            time_in_day = to
            next
          end

          return time + from if time_in_day >= from and time_in_day < to
          return time + from if from >= time_in_day
        end
        # if none is found, go to next day and loop
        time = time + 1.day
      end
    end

    def return_to_working_time(time, config: nil)
      # return_to_exact_working_time may return values with a high number of milliseconds,
      # this is necessary for the end of day hack, here we return a rounded value for the
      # public API
      return_to_exact_working_time(time, config: config).round
    end

    def return_to_exact_working_time time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config).round
      loop do
        # skip holidays and weekends
        while not working_day?(time, config: config)
          time = (time - 1.day).end_of_day
        end
        # find last working range before time
        time_in_day = time.seconds_since_midnight
        (config[:working_hours][time.wday] || {}).reverse_each do |from, to|
          # round is used to suppress miliseconds hack from `end_of_day`
          return time if time_in_day > from and time_in_day <= to
          return (time - (time_in_day - to)) if to <= time_in_day
        end
        # if none is found, go to previous day and loop
        time = (time - 1.day).end_of_day
      end
    end

    def working_day? time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config)
      config[:working_hours][time.wday].present? and not config[:holidays].include?(time.to_date)
    end

    def in_working_hours? time, config: nil
      config ||= wh_config
      time = in_config_zone(time, config: config)
      return false if not working_day?(time, config: config)
      time_in_day = time.seconds_since_midnight
      config[:working_hours][time.wday].each do |from, to|
        return true if time_in_day >= from and time_in_day < to
      end
      false
    end

    def working_days_between from, to, config: nil
      config ||= wh_config
      if to < from
        -working_days_between(to, from, config: config)
      else
        from = in_config_zone(from, config: config)
        to = in_config_zone(to, config: config)
        days = 0
        while from.to_date < to.to_date
          from += 1.day
          days += 1 if working_day?(from, config: config)
        end
        days
      end
    end

    def working_time_between from, to, config: nil
      config ||= wh_config
      if to < from
        -working_time_between(to, from, config: config)
      else
        from = advance_to_working_time(in_config_zone(from, config: config))
        to = in_config_zone(to, config: config).round
        distance = 0
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
          from = advance_to_working_time(from, config: config)
        end
        distance.round # round up to supress miliseconds introduced by 24:00 hack
      end
    end

    private

    def wh_config
      WorkingHours::Config.precompiled
    end

    # fix for ActiveRecord < 4, doesn't implement in_time_zone for Date
    def in_config_zone time, config: nil
      if time.respond_to? :in_time_zone
        time.in_time_zone(config[:time_zone])
      elsif time.is_a? Date
        config[:time_zone].local(time.year, time.month, time.day)
      else
        raise TypeError.new("Can't convert #{time.class} to a Time")
      end
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
