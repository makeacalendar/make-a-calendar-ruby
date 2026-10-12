# Retail 4-4-5 fiscal calendars

The retail calendar starts on the Sunday nearest February 1. By default, the year label is the ending year: a calendar labeled 2029 begins at the anchor Sunday nearest February 1, 2028.

```ruby
fiscal = MakeACalendar.fiscal_calendar(year: 2029, pattern: :four_four_five)
puts fiscal.to_h
puts fiscal.period_for(Date.new(2029, 1, 10)).number
```

The 12 periods repeat the selected 4-4-5, 4-5-4, or 5-4-4 week sequence. A 53rd week goes to period 12 unless `extra_week: :first_period` is selected. Organizations can use different fiscal anchors or adjustment policies; this implementation does not claim universal accounting compatibility.
