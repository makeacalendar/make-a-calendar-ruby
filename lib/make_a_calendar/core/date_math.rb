# frozen_string_literal: true

require "date"

module MakeACalendar
  module DateMath
    WEEKDAYS = %i[sunday monday tuesday wednesday thursday friday saturday].freeze
    module_function

    def date(value)
      raise InvalidDate, "expected a date-only value, not a timestamp" if value.is_a?(DateTime)
      if value.is_a?(Date)
        result = value
      else
        text = value.to_s
        raise InvalidDate, "expected an ISO YYYY-MM-DD date" unless text.match?(/\A\d{4}-\d{2}-\d{2}\z/)
        result = Date.iso8601(text)
      end
      raise InvalidDate, "expected a Gregorian date" unless result.gregorian?
      result
    rescue ArgumentError, TypeError
      raise InvalidDate, "invalid date: #{value.inspect}"
    end

    def month_start(year, month)
      Date.new(Integer(year), Integer(month), 1)
    rescue ArgumentError, TypeError
      raise InvalidDate, "invalid year or month: #{year.inspect}-#{month.inspect}"
    end

    def month_end(year, month)
      (month_start(year, month) >> 1) - 1
    end

    def quarter(date)
      date = self.date(date)
      first_month = ((date.month - 1) / 3) * 3 + 1
      quarter_start = Date.new(date.year, first_month, 1)
      [quarter_start, (quarter_start >> 3) - 1]
    end

    def month_grid(year, month, week_start: :sunday, fixed_rows: nil, undated: false)
      first = month_start(year, month)
      start_index = weekday_index(week_start)
      offset = (first.wday - start_index) % 7
      grid_start = first - offset
      rows = fixed_rows ? Integer(fixed_rows) : ((offset + ((first >> 1) - 1).day + 6) / 7)
      raise ArgumentError, "fixed_rows must be 4, 5, or 6" unless (4..6).cover?(rows)
      (0...(rows * 7)).map do |index|
        current = grid_start + index
        in_month = current.month == first.month
        { date: undated && !in_month ? nil : current, day: undated && !in_month ? nil : current.day,
          in_month: in_month, weekday: WEEKDAYS[(start_index + index % 7) % 7],
          week: current.cweek, week_year: current.cwyear }.freeze
      end.each_slice(7).map(&:freeze).freeze
    end

    def weekday_index(value)
      key = value.is_a?(Integer) ? value : WEEKDAYS.index(value.to_sym)
      raise ArgumentError, "week_start must be a weekday name or 0..6" unless key && (0..6).cover?(key)
      key
    end

    def each_date(from, to)
      return enum_for(:each_date, from, to) unless block_given?
      first = date(from)
      last = date(to)
      step = first <= last ? 1 : -1
      current = first
      while step == 1 ? current <= last : current >= last
        yield current
        current += step
      end
    end

    def ordinal(date)
      date = self.date(date)
      [date.year, date.yday]
    end

    def iso_week(date)
      date = self.date(date)
      [date.cwyear, date.cweek, date.cwday]
    end
  end
end
