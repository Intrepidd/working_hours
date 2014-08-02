require "active_support/all"

require "working_hours/version"
require "working_hours/duration"
require "working_hours/config"
require "working_hours/duration_proxy"
require "working_hours/core_ext/fixnum"

module WorkingHours
  UnknownDuration = Class.new StandardError
  InvalidConfiguration = Class.new StandardError
end
