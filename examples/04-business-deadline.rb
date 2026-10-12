# Add 30 weekdays after a date, excluding observed federal holidays.
require "make_a_calendar"
holidays = MakeACalendar::Holidays.observed_dates(2027)
puts MakeACalendar.add_business_days("2027-02-01", 30, holidays: holidays)
