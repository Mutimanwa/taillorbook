import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../core/constants/app_enums.dart';

/// Clé de persistance de la devise d'affichage (SharedPreferences).
const String kDisplayCurrencyPrefKey = 'displayCurrency';

/// Devise d'affichage initiale, chargée avant le démarrage (voir `main()`)
/// et injectée via `ProviderScope.overrides` — évite tout clignotement de
/// devise au lancement.
final Provider<AppCurrency> initialDisplayCurrencyProvider =
    Provider<AppCurrency>((Ref ref) => AppCurrency.usd);

/// Contrôleur de la devise d'affichage sélectionnée par l'utilisateur.
///
/// Le changement met immédiatement à jour l'interface (tous les prix
/// convertis) et persiste le choix pour les prochaines sessions.
class CurrencyController extends Notifier<AppCurrency> {
  @override
  AppCurrency build() => ref.watch(initialDisplayCurrencyProvider);

  /// Change la devise et persiste le choix.
  ///
  /// Si la persistance échoue (stockage indisponible), le choix reste
  /// actif pour la session en cours.
  Future<void> setCurrency(AppCurrency currency) async {
    state = currency;
    try {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString(kDisplayCurrencyPrefKey, currency.name);
    } catch (_) {
      // Persistance indisponible : choix conservé pour la session.
    }
  }
}

/// Devise d'affichage active — utilisée par tous les prix de l'application
/// (catalogue, fiche produit, panier, checkout, historique).
///
/// Conversion : [CurrencyConverter.convert] (taux fixes de démonstration,
/// USD = devise de base).
final NotifierProvider<CurrencyController, AppCurrency>
    displayCurrencyProvider =
    NotifierProvider<CurrencyController, AppCurrency>(CurrencyController.new);