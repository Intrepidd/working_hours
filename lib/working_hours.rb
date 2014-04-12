require "working_hours/version"
require "working_hours/duration"
require "working_hours/duration_proxy"
require "working_hours/core_ext/fixnum"

module WorkingHours
  class UnknownDuration < StandardError; end
end
