class Period < Struct.new :start, :finish, :scores

  def initialize(start, finish, scores = {})
    self.start = start
    self.finish = finish
    self.scores = scores
  end

end
