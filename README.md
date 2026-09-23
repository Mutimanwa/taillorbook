# SokoMarket 🛍️

Marketplace mobile e-commerce complète — **Flutter + Dart + Firebase + ImgBB + WhatsApp**.

- 👀 **Visiteurs** : parcours du catalogue sans compte, recherche, détails produit
- 🛒 **Clients** : panier, multi-devises (BIF / USD / EUR), livraison ou retrait,
  paiement simulé, historique de commandes, récapitulatif WhatsApp au vendeur
- 🏪 **Vendeurs** : espace dédié, publication et gestion de leurs produits
  (images hébergées sur ImgBB), suivi des commandes qui les concernent

> Projet académique : paiement **strictement simulé**, taux de change **fixes de
> démonstration** — aucune transaction réelle.

## Démarrage rapide

```bash
flutter pub get
flutter run                # mode démonstration (sans Firebase configuré)
```

Avec Firebase + ImgBB :

```bash
flutterfire configure      # écrit lib/config/firebase/firebase_options.dart
flutter run --dart-define=IMGBB_API_KEY=votre_cle_imgbb
```

Consultez **[ARCHITECTURE.md](ARCHITECTURE.md)** pour l'architecture technique,
le schéma Firestore, le design system et le plan d'implémentation détaillé.

## Qualité

```bash
flutter analyze
flutter test
```
