/// Énumérations métier partagées par les modèles, les dépôts et l'interface.

/// Rôle d'un utilisateur (détermine les fonctionnalités accessibles).
enum UserRole {
  client('Client'),
  seller('Vendeur');

  const UserRole(this.label);

  final String label;

  static UserRole fromName(String? name, {UserRole fallback = UserRole.client}) {
    for (final UserRole role in UserRole.values) {
      if (role.name == name) return role;
    }
    return fallback;
  }
}

/// Devise d'affichage des prix (taux fixes de démonstration — voir README).
enum AppCurrency {
  usd('US\$', 'Dollar américain', 1.0),
  eur('€', 'Euro', 1.08),
  bif('FBu', 'Franc burundais', 0.00034);

  const AppCurrency(this.symbol, this.label, this.rateToUsd);

  /// Symbole affiché à côté des montants.
  final String symbol;

  /// Nom lisible de la devise.
  final String label;

  /// Taux de conversion fixe vers l'USD (1 unité de la devise = X USD).
  /// USD est la devise de base (taux = 1.0).
  final double rateToUsd;

  static AppCurrency fromName(String? name, {AppCurrency fallback = AppCurrency.usd}) {
    for (final AppCurrency currency in AppCurrency.values) {
      if (currency.name == name) return currency;
    }
    return fallback;
  }
}

/// Mode de réception choisi par le client au checkout.
enum DeliveryOption {
  delivery('Livraison à domicile'),
  storePickup('Retrait en boutique');

  const DeliveryOption(this.label);

  final String label;

  static DeliveryOption fromName(String? name,
      {DeliveryOption fallback = DeliveryOption.delivery}) {
    for (final DeliveryOption option in DeliveryOption.values) {
      if (option.name == name) return option;
    }
    return fallback;
  }
}

/// Méthode de paiement (strictement simulée — aucun paiement réel).
enum PaymentMethod {
  mobileMoney('Mobile Money'),
  bankCard('Carte bancaire');

  const PaymentMethod(this.label);

  final String label;

  static PaymentMethod fromName(String? name,
      {PaymentMethod fallback = PaymentMethod.mobileMoney}) {
    for (final PaymentMethod method in PaymentMethod.values) {
      if (method.name == name) return method;
    }
    return fallback;
  }
}

/// Statut du paiement simulé d'une commande.
enum PaymentStatus {
  pending('En attente'),
  processing('En cours'),
  paid('Payé'),
  failed('Échoué');

  const PaymentStatus(this.label);

  final String label;

  static PaymentStatus fromName(String? name,
      {PaymentStatus fallback = PaymentStatus.pending}) {
    for (final PaymentStatus status in PaymentStatus.values) {
      if (status.name == name) return status;
    }
    return fallback;
  }
}

/// Statut du cycle de vie d'une commande.
enum OrderStatus {
  pending('En attente'),
  confirmed('Confirmée'),
  processing('En préparation'),
  readyForPickup('Prête pour retrait'),
  shipped('Expédiée'),
  delivered('Livrée'),
  cancelled('Annulée');

  const OrderStatus(this.label);

  final String label;

  static OrderStatus fromName(String? name,
      {OrderStatus fallback = OrderStatus.pending}) {
    for (final OrderStatus status in OrderStatus.values) {
      if (status.name == name) return status;
    }
    return fallback;
  }
}
