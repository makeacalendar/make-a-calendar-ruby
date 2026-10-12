# Make a Calendar Toolkit

An offline Ruby toolkit for calendar grids, business scheduling, holiday dates, fiscal periods, date conversion, printable SVG/HTML, and iCalendar exports. For browser-based calendar creation and printable templates, visit [Make a Calendar](https://make-a-calendar.com/).

[![CI](https://github.com/makeacalendar/make-a-calendar-ruby/actions/workflows/ci.yml/badge.svg)](https://github.com/makeacalendar/make-a-calendar-ruby/actions/workflows/ci.yml)

## Contents

- [What it is](#what-it-is)
- [Install and start](#install-and-start)
- [Calendar grids and print output](#calendar-grids-and-print-output)
- [Business days and US federal holidays](#business-days-and-us-federal-holidays)
- [Pay and shift schedules](#pay-and-shift-schedules)
- [Retail fiscal calendars](#retail-fiscal-calendars)
- [Converters](#converters)
- [ICS export](#ics-export)
- [Command line](#command-line)
- [Rails use](#rails-use)
- [Date rules and limitations](#date-rules-and-limitations)
- [Development](#development)
- [Documentation and related tools](#documentation-and-related-tools)
- [Contributing, security, license](#contributing-security-license)

## What it is

Make a Calendar Toolkit packages reusable date and scheduling behavior for Ruby applications. It creates month and year grids, counts business days, applies a documented set of US federal holiday rules, builds pay and rotating-shift schedules, maps NRF-style 4-4-5/4-5-4/5-4-4 fiscal periods, converts common date representations, and exports calendars as SVG, print-oriented HTML, JSON, CSV, or date-only ICS.

Core features work offline using Ruby's standard library. The gem does not call the Make a Calendar website and does not reproduce its private implementation. Rails is not a runtime dependency.

The project was created by Ethan, the developer behind [Make a Calendar](https://make-a-calendar.com/), a browser-based calendar and date-tools platform. Use the local Ruby gem in applications, or open the [online calendar generator](https://make-a-calendar.com/calendar-generator) when you want to make a calendar in your browser.

## Install and start

```sh
gem install make_a_calendar_toolkit
```

```ruby
require "date"
require "make_a_calendar"

calendar = MakeACalendar.month(year: 2027, month: 10, week_start: :monday)
puts calendar.to_json
File.write("october-2027.svg", calendar.to_svg(theme: :editorial, page_size: :letter))
```

The library declares Ruby `>= 2.6` and has no runtime gem dependencies.

## Calendar grids and print output

Month grids contain four, five, or six rows unless `fixed_rows: 6` is requested. Cells carry civil `Date` values, adjacent-month information, weekdays, and ISO week data. A `Date` stays a date; no UTC instant is constructed to determine its weekday.

```ruby
month = MakeACalendar.month(year: 2027, month: 10, week_start: :sunday, fixed_rows: 6)
puts month.to_csv
File.write("planner.html", month.to_html(theme: :ink_saver, page_size: :letter_landscape))
```

Available print themes are `:editorial`, `:business`, `:academic`, and `:ink_saver`. Paper choices are `:letter`, `:a4`, `:letter_landscape`, and `:a4_landscape`. HTML includes print CSS; SVG is standalone and has accessible title and description elements. `MakeACalendar.year(year: 2027)` returns a twelve-month calendar suitable for one-page SVG or HTML output. For ready-to-print browser templates, see [monthly calendars](https://make-a-calendar.com/monthly-calendars) or the [custom calendar generator](https://make-a-calendar.com/calendar-generator).

## Business days and US federal holidays

Date ranges include both endpoints by default. `inclusive: false` removes both endpoints. Saturday and Sunday are the default weekend (`Date#wday` values 6 and 0); pass your own weekend list for another work pattern. Adding a nonzero number of business days starts counting after the supplied date; zero returns that date unchanged.

```ruby
holidays = MakeACalendar.federal_holidays(2027)
count = MakeACalendar.business_days_between(
  Date.new(2027, 1, 1), Date.new(2027, 3, 31), holidays: holidays
)
deadline = MakeACalendar.add_business_days(Date.new(2027, 2, 1), 30, holidays: holidays)
```

Each federal `Holiday` keeps its legal date and observed weekday separately. The rule set includes effective-date distinctions for MLK Day, Juneteenth, the Monday holiday changes, and Veterans Day's 1971–1977 observance. It is a federal calendar reference, not state law, court rules, bank policy, or an employer's closure schedule. Add caller-owned holidays when a business uses different rules. To check a date range in a browser, use the [business-days calculator](https://make-a-calendar.com/business-days-calculator) or browse the [date tools hub](https://make-a-calendar.com/date-tools).

## Pay and shift schedules

`MakeACalendar::Scheduling.pay_dates` supports weekly, biweekly, semi-monthly, and monthly dates. Weekend/holiday adjustments must be selected explicitly with `:none`, `:following`, `:preceding`, or `:modified_following`. The library does not assume one employer's payday convention.

`shift_dates` accepts a repeating list such as `[2, 2, 3]` or `"2-2-3"`; entries alternate on-duty and off-duty blocks, beginning on duty. Results are date labels only and do not represent hours worked or a fixed-length UTC shift across daylight-saving changes. The browser-based [date tools](https://make-a-calendar.com/date-tools) also include planning calculators for people who do not need Ruby integration.

## Retail fiscal calendars

`MakeACalendar.fiscal_calendar(year: 2029, pattern: :four_four_five)` uses the Sunday nearest February 1. The default label is the ending year, so a fiscal year labeled 2029 starts in 2028. `:four_four_five`, `:four_five_four`, and `:five_four_four` are supported. A 53rd week is assigned to period 12 by default; use `extra_week: :first_period` to assign it to period 1. This is one documented convention, not a claim that every company's accounting calendar matches it. For an interactive version of this retail layout, see Make a Calendar's [4-4-5 fiscal calendar generator](https://make-a-calendar.com/445-calendar).

## Converters

`MakeACalendar::Converters` includes Unix seconds/milliseconds/microseconds/nanoseconds with rational arithmetic, Excel 1900 and 1904 serial dates, Windows FILETIME, ISO-8601 timestamps that require an explicit offset, and unambiguous `YYYY-DDD` / `YYYYDDD` ordinal dates. Excel 1900 serial 60 raises because it represents Excel's fictitious 1900-02-29. Two-digit ordinal years and historical Julian calendar conversions are not inferred. For quick browser conversions, open the [date and time converters](https://make-a-calendar.com/converters) on Make a Calendar.

## ICS export

`MakeACalendar.to_ics` exports date-only events with CRLF line endings, escaped text fields, folded content lines, stable UID defaults, and exclusive `DTEND` dates. It does not emit time-zone definitions or promise full recurrence-rule support. To create an all-day calendar file without writing Ruby, use the [online iCalendar generator](https://make-a-calendar.com/ical-generator).

```ruby
ics = MakeACalendar.to_ics([
  { date: "2027-10-12", summary: "Planning day", description: "Quarterly review" }
])
File.write("planning.ics", ics)
```

## Command line

```sh
make-calendar month --year 2027 --month 10 --format svg --output october.svg
make-calendar year --year 2027 --format html
make-calendar holidays --year 2027 --country us --observed
make-calendar business-days --from 2027-01-01 --to 2027-03-31 --observed
make-calendar add-business-days --date 2027-02-01 --days 30
make-calendar fiscal --year 2029 --pattern 445
make-calendar shifts --start 2027-01-01 --to 2027-01-31 --pattern 2-2-3
make-calendar convert excel --serial 45000 --system 1900
make-calendar convert unix --serial 1234567890 --system seconds
make-calendar export-ics --input events.json --output events.ics
```

Output goes to standard output unless `--output` is supplied. Existing files are protected unless `--force` is used. Run `make-calendar --help` for the full syntax. The CLI accepts US holidays only in this release.

## Rails use

Rails is optional. In a Rails application, add the gem to the application's Gemfile, then call the Ruby API in a service object:

```ruby
# app/services/monthly_report_calendar.rb
class MonthlyReportCalendar
  def self.call(year:, month:)
    MakeACalendar.month(year: year, month: month, week_start: :monday).to_svg
  end
end
```

No Rails modules are loaded by the gem.

## Date rules and limitations

Gregorian civil dates are represented by Ruby `Date`. Month grids use Sunday-first or Monday-first ordering. ISO weeks and week-years follow Ruby's ISO calendar fields. The standard `Date` implementation defines the supported range; invalid dates and invalid month values raise errors. Holiday rules are limited to the documented US federal rule set; local and organization-specific holidays remain caller data. Payroll dates and fiscal-week policies are configurable where the library has a defined option. PDF/PNG generation, time-zone-aware timed events, state holidays, and astronomical/historic calendar systems are outside 0.1.1.

## Development

```sh
ruby -Ilib spec/all_spec.rb
find lib exe spec examples -name '*.rb' -print0 | xargs -0 -n1 ruby -c
gem build make_a_calendar_toolkit.gemspec
```

CI runs tests, Ruby syntax checks, package build, archive inspection, and CLI help on Ruby 2.7, 3.2, and 3.4. The test suite uses independent date expectations and covers calendar boundaries, holidays, business schedules, fiscal periods, converters, renderer escaping, ICS, and CLI behavior.

## Documentation and related tools

Technical guides are in [`docs/`](docs/). Helpful browser-based references include [monthly calendar templates](https://make-a-calendar.com/monthly-calendars), [date calculators](https://make-a-calendar.com/date-tools), [business-day calculator](https://make-a-calendar.com/business-days-calculator), [4-4-5 calendar overview](https://make-a-calendar.com/445-calendar), [date converters](https://make-a-calendar.com/converters), and the [iCalendar generator](https://make-a-calendar.com/ical-generator). Those pages are separate web tools; this gem runs locally and does not depend on them. Additional useful pages are the [calendar reuse calculator](https://make-a-calendar.com/reuse-calendar), [years with the same calendar](https://make-a-calendar.com/same-calendar-years), and [weekdays-in-year calculator](https://make-a-calendar.com/weekdays-in-year-calculator).

## Contributing, security, license

See [CONTRIBUTING.md](CONTRIBUTING.md), [SECURITY.md](SECURITY.md), and [CODE_OF_CONDUCT.md](CODE_OF_CONDUCT.md). Released under the [MIT License](LICENSE).

Created by Ethan, the developer behind [Make a Calendar](https://make-a-calendar.com/).
