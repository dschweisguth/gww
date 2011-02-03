class Period < Struct.new :start, :finish, :scores

  def initialize(start, finish, scores = {})
    self.start = start
    self.finish = finish
    self.scores = scores
  end

  def self.starting_at(start, duration, scores = {})
    new(start, start + duration, scores)
  end

end
