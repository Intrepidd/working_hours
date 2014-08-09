module WorkingHours
  module Computation

    def config
      WorkingHours::Config.precompiled
    end

    def advance_to_working_time time
      return time if in_working_hours? time
      loop do
        # skip holidays and weekends
        while not working_day?(time)
          time = (time + 1.day).beginning_of_day
        end
        # find first working range after time
        time_in_day = time.seconds_since_midnight
        (Config.precompiled[:working_hours][time.wday] || {}).each do |from, to|
          return time + (from - time_in_day) if from >= time_in_day
        end
        # if none is found, go to next day and loop
        time = (time + 1.day).beginning_of_day
      end
    end

    def working_day? time
      Config.precompiled[:working_hours][time.wday].present? and not Config.precompiled[:holidays].include?(time.to_date)
    end

    def in_working_hours? time
      return false if not working_day?(time)
      time_in_day = time.seconds_since_midnight
      Config.precompiled[:working_hours][time.wday].each do |from, to|
        return true if time_in_day >= from and time_in_day < to
      end
      false
    end

  end
end