/// Accès centralisé à la configuration d'environnement et aux secrets.
///
/// Les secrets ne sont JAMAIS écrits en dur dans le code source ni commités
/// dans Git. Ils sont injectés au moment de la compilation via `--dart-define` :
///
/// ```
/// flutter run --dart-define=IMGBB_API_KEY=votre_cle
/// ```
///
/// Voir `.env.example` et le README pour la procédure complète.
class AppEnv {
  AppEnv._();

  static const String _imgbbApiKey = String.fromEnvironment('IMGBB_API_KEY');

  /// Clé API ImgBB (chaîne vide si non fournie à la compilation).
  static String get imgbbApiKey => _imgbbApiKey;

  /// `true` si la clé ImgBB a bien été fournie à la compilation.
  static bool get hasImgbbApiKey => _imgbbApiKey.trim().isNotEmpty;
}
