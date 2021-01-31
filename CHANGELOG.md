# Unreleased

[Compare master with v1.3.0](https://github.com/intrepidd/working_hours/compare/v1.3.0...master)

# v1.3.0
* Improve supports for fractional seconds in input times by only rounding results at the end - [#42](https://github.com/Intrepidd/working_hours/issues/42) [#43](https://github.com/Intrepidd/working_hours/pull/43)

# v1.2.0
* Drop support for ruby 2.0, 2.1, 2.2 and 2.3
* Drop support for jruby 1.7 and 9.0
* Drop support for ActiveSupport 3.x
* Add support for jruby 9.2
* Add support for ruby 2.5, 2.6 and 2.7
* Add support for ActiveSupport 5.x and 6.x
* Fix day computations when origin is a holiday or a non worked day - [#39](https://github.com/Intrepidd/working_hours/pull/39)


# v1.1.4
* Fix thread safety - [#36](https://github.com/Intrepidd/working_hours/pull/36)

# v1.1.3
* Fixed warnings with Ruby 2.4.0+ - [#32](https://github.com/Intrepidd/working_hours/pull/32)
* Fix install bug with jruby 1.7.20

# v1.1.2
* Fixed an issue of float imprecision causing infinite loop - [#27](https://github.com/Intrepidd/working_hours/pull/27)
* Added #next_working_time and #advance_to_closing_time - [#23](https://github.com/Intrepidd/working_hours/pull/23)

_06/12/2015_

# v1.1.1
* Fix infinite loop happening when rewinding seconds and crossing through midgnight

_18/08/2015_

# v1.1.0
* Config set globally is now properly inherited in new threads. This fixes the issue when setting the config once in an initializer won't work in threaded web servers.

_03/04/2015_

# v1.0.4
* Fixed a nasty stack level too deep error on DateTime#+ and DateTime#- (thanks @jlanatta)

_27/03/2015_

# v1.0.3

* Relax configuration input formats - [#10](https://github.com/Intrepidd/working_hours/pull/10)
* Small improvements to the Readme

_08/11/2014_

# v1.0.2

* Dropped use of `prepend` in favor of `alias_method` for core extensions to increase compability with jruby.

_15/10/2014_

# v1.0.1

* Fix bug when calling ``1.working.hour.ago`` would return a time in your system zone instead of the configured time zone. This was due to a conversion to Time that loses the timezone information. We'll now return an ``ActiveSupport::TimeWithZone``.

_10/10/2014_

# v1.0.0

* Replace config freeze by hash based caching (config is recompiled when changed), this avoids freezing unwanted objects (nil, timezones, integers, etc..)

_15/09/2014_

# v0.9.0

* First beta release

_24/08/2014_
