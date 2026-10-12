# Date semantics

## Civil dates

Pass a `Date` or ISO `YYYY-MM-DD` string to date-only APIs. A civil date has no time zone; its weekday is calculated directly as a calendar date.

## Month grids

Week starts are `:sunday` (Ruby `Date#wday` 0) or `:monday`. Natural grids use four through six rows. `fixed_rows: 6` creates a consistent print height. Cells outside the month carry adjacent dates. ISO week number and week-year are attached per cell.

## Business-day ranges

`BusinessDays.between` includes both endpoints by default, skips the configured weekend, and excludes the supplied holiday date or each holiday's `observed_date`. Set `inclusive: false` to exclude both range endpoints. Adding a nonzero number of workdays moves forward or backward after the start date.

## Holiday history

US federal rules distinguish actual dates from weekend-observed dates. Monday observances reflect the post-1971 Uniform Monday Holiday rules; Veterans Day's 1971–1977 Monday observance is accounted for. Juneteenth begins in 2021. Federal observance is not a proxy for state law, financial market closures, or a company's policy.

## Timestamp conversion

Timestamp functions require an explicit unit. ISO timestamps require a UTC marker or numeric offset. Excel's 1900 system rejects serial 60, and FILETIME uses 100-nanosecond ticks since 1601-01-01 UTC.
