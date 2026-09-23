/// Extensions utilitaires sur [String].
extension AppStringExtensions on String {
  /// Met la première lettre en majuscule (ex. 'bonjour' → 'Bonjour').
  String get capitalize {
    if (isEmpty) return this;
    return this[0].toUpperCase() + substring(1);
  }

  /// Version tronquée avec ellipse si plus longue que [maxLength].
  String truncate(int maxLength) {
    if (length <= maxLength) return this;
    return '${substring(0, maxLength)}…';
  }
}

/// Extensions sur [String]? (valeurs potentiellement nulles).
extension AppNullableStringExtensions on String? {
  /// `true` si la chaîne est nulle ou ne contient que des espaces.
  bool get isBlank {
    final String? value = this;
    if (value == null) return true;
    return value.trim().isEmpty;
  }

  /// `true` si la chaîne contient au moins un caractère non blanc.
  bool get isNotBlank => !isBlank;
}
