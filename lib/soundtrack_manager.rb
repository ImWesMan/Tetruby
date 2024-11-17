# lib/soundtrack_manager.rb
require 'gosu'
require_relative 'beat_manager'

class SoundtrackManager
  attr_reader :current_song_name, :current_artist_name, :beat_manager
  
  def initialize
    @songs = Dir['assets/sounds/soundtrack/*.wav']
    @current_song = nil
    @current_song_index = 0
    @playing = false
    @popup_display_time = 9000  # Time in milliseconds (e.g., 4000ms = 4 seconds)
    @popup_timer_start = nil    
    @current_song_name = ""
    @current_artist_name = ""
    @beat_manager = nil
    @play_button = Gosu::Image.new("assets/images/sprites/playbutton.png")
    @song_start_time = nil
  end

  def play_background_music(window)
    unless @playing
      play_song(window, @current_song_index)
    end
  end

  def stop_music
    @current_song.stop if @current_song
    @playing = false
  end

  def pause_music
    @current_song.pause if @current_song
    @playing = false
  end

  def resume_music
    @current_song.play if @current_song
    @playing = true
  end

  def skip_song(window)
    next_song
    play_song(window, @current_song_index)
  end

  def shuffle_music(window)
    @current_song_index = rand(@songs.length)
    play_song(window, @current_song_index)
  end

  def next_song
    @current_song_index += 1
    @current_song_index = 0 if @current_song_index >= @songs.length
  end

  def previous_song
    @current_song_index -= 1
    @current_song_index = @songs.length - 1 if @current_song_index < 0
  end

  def update(window)
    if @popup_timer_start && (Gosu.milliseconds - @popup_timer_start >= @popup_display_time)
      @popup_timer_start = nil 
    end
    
    if @playing && @current_song
      current_time = Gosu.milliseconds - @song_start_time
      @beat_manager.update(current_time / 1000.0) 
    end

    if @playing && !@current_song.playing?
      next_song
      play_song(window, @current_song_index)
    end
  end

  def draw(window)
    draw_song_popup(window) if @popup_timer_start
  end

  private

  def play_song(window, index)
    song_path = @songs[index]
    @current_song = Gosu::Song.new(song_path)
    @current_song.play
    @playing = true
    @song_start_time = Gosu.milliseconds

    @beat_manager = BeatManager.new(song_path)

    filename = File.basename(song_path, ".wav")
    artist, song_name = filename.split('_', 2)
    @current_artist_name = artist.capitalize
    @current_song_name = song_name.gsub('-', ' ').capitalize

    @popup_timer_start = Gosu::milliseconds 
  end

  def draw_song_popup(window)
    font = Gosu::Font.new(30)
    message = "#{@current_artist_name} - #{@current_song_name}"
    
    fx = window.width / @play_button.width.to_f
    fy = window.height / @play_button.height.to_f
    scale_factor = [fx, fy].min * 0.1  
  
    scaled_width = @play_button.width * scale_factor
    scaled_height = @play_button.height * scale_factor
  
    button_x = window.width - font.text_width(message) - scaled_width - 30
    button_y = window.height - font.height - 60
  
    text_x = button_x + scaled_width + 10  
    text_y = button_y
  
    Gosu.draw_rect(text_x - 10, text_y - 10, font.text_width(message) + 20, font.height + 20, Gosu::Color.new(128, 0, 0, 0))
    font.draw_text(message, text_x, text_y, 1, 1, 1, Gosu::Color::WHITE)
  end  
end
