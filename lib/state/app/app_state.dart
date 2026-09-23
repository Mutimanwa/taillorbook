import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Indique si Firebase a démarré correctement.
///
/// La valeur réelle est injectée dans `main()` via `ProviderScope.overrides`
/// (démarrage en mode démonstration si Firebase est indisponible).
final StateProvider<bool> firebaseReadyProvider =
    StateProvider<bool>((Ref ref) => false);

/// Mode de thème actif (clair / système / sombre), modifiable depuis le profil.
final StateProvider<ThemeMode> themeModeProvider =
    StateProvider<ThemeMode>((Ref ref) => ThemeMode.light);
