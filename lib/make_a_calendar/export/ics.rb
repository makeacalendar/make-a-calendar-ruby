# frozen_string_literal: true

require "time"

module MakeACalendar
  module ICS
    module_function

    def calendar(events, name: "Make a Calendar Toolkit")
      raise ArgumentError, "at most 10,000 events may be exported at once" if events.length > 10_000
      lines = ["BEGIN:VCALENDAR", "VERSION:2.0", "PRODID:-//Make a Calendar Toolkit//EN", "CALSCALE:GREGORIAN", "X-WR-CALNAME:#{escape(name)}"]
      events.each_with_index do |event, index|
        date = DateMath.date(event.fetch(:date))
        uid = event[:uid] || "#{date.strftime('%Y%m%d')}-#{index + 1}@make-a-calendar-toolkit"
        summary = event.fetch(:summary)
        lines.concat(["BEGIN:VEVENT", "UID:#{escape(uid)}", "DTSTAMP:#{Time.now.utc.strftime('%Y%m%dT%H%M%SZ')}",
                      "DTSTART;VALUE=DATE:#{date.strftime('%Y%m%d')}", "DTEND;VALUE=DATE:#{(date + 1).strftime('%Y%m%d')}",
                      "SUMMARY:#{escape(summary)}"])
        lines << "DESCRIPTION:#{escape(event[:description])}" if event[:description]
        lines << "LOCATION:#{escape(event[:location])}" if event[:location]
        lines << "END:VEVENT"
      end
      lines << "END:VCALENDAR"
      lines.map { |line| fold(line) }.join("\r\n") + "\r\n"
    end

    def holiday_calendar(year)
      calendar(Holidays.us_federal(year).map { |holiday| { date: holiday.observed_date, summary: holiday.name } }, name: "US Federal Holidays #{year}")
    end

    def escape(value)
      value.to_s.gsub(/\\/, "\\\\").gsub(/\r?\n/, "\\n").gsub(/;/, "\\;").gsub(/,/, "\\,")
    end

    def fold(line)
      # RFC 5545 folds at 75 octets; UTF-8 code points are kept intact.
      result = +""
      count = 0
      line.each_char do |character|
        length = character.bytesize
        if count + length > 75
          result << "\r\n "
          count = 1
        end
        result << character
        count += length
      end
      result
    end
    private_class_method :fold
  end
end
