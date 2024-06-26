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
    apiKey: 'AIzaSyBb-ONIbH2uZrBKaQQBfsgISqB2nzJCjxQ',
    appId: '1:808707795977:web:3201cc61a72d911a9a5cd8',
    messagingSenderId: '808707795977',
    projectId: 'stock-managament-4ab89',
    authDomain: 'stock-managament-4ab89.firebaseapp.com',
    storageBucket: 'stock-managament-4ab89.appspot.com',
    measurementId: 'G-8Y69HSE8M8',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyAqW9gdT5oBCCtyZu_6LTdQzGlYp1lahEw',
    appId: '1:808707795977:android:a56ff87f44d59b0a9a5cd8',
    messagingSenderId: '808707795977',
    projectId: 'stock-managament-4ab89',
    storageBucket: 'stock-managament-4ab89.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCqNXk_i_nropEBcgiSE-gSfsf1ePSn1W0',
    appId: '1:808707795977:ios:1732ab5c4d29a02d9a5cd8',
    messagingSenderId: '808707795977',
    projectId: 'stock-managament-4ab89',
    storageBucket: 'stock-managament-4ab89.appspot.com',
    iosBundleId: 'com.example.stockManagamentApp',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'AIzaSyCqNXk_i_nropEBcgiSE-gSfsf1ePSn1W0',
    appId: '1:808707795977:ios:8ba7086d30d333db9a5cd8',
    messagingSenderId: '808707795977',
    projectId: 'stock-managament-4ab89',
    storageBucket: 'stock-managament-4ab89.appspot.com',
    iosBundleId: 'com.example.stockManagamentApp.RunnerTests',
  );
}
