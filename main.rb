# main.rb
require 'gosu'
require_relative 'lib/soundtrack_manager'
require_relative 'lib/background_manager'

class GameWindow < Gosu::Window
  def initialize
    super(1080, 720)
    self.caption = 'Tetruby'

    @logo = Gosu::Image.new("assets/images/sprites/tetrubylogo.png")

    @soundtrack_manager = SoundtrackManager.new
    @soundtrack_manager.shuffle_music(self)
    @soundtrack_manager.play_background_music(self)

    @background_manager = BackgroundManager.new(self, @soundtrack_manager.beat_manager)

    @menu_displayed = true
    @font = Gosu::Font.new(24)
  end

  def update
    @soundtrack_manager.update(self)
    @background_manager.update
  end

  def draw
    @background_manager.draw
    
    if @menu_displayed
      draw_menu
    else
      draw_game_content
    end
    @soundtrack_manager.draw(self)
  end

  def draw_menu
    scale_x = self.width / @logo.width.to_f
    scale_y = self.height / @logo.height.to_f
    scale_factor = [scale_x, scale_y].min * 0.75

    logo_x = (self.width - @logo.width * scale_factor) / 2
    logo_y = 100
    @logo.draw(logo_x, logo_y, 1, scale_factor, scale_factor)

    play_now_text = "Play Now"
    text_x = (self.width - @font.text_width(play_now_text)) / 2
    text_y = logo_y + @logo.height * scale_factor + 40
    @font.draw_text(play_now_text, text_x, text_y, 1, 1, 1, Gosu::Color::WHITE)
    settings_text = "Settings"
    text_x = (self.width - @font.text_width(settings_text)) / 2
    text_y = logo_y + @logo.height * scale_factor + 80
    @font.draw_text(settings_text, text_x, text_y, 1, 1, 1, Gosu::Color::WHITE)
    exit_text = "Exit"
    text_x = (self.width - @font.text_width(exit_text)) / 2
    text_y = logo_y + @logo.height * scale_factor + 120
    @font.draw_text(exit_text, text_x, text_y, 1, 1, 1, Gosu::Color::WHITE)
    wesman_text = "Made by WesMan v0.01"
    text_x = 5 
    text_y = self.height - @font.height - 5  
    @font.draw_text(wesman_text, text_x, text_y, 0.75, 0.75, 0.75, Gosu::Color::WHITE)
  end

  def draw_game_content
    @font.draw_text("Game Content Here", 50, 50, 1, 1, 1, Gosu::Color::YELLOW)
  end

  def button_down(id)
    if @menu_displayed && (id == Gosu::KB_RETURN || (id == Gosu::MS_LEFT && mouse_over_play_now?))
      @menu_displayed = false
    end
  end

  def close
    @beat_data = nil
    @soundtrack_manager.stop_music
    super
  end

  private

  def mouse_over_play_now?
    # Logic to check if the mouse is over the "Play Now" button
  end
end

window = GameWindow.new
window.show
