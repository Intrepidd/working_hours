require "active_support/all"

require "working_hours/version"
require "working_hours/config"
require "working_hours/core_ext/fixnum"
require "working_hours/core_ext/date_and_time"

module WorkingHours
  InvalidConfiguration = Class.new StandardError
end
