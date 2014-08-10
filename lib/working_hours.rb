require "active_support/all"

require "working_hours/version"
require "working_hours/config"
require "working_hours/core_ext/fixnum"
require "working_hours/core_ext/date_and_time"
require "working_hours/core_ext/time"
require "working_hours/core_ext/date"
require "working_hours/core_ext/datetime"

module WorkingHours
  UnknownDuration = Class.new StandardError
  InvalidConfiguration = Class.new StandardError
end
