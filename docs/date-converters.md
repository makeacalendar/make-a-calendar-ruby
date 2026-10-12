# Date converters

`Converters.unix` takes a value and explicit unit (`:seconds`, `:milliseconds`, `:microseconds`, or `:nanoseconds`) and returns UTC `Time`. `Converters.to_unix` reverses the conversion.

`Converters.excel` accepts the 1900 or 1904 system; 1900 serial 60 is rejected. Fractional days return a UTC `Time`. `Converters.filetime` and `to_filetime` convert 100-nanosecond ticks since 1601-01-01 UTC. `parse_time` requires an explicit UTC marker or numeric offset. `ordinal` accepts only four-digit-year formats `YYYY-DDD` and `YYYYDDD`.
