class Button
  attr_reader :x, :y, :width, :height

  def initialize(font, content, x, y, scale_x = 1, scale_y = 1, color = Gosu::Color::WHITE, hover_color = Gosu::Color::GRAY)
    @text = Text.new(font, content, x, y, scale_x, scale_y, color)
    @hover_color = hover_color
    @default_color = color
  end

  def draw(mouse_x, mouse_y)
    if hovered?(mouse_x, mouse_y)
      @text.instance_variable_set(:@color, @hover_color)
    else
      @text.instance_variable_set(:@color, @default_color)
    end
    @text.draw
  end

  def hovered?(mouse_x, mouse_y)
    mouse_x >= @text.instance_variable_get(:@x) &&
      mouse_x <= @text.instance_variable_get(:@x) + @text.width &&
      mouse_y >= @text.instance_variable_get(:@y) &&
      mouse_y <= @text.instance_variable_get(:@y) + @text.height
  end
end
