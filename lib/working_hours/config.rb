module WorkingHours
  class Config

    class << self

      def working_hours
        config[:working_hours]
      end

      def working_hours=(val)
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
            :mon => ['09:00', '17:00'],
            :tue => ['09:00', '17:00'],
            :wed => ['09:00', '17:00'],
            :thu => ['09:00', '17:00'],
            :fri => ['09:00', '17:00']
          },
          :holidays => []
        }
      end

    end

    private

    def initialize
    end

  end
end
