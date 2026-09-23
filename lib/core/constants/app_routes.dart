/// Chemins de toutes les routes de l'application.
///
/// Les routes des phases suivantes (authentification, produits, checkout,
/// commandes, espace vendeur) sont déjà déclarées ici et seront branchées
/// dans le routeur au fur et à mesure des phases.
class AppRoutes {
  AppRoutes._();

  // Général
  static const String splash = '/';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String cart = '/cart';
  static const String orders = '/orders';
  static const String profile = '/profile';

  // Authentification (phase 2)
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';

  // Catalogue (phase 6)
  static const String search = '/search';
  static const String productList = '/products';
  static String productDetails(String productId) => '/product/$productId';

  /// Chemin de route (avec paramètre) de la fiche produit.
  static String get productDetailsPath => '/product/:productId';

  // Checkout (phases 8 & 9)
  static const String checkout = '/checkout';
  static const String orderSuccess = '/order-success';

  // Commandes (phase 10)
  static String orderDetails(String orderId) => '/order/$orderId';

  /// Chemin de route (avec paramètre) de la fiche commande client.
  static String get orderDetailsPath => '/order/:orderId';

  /// Chemin de route (avec paramètre) de la fiche commande vendeur.
  static String get sellerOrderDetailsPath => '/seller/orders/:orderId';

  // Espace vendeur (phase 5)
  static const String sellerDashboard = '/seller';
  static const String sellerProducts = '/seller/products';
  static const String sellerCreateProduct = '/seller/products/new';
  static String sellerEditProduct(String productId) => '/seller/products/$productId/edit';
  static final RegExp sellerEditProductPattern = RegExp(r'^/seller/products/([^/]+)/edit$');

  /// Chemin de route (avec paramètre) pour l'édition produit.
  static String get sellerEditProductPath => '/seller/products/:productId/edit';

  static const String sellerOrders = '/seller/orders';
  static String sellerOrderDetails(String orderId) => '/seller/orders/$orderId';
}