# Getting started

Install `make_a_calendar_toolkit`, require `make_a_calendar`, and call the same API from scripts, services, or Rails applications. Runtime code has no external gem dependencies and performs no network requests.

```ruby
require "make_a_calendar"

calendar = MakeACalendar.month(year: 2027, month: 10, week_start: :monday)
File.write("october.svg", calendar.to_svg)
```

For command-line use, install the gem then run `make-calendar --help`. By default, commands print to standard output; `--output FILE` writes a file and refuses to overwrite it unless `--force` is given.
