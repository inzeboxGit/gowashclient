import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

class DefaultFirebaseOptions {
  const DefaultFirebaseOptions._();

  static FirebaseOptions get currentPlatform {
    if (kIsWeb) {
      throw UnsupportedError(
        'DefaultFirebaseOptions are not configured for web.',
      );
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return android;
      case TargetPlatform.iOS:
        return ios;
      default:
        throw UnsupportedError(
          'DefaultFirebaseOptions are not configured for '
          '${defaultTargetPlatform.name}.',
        );
    }
  }

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'AIzaSyCP0oLEhlcVJDAO7cyD60I57XfyyfsVdsA',
    appId: '1:1089924470616:android:d8087836eb619643a2b72d',
    messagingSenderId: '1089924470616',
    projectId: 'gowash-5f356',
    storageBucket: 'gowash-5f356.firebasestorage.app',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'AIzaSyCD2ap2nsocmpB1tW-b-ugK_Q_NUffwuYc',
    appId: '1:1089924470616:ios:97e6e3729c9cf8eea2b72d',
    messagingSenderId: '1089924470616',
    projectId: 'gowash-5f356',
    storageBucket: 'gowash-5f356.firebasestorage.app',
    iosBundleId: 'com.gowash.pro.gowashpro',
  );
}
