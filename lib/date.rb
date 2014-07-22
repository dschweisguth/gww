class Date
  def self.parse_utc_time(string)
    parse(string).to_time.getutc
  end
end
