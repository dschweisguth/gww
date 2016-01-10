class Fixnum
  def ordinal
    string = to_s
    case string
      when /^1.$/
        suffix = 'th'
      when /1$/
        suffix = 'st'
      when /2$/
        suffix = 'nd'
      when /3$/
        suffix = 'rd'
      else
        suffix = 'th'
    end
    string + suffix
  end
end
