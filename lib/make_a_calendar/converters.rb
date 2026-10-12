# frozen_string_literal: true

require "date"
require "time"

module MakeACalendar
  module Converters
    EXCEL_EPOCH_1900 = Date.new(1899, 12, 31).freeze
    EXCEL_EPOCH_1904 = Date.new(1904, 1, 1).freeze
    FILETIME_EPOCH = Time.utc(1601, 1, 1).freeze
    module_function

    def unix(value, unit: :seconds)
      unit_divisors = { seconds: 1, milliseconds: 1_000, microseconds: 1_000_000, nanoseconds: 1_000_000_000 }
      divisor = unit_divisors[unit.to_sym] or raise ArgumentError, "unsupported Unix timestamp unit"
      seconds = Rational(value.to_s) / divisor
      Time.at(seconds).utc
    rescue ArgumentError, TypeError, ZeroDivisionError
      raise ArgumentError, "invalid Unix timestamp or unit"
    end

    def to_unix(time, unit: :seconds)
      time = parse_time(time)
      factors = { seconds: 1, milliseconds: 1_000, microseconds: 1_000_000, nanoseconds: 1_000_000_000 }
      factor = factors[unit.to_sym] or raise ArgumentError, "unsupported Unix timestamp unit"
      (time.to_r * factor).to_i
    end

    def excel(serial, system: "1900")
      value = Rational(serial.to_s)
      days = value.floor
      fraction = value - days
      mode = system.to_s
      case mode
      when "1900"
        raise ArgumentError, "Excel serial 60 is the fictitious 1900-02-29" if days == 60
        date = EXCEL_EPOCH_1900 + days - (days > 60 ? 1 : 0)
      when "1904"
        date = EXCEL_EPOCH_1904 + days
      else
        raise ArgumentError, "system must be :1900 or :1904"
      end
      return date if fraction.zero?
      seconds = (fraction * 86_400).round
      Time.utc(date.year, date.month, date.day) + seconds
    rescue TypeError, ArgumentError, ZeroDivisionError
      raise unless $!.message.include?("fictitious") || $!.message.start_with?("system must")
      raise
    end

    def filetime(ticks)
      FILETIME_EPOCH + Rational(Integer(ticks), 10_000_000)
    rescue ArgumentError, TypeError
      raise ArgumentError, "FILETIME must be an integer count of 100-nanosecond intervals"
    end

    def to_filetime(time)
      ((parse_time(time).to_r - FILETIME_EPOCH.to_r) * 10_000_000).to_i
    end

    def iso8601(value)
      value.is_a?(DateTime) ? value.iso8601 : (value.is_a?(Date) ? value.iso8601 : parse_time(value).iso8601)
    end

    def parse_time(value)
      return value.getutc if value.is_a?(Time)
      return value.to_time.getutc if value.is_a?(DateTime)
      text = value.to_s
      raise ArgumentError unless text.match?(/(?:Z|[+-]\d{2}:?\d{2})\z/i)
      Time.iso8601(text).getutc
    rescue ArgumentError, TypeError
      raise ArgumentError, "expected an ISO 8601 timestamp with an explicit offset"
    end

    def ordinal(value)
      text = value.to_s
      if text.match?(/\A\d{4}-\d{3}\z/)
        year, day = text.split("-").map(&:to_i)
      elsif text.match?(/\A\d{7}\z/)
        year = text[0, 4].to_i
        day = text[4, 3].to_i
      else
        raise ArgumentError, "ordinal date must use YYYY-DDD or YYYYDDD"
      end
      Date.ordinal(year, day)
    rescue Date::Error
      raise ArgumentError, "ordinal day is outside the year"
    end
  end
end
