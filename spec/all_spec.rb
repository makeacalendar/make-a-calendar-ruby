# frozen_string_literal: true

require "minitest/autorun"
require "open3"
require "make_a_calendar"

class MakeACalendarSpec < Minitest::Test
  def test_month_boundaries_and_leap_days
    assert_equal Date.new(2027, 1, 1), MakeACalendar::DateMath.month_start(2027, 1)
    assert_equal Date.new(2027, 1, 31), MakeACalendar::DateMath.month_end(2027, 1)
    assert_equal Date.new(2024, 2, 29), Date.new(2024, 2, 29)
    assert_equal 28, MakeACalendar::DateMath.month_end(2100, 2).day
    assert_equal 29, MakeACalendar::DateMath.month_end(2000, 2).day
  end

  def test_quarters_and_iso_week_year_boundary
    assert_equal [Date.new(2027, 10, 1), Date.new(2027, 12, 31)], MakeACalendar::DateMath.quarter(Date.new(2027, 10, 12))
    assert_equal [2020, 53, 4], MakeACalendar::DateMath.iso_week(Date.new(2020, 12, 31))
    assert_equal [2020, 53, 5], MakeACalendar::DateMath.iso_week(Date.new(2021, 1, 1))
    assert_equal [2026, 365], MakeACalendar::DateMath.ordinal(Date.new(2026, 12, 31))
  end

  def test_week_start_and_four_five_six_row_months
    monday = MakeACalendar.month(year: 2021, month: 2, week_start: :monday)
    sunday = MakeACalendar.month(year: 2021, month: 2, week_start: :sunday)
    assert_equal 4, monday.grid.length
    assert_equal 5, sunday.grid.length
    assert_equal Date.new(2021, 2, 1), monday.grid.first.first[:date]
    assert_equal Date.new(2021, 1, 31), sunday.grid.first.first[:date]
    assert_equal 6, MakeACalendar.month(year: 2020, month: 8).grid.length
    assert_equal 6, MakeACalendar.month(year: 2027, month: 10, fixed_rows: 6).grid.length
  end

  def test_grid_has_seven_cells_and_adjacent_months
    [Date.new(2027, 1, 1), Date.new(2026, 12, 31), Date.new(2024, 2, 29), Date.new(2100, 2, 28), Date.new(2000, 2, 29)].each do |date|
      grid = MakeACalendar.month(year: date.year, month: date.month).grid
      assert grid.all? { |row| row.length == 7 }
      assert_includes grid.flatten.map { |cell| cell[:date] }, date
    end
  end

  def test_date_range_iteration_is_inclusive_and_supports_reverse
    assert_equal [Date.new(2027, 1, 1), Date.new(2027, 1, 2), Date.new(2027, 1, 3)], MakeACalendar::DateMath.each_date("2027-01-01", "2027-01-03").to_a
    assert_equal [Date.new(2027, 1, 3), Date.new(2027, 1, 2), Date.new(2027, 1, 1)], MakeACalendar::DateMath.each_date("2027-01-03", "2027-01-01").to_a
    assert_raises(MakeACalendar::InvalidDate) { MakeACalendar::DateMath.date("2027-01-01T12:00:00Z") }
    assert_raises(MakeACalendar::InvalidDate) { MakeACalendar::DateMath.date(DateTime.new(2027, 1, 1)) }
  end

  def test_federal_holidays_have_actual_and_observed_dates
    july = MakeACalendar.federal_holidays(2021).find { |holiday| holiday.name == "Independence Day" }
    assert_equal Date.new(2021, 7, 4), july.date
    assert_equal Date.new(2021, 7, 5), july.observed_date
    new_year = MakeACalendar.federal_holidays(2022).find { |holiday| holiday.name == "New Year's Day" }
    assert_equal Date.new(2022, 1, 1), new_year.date
    assert_equal Date.new(2021, 12, 31), new_year.observed_date
  end

  def test_holiday_effective_dates
    refute_includes MakeACalendar.federal_holidays(1985).map(&:name), "Birthday of Martin Luther King, Jr."
    assert_includes MakeACalendar.federal_holidays(1986).map(&:name), "Birthday of Martin Luther King, Jr."
    refute_includes MakeACalendar.federal_holidays(2020).map(&:name), "Juneteenth National Independence Day"
    assert_includes MakeACalendar.federal_holidays(2021).map(&:name), "Juneteenth National Independence Day"
    memorial_1970 = MakeACalendar.federal_holidays(1970).find { |holiday| holiday.name == "Memorial Day" }
    assert_equal Date.new(1970, 5, 30), memorial_1970.date
    washington_1970 = MakeACalendar.federal_holidays(1970).find { |holiday| holiday.name == "Washington's Birthday" }
    assert_equal Date.new(1970, 2, 22), washington_1970.date
    veterans_1975 = MakeACalendar.federal_holidays(1975).find { |holiday| holiday.name == "Veterans Day" }
    assert_equal Date.new(1975, 10, 27), veterans_1975.date
  end

  def test_business_days_are_inclusive_and_can_exclude_endpoints
    assert_equal 3, MakeACalendar.business_days_between("2027-01-01", "2027-01-05")
    assert_equal 1, MakeACalendar.business_days_between("2027-01-01", "2027-01-05", inclusive: false)
    assert_equal 1, MakeACalendar.business_days_between("2027-01-04", "2027-01-04")
    assert_equal 0, MakeACalendar.business_days_between("2027-01-04", "2027-01-04", inclusive: false)
  end

  def test_custom_weekend_holidays_and_month_totals
    assert_equal 3, MakeACalendar.business_days_between("2027-01-01", "2027-01-05", weekend: [5, 6])
    assert_equal 2, MakeACalendar.business_days_between("2027-01-04", "2027-01-06", holidays: [Date.new(2027, 1, 5)])
    assert_equal 21, MakeACalendar::BusinessDays.in_month(2027, 1)
    assert_equal 261, MakeACalendar::BusinessDays.in_year(2027)
    assert_raises(ArgumentError) { MakeACalendar.business_days_between("1900-01-01", "2027-01-01") }
  end

  def test_business_day_addition_and_iteration
    assert_equal Date.new(2027, 1, 4), MakeACalendar.add_business_days("2027-01-01", 1)
    assert_equal Date.new(2027, 1, 1), MakeACalendar.add_business_days("2027-01-04", -1)
    assert_equal Date.new(2027, 1, 1), MakeACalendar.add_business_days("2027-01-01", 0)
    assert_equal [Date.new(2027, 1, 4), Date.new(2027, 1, 5)], MakeACalendar::BusinessDays.each_workday("2027-01-03", "2027-01-05").to_a
  end

  def test_payroll_frequencies_and_explicit_adjustment
    biweekly = MakeACalendar::Scheduling.pay_dates(start_date: "2027-01-01", end_date: "2027-02-01", frequency: :biweekly, anchor: "2027-01-01")
    assert_equal [Date.new(2027, 1, 1), Date.new(2027, 1, 15), Date.new(2027, 1, 29)], biweekly
    monthly = MakeACalendar::Scheduling.pay_dates(start_date: "2027-01-01", end_date: "2027-03-31", frequency: :monthly, anchor: "2027-01-31")
    assert_equal [31, 28, 31], monthly.map(&:day)
    semi = MakeACalendar::Scheduling.pay_dates(start_date: "2027-01-01", end_date: "2027-01-31", frequency: :semi_monthly)
    assert_equal [15, 31], semi.map(&:day)
    moved = MakeACalendar::Scheduling.pay_dates(start_date: "2027-01-01", end_date: "2027-01-31", frequency: :biweekly, anchor: "2027-01-02", adjust: :following)
    assert_equal Date.new(2027, 1, 4), moved.first
  end

  def test_rotating_shift_uses_anchor_and_repeating_cycle
    rows = MakeACalendar::Scheduling.shift_dates(start_date: "2027-01-01", end_date: "2027-01-07", pattern: "2-2-3", anchor: "2027-01-01")
    assert_equal [true, true, false, false, true, true, true], rows.map { |row| row[:on_duty] }
    assert_equal 1, rows.first[:cycle_day]
    assert_equal 7, rows.last[:cycle_day]
  end

  def test_retail_fiscal_periods_and_53rd_week
    fiscal = MakeACalendar.fiscal_calendar(year: 2027, pattern: :four_four_five)
    assert_equal 52, fiscal.to_h[:weeks]
    assert_equal [4, 4, 5], fiscal.periods.first(3).map(&:weeks)
    assert_equal Date.new(2026, 2, 1), fiscal.start_date
    long = MakeACalendar.fiscal_calendar(year: 2029, pattern: :four_four_five)
    assert_equal 53, long.to_h[:weeks]
    assert_equal 6, long.periods.last.weeks
    assert_equal 12, long.periods.length
    assert_equal 12, long.period_for(long.end_date).number
  end

  def test_date_converters_and_excel_1900_bug
    assert_equal Date.new(1900, 1, 1), MakeACalendar::Converters.excel(1)
    assert_equal Date.new(1900, 2, 28), MakeACalendar::Converters.excel(59)
    assert_raises(ArgumentError) { MakeACalendar::Converters.excel(60) }
    assert_equal Date.new(1900, 3, 1), MakeACalendar::Converters.excel(61)
    assert_equal Date.new(1904, 1, 1), MakeACalendar::Converters.excel(0, system: "1904")
    assert_equal 12, MakeACalendar::Converters.excel("1.5").hour
    assert_equal Date.new(2024, 2, 29), MakeACalendar::Converters.ordinal("2024-060")
  end

  def test_unix_precision_and_iso_offset
    time = MakeACalendar::Converters.unix("1234", unit: :milliseconds)
    assert_equal "1970-01-01T00:00:01Z", time.utc.iso8601
    assert_equal 1_234_000_000, MakeACalendar::Converters.to_unix(time, unit: :nanoseconds)
    assert_equal Time.utc(2020, 1, 1), MakeACalendar::Converters.parse_time("2020-01-01T02:00:00+02:00")
    assert_raises(ArgumentError) { MakeACalendar::Converters.parse_time("2020-01-01T02:00:00") }
  end

  def test_filetime_round_trip
    assert_equal Time.utc(1601, 1, 1), MakeACalendar::Converters.filetime(0).utc
    time = Time.utc(2027, 1, 1)
    assert_equal time.to_i, MakeACalendar::Converters.filetime(MakeACalendar::Converters.to_filetime(time)).to_i
  end

  def test_month_renderers_escape_content_and_support_themes
    holiday = MakeACalendar::Holiday.new(name: "A & <B>", date: Date.new(2027, 1, 1), observed_date: Date.new(2027, 1, 1))
    calendar = MakeACalendar.month(year: 2027, month: 1, holidays: [holiday])
    svg = calendar.to_svg(title: "<unsafe>", theme: :ink_saver, page_size: :a4)
    html = calendar.to_html(title: "<unsafe>", theme: :academic)
    assert_includes svg, "&lt;unsafe&gt;"
    assert_includes svg, "A &amp; &lt;B&gt;"
    assert_includes html, "&lt;unsafe&gt;"
    assert_includes html, "@media print"
    assert_includes calendar.to_html(page_size: :a4_landscape), "size:A4 landscape"
    assert_includes calendar.to_csv, "Su,Mo,Tu,We,Th,Fr,Sa"
    assert_includes calendar.to_json, '"year": 2027'
  end

  def test_year_calendar_outputs_twelve_months
    year = MakeACalendar.year(year: 2027)
    assert_equal 12, year.months.length
    assert_includes year.to_svg, "Twelve month calendar"
    assert_equal 12, year.to_json.scan(/\"month\"/).length
    assert_includes year.to_html, "grid-template-columns:repeat(3,1fr)"
  end

  def test_ics_format_escaping_and_crlf
    output = MakeACalendar.to_ics([{ date: "2027-10-12", summary: "R&D, <planning>", description: "line one\nline two" }])
    assert_includes output, "BEGIN:VCALENDAR\r\n"
    assert_includes output, "DTSTART;VALUE=DATE:20271012\r\n"
    assert_includes output, "SUMMARY:R&D\\, <planning>"
    assert_includes output, "DESCRIPTION:line one\\nline two"
    assert output.end_with?("END:VCALENDAR\r\n")
    assert output.lines.all? { |line| line.chomp.bytesize <= 76 }
    assert_raises(ArgumentError) { MakeACalendar.to_ics(Array.new(10_001) { { date: "2027-01-01", summary: "x" } }) }
  end

  def test_cli_smoke_and_invalid_input
    output, status = Open3.capture2("ruby", "exe/make-calendar", "month", "--year", "2027", "--month", "10", "--format", "svg")
    assert status.success?
    assert_includes output, "<svg"
    error, status = Open3.capture2e("ruby", "exe/make-calendar", "month", "--year", "2027")
    refute status.success?
    assert_includes error, "missing required option"
    help, status = Open3.capture2("ruby", "exe/make-calendar", "--help")
    assert status.success?
    assert_includes help, "business-days"
  end
end
