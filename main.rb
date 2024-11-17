# main.rb

require 'gosu'
require_relative 'lib/soundtrack_manager'
require_relative 'lib/background_manager'
require_relative 'lib/helpers/text'
require_relative 'lib/helpers/button'
require_relative 'lib/helpers/image_helper'
require_relative 'lib/user_auth'

class GameWindow < Gosu::Window
  def initialize
    super(1080, 720)
    self.caption = 'Tetruby'

    @logo = Gosu::Image.new("assets/images/sprites/tetrubylogo.png")
    @font = Gosu::Font.new(24)
    @small_font = Gosu::Font.new(16)

    @soundtrack_manager = SoundtrackManager.new
    @soundtrack_manager.shuffle_music(self)
    @soundtrack_manager.play_background_music(self)

    @background_manager = BackgroundManager.new(self, @soundtrack_manager.beat_manager)

    @menu_displayed = true
    @user_auth = UserAuth.new
    @username_input = ''
    @password_input = '' 

    setup_menu
  end

  def setup_dialog_buttons
    @submit_button = Button.new(@small_font, @is_signup ? "Sign Up" : "Login", 400, 320)
    @cancel_button = Button.new(@small_font, "Cancel", 400, 360)
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
      draw_input_dialog
    end

    if @user_auth.user
      draw_logged_in_info
    end

    @soundtrack_manager.draw(self)
  end

  def draw_menu
    scale_factor = calculate_logo_scale
    ImageHelper.draw_scaled(@logo, self, scale_factor, calculate_logo_x(scale_factor), 100)
  
    mouse_x, mouse_y = mouse_x(), mouse_y()
  
    @buttons.each do |button|
      unless @user_auth.user && (button.text_content == "Login" || button.text_content == "Sign Up")
        button.draw(mouse_x, mouse_y)
      end
    end
  
    @credits.draw
  end

  def draw_input_dialog
    if @menu_displayed == false
      setup_dialog_buttons
      Gosu.draw_rect(300, 200, 480, 300, Gosu::Color.new(0x77FFFFFF))
  
      Text.new(@small_font, "Username:", 320, 220, 1, 1, Gosu::Color::BLACK).draw
      Text.new(@small_font, "Password:", 320, 260, 1, 1, Gosu::Color::BLACK).draw
  
      Text.new(@small_font, @username_input, 400, 220, 1, 1, Gosu::Color::BLACK).draw
      Text.new(@small_font, "*" * @password_input.length, 400, 260, 1, 1, Gosu::Color::BLACK).draw
  
      @submit_button.draw(mouse_x(), mouse_y())
      @cancel_button.draw(mouse_x(), mouse_y())
  
      if @focused_field == :username
        Gosu.draw_rect(395, 215, 120, 20, Gosu::Color::YELLOW)  
      elsif @focused_field == :password
        Gosu.draw_rect(395, 255, 120, 20, Gosu::Color::YELLOW) 
      end
    end
  end

  def cancel_input
    # Reset inputs and show menu again
    @username_input = ""
    @password_input = ""
    @focused_field = nil
    @menu_displayed = true
  end

  def text_input(id, text)
    if @focused_field == :username
      @username_input += text
    elsif @focused_field == :password
      @password_input += text
    end
  end

  def draw_logged_in_info
    Text.new(@small_font, "Logged in as: #{@user_auth.user.username}", self.width - 200, self.height - 30, 1, 1, Gosu::Color::WHITE).draw
    sign_out_button.draw(mouse_x(), mouse_y())
  end

  def button_down(id)
    if @menu_displayed && id == Gosu::MS_LEFT
      if @buttons.first.hovered?(mouse_x, mouse_y)  # "Play Now"
        @menu_displayed = false
      elsif @buttons[2].hovered?(mouse_x, mouse_y)  # "Sign Up"
        show_signup_dialog
      elsif @buttons[3].hovered?(mouse_x, mouse_y)  # "Login"
        show_login_dialog
      elsif @buttons.last.hovered?(mouse_x, mouse_y)  # "Exit"
        close
      elsif @sign_out_button&.hovered?(mouse_x(), mouse_y())
        sign_out
      end
    end
  
    if !@menu_displayed && id == Gosu::MS_LEFT
      if @submit_button&.hovered?(mouse_x(), mouse_y())  # Submit button
        submit_action
      elsif @cancel_button&.hovered?(mouse_x(), mouse_y())  # Cancel button
        cancel_action
      elsif mouse_x >= 320 && mouse_x <= 400 && mouse_y >= 220 && mouse_y <= 240
        @focused_field = :username
      elsif mouse_x >= 320 && mouse_x <= 400 && mouse_y >= 260 && mouse_y <= 280
        @focused_field = :password
      end
    end
  
    if !@menu_displayed && id.between?(Gosu::KB_A, Gosu::KB_Z) || id.between?(Gosu::KB_0, Gosu::KB_9)
      if @focused_field == :username
        @username_input += Gosu.button_id_to_char(id)
      elsif @focused_field == :password
        @password_input += Gosu.button_id_to_char(id)
      end
    elsif id == Gosu::KB_BACKSPACE
      if @focused_field == :username && !@username_input.empty?
        @username_input.chop!
      elsif @focused_field == :password && !@password_input.empty?
        @password_input.chop!
      end
    end
  end

  def submit_action
    puts "Username: #{@username_input}"
    puts "Password: #{@password_input}"
  
    if @is_signup
      signup_user(@username_input, @password_input)
    else
      begin
        login_user(@username_input, @password_input)
      rescue WrongPasswordError => e
        @user_auth.user = nil
        puts "login failed: #{e.message}"
        return
      end
    end
    
    clear_inputs
    @focused_field = nil  
    @menu_displayed = true  
  end

  def clear_inputs
    @username_input = ""
    @password_input = ""
  end

  def cancel_action
    clear_inputs
    @focused_field = nil
    @menu_displayed = true
  end

  def show_signup_dialog
    @is_signup = true
    @menu_displayed = false  # Hide the menu to show the dialog
  end

  def show_login_dialog
    @is_signup = false
    @menu_displayed = false  # Hide the menu to show the dialog
  end

  def signup_user(username, password)
    @user_auth.signup(username, password)
    puts "User signed up successfully!"
  end

  def login_user(username, password)
    if @user_auth.login(username, password)
      puts "User logged in successfully!"
    else
      @user_auth.user = nil
      puts "Login failed!"
    end
  end

  def sign_out
    @user_auth.logout
    puts "User logged out!"
  end

  def sign_out_button
    @sign_out_button = Button.new(@small_font, "Sign Out", self.width - @small_font.text_width("Sign Out") - 20, self.height - 50)
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
      Button.new(@small_font, "Sign Up", self.width - @small_font.text_width("Sign Up") - 20, self.height - @small_font.height - 20),
      Button.new(@small_font, "Login", self.width - @small_font.text_width("Login") - 20 - @small_font.text_width("Sign Up") - 10, self.height - @small_font.height - 20),
      Button.new(@font, "Exit", (self.width - @font.text_width("Exit")) / 2, logo_y + text_y_offset + 80)
    ]

    @credits = Text.new(@small_font, "Made by WesMan v0.01", 10, self.height - @font.height - 10, 1, 1, Gosu::Color::WHITE)
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
