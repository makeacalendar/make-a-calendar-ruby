# Convert an Excel 1900-system serial date.
require "make_a_calendar"
puts MakeACalendar::Converters.excel(45_000, system: "1900")
