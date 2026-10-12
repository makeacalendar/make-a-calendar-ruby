# US federal holiday dates

`MakeACalendar.federal_holidays(year)` returns `Holiday` entries with a legal date and a weekend-observed date. The model covers federal holidays in the modern statutory era and distinguishes important changes: Memorial Day's pre-1971 May 30 date, Washington's Birthday's pre-1971 February 22 date, Columbus Day from 1971, Veterans Day's 1971–1977 October observance, Juneteenth from 2021, and Thanksgiving's 1939 move to the fourth Thursday.

The older Thanksgiving dates use a recurring November rule as a practical calendar approximation; Presidential proclamations varied in some early years. This is not an authoritative legal history or a state, bank, or employer closure calendar. Supply custom `Date` values or `Holiday` objects when a caller follows other rules.

For a range spanning year boundaries, `Holidays.observed_dates(first_year, last_year)` includes adjacent legal years so a New Year's observed date on December 31 is available.
