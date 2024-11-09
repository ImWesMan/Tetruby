# main.rb
require 'gosu'
require_relative 'lib/soundtrack_manager'

class GameWindow < Gosu::Window
  def initialize
    super(800, 600)  
    self.caption = 'Tetruby'  

    @soundtrack_manager = SoundtrackManager.new
    @soundtrack_manager.play_background_music(self) 

    @menu_displayed = true
  end

  def update
    @soundtrack_manager.update(self)

    if @menu_displayed
    
    else
     
    end
  end

  def draw
    if @menu_displayed
      draw_menu
    else
    
    end

    @soundtrack_manager.draw(self)
  end

  def draw_menu
    Gosu::Font.new(36).draw_text("Welcome to Tetruby!", 250, 200, 1, 1, 1, Gosu::Color::WHITE)
    Gosu::Font.new(24).draw_text("Press 'Enter' to start", 250, 300, 1, 1, 1, Gosu::Color::WHITE)
  end

  def button_down(id)
    if id == Gosu::KB_RETURN  
      @menu_displayed = false
    end
  end
end

window = GameWindow.new
window.show
