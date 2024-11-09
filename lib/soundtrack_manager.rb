# lib/soundtrack_manager.rb
require 'gosu'

class SoundtrackManager
  attr_reader :current_song_name, :current_artist_name
  
  def initialize
    @songs = Dir['assets/sounds/soundtrack/*.wav'] 
    @current_song = nil
    @current_song_index = 0
    @playing = false
    @popup_display_time = 100
    @popup_timer = 0
    @current_song_name = ""
    @current_artist_name = ""
  end

  def play_background_music(window)
    if !@playing
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
    if @popup_timer > 0
      @popup_timer -= 1
    end
  end

  def draw(window)
    if @popup_timer > 0
      draw_song_popup(window)
    end
  end

  private

  def play_song(window, index)
    song_path = @songs[index]
    @current_song = Gosu::Song.new(song_path)
    @current_song.play
    @playing = true

    filename = File.basename(song_path, ".wav")
    artist, song_name = filename.split('_', 2)
    @current_artist_name = artist.capitalize
    @current_song_name = song_name.gsub('-', ' ').capitalize

    @popup_timer = @popup_display_time
  end

  def draw_song_popup(window)
    font = Gosu::Font.new(30)
    message = "#{@current_artist_name} - #{@current_song_name}"
  
    x = window.width - font.text_width(message) - 20
    y = window.height - font.height - 40 
  
    Gosu.draw_rect(x - 10, y - 10, font.text_width(message) + 20, font.height + 20, Gosu::Color.new(128, 0, 0, 0))
    font.draw_text(message, x, y, 1, 1, 1, Gosu::Color::WHITE)
  end
end