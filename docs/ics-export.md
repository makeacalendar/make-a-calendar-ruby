# iCalendar export

`MakeACalendar.to_ics(events, name: ...)` writes date-only VEVENT entries with a one-day exclusive `DTEND`. It escapes text fields, folds lines at the RFC 5545 octet limit, and writes CRLF separators. UIDs are deterministic for an ordered input list unless an event supplies one. `DTSTAMP` records the export time.

This subset omits `VTIMEZONE`, timed events, and recurrence rules. Use it for all-day planning data, not for local-time meeting schedules where daylight-saving behavior matters.
