# lib/background_manager.rb
require 'gosu'

class BackgroundManager
  def initialize
    @backgrounds = Dir['assets/images/backgrounds/bg*.jpg']
    @current_background = nil
    @opacity = 55 
  end

  def shuffle_background
    random_background_index = rand(@backgrounds.length)
    set_background(random_background_index)
  end

  def set_background(index)
    background_path = @backgrounds[index]
    @current_background = Gosu::Image.new(background_path)
  end

 
  def set_opacity(opacity)
    @opacity = [[opacity, 0].max, 255].min  
  end

  def draw(window)
    if @current_background
      color_with_opacity = Gosu::Color.new(@opacity, 255, 255, 255) # White color with opacity
      @current_background.draw(0, 0, 0, window.width / @current_background.width.to_f, window.height / @current_background.height.to_f, color_with_opacity)
    end
  end
end
