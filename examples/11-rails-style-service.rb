# A service object for a Rails app; Rails itself is not required to run this example.
require "make_a_calendar"
class MonthlyCalendarService
  def self.call(year:, month:)
    MakeACalendar.month(year: year, month: month, week_start: :monday).to_html(theme: :business)
  end
end
puts MonthlyCalendarService.call(year: 2027, month: 10).include?("<table>")
