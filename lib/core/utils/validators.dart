/// Validateurs de formulaires de l'application.
///
/// Chaque validateur renvoie `null` si la valeur est valide, sinon un message
/// d'erreur en français prêt à être affiché sous le champ.
class Validators {
  Validators._();

  static const String kRequiredField = 'Ce champ est obligatoire';
  static const String kInvalidEmail = 'Adresse email invalide';
  static const String kInvalidPassword = 'Le mot de passe doit contenir au moins 6 caractères';
  static const String kInvalidPhone = 'Numéro de téléphone invalide';
  static const String kInvalidPrice = 'Le prix doit être un nombre supérieur à 0';
  static const String kInvalidStock = 'Le stock doit être un nombre entier positif ou nul';

  static final RegExp _emailRegExp = RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.\-]+$');

  /// Champ obligatoire (refuse les chaînes vides ou ne contenant que des espaces).
  static String? required(String? value, {String message = kRequiredField}) {
    if (value == null || value.trim().isEmpty) return message;
    return null;
  }

  /// Adresse email valide et obligatoire.
  static String? email(String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return kRequiredField;
    if (!_emailRegExp.hasMatch(trimmed)) return kInvalidEmail;
    return null;
  }

  /// Mot de passe d'au moins 6 caractères (règle Firebase Auth).
  static String? password(String? value) {
    final String password = value ?? '';
    if (password.length < 6) return kInvalidPassword;
    return null;
  }

  /// Numéro de téléphone : au moins 8 chiffres (espaces, +, - et () tolérés).
  static String? phone(String? value) {
    final String trimmed = value?.trim() ?? '';
    if (trimmed.isEmpty) return kRequiredField;
    final String digits = trimmed.replaceAll(RegExp(r'[\s+\-()]'), '');
    if (digits.length < 8 || int.tryParse(digits) == null) return kInvalidPhone;
    return null;
  }

  /// Prix strictement positif (virgule décimale acceptée).
  static String? price(String? value) {
    final String raw = value?.trim().replaceAll(',', '.') ?? '';
    final double? price = double.tryParse(raw);
    if (price == null || price <= 0) return kInvalidPrice;
    return null;
  }

  /// Stock entier positif ou nul (0 = produit en rupture).
  static String? stock(String? value) {
    final String raw = value?.trim() ?? '';
    final int? stock = int.tryParse(raw);
    if (stock == null || stock < 0) return kInvalidStock;
    return null;
  }

  /// Champ obligatoire + validation supplémentaire.
  static String? composed(String? value, String? Function(String?) next) {
    final String? requiredError = required(value);
    if (requiredError != null) return requiredError;
    return next(value);
  }
}
