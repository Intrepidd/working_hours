module WorkingHours
  class Duration

      attr_accessor :value, :kind

      SUPPORTED_KINDS = [:days, :hours, :minutes]

      def initialize(value, kind)
        raise WorkingHours::UnknownDuration unless SUPPORTED_KINDS.include?(kind)
        @value = value
        @kind = kind
      end

      def seconds
        case @kind
        when :days
          @value * 24 * 3600
        when :hours
          @value * 3600
        when :minutes
          @value * 60
        else
          raise UnknowDuration
        end
      end

  end
end
