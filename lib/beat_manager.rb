require 'aubio'

class BeatManager
  def initialize(song_path)
    @file = Aubio.open(song_path)

    @last_beat_time = 0
    @beat_intensity = 1.0  
  end

  def update
    while (beat = @file.beats.next)
      time = beat
      if time > @last_beat_time
        @last_beat_time = time
        @beat_intensity = 1.2 + rand(0.2)  
      end
    end
  end

  def get_beat_intensity
    @beat_intensity
  end

  def close
    @file.close if @file
  end
end
