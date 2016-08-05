module PhotoScoreSupport
  def seconds_old
    (Time.now - dateadded).to_i
  end
end
