# frozen_string_literal: true

require "date"

module MakeACalendar
  Holiday = Struct.new(:name, :date, :observed_date, keyword_init: true) do
    def to_h
      { name: name, date: date.iso8601, observed_date: observed_date.iso8601 }
    end
  end

  module Holidays
    module_function

    def us_federal(year)
      year = Integer(year)
      holidays = []
      add = lambda do |name, day|
        observed = day.saturday? ? day - 1 : (day.sunday? ? day + 1 : day)
        holidays << Holiday.new(name: name, date: day, observed_date: observed).freeze
      end
      add.call("New Year's Day", Date.new(year, 1, 1)) if year >= 1870
      add.call("Birthday of Martin Luther King, Jr.", nth_weekday(year, 1, 1, 3)) if year >= 1986
      washington = year >= 1971 ? nth_weekday(year, 2, 1, 3) : Date.new(year, 2, 22)
      add.call("Washington's Birthday", washington) if year >= 1879
      memorial = year >= 1971 ? last_weekday(year, 5, 1) : Date.new(year, 5, 30)
      add.call("Memorial Day", memorial) if year >= 1888
      add.call("Juneteenth National Independence Day", Date.new(year, 6, 19)) if year >= 2021
      add.call("Independence Day", Date.new(year, 7, 4)) if year >= 1870
      add.call("Labor Day", nth_weekday(year, 9, 1, 1)) if year >= 1894
      add.call("Columbus Day", nth_weekday(year, 10, 1, 2)) if year >= 1971
      veterans = (1971..1977).cover?(year) ? nth_weekday(year, 10, 1, 4) : Date.new(year, 11, 11)
      add.call("Veterans Day", veterans) if year >= 1938
      thanksgiving = year >= 1939 ? nth_weekday(year, 11, 4, 4) : last_weekday(year, 11, 4)
      add.call("Thanksgiving Day", thanksgiving) if year >= 1863
      add.call("Christmas Day", Date.new(year, 12, 25)) if year >= 1870
      holidays.freeze
    end

    def for_years(first_year, last_year = first_year)
      (Integer(first_year)..Integer(last_year)).flat_map { |year| us_federal(year) }
    end

    def observed_dates(first_year, last_year = first_year)
      # Include adjacent legal years because a Saturday New Year's Day is observed on Dec 31.
      for_years(Integer(first_year) - 1, Integer(last_year) + 1).map(&:observed_date).uniq.freeze
    end

    def nth_weekday(year, month, wday, occurrence)
      first = Date.new(year, month, 1)
      first + ((wday - first.wday) % 7) + 7 * (occurrence - 1)
    end

    def last_weekday(year, month, wday)
      last = (Date.new(year, month, 1) >> 1) - 1
      last - ((last.wday - wday) % 7)
    end
    private_class_method :nth_weekday, :last_weekday
  end
end
