# frozen_string_literal: true

require "date"
require_relative "make_a_calendar/version"
require_relative "make_a_calendar/errors"
require_relative "make_a_calendar/core/date_math"
require_relative "make_a_calendar/scheduling/holidays"
require_relative "make_a_calendar/scheduling/business_days"
require_relative "make_a_calendar/scheduling/recurring"
require_relative "make_a_calendar/scheduling/fiscal"
require_relative "make_a_calendar/converters"
require_relative "make_a_calendar/calendar"
require_relative "make_a_calendar/export/ics"

module MakeACalendar
  module_function

  # Build an immutable month grid. Weekdays use Sunday=0 through Saturday=6.
  def month(year:, month:, week_start: :sunday, fixed_rows: nil, holidays: [])
    Calendar.new(year: year, month: month, week_start: week_start, fixed_rows: fixed_rows, holidays: holidays)
  end

  # Build a twelve-month printable calendar.
  def year(year:, week_start: :sunday, holidays: [])
    YearCalendar.new(year: year, week_start: week_start, holidays: holidays)
  end

  # Count workdays in an inclusive date range by default.
  def business_days_between(from, to, **options)
    BusinessDays.between(from, to, **options)
  end

  # Add business days; the start date is not counted when days is nonzero.
  def add_business_days(date, days, **options)
    BusinessDays.add(date, days, **options)
  end

  # Return the US federal holiday rules for a calendar year.
  def federal_holidays(year)
    Holidays.us_federal(year)
  end

  # Create an NRF-style retail fiscal calendar named for its ending year.
  def fiscal_calendar(year:, pattern: :four_four_five, extra_week: :last_period, label: :ending_year)
    FiscalCalendar.new(year: year, pattern: pattern, extra_week: extra_week, label: label)
  end

  # Build date-only events as an RFC 5545 iCalendar string.
  def to_ics(events, name: "Make a Calendar Toolkit")
    ICS.calendar(events, name: name)
  end
end
