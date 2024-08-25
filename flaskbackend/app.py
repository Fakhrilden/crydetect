from flask import Flask, request, jsonify
import os
from functions import *

app = Flask(__name__)

# Directory where uploaded files will be saved
UPLOAD_FOLDER = 'upload'
app.config['UPLOAD_FOLDER'] = UPLOAD_FOLDER
CSV_FOLDER = 'features/csv'
app.config['CSV_FOLDER'] = CSV_FOLDER

if not os.path.exists(UPLOAD_FOLDER):
    os.makedirs(UPLOAD_FOLDER)

@app.route('/')
def hello_world():
    return 'Hello, World!'

@app.route('/upload', methods=['POST'])
def upload_file():
    if 'file' not in request.files:
        return jsonify({'error': 'No file part'}), 400
    file = request.files['file']
    if file.filename == '':
        return jsonify({'error': 'No selected file'}), 400
    if file:
        file_path = os.path.join(app.config['UPLOAD_FOLDER'], file.filename)
        file.save(file_path)


        add_uploaded_to_dataset(file.filename)
        prediction = process_audio(file.filename)
        clear_csv(os.path.join(app.config['CSV_FOLDER'], 'dataset.csv'))
        print (prediction)
        return jsonify( prediction=prediction[0]),200

if __name__ == '__main__':
    app.run(debug=True, host='192.168.1.11')
