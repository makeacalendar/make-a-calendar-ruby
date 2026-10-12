# frozen_string_literal: true

module MakeACalendar
  class Error < StandardError; end
  class InvalidDate < Error; end
  class UnsupportedConversion < Error; end
end
