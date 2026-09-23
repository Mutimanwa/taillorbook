import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'config/firebase/firebase_bootstrap.dart';
import 'core/constants/app_enums.dart';
import 'state/app/app_state.dart';
import 'state/currency/currency_providers.dart';

Future<void> main() async {
  await runZonedGuarded<Future<void>>(() async {
    WidgetsFlutterBinding.ensureInitialized();

    // Erreurs non interceptées : journalisées sans planter l'application.
    WidgetsBinding.instance.platformDispatcher.onError =
        (Object error, StackTrace stack) {
      if (kDebugMode) debugPrint('Erreur non interceptée : $error');
      return true;
    };

    // Journalisation globale des erreurs de framework et d'isolate :
    // l'application ne doit jamais planter brutalement face à une erreur
    // non interceptée (les erreurs métier sont déjà typées AppException).
    FlutterError.onError = (FlutterErrorDetails details) {
      FlutterError.presentError(details);
      if (kDebugMode) debugPrint('Erreur framework : ${details.exception}');
    };

    await _bootstrap();
  }, (Object error, StackTrace stack) {
    if (kDebugMode) debugPrint('Erreur zone : $error');
  });
}

Future<void> _bootstrap() async {

  // Initialisation de Firebase. En cas d'échec (configuration démo non
  // remplacée, absence de réseau...), l'application démarre en mode
  // démonstration : navigation invitée + bannière d'information.
  // Symboles de dates françaises (intl) pour le formatage des commandes.
  await initializeDateFormatting('fr');

  final FirebaseBootstrapStatus firebaseStatus =
      await FirebaseBootstrap.initialize();

  // Devise d'affichage persistée (chargée avant le démarrage pour éviter
  // tout clignotement de devise à l'ouverture).
  AppCurrency initialCurrency = AppCurrency.usd;
  try {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    initialCurrency =
        AppCurrency.fromName(prefs.getString(kDisplayCurrencyPrefKey));
  } catch (_) {
    // Stockage indisponible : devise de base (USD).
  }

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
        firebaseReadyProvider.overrideWith(
          (Ref ref) => firebaseStatus == FirebaseBootstrapStatus.ready),
        initialDisplayCurrencyProvider.overrideWithValue(initialCurrency),
      ],
      child: const SokoMarketApp(),
    ),
  );
}