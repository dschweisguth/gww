class Period < Struct.new :start, :finish, :scores

  def initialize(start, finish)
    self.start = start
    self.finish = finish
    self.scores = {}
  end

  def self.starting_at(start, duration)
    period = new(start, start + duration)
    #noinspection RubyResolve
    period.scores = {}
    period
  end

end
