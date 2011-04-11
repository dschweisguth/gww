class Address < Struct.new :text, :number, :street
  def initialize(*args)
    if args.length == 3
      super
    elsif args.length == 4
      super args[0], args[1], Street.new(args[3], args[4])
    else
      raise ArgumentError,
        "Expected String, String, Street or String x 4, but got #{args.length} args"
    end
  end
end
