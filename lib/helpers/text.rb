class Text
  def initialize(font, content, x, y, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE)
    @font = font
    @content = content
    @x = x
    @y = y
    @scale_x = scale_x
    @scale_y = scale_y
    @color = color
  end

  def draw
    @font.draw_text(@content, @x, @y, 1, @scale_x, @scale_y, @color)
  end

  def width
    @font.text_width(@content) * @scale_x
  end

  def height
    @font.height * @scale_y
  end
end
