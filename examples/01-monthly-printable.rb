# October 2027 monthly calendar as print-friendly SVG.
require "make_a_calendar"
puts MakeACalendar.month(year: 2027, month: 10).to_svg(theme: :ink_saver)
