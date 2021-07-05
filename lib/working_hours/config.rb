require 'set'

module WorkingHours
  InvalidConfiguration = Class.new StandardError

  class Config
    TIME_FORMAT = /\A([0-2][0-9])\:([0-5][0-9])(?:\:([0-5][0-9]))?\z/
    DAYS_OF_WEEK = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]
    MIDNIGHT = Rational('86399.999999')

    class << self
      def working_hours
        config[:working_hours]
      end

      def working_hours=(val)
        validate_working_hours! val
        config[:working_hours] = val
        global_config[:working_hours] = val
        config.delete :precompiled
      end

      def holidays
        config[:holidays]
      end

      def holidays=(val)
        validate_holidays! val
        config[:holidays] = val
        global_config[:holidays] = val
        config.delete :precompiled
      end

      def holiday_hours
        config[:holiday_hours]
      end

      def holiday_hours=(val)
        validate_holiday_hours! val
        config[:holiday_hours] = val
        global_config[:holiday_hours] = val
        config.delete :precompiled
      end

      # Returns an optimized for computing version
      def precompiled
        config_hash = [
          config[:working_hours],
          config[:holiday_hours],
          config[:holidays],
          config[:time_zone]
        ].hash

        if config_hash != config[:config_hash]
          config[:config_hash] = config_hash
          config.delete :precompiled
        end

        config[:precompiled] ||= begin
          validate_working_hours! config[:working_hours]
          validate_holiday_hours! config[:holiday_hours]
          validate_holidays! config[:holidays]
          validate_time_zone! config[:time_zone]
          compiled = { working_hours: Array.new(7) { Hash.new }, holiday_hours: {} }
          working_hours.each do |day, hours|
            hours.each do |start, finish|
              compiled[:working_hours][DAYS_OF_WEEK.index(day)][compile_time(start)] = compile_time(finish)
            end
          end
          holiday_hours.each do |day, hours|
            compiled[:holiday_hours][day] = {}
            hours.each do |start, finish|
              compiled[:holiday_hours][day][compile_time(start)] = compile_time(finish)
            end
          end
          compiled[:holidays] = Set.new(holidays)
          compiled[:time_zone] = time_zone
          compiled
        end
      end

      def time_zone
        config[:time_zone]
      end

      def time_zone=(val)
        zone = validate_time_zone! val
        config[:time_zone] = zone
        global_config[:time_zone] = val
        config.delete :precompiled
      end

      def reset!
        Thread.current[:working_hours] = default_config
      end

      def with_config(working_hours: nil, holiday_hours: nil, holidays: nil, time_zone: nil)
        original_working_hours = self.working_hours
        original_holiday_hours = self.holiday_hours
        original_holidays = self.holidays
        original_time_zone = self.time_zone
        self.working_hours = working_hours if working_hours
        self.holiday_hours = holiday_hours if holiday_hours
        self.holidays = holidays if holidays
        self.time_zone = time_zone if time_zone
        yield
      ensure
        self.working_hours = original_working_hours
        self.holiday_hours = original_holiday_hours
        self.holidays = original_holidays
        self.time_zone = original_time_zone
      end

      private

      def config
        Thread.current[:working_hours] ||= global_config.dup
      end

      def global_config
        @@global_config ||= default_config
      end

      def default_config
        {
          working_hours: {
            mon: {'09:00' => '17:00'},
            tue: {'09:00' => '17:00'},
            wed: {'09:00' => '17:00'},
            thu: {'09:00' => '17:00'},
            fri: {'09:00' => '17:00'}
          },
          holiday_hours: {},
          holidays: [],
          time_zone: ActiveSupport::TimeZone['UTC']
        }
      end

      def compile_time time
        hour = time[TIME_FORMAT,1].to_i
        min = time[TIME_FORMAT,2].to_i
        sec = time[TIME_FORMAT,3].to_i
        time = hour * 3600 + min * 60 + sec
        # Converts 24:00 to 23:59:59.999999
        return MIDNIGHT if time == 86400
        time
      end

      def validate_hours! dates
        dates.each do |day, hours|
          if not hours.is_a? Hash
            raise InvalidConfiguration.new "Invalid type for `#{day}`: #{hours.class} - must be Hash"
          elsif hours.empty?
            raise InvalidConfiguration.new "No working hours given for day `#{day}`"
          end
          last_time = nil
          hours.sort.each do |start, finish|
            if not start =~ TIME_FORMAT
              raise InvalidConfiguration.new "Invalid time: #{start} - must be 'HH:MM(:SS)'"
            elsif not finish =~ TIME_FORMAT
              raise InvalidConfiguration.new "Invalid time: #{finish} - must be 'HH:MM(:SS)'"
            elsif compile_time(finish) >= 24 * 60 * 60
              raise InvalidConfiguration.new "Invalid time: #{finish} - outside of day"
            elsif start >= finish
              raise InvalidConfiguration.new "Invalid range: #{start} => #{finish} - ends before it starts"
            elsif last_time and start < last_time
              raise InvalidConfiguration.new "Invalid range: #{start} => #{finish} - overlaps previous range"
            end
            last_time = finish
          end
        end
      end

      def validate_working_hours! week
        if week.empty?
          raise InvalidConfiguration.new "No working hours given"
        end
        if (invalid_keys = (week.keys - DAYS_OF_WEEK)).any?
          raise InvalidConfiguration.new "Invalid day identifier(s): #{invalid_keys.join(', ')} - must be 3 letter symbols"
        end
        validate_hours!(week)
      end

      def validate_holiday_hours! days
        if (invalid_keys = (days.keys.reject{ |day| day.is_a?(Date) })).any?
          raise InvalidConfiguration.new "Invalid day identifier(s): #{invalid_keys.join(', ')} - must be a Date object"
        end
        validate_hours!(days)
      end

      def validate_holidays! holidays
        if not holidays.respond_to?(:to_a)
          raise InvalidConfiguration.new "Invalid type for holidays: #{holidays.class} - must act like an array"
        end
        holidays.to_a.each do |day|
          if not day.is_a? Date
            raise InvalidConfiguration.new "Invalid holiday: #{day} - must be Date"
          end
        end
      end

      def validate_time_zone! zone
        if zone.is_a? String
          res = ActiveSupport::TimeZone[zone]
          if res.nil?
            raise InvalidConfiguration.new "Unknown time zone: #{zone}"
          end
        elsif zone.is_a? ActiveSupport::TimeZone
          res = zone
        else
          raise InvalidConfiguration.new "Invalid time zone: #{zone.inspect} - must be String or ActiveSupport::TimeZone"
        end
        res
      end
    end

    private

    def initialize; end
  end
end
