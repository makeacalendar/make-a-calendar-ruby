# Advanced examples

## Fiscal period lookup

```ruby
fiscal = MakeACalendar.fiscal_calendar(year: 2029, pattern: :four_five_four)
period = fiscal.period_for(Date.new(2028, 10, 1))
puts [fiscal.label_year, period.quarter, period.number].join(" / ")
```

## Excel date validation

```ruby
begin
  date = MakeACalendar::Converters.excel(60, system: "1900")
rescue ArgumentError => error
  warn error.message
end
```

## iCalendar holiday export

```ruby
events = MakeACalendar.federal_holidays(2027).map do |holiday|
  { date: holiday.observed_date, summary: holiday.name }
end
File.write("federal-holidays.ics", MakeACalendar.to_ics(events))
```
