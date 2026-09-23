import 'package:intl/intl.dart';

/// Formatage des dates de l'application (locale française, symboles chargés
/// au démarrage via `initializeDateFormatting('fr')` dans `main.dart`).
class AppDateFormatter {
  AppDateFormatter._();

  static final DateFormat _dateTimeFormat =
      DateFormat('d MMM yyyy · HH:mm', 'fr');

  /// « 23 sept. 2026 · 14:05 » (null-safe).
  static String formatDateTime(DateTime? dateTime) {
    if (dateTime == null) return '—';
    return _dateTimeFormat.format(dateTime.toLocal());
  }
}