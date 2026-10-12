# Generate a biweekly Friday payroll schedule.
require "make_a_calendar"
dates = MakeACalendar::Scheduling.pay_dates(start_date: "2027-01-01", end_date: "2027-12-31", frequency: :biweekly, anchor: "2027-01-01", adjust: :preceding)
puts dates.map(&:iso8601)
