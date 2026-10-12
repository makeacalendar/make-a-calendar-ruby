# Architecture

The `DateMath` module owns civil date operations and month-grid geometry. Calendar renderers consume immutable grids. Scheduling modules implement holiday rules, workday iteration, pay dates, rotating patterns, and NRF-style fiscal periods. Converter methods make source epochs and units explicit. The `ICS` module serializes date-only events. The executable maps options to these public modules and does not contain a separate date engine.

The gem uses the Ruby standard library (`date`, `time`, `json`, `csv`, `cgi`, and `optparse`) and no runtime dependencies. It does not request data from Make a Calendar or claim to reproduce the site's private code.
