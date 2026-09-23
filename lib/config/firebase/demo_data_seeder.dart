import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException, WriteBatch, QuerySnapshot;
import 'package:flutter/foundation.dart';

import '../../core/constants/app_enums.dart';
import '../../core/constants/firestore_collections.dart';
import '../../core/errors/app_exceptions.dart';
import '../../models/category_model.dart';
import '../../models/product_model.dart';
import '../../services/firestore_service.dart';

/// Peuplement idempotent de données de démonstration (catégories + produits).
///
/// Exécuté au lancement (splash) uniquement si Firebase est disponible et si
/// les collections sont vides — les données restent modifiables/supprimables
/// normalement depuis l'espace vendeur.
///
/// Les images de démonstration proviennent de picsum.photos (CDN stable) ;
/// les produits créés par les vendeurs utilisent ImgBB (phase « Upload »).
class DemoDataSeeder {
  DemoDataSeeder(this._service);

  final FirestoreService _service;

  static const String _sellerTechId = 'demo-seller-tech';
  static const String _sellerTechName = 'Kirundo Tech';
  static const String _sellerTechWhatsApp = '+25779900111';

  static const String _sellerFashionId = 'demo-seller-fashion';
  static const String _sellerFashionName = 'Bujumbura Fashion';
  static const String _sellerFashionWhatsApp = '+25779900222';

  static const String _sellerMarketId = 'demo-seller-market';
  static const String _sellerMarketName = 'Gitega Market';
  static const String _sellerMarketWhatsApp = '+25779900333';

  Future<void> seedIfEmpty() async {
    try {
      await _seedCategoriesIfEmpty();
      await _seedProductsIfEmpty();
    } on AppException catch (error) {
      if (kDebugMode) debugPrint('Seed ignoré : ${error.message}');
    } on FirebaseException catch (error) {
      if (kDebugMode) debugPrint('Seed ignoré (Firestore) : ${error.code}');
    }
  }

  Future<void> _seedCategoriesIfEmpty() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _service.collection(FirestoreCollections.categories).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final WriteBatch batch = _service.instance.batch();
    final DateTime now = DateTime.now();

    final List<CategoryModel> categories = <CategoryModel>[
      _category('mode', 'Mode & Vêtements', 1, now),
      _category('electronique', 'Électronique', 2, now),
      _category('maison', 'Maison & Déco', 3, now),
      _category('beaute', 'Beauté & Santé', 4, now),
      _category('sport', 'Sport & Loisirs', 5, now),
      _category('alimentation', 'Alimentation', 6, now),
    ];

    for (final CategoryModel category in categories) {
      batch.set(
        _service.collection(FirestoreCollections.categories).doc(category.id),
        category.toMap(),
      );
    }
    await batch.commit();
    if (kDebugMode) debugPrint('Seed : ${categories.length} catégories créées.');
  }

  Future<void> _seedProductsIfEmpty() async {
    final QuerySnapshot<Map<String, dynamic>> snapshot =
        await _service.collection(FirestoreCollections.products).limit(1).get();
    if (snapshot.docs.isNotEmpty) return;

    final WriteBatch batch = _service.instance.batch();

    final List<ProductModel> products = <ProductModel>[
      _product(
        id: 'demo-robe-kitenge',
        name: 'Robe kitenge élégante',
        description:
            "Robe en tissu kitenge authentique, coupe ajustée et finitions "
            "couture main. Idéale pour les cérémonies et les grandes occasions.",
        price: 45, oldPrice: 60, currency: AppCurrency.usd,
        categoryId: 'mode', categoryName: 'Mode & Vêtements',
        stock: 12, sellerId: _sellerFashionId, sellerName: _sellerFashionName,
        sellerWhatsapp: _sellerFashionWhatsApp, daysAgo: 2,
      ),
      _product(
        id: 'demo-tshirt-coton',
        name: 'T-shirt coton bio unisexe',
        description:
            "T-shirt 100 % coton biologique, confortable et respirant. "
            "Disponible du S au XXL.",
        price: 12, currency: AppCurrency.usd,
        categoryId: 'mode', categoryName: 'Mode & Vêtements',
        stock: 40, sellerId: _sellerFashionId, sellerName: _sellerFashionName,
        sellerWhatsapp: _sellerFashionWhatsApp, daysAgo: 5,
      ),
      _product(
        id: 'demo-sac-dos',
        name: 'Sac à dos scolaire renforcé',
        description:
            "Sac à dos imperméable avec compartiment ordinateur 15\", "
            "bretelles rembourrées et fond renforcé.",
        price: 14, currency: AppCurrency.usd,
        categoryId: 'sport', categoryName: 'Sport & Loisirs',
        stock: 3, sellerId: _sellerFashionId, sellerName: _sellerFashionName,
        sellerWhatsapp: _sellerFashionWhatsApp, daysAgo: 8,
      ),
      _product(
        id: 'demo-ecouteurs-pro',
        name: 'Écouteurs sans fil Pro',
        description:
            "Écouteurs Bluetooth 5.3 avec réduction de bruit active, "
            "autonomie 30 h avec le boîtier et étancheité IPX5.",
        price: 25, oldPrice: 35, currency: AppCurrency.usd,
        categoryId: 'electronique', categoryName: 'Électronique',
        stock: 8, sellerId: _sellerTechId, sellerName: _sellerTechName,
        sellerWhatsapp: _sellerTechWhatsApp, daysAgo: 1,
      ),
      _product(
        id: 'demo-smartphone-xpower',
        name: 'Smartphone XPower 128 Go',
        description:
            "Écran 6,8\" 90 Hz, batterie 6000 mAh, 8 Go de RAM, triple "
            "caméra 50 Mpx. Garantie boutique 12 mois.",
        price: 210, currency: AppCurrency.usd,
        categoryId: 'electronique', categoryName: 'Électronique',
        stock: 5, sellerId: _sellerTechId, sellerName: _sellerTechName,
        sellerWhatsapp: _sellerTechWhatsApp, daysAgo: 3,
      ),
      _product(
        id: 'demo-ballon-football',
        name: 'Ballon de football taille 5',
        description:
            "Ballon cousu machine, revêtement résistant à l'usure, "
            "adapté aux terrains synthétiques et en terre battue.",
        price: 16, currency: AppCurrency.usd,
        categoryId: 'sport', categoryName: 'Sport & Loisirs',
        stock: 10, sellerId: _sellerTechId, sellerName: _sellerTechName,
        sellerWhatsapp: _sellerTechWhatsApp, daysAgo: 6,
      ),
      _product(
        id: 'demo-lampe-solaire',
        name: 'Lampe LED solaire portable',
        description:
            "Lampe solaire 3 intensités avec panneau amovible et port USB "
            "pour recharger un téléphone. Autonomie jusqu'à 12 h.",
        price: 18, currency: AppCurrency.usd,
        categoryId: 'maison', categoryName: 'Maison & Déco',
        stock: 25, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 4,
      ),
      _product(
        id: 'demo-panier-tresse',
        name: 'Panier tressé artisanal',
        description:
            "Panier de rangement tressé à la main en fibres naturelles. "
            "Chaque pièce est unique, fabriquée par nos artisanes locales.",
        price: 9500, currency: AppCurrency.bif,
        categoryId: 'maison', categoryName: 'Maison & Déco',
        stock: 15, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 9,
      ),
      _product(
        id: 'demo-karite',
        name: 'Beurre de karité pur 250 g',
        description:
            "Beurre de karité 100 % naturel et non raffiné, importé "
            "directement des coopératives. Nourrit peau et cheveux.",
        price: 6.5, currency: AppCurrency.eur,
        categoryId: 'beaute', categoryName: 'Beauté & Santé',
        stock: 30, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 7,
      ),
      _product(
        id: 'demo-savon-crie',
        name: 'Savon artisanal aloé vera (lot de 3)',
        description:
            "Lot de trois savons artisanaux à l'aloé vera, sans parfum de "
            "synthèse. Convient aux peaux sensibles.",
        price: 8, oldPrice: 10, currency: AppCurrency.eur,
        categoryId: 'beaute', categoryName: 'Beauté & Santé',
        stock: 0, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 10,
      ),
      _product(
        id: 'demo-cafe-arabica',
        name: 'Café Burundi Arabica 1 kg',
        description:
            "Café arabica de haute altitude, torréfaction moyenne. "
            "Notes de chocolat et d'agrumes. Moulu sur demande.",
        price: 22, oldPrice: 28, currency: AppCurrency.usd,
        categoryId: 'alimentation', categoryName: 'Alimentation',
        stock: 20, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 2,
      ),
      _product(
        id: 'demo-riz-premium',
        name: 'Riz premium local 5 kg',
        description:
            "Riz de la plaine de l'Imbo, trié et nettoyé. Sac de 5 kg, "
            "récolte de la saison en cours.",
        price: 55000, currency: AppCurrency.bif,
        categoryId: 'alimentation', categoryName: 'Alimentation',
        stock: 50, sellerId: _sellerMarketId, sellerName: _sellerMarketName,
        sellerWhatsapp: _sellerMarketWhatsApp, daysAgo: 11,
      ),
    ];

    for (final ProductModel product in products) {
      batch.set(
        _service.collection(FirestoreCollections.products).doc(product.id),
        product.toMap(),
      );
    }
    await batch.commit();
    if (kDebugMode) debugPrint('Seed : ${products.length} produits créés.');
  }

  // ------------------------------------------------------------------ helpers

  CategoryModel _category(String slug, String name, int sortOrder, DateTime now) {
    return CategoryModel(
      id: slug,
      name: name,
      slug: slug,
      imageUrl: 'https://picsum.photos/seed/soko-$slug/600/400',
      sortOrder: sortOrder,
      isActive: true,
      createdAt: now,
    );
  }

  ProductModel _product({
    required String id,
    required String name,
    required String description,
    required double price,
    required AppCurrency currency,
    required String categoryId,
    required String categoryName,
    required int stock,
    required String sellerId,
    required String sellerName,
    required String sellerWhatsapp,
    required int daysAgo,
    double? oldPrice,
  }) {
    return ProductModel(
      id: id,
      name: name,
      description: description,
      price: price,
      oldPrice: oldPrice,
      currency: currency,
      categoryId: categoryId,
      categoryName: categoryName,
      stock: stock,
      imageUrl: 'https://picsum.photos/seed/soko-$id/640/640',
      sellerId: sellerId,
      sellerName: sellerName,
      sellerWhatsappNumber: sellerWhatsapp,
      isActive: true,
      createdAt: DateTime.now().subtract(Duration(days: daysAgo)),
      updatedAt: DateTime.now().subtract(Duration(days: daysAgo)),
    );
  }
}