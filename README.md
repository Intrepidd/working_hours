# WorkingHours

TODO: Write a gem description

## Installation

Add this line to your application's Gemfile:

    gem 'working_hours'

And then execute:

    $ bundle

Or install it yourself as:

    $ gem install working_hours

## Usage

```ruby
require 'working_hours'

# Move forward
2.working.hour.from_now
8.working.hours.from_now
1.working.day.from_now
4.working.days.from_now

# Move backward
2.working.hour.ago
8.working.hours.ago
1.working.day.ago
4.working.days.ago

# Start from custom Date or Time
Date.new(1989, 12, 31) + 8.working.days
Time.new(1969, 8, 4, 8, 32) - 4.working.hours

# Configure working hours
WorkingHours::Config.working_hours = {
  :mon => {'09:00' => '12:00', '13:00' => '17:00'},
  :tue => {'09:00' => '12:00', '13:00' => '17:00'},
  :wed => {'09:00' => '12:00', '13:00' => '17:00'},
  :thu => {'09:00' => '12:00', '13:00' => '17:00'},
  :fri => {'09:00' => '12:00', '13:00' => '17:00'},
  :sat => {'10:00' => '15:00'}
}
```

## Contributing

1. Fork it ( http://github.com/<my-github-username>/working_hours/fork )
2. Create your feature branch (`git checkout -b my-new-feature`)
3. Commit your changes (`git commit -am 'Add some feature'`)
4. Push to the branch (`git push origin my-new-feature`)
5. Create new Pull Request
