# A fixed six-row black-and-white planner with Monday-first weeks.
require "make_a_calendar"
puts MakeACalendar.month(year: 2027, month: 10, week_start: :monday, fixed_rows: 6).to_svg(theme: :ink_saver, page_size: :a4_landscape)
