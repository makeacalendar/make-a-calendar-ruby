# Repeat a 2-on, 2-off, 3-on rotation over January 2027.
require "make_a_calendar"
rows = MakeACalendar::Scheduling.shift_dates(start_date: "2027-01-01", end_date: "2027-01-31", pattern: "2-2-3", anchor: "2027-01-01")
puts rows.select { |row| row[:on_duty] }.map { |row| row[:date].iso8601 }
