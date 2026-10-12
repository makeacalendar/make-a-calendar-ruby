# Convert Windows FILETIME ticks to UTC.
require "make_a_calendar"
puts MakeACalendar::Converters.filetime("134000000000000000").utc.iso8601
