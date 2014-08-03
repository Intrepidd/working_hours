module WorkingHours
  class Config
    TIME_FORMAT = /\A([0-1][0-9]|2[0-3]):([0-5][0-9])\z/

    class << self

      def working_hours
        config[:working_hours]
      end

      def working_hours=(val)
        validate_working_hours! val
        config[:working_hours] = val
      end

      def holidays
        config[:holidays]
      end

      def holidays=(val)
        validate_holidays! val
        config[:holidays] = val
      end

      def time_zone
        config[:time_zone]
      end

      def time_zone=(val)
        zone = validate_time_zone! val
        config[:time_zone] = zone
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
          :working_hours => {
            :mon => {'09:00' => '17:00'},
            :tue => {'09:00' => '17:00'},
            :wed => {'09:00' => '17:00'},
            :thu => {'09:00' => '17:00'},
            :fri => {'09:00' => '17:00'}
          },
          :holidays => [],
          :time_zone => Time.zone
        }
      end

    end

    private

    def initialize
    end

    def self.validate_working_hours! week
      if (invalid_keys = (week.keys - [:mon, :tue, :wed, :thu, :fri, :sat, :sun])).any?
        raise InvalidConfiguration.new "Invalid day identifier(s): #{invalid_keys.join(', ')} - must be 3 letter symbols"
      end
      week.each do |day, hours|
        if not hours.is_a? Hash
          raise InvalidConfiguration.new "Invalid type for `#{day}`: #{hours.class} - must be Hash"
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

    def self.validate_holidays! holidays
      if not holidays.is_a? Array
        raise InvalidConfiguration.new "Invalid type for holidays: #{holidays.class} - must be Array"
      end
      holidays.each do |day|
        if not day.is_a? Date
          raise InvalidConfiguration.new "Invalid holiday: #{day} - must be Date"
        end
      end
    end

    def self.validate_time_zone! zone
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
end
