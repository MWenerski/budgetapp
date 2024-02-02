// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
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
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for windows - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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
    apiKey: 'AIzaSyA_hgivvxcvDyMu24BzdGRZMpszpJjv_kw',
    appId: '1:248167272130:web:9e8114559bba6c2d61755b',
    messagingSenderId: '248167272130',
    projectId: 'budgetapp-7f675',
    authDomain: 'budgetapp-7f675.firebaseapp.com',
    storageBucket: 'budgetapp-7f675.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyB3o4aBzUe7t_se5u0OyFUHHWfGL1tT9R4',
    appId: '1:248167272130:android:21249b953f70452961755b',
    messagingSenderId: '248167272130',
    projectId: 'budgetapp-7f675',
    storageBucket: 'budgetapp-7f675.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyAjAkX5haP6y4KOjU5x-qVkaqbDO7ZWDYw',
    appId: '1:248167272130:ios:ee10fbccf06115c361755b',
    messagingSenderId: '248167272130',
    projectId: 'budgetapp-7f675',
    storageBucket: 'budgetapp-7f675.appspot.com',
    iosBundleId: 'com.example.budgetapp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyAjAkX5haP6y4KOjU5x-qVkaqbDO7ZWDYw',
    appId: '1:248167272130:ios:215d02db698fcf3c61755b',
    messagingSenderId: '248167272130',
    projectId: 'budgetapp-7f675',
    storageBucket: 'budgetapp-7f675.appspot.com',
    iosBundleId: 'com.example.budgetapp.RunnerTests',
  );
}
