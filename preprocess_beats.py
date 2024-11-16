import librosa
import numpy as np
import json
import os

INPUT_FOLDER = "assets/sounds/soundtrack/"
OUTPUT_FOLDER = "assets/sounds/beat_data/"
os.makedirs(OUTPUT_FOLDER, exist_ok=True)

def analyze_beat_intensity(song_path, low_freq=10, high_freq=400):
    # Load the audio file
    y, sr = librosa.load(song_path)
    
    # Apply Harmonic-Percussive Source Separation to isolate percussive elements
    y_harmonic, y_percussive = librosa.effects.hpss(y)
    
    # Perform short-time Fourier transform (STFT) to extract frequency data
    D = librosa.stft(y_percussive)  # Use percussive part for better kick/snare detection
    magnitude, phase = librosa.magphase(D)
    
    # Get the frequency bins
    freqs = librosa.fft_frequencies(sr=sr)
    
    # Select the frequency range for kicks and snares (drum frequencies)
    drum_range = (freqs >= low_freq) & (freqs <= high_freq)
    
    # Compute the magnitude in the drum frequency range
    drum_magnitude = magnitude[drum_range, :]
    
    # Sum the magnitudes to get an overall intensity for the drum frequencies
    drum_intensity = np.sum(drum_magnitude, axis=0)
    
    # Perform beat tracking
    tempo, beat_frames = librosa.beat.beat_track(y=y_percussive, sr=sr)
    
    # Convert beat frames to time (in seconds)
    beat_times = librosa.frames_to_time(beat_frames, sr=sr)

    # Now map the beat frames to corresponding intensities
    beat_amplitudes = []
    
    # For each beat, find the closest frame in the drum intensity array
    for beat_time in beat_times:
        # Convert beat time to frame index
        frame_idx = librosa.time_to_frames(beat_time, sr=sr)
        
        # Ensure the frame index is within bounds of the drum intensity array
        if frame_idx < len(drum_intensity):
            intensity_value = drum_intensity[frame_idx]
        else:
            # If the frame index exceeds available drum intensity, set to 0
            intensity_value = 0
        
        beat_amplitudes.append(float(intensity_value))  # Append intensity for the beat
    
    return beat_times, beat_amplitudes

def generate_beat_map(song_path):
    beat_times, beat_amplitudes = analyze_beat_intensity(song_path)

    # Build the beat map based on detected beats
    beat_map = {'beats': beat_times.tolist(), 'intensities': beat_amplitudes}
    
    # Save the beat map to a JSON file
    beat_map_path = song_path.replace('.wav', '_beats_bass.json')
    with open(beat_map_path, 'w') as f:
        json.dump(beat_map, f)
    
    print(f"Beat map saved to {beat_map_path}")

# Process all .wav files in the input folder
for file_name in os.listdir(INPUT_FOLDER):
    if file_name.endswith(".wav"):
        file_path = os.path.join(INPUT_FOLDER, file_name)
        generate_beat_map(file_path)

print("Beat maps generated successfully!")
