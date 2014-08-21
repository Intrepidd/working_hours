require "active_support/all"

require "working_hours/version"
require "working_hours/config"
require "working_hours/core_ext/fixnum"
require "working_hours/core_ext/date_and_time"

module WorkingHours
  extend WorkingHours::Computation

  InvalidConfiguration = Class.new StandardError

  def self.working_days_between from, to
    if to < from
      -working_days_between(to, from)
    else
      from = in_config_zone(from)
      to = in_config_zone(to)
      days = 0
      while from.to_date < to.to_date
        from += 1.day
        days += 1 if working_day?(from)
      end
      days
    end
  end
end
