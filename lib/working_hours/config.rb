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
        config[:holidays] = val
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
        raise InvalidConfiguration.new "Invalid day identifier(s): #{invalid_keys.inspect}"
      end
      week.each do |day, hours|
        if not hours.is_a? Hash
          raise InvalidConfiguration.new "Invalid type for `#{day}`: #{hours.class}, must be Hash"
        end
        last_time = nil
        hours.each do |start, finish|
          if not start =~ TIME_FORMAT
            raise InvalidConfiguration.new "Invalid time: #{start}, must be 'HH:MM'"
          elsif not finish =~ TIME_FORMAT
            raise InvalidConfiguration.new "Invalid time: #{finish}, must be 'HH:MM'"
          elsif start >= finish
            raise InvalidConfiguration.new "Invalid range: #{start} => #{finish}, ends before it starts"
          elsif last_time and start < last_time
            raise InvalidConfiguration.new "Invalid range: #{start} => #{finish}, overlaps previous range"
          end
          last_time = finish
        end
      end
    end

  end
end
