// Fichier de configuration Firebase (options par plateforme).
//
// ⚠️  VALEURS DE DÉMONSTRATION — ce fichier contient des valeurs factices afin
// que le projet compile sans compte Firebase. Pour brancher un vrai projet :
//
//   1. créez un projet sur https://console.firebase.google.com ;
//   2. exécutez à la racine du projet :   flutterfire configure
//   3. choisissez ce chemin de sortie :   lib/config/firebase/firebase_options.dart
//
// Le format ci-dessous est identique à celui généré par FlutterFire CLI :
// la commande remplace simplement les valeurs factices par les vôtres.
import 'package:firebase_core/firebase_core.dart' show FirebaseOptions;
import 'package:flutter/foundation.dart'
    show TargetPlatform, defaultTargetPlatform, kIsWeb;

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
      case TargetPlatform.linux:
        throw UnsupportedError(
          'DefaultFirebaseOptions n\'est pas configuré pour cette plateforme.',
        );
      default:
        throw UnsupportedError(
          'Plateforme non supportée pour la configuration Firebase.',
        );
    }
  }

  static const FirebaseOptions web = FirebaseOptions(
    apiKey: 'DEMO-WEB-API-KEY',
    appId: 'DEMO-WEB-APP-ID',
    messagingSenderId: '000000000000',
    projectId: 'demo-sokomarket',
    authDomain: 'demo-sokomarket.firebaseapp.com',
    storageBucket: 'demo-sokomarket.appspot.com',
  );

  static const FirebaseOptions android = FirebaseOptions(
    apiKey: 'DEMO-ANDROID-API-KEY',
    appId: 'DEMO-ANDROID-APP-ID',
    messagingSenderId: '000000000000',
    projectId: 'demo-sokomarket',
    storageBucket: 'demo-sokomarket.appspot.com',
  );

  static const FirebaseOptions ios = FirebaseOptions(
    apiKey: 'DEMO-IOS-API-KEY',
    appId: 'DEMO-IOS-APP-ID',
    messagingSenderId: '000000000000',
    projectId: 'demo-sokomarket',
    storageBucket: 'demo-sokomarket.appspot.com',
    iosBundleId: 'com.example.taillorbook',
  );

  static const FirebaseOptions macos = FirebaseOptions(
    apiKey: 'DEMO-MACOS-API-KEY',
    appId: 'DEMO-MACOS-APP-ID',
    messagingSenderId: '000000000000',
    projectId: 'demo-sokomarket',
    storageBucket: 'demo-sokomarket.appspot.com',
    iosBundleId: 'com.example.taillorbook',
  );
}
