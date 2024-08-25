// File generated by FlutterFire CLI.
// ignore_for_file: type=lint
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show defaultTargetPlatform, kIsWeb, TargetPlatform;

/// Default [FirebaseOptions] for use with your Firebase apps.
///
/// Example:
/// ```dart
/// import 'firebase_options.dart';
/// // ...
/// await Firebase.initializeApp(
///   options: DefaultFirebaseOptions.currentPlatform,
/// );
/// ```
class DefaultFirebaseOptions {
  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      return web;
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        return macos;
      case TargetPlatform.windows:
        return windows;
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for linux - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not supported for this platform.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'AIzaSyCpFmXZ-QHozHkJS6otWj4Y-ov6mc_0F88',
    appId: '1:70291506501:web:b0fcb2169672291407aa2c',
    messagingSenderId: '70291506501',
    projectId: 'crydetect-3131e',
    authDomain: 'crydetect-3131e.firebaseapp.com',
    storageBucket: 'crydetect-3131e.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyD0S2YasFZPZYHoj2x1OVRAEANT6WXzPlA',
    appId: '1:70291506501:android:d7168c3247ad0b8407aa2c',
    messagingSenderId: '70291506501',
    projectId: 'crydetect-3131e',
    storageBucket: 'crydetect-3131e.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAmt60KXMn51YhobvRGcMMP472Z8vtOXpQ',
    appId: '1:70291506501:ios:c16e0dd98ae4a80907aa2c',
    messagingSenderId: '70291506501',
    projectId: 'crydetect-3131e',
    storageBucket: 'crydetect-3131e.appspot.com',
    iosBundleId: 'com.example.crydetect',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAmt60KXMn51YhobvRGcMMP472Z8vtOXpQ',
    appId: '1:70291506501:ios:c16e0dd98ae4a80907aa2c',
    messagingSenderId: '70291506501',
    projectId: 'crydetect-3131e',
    storageBucket: 'crydetect-3131e.appspot.com',
    iosBundleId: 'com.example.crydetect',
  );

  static const FirebaseOptions windows = FirebaseOptions(
    apiKey: 'AIzaSyCpFmXZ-QHozHkJS6otWj4Y-ov6mc_0F88',
    appId: '1:70291506501:web:72b9eac90168fee907aa2c',
    messagingSenderId: '70291506501',
    projectId: 'crydetect-3131e',
    authDomain: 'crydetect-3131e.firebaseapp.com',
    storageBucket: 'crydetect-3131e.appspot.com',
  );

}