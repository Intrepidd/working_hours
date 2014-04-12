module WorkingHours
  class DurationProxy

    attr_accessor :value

    def initialize(value)
      @value = value
    end

    Duration::SUPPORTED_KINDS.each do |kind|
      define_method kind do
        Duration.new(@value, kind)
      end
    end
  end
end
