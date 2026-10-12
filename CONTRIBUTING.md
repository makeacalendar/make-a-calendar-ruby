# Contributing

Bug reports and focused pull requests are welcome. Please include the Ruby version, a minimal reproduction, expected result, and actual result. Date changes should include independent calendar references or clearly stated rules.

Run the local checks with `ruby -Ilib spec/all_spec.rb`, `ruby -c` on changed Ruby files, and `gem build make_a_calendar_toolkit.gemspec`. Keep runtime dependencies at zero and document any new public behavior in the README or `docs/`.

Do not include credentials, private data, generated files that are not deliberate samples, or changes copied from the Make a Calendar website's private implementation.
