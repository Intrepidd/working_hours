require 'set'

module WorkingHours
  InvalidConfiguration = Class.new StandardError

  class Config

    TIME_FORMAT = /\A([0-1][0-9]|2[0-3]):([0-5][0-9])\z/
    DAYS_OF_WEEK = [:sun, :mon, :tue, :wed, :thu, :fri, :sat]

    class << self

      def working_hours
        config[:working_hours]
      end

      def working_hours=(val)
        validate_working_hours! val
        config[:working_hours] = val
        config.delete :precompiled
      end

      def holidays
        config[:holidays]
      end

      def holidays=(val)
        validate_holidays! val
        config[:holidays] = val
        config.delete :precompiled
      end

      # Returns an optimized for computing version
      def precompiled
        config_hash = [config[:working_hours], config[:holidays], config[:time_zone]].hash
        if config_hash != config[:config_hash]
          config[:config_hash] = config_hash
          config.delete :precompiled
        end

        config[:precompiled] ||= begin
          compiled = {working_hours: []}
          working_hours.each do |day, hours|
            compiled[:working_hours][DAYS_OF_WEEK.index(day)] = {}
            hours.each do |start, finish|
              compiled[:working_hours][DAYS_OF_WEEK.index(day)][compile_time(start)] = compile_time(finish)
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
        config.delete :precompiled
      end

      def reset!
        Thread.current[:working_hours] = default_config
      end

      private

      def config
        Thread.current[:working_hours] ||= default_config
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
          holidays: [],
          time_zone: ActiveSupport::TimeZone['UTC']
        }
      end

      def compile_time time
        hour = time[TIME_FORMAT,1].to_i
        min = time[TIME_FORMAT,2].to_i
        hour * 3600 + min * 60
      end

      def validate_working_hours! week
        if week.empty?
          raise InvalidConfiguration.new "No working hours given"
        end
        if (invalid_keys = (week.keys - DAYS_OF_WEEK)).any?
          raise InvalidConfiguration.new "Invalid day identifier(s): #{invalid_keys.join(', ')} - must be 3 letter symbols"
        end
        week.each do |day, hours|
          if not hours.is_a? Hash
            raise InvalidConfiguration.new "Invalid type for `#{day}`: #{hours.class} - must be Hash"
          elsif hours.empty?
            raise InvalidConfiguration.new "No working hours given for day `#{day}`"
          end
          last_time = nil
          hours.each do |start, finish|
            if not start =~ TIME_FORMAT
              raise InvalidConfiguration.new "Invalid time: #{start} - must be 'HH:MM'"
            elsif not finish =~ TIME_FORMAT
              raise InvalidConfiguration.new "Invalid time: #{finish} - must be 'HH:MM'"
            elsif start >= finish
              raise InvalidConfiguration.new "Invalid range: #{start} => #{finish} - ends before it starts"
            elsif last_time and start < last_time
              raise InvalidConfiguration.new "Invalid range: #{start} => #{finish} - overlaps previous range"
            end
            last_time = finish
          end
        end
      end

      def validate_holidays! holidays
        if not holidays.is_a? Array
          raise InvalidConfiguration.new "Invalid type for holidays: #{holidays.class} - must be Array"
        end
        holidays.each do |day|
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

    def initialize
    end
  end
end
