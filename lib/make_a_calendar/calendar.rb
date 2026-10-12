# frozen_string_literal: true

require "json"
require "csv"
require "cgi"

module MakeACalendar
  class Calendar
    attr_reader :year, :month, :week_start, :grid, :holidays

    def initialize(year:, month:, week_start: :sunday, fixed_rows: nil, holidays: [])
      @year = Integer(year)
      @month = Integer(month)
      @week_start = week_start.to_sym
      @grid = DateMath.month_grid(@year, @month, week_start: @week_start, fixed_rows: fixed_rows)
      @holidays = holidays.freeze
      freeze
    end

    def to_h
      { year: year, month: month, week_start: week_start,
        weekdays: weekday_names, weeks: grid.map { |row| row.map { |cell| cell[:date]&.iso8601 } } }
    end

    def to_json(*_args)
      JSON.pretty_generate(to_h)
    end

    def to_csv
      CSV.generate do |csv|
        csv << weekday_names
        grid.each { |row| csv << row.map { |cell| cell[:date]&.day } }
      end
    end

    def to_html(title: nil, theme: :editorial, page_size: :letter)
      title ||= Date::MONTHNAMES[month] + " #{year}"
      cells = grid.flatten.map do |cell|
        date = cell[:date]
        label = date ? date.day.to_s : ""
        holiday = date && holidays.find { |item| item.observed_date == date }
        %(<td class="#{cell[:in_month] ? "in-month" : "adjacent"}">#{label}#{holiday ? "<small>#{escape(holiday.name)}</small>" : ""}</td>)
      end.each_slice(7).map { |row| "<tr>#{row.join}</tr>" }.join
      headers = weekday_names.map { |name| "<th scope=\"col\">#{name}</th>" }.join
      %(<!doctype html><html lang="en"><meta charset="utf-8"><title>#{escape(title)}</title><style>#{html_css(theme, page_size)}</style><main><h1>#{escape(title)}</h1><table><thead><tr>#{headers}</tr></thead><tbody>#{cells}</tbody></table></main></html>)
    end

    def to_svg(title: nil, theme: :editorial, page_size: :letter)
      title ||= Date::MONTHNAMES[month] + " #{year}"
      width, height = page_dimensions(page_size)
      pad = 40.0
      header_h = 78.0
      cell_w = (width - 2 * pad) / 7
      cell_h = (height - 2 * pad - header_h) / (grid.length + 1)
      colors = theme_colors(theme)
      out = [%(<svg xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="title desc" viewBox="0 0 #{width} #{height}">),
             %(<title id="title">#{escape(title)}</title><desc id="desc">Monthly calendar, #{escape(title)}</desc>),
             %(<rect width="100%" height="100%" fill="#{colors[:background]}"/>),
             %(<text x="#{pad}" y="#{pad + 32}" font-family="Arial,sans-serif" font-size="28" font-weight="700" fill="#{colors[:ink]}">#{escape(title)}</text>)]
      weekday_names.each_with_index do |name, index|
        x = pad + index * cell_w
        y = pad + header_h
        out << %(<rect x="#{x}" y="#{y}" width="#{cell_w}" height="#{cell_h}" fill="#{colors[:header]}" stroke="#{colors[:grid]}"/> )
        out << %(<text x="#{x + cell_w / 2}" y="#{y + cell_h / 2 + 5}" text-anchor="middle" font-family="Arial,sans-serif" font-size="12" font-weight="700" fill="#{colors[:ink]}">#{name}</text>)
      end
      grid.each_with_index do |row, row_index|
        row.each_with_index do |cell, col_index|
          x = pad + col_index * cell_w
          y = pad + header_h + (row_index + 1) * cell_h
          date = cell[:date]
          fill = cell[:in_month] ? colors[:cell] : colors[:muted]
          out << %(<rect x="#{x}" y="#{y}" width="#{cell_w}" height="#{cell_h}" fill="#{fill}" stroke="#{colors[:grid]}"/> )
          next unless date
          out << %(<text x="#{x + 9}" y="#{y + 20}" font-family="Arial,sans-serif" font-size="13" fill="#{colors[:ink]}">#{date.day}</text>)
          holiday = holidays.find { |item| item.observed_date == date }
          out << %(<text x="#{x + 9}" y="#{y + 38}" font-family="Arial,sans-serif" font-size="8" fill="#{colors[:ink]}">#{escape(holiday.name[0, 18])}</text>) if holiday
        end
      end
      out << "</svg>"
      out.join("\n")
    end

    private

    def weekday_names
      names = DateMath::WEEKDAYS.map { |name| name.to_s[0, 2].capitalize }
      offset = DateMath.weekday_index(week_start)
      names.rotate(offset)
    end

    def escape(text)
      CGI.escapeHTML(text.to_s)
    end

    def page_dimensions(size)
      case size.to_sym
      when :letter then [612, 792]
      when :letter_landscape then [792, 612]
      when :a4 then [595, 842]
      when :a4_landscape then [842, 595]
      else raise ArgumentError, "page_size must be :letter or :a4"
      end
    end

    def theme_colors(theme)
      themes = {
        editorial: { background: "#ffffff", ink: "#20252b", grid: "#c7cdd2", header: "#edf1f4", cell: "#ffffff", muted: "#f7f8f9" },
        business: { background: "#ffffff", ink: "#17324d", grid: "#aebdca", header: "#e5eef5", cell: "#ffffff", muted: "#f5f7f9" },
        academic: { background: "#ffffff", ink: "#312d44", grid: "#cbc5dc", header: "#f0edf7", cell: "#ffffff", muted: "#faf9fc" },
        ink_saver: { background: "#ffffff", ink: "#000000", grid: "#555555", header: "#ffffff", cell: "#ffffff", muted: "#f1f1f1" }
      }
      themes.fetch(theme.to_sym) { raise ArgumentError, "theme must be editorial, business, academic, or ink_saver" }
    end

    def html_css(theme, size)
      colors = theme_colors(theme)
      width, height = page_dimensions(size)
      paper = size.to_s.start_with?("a4") ? "A4" : "Letter"
      orientation = size.to_s.end_with?("landscape") ? " landscape" : ""
      %(@page{size:#{paper}#{orientation};margin:12mm}body{font-family:Arial,sans-serif;color:#{colors[:ink]};max-width:#{width}px;margin:0 auto}table{border-collapse:collapse;width:100%;height:#{height - 130}px;table-layout:fixed}th,td{border:1px solid #{colors[:grid]};vertical-align:top;padding:6px}th{background:#{colors[:header]}}td{height:18%;font-size:14px}td.adjacent{color:#999;background:#{colors[:muted]}}small{display:block;font-size:9px;margin-top:5px}@media print{body{max-width:none}h1{font-size:18pt}})
    end
  end

  class YearCalendar
    attr_reader :year, :week_start, :holidays

    def initialize(year:, week_start: :sunday, holidays: [])
      @year = Integer(year)
      @week_start = week_start.to_sym
      @holidays = holidays.freeze
      freeze
    end

    def months
      (1..12).map { |month| Calendar.new(year: year, month: month, week_start: week_start, holidays: holidays) }.freeze
    end

    def to_json(*_args)
      JSON.pretty_generate(year: year, months: months.map(&:to_h))
    end

    def to_html(title: "#{year} Calendar", theme: :editorial, page_size: :letter)
      cards = months.map do |calendar|
        html = calendar.to_html(theme: theme, page_size: page_size)
        table = html[/<table>.*?<\/table>/m]
        %(<section><h2>#{Date::MONTHNAMES[calendar.month]}</h2>#{table}</section>)
      end
      %(<html lang="en"><meta charset="utf-8"><title>#{CGI.escapeHTML(title)}</title><style>@page{size:#{page_size == :a4 ? "A4" : "Letter"};margin:8mm}body{font-family:Arial,sans-serif}h1{text-align:center}.year{display:grid;grid-template-columns:repeat(3,1fr);gap:10px}section{break-inside:avoid}h2{font-size:12px;margin:4px 0}table{border-collapse:collapse;width:100%;table-layout:fixed;font-size:8px}td,th{border:1px solid #aaa;padding:2px;text-align:center}@media print{.year{gap:6px}}</style><h1>#{CGI.escapeHTML(title)}</h1><div class="year">#{cards.join}</div></html>)
    end

    def to_svg(title: "#{year} Calendar", theme: :editorial)
      width = 900
      height = 1160
      margin = 24
      card_w = (width - margin * 2) / 3.0
      card_h = (height - 100) / 4.0
      ink = theme.to_sym == :ink_saver ? "#000000" : "#25313b"
      out = [%(<svg xmlns="http://www.w3.org/2000/svg" role="img" aria-labelledby="title desc" viewBox="0 0 #{width} #{height}">),
             %(<title id="title">#{CGI.escapeHTML(title)}</title><desc id="desc">Twelve month calendar for #{year}</desc>),
             %(<rect width="100%" height="100%" fill="#fff"/><text x="#{width / 2}" y="38" text-anchor="middle" font-family="Arial" font-size="26" font-weight="bold" fill="#{ink}">#{CGI.escapeHTML(title)}</text>)]
      months.each_with_index do |calendar, index|
        x0 = margin + (index % 3) * card_w
        y0 = 60 + (index / 3) * card_h
        out << %(<text x="#{x0 + card_w / 2}" y="#{y0 + 18}" text-anchor="middle" font-family="Arial" font-size="15" font-weight="bold" fill="#{ink}">#{Date::MONTHNAMES[index + 1]}</text>)
        cell_w = (card_w - 20) / 7.0
        cell_h = 19
        names = calendar.send(:weekday_names)
        names.each_with_index do |name, column|
          x = x0 + 10 + column * cell_w
          y = y0 + 27
          out << %(<text x="#{x + cell_w / 2}" y="#{y + 12}" text-anchor="middle" font-family="Arial" font-size="8" font-weight="bold" fill="#{ink}">#{name}</text>)
        end
        calendar.grid.each_with_index do |row, row_index|
          row.each_with_index do |cell, column|
            x = x0 + 10 + column * cell_w
            y = y0 + 42 + row_index * cell_h
            fill = cell[:in_month] ? "#fff" : "#f4f5f6"
            out << %(<rect x="#{x}" y="#{y}" width="#{cell_w}" height="#{cell_h}" fill="#{fill}" stroke="#c7cdd2"/>)
            out << %(<text x="#{x + cell_w / 2}" y="#{y + 13}" text-anchor="middle" font-family="Arial" font-size="9" fill="#{ink}">#{cell[:in_month] ? cell[:day] : ""}</text>)
          end
        end
      end
      out << "</svg>"
      out.join("\n")
    end
  end
end
