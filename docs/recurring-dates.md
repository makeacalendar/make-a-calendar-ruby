# Pay dates and shift rotations

`Scheduling.pay_dates` creates weekly, biweekly, semi-monthly, or monthly dates. Weekly schedules use a seven-day anchor interval; biweekly uses fourteen days. Semi-monthly dates default to the 15th and month end. Monthly dates preserve the anchor's day and clamp to the last day in shorter months. The caller chooses weekend/holiday handling.

`Scheduling.shift_dates` accepts alternating on/off block lengths. `"2-2-3"` means two on, two off, three on, then the cycle repeats. An anchor date establishes cycle day 1. The library returns civil dates and does not infer shift duration, timezone, or daylight-saving behavior.

Generated date ranges are limited to 100 years to keep accidental oversized requests bounded.
