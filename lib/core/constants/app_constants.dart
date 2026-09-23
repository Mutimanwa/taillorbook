/// Constantes générales de l'application.
class AppConstants {
  AppConstants._();

  static const String appName = 'SokoMarket';
  static const String appSlogan = 'La marketplace moderne';
  static const String appVersion = '1.0.0';

  /// Seuil en dessous duquel le stock d'un produit est considéré comme faible
  /// (affichage « Only X left » → « Plus que X en stock »).
  static const int lowStockThreshold = 5;

  /// Frais de livraison par défaut, exprimés en USD (devise de base).
  /// Convertis dans la devise active au moment du checkout.
  static const double defaultDeliveryFeeUsd = 2.0;

  /// Durée d'affichage du splash avant navigation vers l'accueil.
  static const Duration splashDuration = Duration(milliseconds: 2200);

  /// Mention légale affichée partout où les taux de change sont utilisés.
  static const String currencyRatesDisclaimer =
      'Taux de change fixes de démonstration — ils ne reflètent pas les taux réels du marché.';
}
