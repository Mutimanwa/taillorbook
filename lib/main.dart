import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'app/app.dart';
import 'config/firebase/firebase_bootstrap.dart';
import 'state/app/app_state.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialisation de Firebase. En cas d'échec (configuration démo non
  // remplacée, absence de réseau...), l'application démarre en mode
  // démonstration : navigation invitée + bannière d'information.
  final FirebaseBootstrapStatus firebaseStatus =
      await FirebaseBootstrap.initialize();

  await SystemChrome.setPreferredOrientations(<DeviceOrientation>[
    DeviceOrientation.portraitUp,
    DeviceOrientation.portraitDown,
  ]);
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
    ),
  );

  runApp(
    ProviderScope(
      overrides: <Override>[
        firebaseReadyProvider
            .overrideWithValue(firebaseStatus == FirebaseBootstrapStatus.ready),
      ],
      child: const SokoMarketApp(),
    ),
  );
}
