class BackgroundManager
  attr_accessor :beat_manager
  def initialize(window, beat_manager)
    @window = window
    @backgrounds = Dir['assets/images/backgrounds/bg*.jpg']
    @current_background = nil
    @opacity = 40 
    @zoom_factor = 1.0  
    @target_zoom_factor = 1.0  
    @beat_manager = beat_manager
    shuffle_background  
  end

  def update
    beat_intensity = @beat_manager.get_beat_intensity
    
    target_zoom = 1.0 + beat_intensity * 0.00005

    @zoom_factor = lerp(@zoom_factor, target_zoom, 0.05)

    @opacity = [[@opacity + beat_intensity * 0.0009, 0].max, 45].min
  end

  def draw
    if @current_background
      color_with_opacity = Gosu::Color.new(@opacity, 255, 255, 255) # White color with opacity
      @current_background.draw(0, 0, 0, @window.width / @current_background.width.to_f * @zoom_factor, 
                               @window.height / @current_background.height.to_f * @zoom_factor, color_with_opacity)
    end
  end

  def shuffle_background
    random_background_index = rand(@backgrounds.length)
    set_background(random_background_index)
  end

  def set_background(index)
    background_path = @backgrounds[index]
    @current_background = Gosu::Image.new(background_path)
  end

  # Linear interpolation helper function
  def lerp(start, target, alpha)
    start + (target - start) * alpha
  end

  def close
    @beat_manager.close
  end
end
