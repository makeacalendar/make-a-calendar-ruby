# NRF-style fiscal periods labeled by their ending year.
require "json"
require "make_a_calendar"
puts JSON.pretty_generate(MakeACalendar.fiscal_calendar(year: 2029, pattern: :four_four_five).to_h)
