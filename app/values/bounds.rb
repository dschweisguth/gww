class Bounds < Struct.new :min_lat, :max_lat, :min_long, :max_long
  def as_json(_options = {})
    {
      min_lat: min_lat,
      max_lat: max_lat,
      min_long: min_long,
      max_long: max_long
    }
  end
end
