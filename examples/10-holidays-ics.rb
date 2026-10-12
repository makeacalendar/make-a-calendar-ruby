# Export 2027 observed federal holidays as date-only iCalendar events.
require "make_a_calendar"
events = MakeACalendar.federal_holidays(2027).map { |holiday| { date: holiday.observed_date, summary: holiday.name } }
print MakeACalendar.to_ics(events, name: "US Federal Holidays 2027")
