# CryDetect
[![Ask DeepWiki](https://devin.ai/assets/askdeepwiki.png)](https://deepwiki.com/Fakhrilden/crydetect)

CryDetect is a cross-platform mobile application built with Flutter that helps new parents understand their baby's needs by analyzing the sound of their cries. It leverages a deep learning model to classify cries into various categories such as hunger, discomfort, or tiredness, providing valuable insights to caregivers.

## Features

- **AI-Powered Cry Analysis:** Record your baby's cry or upload an existing audio file to get an AI-driven prediction about its cause.
- **Multiple Cry Categories:** The model is trained to identify several reasons for crying, including:
    - Hunger
    - Belly Pain
    - Burping
    - Discomfort
    - Tiredness
- **Secure User Authentication:** Sign up and log in securely using Email/Password, Google, or Apple accounts, powered by Firebase Authentication.
- **Child Profile Management:** Add and manage profiles for multiple children within a single parent account.
- **Historical Data Tracking:** The app stores prediction history for each child in Firebase Firestore.
- **Visual Analytics:** View a summary of cry reasons for each child through an interactive pie chart, helping you identify patterns over time.

## Architecture & Technology Stack

The application consists of a Flutter frontend and a Python backend. The workflow is as follows:
1. The **Flutter app** captures or uploads an audio file and sends it to the backend.
2. The **Flask API** receives the audio file.
3. The backend processes the audio, converting it to a compatible format and extracting MFCC (Mel-frequency cepstral coefficients) features using **Librosa**.
4. The extracted features are fed into a pre-trained **TensorFlow/Keras** model (`.h5`) for classification.
5. The prediction result is sent back to the Flutter app.
6. The app displays the result to the user and updates the historical data in **Firebase Firestore**.

### Key Technologies
- **Frontend:** Flutter, Dart
- **Backend:** Python, Flask
- **Machine Learning:** TensorFlow, Keras, Librosa
- **Database & Auth:** Firebase (Firestore, Authentication)
- **Audio Handling:** `flutter_sound`, `pydub`
- **Charting:** `fl_chart`

## Local Setup and Installation

To run this project locally, you will need to set up both the backend server and the frontend application.

### Prerequisites
- [Flutter SDK](https://flutter.dev/docs/get-started/install)
- [Python 3.x](https://www.python.org/downloads/)
- A Firebase project

### 1. Firebase Configuration

1.  Create a new project on the [Firebase Console](https://console.firebase.google.com/).
2.  Enable **Firestore Database** and **Authentication** (with Email/Password, Google, and Apple providers).
3.  Register your app for Android, iOS, and Web.
4.  Download the `google-services.json` file for Android and place it in `android/app/`.
5.  Follow the Firebase instructions for iOS setup.
6.  Use the `flutterfire configure` command from the FlutterFire CLI or manually update the placeholder values in `lib/firebase_options.dart` with your project's web credentials.

### 2. Backend Setup

1.  **Navigate to the backend directory:**
    ```bash
    cd flaskbackend
    ```
2.  **Create a `requirements.txt` file** with the following content:
    ```
    Flask
    numpy
    pandas
    librosa
    tensorflow
    pydub
    ```
3.  **Install the Python dependencies:**
    ```bash
    pip install -r requirements.txt
    ```
4.  **Update the host IP address** in `flaskbackend/app.py`. Find your local network IP and replace the placeholder in this line:
    ```python
    # In flaskbackend/app.py
    if __name__ == '__main__':
        app.run(debug=True, host='YOUR_LOCAL_IP_ADDRESS') # e.g., '192.168.1.11'
    ```
5.  **Run the Flask server:**
    ```bash
    python app.py
    ```
    The server will start, typically on port 5000.

### 3. Frontend Setup

1.  **Get Flutter dependencies:**
    ```bash
    flutter pub get
    ```
2.  **Update the backend URL** in `lib/screens/predict_voice_screen.dart` to match the IP address and port from the backend setup.
    ```dart
    // In lib/screens/predict_voice_screen.dart
    var uri = Uri.parse('http://YOUR_LOCAL_IP_ADDRESS:5000/upload');
    ```
3.  **Run the application:**
    ```bash
    flutter run
    ```

## Project Structure
```
.
├── flaskbackend/          # Python Flask backend
│   ├── app.py             # Main Flask application
│   ├── functions.py       # Audio processing & prediction logic
│   └── features/
│       └── my_model.h5    # Pre-trained Keras model
├── lib/                   # Flutter application source code
│   ├── main.dart          # App entry point
│   ├── models/            # Data models (Child, Message)
│   └── screens/           # UI screens for the application
│       ├── auth/          # Login, Signup, Auth services
│       └── home/          # Home screen (not currently in main navigation)
├── assets/                # Images and logos for the app
└── pubspec.yaml           # Flutter project dependencies and metadata
