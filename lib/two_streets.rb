module TwoStreets
  def equal_ignoring_order?(a1, a2, b1, b2)
    a1 == b1 && a2 == b2 || a1 == b2 && a2 == b1
  end
end
