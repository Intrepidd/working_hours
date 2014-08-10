require 'date'
require 'working_hours/computation'

module WorkingHours
  class Duration
    include Computation

    attr_accessor :value, :kind

    SUPPORTED_KINDS = [:days, :hours, :minutes, :seconds]

    def initialize(value, kind)
      raise WorkingHours::UnknownDuration unless SUPPORTED_KINDS.include?(kind)
      @value = value
      @kind = kind
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

  end
end
