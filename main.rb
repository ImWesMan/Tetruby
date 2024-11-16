require 'gosu'
require_relative 'lib/soundtrack_manager'
require_relative 'lib/background_manager'
require_relative 'lib/helpers/text'
require_relative 'lib/helpers/button'
require_relative 'lib/helpers/image_helper'

class GameWindow < Gosu::Window
  def initialize
    super(1080, 720)
    self.caption = 'Tetruby'

    @logo = Gosu::Image.new("assets/images/sprites/tetrubylogo.png")
    @font = Gosu::Font.new(24)

    @soundtrack_manager = SoundtrackManager.new
    @soundtrack_manager.shuffle_music(self)
    @soundtrack_manager.play_background_music(self)

    @background_manager = BackgroundManager.new(self, @soundtrack_manager.beat_manager)

    @menu_displayed = true

    setup_menu
  end

  def update
    @soundtrack_manager.update(self)
    @background_manager.beat_manager = @soundtrack_manager.beat_manager
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
    # Draw logo
    scale_factor = calculate_logo_scale
    ImageHelper.draw_scaled(@logo, self, scale_factor, calculate_logo_x(scale_factor), 100)

    # Draw buttons
    mouse_x, mouse_y = mouse_x(), mouse_y()
    @buttons.each { |button| button.draw(mouse_x, mouse_y) }
    @credits.draw
  end

  def draw_game_content
    Text.new(@font, "Game Content Here", 50, 50, 1, 1, Gosu::Color::YELLOW).draw
  end

  def button_down(id)
    if @menu_displayed && id == Gosu::KB_RETURN
      @menu_displayed = false
    elsif @menu_displayed && id == Gosu::MS_LEFT
      @menu_displayed = false if @buttons.first.hovered?(mouse_x, mouse_y) # "Play Now" button
      close if @buttons.last.hovered?(mouse_x, mouse_y)
    end
  end

  def close
    @soundtrack_manager.stop_music
    super
  end

  private

  def setup_menu
    scale_factor = calculate_logo_scale
    logo_y = 100
    text_y_offset = @logo.height * scale_factor + 40

    @buttons = [
      Button.new(@font, "Play Now", (self.width - @font.text_width("Play Now")) / 2, logo_y + text_y_offset),
      Button.new(@font, "Settings", (self.width - @font.text_width("Settings")) / 2, logo_y + text_y_offset + 40),
      Button.new(@font, "Exit", (self.width - @font.text_width("Exit")) / 2, logo_y + text_y_offset + 80)
    ]
    @credits = Text.new(@font, "Made by WesMan v0.01", 10, self.height - @font.height - 5, 0.75, 0.75, Gosu::Color::WHITE)
  end

  def calculate_logo_scale
    scale_x = self.width / @logo.width.to_f
    scale_y = self.height / @logo.height.to_f
    [scale_x, scale_y].min * 0.75
  end

  def calculate_logo_x(scale_factor)
    (self.width - @logo.width * scale_factor) / 2
  end
end

window = GameWindow.new
window.show
