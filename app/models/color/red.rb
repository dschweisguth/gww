class Color::Red < Color::Color
  private_class_method def self.color_ranges
    [[256, 224], [192, 0], [192, 0]]
  end
end
