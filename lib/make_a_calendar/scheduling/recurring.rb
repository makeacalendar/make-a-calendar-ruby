# frozen_string_literal: true

require "date"

module MakeACalendar
  module Scheduling
    module_function

    def pay_dates(start_date:, end_date:, frequency:, anchor: nil, adjust: :none, weekend: [0, 6], holidays: [])
      first = DateMath.date(start_date)
      last = DateMath.date(end_date)
      raise ArgumentError, "schedule range is limited to 100 years" if (last - first).abs > BusinessDays::MAX_RANGE_DAYS
      dates = case frequency.to_sym
              when :weekly, :biweekly
                interval = frequency.to_sym == :weekly ? 7 : 14
                cursor = DateMath.date(anchor || first)
                cursor += interval while cursor < first
                list = []
                while cursor <= last
                  list << cursor
                  cursor += interval
                end
                list
              when :semi_monthly
                semi_monthly_dates(first, last, anchor)
              when :monthly
                monthly_dates(first, last, anchor)
              else
                raise ArgumentError, "frequency must be weekly, biweekly, semi_monthly, or monthly"
              end
      dates.map do |date|
        case adjust.to_sym
        when :none then date
        when :following then move_to_workday(date, 1, weekend, holidays)
        when :preceding then move_to_workday(date, -1, weekend, holidays)
        when :modified_following
          moved = move_to_workday(date, 1, weekend, holidays)
          moved.month == date.month ? moved : move_to_workday(date, -1, weekend, holidays)
        else raise ArgumentError, "adjust must be none, following, preceding, or modified_following"
        end
      end.uniq.freeze
    end

    def shift_dates(start_date:, end_date:, pattern:, anchor: nil)
      first = DateMath.date(start_date)
      last = DateMath.date(end_date)
      raise ArgumentError, "schedule range is limited to 100 years" if (last - first).abs > BusinessDays::MAX_RANGE_DAYS
      cycle = pattern.is_a?(String) ? pattern.split("-").map { |part| Integer(part) } : pattern.map { |part| Integer(part) }
      raise ArgumentError, "pattern must contain positive on/off lengths" if cycle.empty? || cycle.any? { |part| part <= 0 }
      anchor_date = DateMath.date(anchor || first)
      DateMath.each_date(first, last).map do |date|
        offset = (date - anchor_date).to_i % cycle.sum
        segment_start = 0
        segment_index = cycle.index do |segment_length|
          covered = offset < segment_start + segment_length
          segment_start += segment_length unless covered
          covered
        end
        on_duty = segment_index.even?
        { date: date, on_duty: on_duty, cycle_day: offset + 1 }.freeze
      end.freeze
    end

    def semi_monthly_dates(first, last, anchor)
      day = anchor ? DateMath.date(anchor).day : 15
      dates = []
      cursor = Date.new(first.year, first.month, 1)
      while cursor <= last
        month_end = (cursor >> 1) - 1
        [Date.new(cursor.year, cursor.month, [day, month_end.day].min), month_end].each do |date|
          dates << date if date >= first && date <= last
        end
        cursor = cursor >> 1
      end
      dates.uniq.sort
    end

    def monthly_dates(first, last, anchor)
      requested_day = anchor ? DateMath.date(anchor).day : 1
      dates = []
      cursor = Date.new(first.year, first.month, 1)
      while cursor <= last
        month_end = (cursor >> 1) - 1
        date = Date.new(cursor.year, cursor.month, [requested_day, month_end.day].min)
        dates << date if date >= first && date <= last
        cursor = cursor >> 1
      end
      dates
    end

    def move_to_workday(date, direction, weekend, holidays)
      current = date
      weekend_days = weekend.map { |day| DateMath.weekday_index(day) }
      holiday_dates = holidays.map { |holiday| holiday.respond_to?(:observed_date) ? holiday.observed_date : DateMath.date(holiday) }
      current += direction while weekend_days.include?(current.wday) || holiday_dates.include?(current)
      current
    end
    private_class_method :semi_monthly_dates, :monthly_dates, :move_to_workday
  end
end
