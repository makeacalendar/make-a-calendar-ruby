# Business-day arithmetic

Use `MakeACalendar.business_days_between(from, to, weekend: [0, 6], holidays: [], inclusive: true)` to count working dates. Ruby weekday numbers are Sunday 0 through Saturday 6. A `Holiday` contributes its observed date; a `Date` or ISO date string contributes itself.

`MakeACalendar.add_business_days(date, count, ...)` counts after the start for nonzero values. `BusinessDays.each_workday` yields dates in the requested range. `in_month` and `in_year` count weekdays with the same options.

The US federal holiday rules are convenience inputs. Add caller-owned dates for company closures and verify contract, court, payroll, and state rules independently.
