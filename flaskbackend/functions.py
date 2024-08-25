import os
import shutil
import csv
import numpy as np
import pandas as pd
import librosa
import tensorflow as tf
from pydub import AudioSegment

UPLOAD_FOLDER = 'upload'
RECORDED_FOLDER = 'recorded'
CSV_FOLDER = 'features/csv'
FEATURES_FOLDER = 'features'

def add_uploaded_to_dataset(filename):
    with open(os.path.join(CSV_FOLDER, 'dataset.csv'), 'a', newline='') as csvfile:
        csv_writer = csv.writer(csvfile)
        csv_writer.writerow([filename])
    shutil.copy(os.path.join(UPLOAD_FOLDER, filename), os.path.join(CSV_FOLDER, filename))

def convert_to_wav(file_path):
    try:
        audio = AudioSegment.from_file(file_path)
        wav_path = file_path.replace(file_path.split('.')[-1], 'wav')
        audio.export(wav_path, format="wav")
        return wav_path
    except Exception as e:
        print(f"Error converting file {file_path} to WAV: {e}")
        return None

def feature_extraction(file_path):
    try:
        x, sample_rate = librosa.load(file_path, res_type='kaiser_fast')
        mfcc = np.mean(librosa.feature.mfcc(y=x, sr=sample_rate, n_mfcc=100).T, axis=0)
        return mfcc
    except Exception as e:
        print(f"Error loading {file_path}: {e}")
        return None

def extract_features():
    row = None
    file_to_delete = None
    with open(os.path.join(CSV_FOLDER, 'dataset.csv'), 'r', newline='') as csvfile:
        csv_reader = csv.reader(csvfile)
        next(csv_reader)
        for line in csv_reader:
            file_path = os.path.join(CSV_FOLDER, line[0])
            print("Processing:", file_path)
            wav_path = convert_to_wav(file_path)
            if wav_path is None:
                continue
            features = feature_extraction(wav_path)
            if features is not None:
                row = features.tolist()
                file_to_delete = wav_path
                break  # Assuming we only need to process one file for prediction
    
    
    return row, file_to_delete

def normalize(row):
    min_values = []
    max_values = []
    csv1 = os.path.join(CSV_FOLDER, 'min_max_values.csv')
    with open(csv1, 'r', newline='') as csvfile:
        csv_reader = csv.reader(csvfile)
        next(csv_reader)
        for line in csv_reader:
            min_val = float(line[1])
            max_val = float(line[2])
            min_values.append(min_val)
            max_values.append(max_val)
    row1 = []
    for i in range(len(row)):
        normalized_val = (row[i] - min_values[i]) / (max_values[i] - min_values[i])
        row1.append(normalized_val)
    return row1

def decode(labels):
    label_map = {1: 'belly_pain', 2: 'burping', 3: 'discomfort', 4: 'hungry', 5: 'tired'}
    return [label_map.get(label, 'unknown') for label in labels]

def predict(norm):
    loaded_model = tf.keras.models.load_model('features/my_model.h5')
    data_array = np.vstack([norm, norm])
    predictions = loaded_model.predict(data_array)
    predicted_labels = np.argmax(predictions, axis=1) + 1
    return decode(predicted_labels)

def process_audio(filename):
    row, file_to_delete = extract_features()
    if row is None:
        return ["Error: Feature extraction failed"]
    norm = normalize(row)
    result = predict(norm)
    
    # Delete the .wav file after processing
    if file_to_delete:
        try:
            os.remove(file_to_delete)
            print(f"Deleted file: {file_to_delete}")
        except Exception as e:
            print(f"Error deleting file {file_to_delete}: {e}")
    
    return result

def clear_csv(file_path):
    try:
        with open(file_path, 'r') as file:
            reader = csv.reader(file)
            header = next(reader)
        with open(file_path, 'w', newline='') as file:
            writer = csv.writer(file)
            writer.writerow(header)
        print(f"Cleared all rows in {file_path}.")
    except Exception as e:
        print(f"Error clearing rows in {file_path}: {e}")
        raise

def clear_csv_except_header(file_path):
    try:
        df = pd.read_csv(file_path)
        df.iloc[0:1].to_csv(file_path, index=False)
        print(f"Cleared all rows in {file_path} except for the header.")
    except Exception as e:
        print(f"Error clearing rows in {file_path}: {e}")
        raise
