Period = Struct.new :start, :finish, :scores do
  def initialize(start, finish)
    self.start = start
    self.finish = finish
    self.scores = {}
  end

  def self.starting_at(start, duration)
    new(start, start + duration)
  end

end
