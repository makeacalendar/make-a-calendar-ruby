# frozen_string_literal: true

require_relative "lib/make_a_calendar/version"

Gem::Specification.new do |spec|
  spec.name = "make_a_calendar_toolkit"
  spec.version = MakeACalendar::VERSION
  spec.authors = ["Ethan"]
  spec.email = ["makeacalendarcom@gmail.com"]
  spec.summary = "Ruby toolkit for printable calendars, business schedules, holidays, fiscal planning, and date conversions."
  spec.description = <<~DESCRIPTION
    Make a Calendar Toolkit is an offline Ruby library and command-line tool for calendar grids,
    US federal holiday dates, business-day arithmetic, recurring pay schedules, rotating shifts,
    NRF-style retail fiscal calendars, date conversions, SVG and HTML calendars, JSON and CSV
    data, and date-only iCalendar exports. It is original Ruby code inspired by practical date
    workflows; it does not call or reproduce the private implementation of Make a Calendar.
    Created by Ethan, the developer behind https://make-a-calendar.com/.
  DESCRIPTION
  spec.homepage = "https://make-a-calendar.com/"
  spec.license = "MIT"
  spec.required_ruby_version = ">= 2.6"
  spec.files = Dir.chdir(__dir__) do
    Dir.glob("{lib,exe,docs,examples,samples}/**/*", File::FNM_DOTMATCH).select { |path| File.file?(path) } +
      %w[README.md LICENSE CHANGELOG.md CONTRIBUTING.md CODE_OF_CONDUCT.md SECURITY.md Rakefile Gemfile Gemfile.lock .ruby-version .gitignore .rspec .rubocop.yml]
  end.uniq.sort
  spec.bindir = "exe"
  spec.executables = ["make-calendar"]
  spec.require_paths = ["lib"]
  spec.metadata = {
    "homepage_uri" => "https://make-a-calendar.com/",
    "source_code_uri" => "https://github.com/makeacalendar/make-a-calendar-ruby",
    "documentation_uri" => "https://github.com/makeacalendar/make-a-calendar-ruby/tree/main/docs",
    "changelog_uri" => "https://github.com/makeacalendar/make-a-calendar-ruby/blob/main/CHANGELOG.md",
    "bug_tracker_uri" => "https://github.com/makeacalendar/make-a-calendar-ruby/issues"
  }
  spec.add_development_dependency "rake", "~> 12.0"
  spec.add_development_dependency "minitest", "~> 5.0"
end
