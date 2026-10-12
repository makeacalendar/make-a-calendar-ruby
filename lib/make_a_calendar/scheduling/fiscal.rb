# frozen_string_literal: true

require "date"

module MakeACalendar
  FiscalPeriod = Struct.new(:number, :start_date, :end_date, :quarter, :weeks, keyword_init: true) do
    def to_h
      { number: number, start_date: start_date.iso8601, end_date: end_date.iso8601, quarter: quarter, weeks: weeks }
    end
  end

  class FiscalCalendar
    attr_reader :label_year, :start_date, :end_date, :pattern, :periods

    def initialize(year:, pattern: :four_four_five, extra_week: :last_period, label: :ending_year)
      @label_year = Integer(year)
      @pattern = normalize_pattern(pattern).freeze
      raise ArgumentError, "extra_week must be :last_period or :first_period" unless %i[last_period first_period].include?(extra_week.to_sym)
      raise ArgumentError, "label must be :ending_year or :starting_year" unless %i[ending_year starting_year].include?(label.to_sym)
      start_year = label.to_sym == :ending_year ? @label_year - 1 : @label_year
      next_start_year = start_year + 1
      @start_date = nearest_sunday(Date.new(start_year, 2, 1))
      next_start = nearest_sunday(Date.new(next_start_year, 2, 1))
      weeks = ((next_start - @start_date).to_i / 7)
      raise Error, "retail fiscal year must have 52 or 53 weeks" unless [52, 53].include?(weeks)
      @end_date = next_start - 1
      lengths = @pattern * 4
      if weeks == 53
        extra_week.to_sym == :last_period ? lengths[-1] += 1 : lengths[0] += 1
      end
      cursor = @start_date
      @periods = lengths.each_with_index.map do |period_weeks, index|
        period_end = cursor + (period_weeks * 7) - 1
        period = FiscalPeriod.new(number: index + 1, start_date: cursor, end_date: period_end,
                                  quarter: index / 3 + 1, weeks: period_weeks).freeze
        cursor = period_end + 1
        period
      end.freeze
      freeze
    end

    def period_for(date)
      date = DateMath.date(date)
      periods.find { |period| date >= period.start_date && date <= period.end_date }
    end

    def to_h
      { label_year: label_year, start_date: start_date.iso8601, end_date: end_date.iso8601,
        weeks: ((end_date - start_date + 1).to_i / 7), pattern: pattern, periods: periods.map(&:to_h) }
    end

    private

    def normalize_pattern(value)
      key = value.to_s.downcase.delete("_").delete("-")
      patterns = { "445" => [4, 4, 5], "454" => [4, 5, 4], "544" => [5, 4, 4],
                   "fourfourfive" => [4, 4, 5], "fourfivefour" => [4, 5, 4], "fivefourfour" => [5, 4, 4] }
      patterns.fetch(key) { raise ArgumentError, "pattern must be 445, 454, or 544" }
    end

    def nearest_sunday(date)
      before = date - date.wday
      after = before + 7
      (date - before).to_i <= (after - date).to_i ? before : after
    end
  end
end
