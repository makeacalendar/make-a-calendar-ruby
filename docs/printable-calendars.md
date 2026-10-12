# Printable calendars

Monthly SVG output uses a fixed page viewBox and scalable geometry. HTML output adds print CSS for A4/Letter paper in portrait or landscape. The `:ink_saver` theme uses a white background and dark lines; `:editorial`, `:business`, and `:academic` adjust the color palette. No remote fonts, logos, or tracking are added.

```ruby
calendar = MakeACalendar.month(year: 2027, month: 10, week_start: :monday, fixed_rows: 6)
File.write("planner.svg", calendar.to_svg(theme: :ink_saver, page_size: :a4_landscape))
File.write("planner.html", calendar.to_html(theme: :business, page_size: :letter))
```

SVG and HTML are provided; PDF and PNG are not. Print the HTML in a browser or use an external converter selected by your application.
