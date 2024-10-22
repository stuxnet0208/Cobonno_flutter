// File generated by FlutterFire CLI.
// ignore_for_file: lines_longer_than_80_chars, avoid_classes_with_only_static_members
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart' show defaultTargetPlatform, kIsWeb, TargetPlatform;

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
      throw UnsupportedError(
        'DefaultFirebaseOptions have not been configured for web - '
        'you can reconfigure this by running the FlutterFire CLI again.',
      );
    }
    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      case TargetPlatform.macOS:
        throw UnsupportedError(
          'DefaultFirebaseOptions have not been configured for macos - '
          'you can reconfigure this by running the FlutterFire CLI again.',
        );
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

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCdl61wQcx3jqBrjII6k8vDQdI8FSzRHi0',
    appId: '1:564222187247:android:04d2883a86e13361576d1a',
    messagingSenderId: '564222187247',
    projectId: 'cobonno-museum',
    storageBucket: 'cobonno-museum.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCrTcgyrRVjFcW3lo4Jw9FkGT3YEYe0CFc',
    appId: '1:564222187247:ios:95bf2427cdc37912576d1a',
    messagingSenderId: '564222187247',
    projectId: 'cobonno-museum',
    storageBucket: 'cobonno-museum.appspot.com',
    androidClientId: '564222187247-5uqvrj0kqqq815ob3s0ogpquhldcfvqi.apps.googleusercontent.com',
    iosClientId: '564222187247-gpcqkd8r5h9i6vt0g67ms8170lqpfkrd.apps.googleusercontent.com',
    iosBundleId: 'com.cobonno.app',
  );
}
