require 'json'

class BeatManager
  def initialize(song_path)
    beat_map_path = "assets/sounds/beat_data/#{File.basename(song_path, '.wav')}_beats_bass.json"
    raise "Beat map not found for #{song_path}" unless File.exist?(beat_map_path)

    @beat_data = JSON.parse(File.read(beat_map_path))
    @beats = @beat_data['beats']
    @intensities = @beat_data['intensities']
    @current_beat_index = 0
    @last_intensity = 0
  end

  def update(current_time)
    return if @current_beat_index >= @beats.length
    
    while @current_beat_index < @beats.length && current_time >= @beats[@current_beat_index]
      @last_intensity = @intensities[@current_beat_index]
      @current_beat_index += 1
    end
  end

  def get_beat_intensity
    intensity = @last_intensity
    @last_intensity = 0 
    intensity
  end
end
