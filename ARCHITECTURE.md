# SokoMarket — Architecture technique & plan d'implémentation

> Marketplace mobile e-commerce — **Flutter + Dart + Firebase + ImgBB + WhatsApp**
> Projet final académique, conçu pour évoluer vers une véritable marketplace.

---

## A. Architecture technique

L'application suit une **architecture propre en couches**, avec une dépendance
stricte et unidirectionnelle : chaque couche ne connaît que la couche
immédiatement inférieure.

```
UI (widgets, écrans)
   ↓
State management (Riverpod Notifiers / Providers)
   ↓
Repositories (contrats d'accès aux données)
   ↓
Services (Firebase Auth, Firestore, ImgBB, WhatsApp, Paiement)
   ↓
Sources externes (Firebase, API ImgBB, WhatsApp, SharedPreferences)
```

**Règles non négociables :**

| Règle | Application |
|---|---|
| Les widgets n'appellent jamais Firestore / ImgBB directement | Ils écoutent des providers et invoquent des méthodes de Notifier |
| Les secrets ne sont jamais dans le code commité | `--dart-define` → `AppEnv` (`.env.example` fourni, `.env` ignoré par Git) |
| Les erreurs techniques sont traduites en exceptions métier | Hiérarchie `AppException` (`core/errors/`) → messages FR affichables |
| Les images produits ne passent **jamais** par Firebase Storage | Upload **ImgBB** uniquement ; Firestore stocke l'URL publique `imageUrl` |
| Le paiement est **strictement simulé** | `PaymentSimulationService`, aucun SDK financier, aucune transaction réelle |
| Les modèles sérialisent manuellement | `fromMap()` / `toMap()` explicites, gestion propre des `Timestamp` |

**Stack :** Flutter 3.x (Dart ^3.11), Firebase Authentication, Cloud Firestore,
API ImgBB, WhatsApp deep links, Riverpod 2, GoRouter 2-style `StatefulShellRoute`.

---

## B. Architecture des dossiers

```
lib/
├── app/                            # Racine applicative
│   ├── app.dart                    # Widget racine (thèmes + router)
│   ├── router/
│   │   └── app_router.dart         # GoRouter (shell 5 onglets + routes)
│   └── theme/                      # DESIGN SYSTEM
│       ├── app_colors.dart
│       ├── app_typography.dart
│       ├── app_spacing.dart
│       ├── app_radius.dart
│       ├── app_shadows.dart
│       └── app_theme.dart          # ThemeData clair + sombre
│
├── core/
│   ├── constants/
│   │   ├── app_constants.dart      # Nom, seuils, frais livraison, mentions
│   │   ├── app_enums.dart          # UserRole, AppCurrency, OrderStatus...
│   │   ├── app_routes.dart         # Chemins de toutes les routes
│   │   ├── app_assets.dart
│   │   └── firestore_collections.dart
│   ├── errors/
│   │   └── app_exceptions.dart     # NetworkException, AuthException, ...
│   ├── extensions/
│   │   ├── context_extensions.dart # snackbars, dialogs de confirmation
│   │   └── string_extensions.dart
│   ├── utils/
│   │   ├── validators.dart         # email, mot de passe, prix, stock, tél.
│   │   └── money_formatter.dart    # « 12 500 FBu », « 24,99 US$ »
│   └── widgets/                    # Composants réutilisables
│       ├── app_button.dart         # CTA (5 variantes, loading intégré)
│       ├── app_text_field.dart
│       ├── app_loading.dart
│       ├── app_error.dart          # ErrorState + bouton Réessayer
│       ├── app_empty.dart          # EmptyState + action
│       ├── app_skeleton.dart       # Skeletons shimmer
│       ├── price_text.dart
│       ├── section_header.dart
│       └── main_scaffold.dart      # NavigationBar + badge panier
│
├── config/
│   ├── environment/
│   │   └── app_env.dart            # Lecture des secrets (--dart-define)
│   └── firebase/
│       ├── firebase_options.dart   # Généré par `flutterfire configure`
│       └── firebase_bootstrap.dart # Init robuste + mode démonstration
│
├── models/                         # fromMap() / toMap()
│   ├── user_model.dart
│   ├── category_model.dart
│   ├── product_model.dart
│   ├── cart_item_model.dart
│   ├── order_model.dart            # + PaymentModel & DeliveryModel embarqués
│   ├── order_item_model.dart
│   ├── payment_model.dart
│   └── delivery_model.dart
│
├── services/                       # Accès brut aux sources externes
│   ├── firebase_auth_service.dart
│   ├── firestore_service.dart
│   ├── imgbb_service.dart
│   ├── whatsapp_service.dart
│   └── payment_simulation_service.dart
│
├── repositories/                   # Logique d'accès aux données
│   ├── auth_repository.dart
│   ├── user_repository.dart
│   ├── category_repository.dart
│   ├── product_repository.dart
│   └── order_repository.dart
│
├── state/                          # État global (Riverpod)
│   ├── app/app_state.dart
│   ├── auth/auth_providers.dart
│   ├── cart/cart_providers.dart
│   ├── currency/currency_providers.dart
│   ├── products/products_providers.dart
│   ├── orders/orders_providers.dart
│   └── seller/seller_providers.dart
│
├── features/                       # Écrans, organisés par domaine
│   ├── splash/  auth/  home/  categories/  products/
│   ├── cart/    checkout/  orders/  profile/  seller/
│   └── .../presentation/screens/ + .../presentation/widgets/
│
└── main.dart                       # Bootstrap + ProviderScope
```

---

## C. Modèles de données

| Modèle | Champs clés | Notes |
|---|---|---|
| `UserModel` | id, name, email, phone, `role` (UserRole), `whatsappNumber` (vendeur), createdAt, profileImageUrl | Rôle = client ou vendeur |
| `CategoryModel` | id, name, slug, imageUrl, sortOrder, isActive | Liste publique |
| `ProductModel` | id, name, description, price, currency, categoryId, categoryName, stock, `imageUrl` (ImgBB), sellerId, sellerName, sellerWhatsappNumber, isActive, createdAt, updatedAt | Vendeur dénormalisé pour l'affichage |
| `CartItemModel` | productId, productName, imageUrl, sellerId, sellerName, sellerWhatsappNumber, unitPrice, currency, quantity | Photo du produit au moment de l'ajout |
| `OrderModel` | orderId, clientId, clientName, clientPhone, **sellerId / sellerName / sellerWhatsappNumber**, items[], subtotal, deliveryFee, total, currency, deliveryOption, deliveryLocation, payment (PaymentModel), orderStatus, createdAt, updatedAt | Une commande = un vendeur (v1) |
| `OrderItemModel` | productId, productName, imageUrl, unitPrice, currency, quantity, lineTotal | Instantané du prix |
| `PaymentModel` | method, status, transactionReference, processedAt | 100 % simulé |
| `DeliveryModel` | option (delivery / storePickup), address, city, phone, additionalInfo, fee | Adresse vide en retrait |

Chaque modèle expose `copyWith`, `toMap()`, `fromMap()` ; les dates utilisent
`Timestamp` (Firestore) converties en `DateTime` via helpers dédiés.

---

## D. Schéma Firestore

```
users/{uid}
  name, email, phone, role: "client"|"seller", whatsappNumber,
  profileImageUrl, createdAt

categories/{categoryId}
  name, slug, imageUrl, sortOrder, isActive

products/{productId}
  name, description, price, currency, categoryId, categoryName,
  stock, imageUrl (https://i.ibb.co/...), sellerId, sellerName,
  sellerWhatsappNumber, isActive, createdAt, updatedAt

orders/{orderId}
  orderId, clientId, clientName, clientPhone,
  sellerId, sellerName, sellerWhatsappNumber,
  items: [ OrderItemModel.toMap() ],
  subtotal, deliveryFee, total, currency,
  deliveryOption: "delivery"|"storePickup", deliveryLocation,
  payment: { method, status, transactionReference, processedAt },
  orderStatus, createdAt, updatedAt
```

**Sécurité (règles déployées à la phase dédiée, fichier `firestore.rules`) :**

- `products` : lecture publique des produits actifs ; création réservée aux
  `role == "seller"` ; **modification/suppression uniquement par le propriétaire** ;
- `orders` : un client ne lit/crée **que ses commandes** ; un vendeur ne lit
  que les commandes contenant **ses produits** ; aucun write client après création ;
- `users/{uid}` : lecture/écriture **uniquement par le propriétaire** ;
- aucun `allow read, write: if true` en production.

---

## E. Navigation

GoRouter avec `StatefulShellRoute.indexedStack` (état préservé par onglet) :

| Onglet | Route | Écran | Accès |
|---|---|---|---|
| 1 Accueil | `/home` | HomeScreen | Public |
| 2 Catégories | `/categories` | CategoriesScreen | Public |
| 3 Panier | `/cart` | CartScreen | Panier public, checkout protégé |
| 4 Commandes | `/orders` | OrdersScreen | Protégé (client) |
| 5 Profil | `/profile` | ProfileScreen | Public (état invité) |

Routes hors shell : splash `/`, login, register, forgot-password, recherche,
`/product/:id`, checkout, `/order-success`, `/order/:id`, espace vendeur
(`/seller`, `/seller/products`, création/édition produit, commandes vendeur).

**Routes protégées** : redirection vers `/login` via un `redirect` GoRouter
branché sur `authStateProvider` (phase Authentification). Les actions protégées
tentées par un visiteur affichent un message et redirigent vers la connexion.

---

## F. State management (Riverpod 2)

| Provider | Type | Rôle |
|---|---|---|
| `cartProvider` | `NotifierProvider<CartNotifier, List<CartItemModel>>` | Panier global : add/remove/increase/decrease/clear |
| `cartTotalItemsProvider` | `Provider<int>` | Badge de la barre de navigation |
| `cartSubtotalProvider` | `Provider<double>` | Sous-total dérivé |
| `authStateProvider` | `StreamProvider<User?>` | État de connexion Firebase Auth |
| `currentUserProvider` / `isAuthenticatedProvider` | `Provider` | Utilisateur courant, garde de routes |
| `userProfileProvider` | `StreamProvider<UserModel?>` | Profil Firestore (rôle, WhatsApp) |
| `currencyProvider` | `NotifierProvider<AppCurrency>` | Devise active (persistée) |
| `categoriesProvider` / `activeProductsProvider` | `StreamProvider` | Catégories & produits actifs Firestore (temps réel) |
| `productByIdProvider` | `StreamProvider.family` | Produit par id (temps réel, auto-disposé) |
| `productCountByCategoryProvider` | `Provider<Map<String, int>>` | Badges « X produits » des catégories |
| `ordersProvider` / `sellerOrdersProvider` | `StreamProvider` | Historique client / commandes vendeur |
| `themeModeProvider` | `StateProvider<ThemeMode>` | Thème clair / sombre |
| `firebaseReadyProvider` | `StateProvider<bool>` | Mode démonstration si Firebase absent |

Convention : **UI → Notifier → Repository → Service**. Les widgets écoutent des
états (`AsyncValue` : loading / data / error) et appellent des méthodes ; ils ne
connaissent ni Firestore ni ImgBB.

---

## G. Design system

Identité visuelle originale « marketplace premium » : espaces blancs, cartes
à bord fin + coins 16, CTA émeraude pleins, ambre réservé aux promotions et au
badge panier.

| Jeton | Valeur | Usage |
|---|---|---|
| `primary` | `#0E7C66` (émeraude) | CTA, liens, sélection |
| `primaryDark` | `#0A5D4D` | Titres de marque |
| `secondary` | `#F5A623` (ambre) | Promos, badge panier |
| `background` | `#F7F8FA` | Fond des écrans |
| `surface` | `#FFFFFF` | Cartes, barres |
| `success / warning / error` | `#12B76A / #F79009 / #E5484D` | Feedbacks |
| Typographie | **Poppins** (embarquée) | Hiérarchie 30 → 11 |
| Rayons | 8 / 12 / 16 / 24 | Boutons, champs, cartes |
| Ombres | card / floating / subtle | Profondeur discrète |

Thèmes **clair + sombre** (`AppTheme.light()` / `AppTheme.dark()`), bascule
depuis le profil. Composants centralisés : `AppButton`, `AppTextField`,
`AppLoading`, `AppError`, `AppEmpty`, skeletons, `PriceText`, `ProductCard`,
`OrderCard`, `SectionHeader`, `MainScaffold`.

---

## H. Liste des packages

| Package | Rôle | Justification |
|---|---|---|
| `firebase_core` | Initialisation Firebase | Requis par Auth & Firestore |
| `firebase_auth` | Authentification email/mot de passe | Inscription/connexion/rôles |
| `cloud_firestore` | Base de données | users, products, categories, orders |
| `flutter_riverpod` | État global testable | Panier, auth, devise, catalogue |
| `go_router` | Navigation déclarative | Shell 5 onglets, deep links, guards |
| `dio` | HTTP (upload ImgBB) | Timeout & gestion d'erreurs propres |
| `image_picker` | Sélection photo produit | Caméra + galerie |
| `cached_network_image` | Cache d'images produits | Fluidité + placeholders |
| `url_launcher` | Deep links WhatsApp / mailto | Récapitulatif commande vendeur |
| `shared_preferences` | Persistance légère | Devise, thème, onboarding |
| `intl` | Formatage monétaire & dates | « 12 500 FBu », dates FR |
| `uuid` | Références de transaction | `payment.transactionReference` |
| `shimmer` | Skeletons de chargement | UX perçue premium |

*Écartés volontairement :* Bloc/Provider (Riverpod retenu), GetX, Hive
(SharedPreferences suffit v1), Firebase Storage (interdit par le cahier des
charges pour les images).

---

## I. Plan d'implémentation (15 phases)

| # | Phase | Contenu | État |
|---|---|---|---|
| 1 | **Socle** | Setup, design system, architecture, config Firebase robuste, navigation 5 onglets, panier v1 fonctionnel, CI d'analyse | ✅ **Réalisée** |
| 2 | **Authentification & rôles** | Login/Register (client ou vendeur + WhatsApp), Forgot Password, `users/{uid}`, contrôleur AsyncValue, guards de pages d'auth, profil réel + badge rôle, prompt connexion sur les commandes | ✅ **Réalisée** |
| 3 | Modèles & catalogue interne | Tous les `fromMap/toMap`, catégories, `ProductRepository` | ⏭ À venir |
| 4 | Upload ImgBB | `ImgbbService` + `ImageUploadResult`, clé via `--dart-define` | ⏭ À venir |
| 5 | Espace vendeur | Dashboard, CRUD produits, sécurité propriétaire | ⏭ À venir |
| 6 | Catalogue public | Home complète, recherche, filtres, tri, détails produit | ⏭ À venir |
| 7 | Panier & devise | Stock checks, conversion BIF/USD/EUR, persistance | ⏭ À venir |
| 8 | Checkout | 5 étapes : panier → livraison → adresse → paiement → récap | ⏭ À venir |
| 9 | Paiement simulé | Mobile Money / carte, succès/échec, référence transaction | ⏭ À venir |
| 10 | Commandes | Création Firestore, historique, détails, commandes vendeur | ⏭ À venir |
| 11 | WhatsApp | Message récapitulatif + deep link + fallback copie | ⏭ À venir |
| 12 | Sécurité | `firestore.rules` complètes, tests de règles | ⏭ À venir |
| 13 | Gestion d'erreurs | Mapping complet des erreurs, états de repli | ⏭ À venir (base posée) |
| 14 | UI polish | Animations, Hero, skeletons partout, dark mode complet | ⏭ À venir (base posée) |
| 15 | Tests | Unitaires, widgets, parcours complet | ⏭ À venir (3 suites en place) |

> Les phases suivent l'ordre imposé par le cahier des charges ; chaque phase
> livre des fichiers **complets**, compilables avec les phases précédentes.

---

## Configuration locale (mode démonstration inclus)

```bash
flutter pub get

# Lancer sans Firebase (mode démonstration, navigation invitée) :
flutter run

# Lancer avec Firebase + ImgBB :
flutterfire configure                     # remplace lib/config/firebase/firebase_options.dart
flutter run --dart-define=IMGBB_API_KEY=votre_cle_imgbb
```

Copiez `.env.example` vers `.env` pour conserver vos clés localement
(**jamais commité** — le `.gitignore` l'ignore déjà).

## Tests

```bash
flutter analyze    # 0 problème attendu
flutter test       # validateurs, panier, widgets réutilisables
```
