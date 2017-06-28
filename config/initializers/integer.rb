class Integer
  def ordinal
    string = to_s
    suffix =
      case string
        when /^1.$/
          'th'
        when /1$/
          'st'
        when /2$/
          'nd'
        when /3$/
          'rd'
        else
          'th'
      end
    string + suffix
  end
end
