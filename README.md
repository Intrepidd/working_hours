# WorkingHours

Gem allowing to do time calculation with working hours.

## Installation

Gemfile:

    gem 'working_hours'

## Usage

```ruby
require 'working_hours'

# Move forward
1.working.day.from_now
2.working.hours.from_now
15.working.minutes.from_now

# Move backward
1.working.day.ago
2.working.hours.ago
15.working.minutes.ago

# Start from custom Date or Time
Date.new(1989, 12, 31) + 8.working.days
Time.new(1969, 8, 4, 8, 32) - 4.working.hours

# Compute working days between two date
friday.working_days_until(monday) # => 1

# Compute working duration between two times
time1.business_time_until(time2)

# Configure working hours
WorkingHours::Config.working_hours = {
  :mon => {'09:00' => '12:00', '13:00' => '17:00'},
  :tue => {'09:00' => '12:00', '13:00' => '17:00'},
  :wed => {'09:00' => '12:00', '13:00' => '17:00'},
  :thu => {'09:00' => '12:00', '13:00' => '17:00'},
  :fri => {'09:00' => '12:00', '13:00' => '17:00'},
  :sat => {'10:00' => '15:00'}
}

# Configure holidays
WorkingHours::Config.holidays = [Date.new(1989, 12, 31)]

# Configure timezone (uses activesupport, defaults to Time.zone)
WorkingHours::Config.time_zone = 'Paris'

```

## Timezones

This gem uses a simple but efficient approach in dealing with timezones. When you define your working hours you choose a timezome associated with it (in the above example, the working hours are then in Paris time). Then, any time used in calcultation will be converted to this timezone first, so you don't have to worry if your times are local or UTC as long as they are valid :)

## Contributing

1. Fork it ( http://github.com/<my-github-username>/working_hours/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
