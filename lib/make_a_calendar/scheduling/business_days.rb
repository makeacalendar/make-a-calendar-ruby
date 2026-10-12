# frozen_string_literal: true

require "date"

module MakeACalendar
  module BusinessDays
    MAX_RANGE_DAYS = 36_600
    module_function

    def between(from, to, weekend: [0, 6], holidays: [], inclusive: true)
      first = DateMath.date(from)
      last = DateMath.date(to)
      ensure_reasonable_range(first, last)
      weekend_days = weekend.map { |day| DateMath.weekday_index(day) }
      holiday_dates = holidays.map { |item| item.respond_to?(:observed_date) ? item.observed_date : DateMath.date(item) }
      DateMath.each_date(first, last).count do |date|
        included = inclusive || (date != first && date != last)
        included && !weekend_days.include?(date.wday) && !holiday_dates.include?(date)
      end
    end

    def each_workday(from, to, weekend: [0, 6], holidays: [])
      return enum_for(:each_workday, from, to, weekend: weekend, holidays: holidays) unless block_given?
      first = DateMath.date(from)
      last = DateMath.date(to)
      ensure_reasonable_range(first, last)
      weekend_days = weekend.map { |day| DateMath.weekday_index(day) }
      holiday_dates = holidays.map { |item| item.respond_to?(:observed_date) ? item.observed_date : DateMath.date(item) }
      DateMath.each_date(first, last) do |date|
        yield date unless weekend_days.include?(date.wday) || holiday_dates.include?(date)
      end
    end

    def add(date, days, weekend: [0, 6], holidays: [])
      current = DateMath.date(date)
      count = Integer(days)
      return current if count.zero?
      step = count.positive? ? 1 : -1
      remaining = count.abs
      weekend_days = weekend.map { |day| DateMath.weekday_index(day) }
      holiday_dates = holidays.map { |item| item.respond_to?(:observed_date) ? item.observed_date : DateMath.date(item) }
      while remaining.positive?
        current += step
        next if weekend_days.include?(current.wday) || holiday_dates.include?(current)
        remaining -= 1
      end
      current
    end

    def next(date, **options)
      add(date, 1, **options)
    end

    def previous(date, **options)
      add(date, -1, **options)
    end

    def in_month(year, month, **options)
      first = Date.new(Integer(year), Integer(month), 1)
      between(first, (first >> 1) - 1, **options)
    end

    def in_year(year, **options)
      between(Date.new(Integer(year), 1, 1), Date.new(Integer(year), 12, 31), **options)
    end

    def ensure_reasonable_range(first, last)
      raise ArgumentError, "business-day range is limited to 100 years" if (last - first).abs > MAX_RANGE_DAYS
    end
    private_class_method :ensure_reasonable_range
  end
end
