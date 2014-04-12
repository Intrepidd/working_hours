module WorkingHours
  class Duration

      attr_accessor :value, :kind

      SUPPORTED_KINDS = [:days, :hours, :minutes]

      def initialize(value, kind)
        raise WorkingHours::UnknownDuration unless SUPPORTED_KINDS.include?(kind)
        @value = value
        @kind = kind
      end

  end
end
