class Intersection < Struct.new :text, :at1, :at2
  def initialize(*args)
    if args.length == 3
      super
    elsif args.length == 5
      super args[0], Street.new(args[1], args[2]), Street.new(args[3], args[4])
    else
      raise ArgumentError,
        "Expected String, Street x 2 or String x 5, but got #{args.length} args"
    end
  end
end
