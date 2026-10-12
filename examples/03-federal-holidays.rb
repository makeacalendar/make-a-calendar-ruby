# Legal and observed US federal holidays for 2027.
require "json"
require "make_a_calendar"
puts JSON.pretty_generate(MakeACalendar.federal_holidays(2027).map(&:to_h))
