import librosa
import json
import os

INPUT_FOLDER = "assets/sounds/soundtrack/"
OUTPUT_FOLDER = "assets/sounds/beat_data/"

os.makedirs(OUTPUT_FOLDER, exist_ok=True)

for file_name in os.listdir(INPUT_FOLDER):
    if file_name.endswith(".wav"):
        file_path = os.path.join(INPUT_FOLDER, file_name)
        y, sr = librosa.load(file_path)
        tempo, beat_frames = librosa.beat.beat_track(y=y, sr=sr)
        beat_times = librosa.frames_to_time(beat_frames, sr=sr)
        beat_amplitudes = [sum(abs(y[int(f * 512):int((f + 1) * 512)])) for f in beat_frames]

        output_data = {
            "beats": beat_times.tolist(),
            "intensities": beat_amplitudes
        }

        output_file = os.path.join(OUTPUT_FOLDER, f"{os.path.splitext(file_name)[0]}_beats.json")
        with open(output_file, "w") as f:
            json.dump(output_data, f)

print("Beat maps generated successfully!")
