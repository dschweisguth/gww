class Block < Struct.new :text, :on, :between1, :between2
  def initialize(*args)
    if args.length == 4
      super
    elsif args.length == 7
      super args[0], Street.new(args[1], args[2]), Street.new(args[3], args[4]),
        Street.new(args[5], args[6])
    else
      raise ArgumentError,
        "Expected String, Street, Street x 2 or String x 7, but got #{args.length} args"
    end
  end
end
