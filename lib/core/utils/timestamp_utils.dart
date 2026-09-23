import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

/// Conversion centralisée des dates stockées dans Firestore.
class TimestampUtils {
  TimestampUtils._();

  /// Convertit une valeur Firestore (`Timestamp`, `DateTime`, epoch, ISO)
  /// en [DateTime] ; renvoie `null` pour toute autre valeur.
  static DateTime? toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
