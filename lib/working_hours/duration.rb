require 'date'
require 'working_hours/computation'

module WorkingHours
  class Duration
    include Computation

    attr_accessor :value, :kind

    SUPPORTED_KINDS = [:days, :hours, :minutes, :seconds]

    def initialize(value, kind)
      raise ArgumentError.new("Invalid working time unit: #{kind}") unless SUPPORTED_KINDS.include?(kind)
      @value = value
      @kind = kind
    end

    def -@
      Duration.new(-value, kind)
    end

    def ==(other)
      self.class == other.class and kind == other.kind and value == other.value
    end
    alias :eql? :==

    def hash
      [self.class, kind, value].hash
    end

    def +(other)
      unless other.respond_to?(:in_time_zone)
        raise TypeError.new("Can't convert #{other.class} to a time")
      end
      send("add_#{@kind}", other, @value)
    end

    def from_now
      self + Time.now
    end

    def ago
      (-self) + Time.now
    end

  end
end
