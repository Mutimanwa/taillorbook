import 'package:url_launcher/url_launcher.dart' show LaunchMode, launchUrl;

import '../core/utils/money_formatter.dart';
import '../models/order_model.dart';
import '../models/order_item_model.dart';
import '../models/product_model.dart';

/// Résultat de l'ouverture de WhatsApp.
///
/// En cas d'échec (application non installée, erreur plateforme), [error]
/// contient un message explicite et [message] le texte à proposer à la copie.
class WhatsAppOpenResult {
  const WhatsAppOpenResult._({required this.success, this.error});

  const WhatsAppOpenResult.success() : success = true, error = null;

  const WhatsAppOpenResult.failure(this.error) : success = false;

  final bool success;
  final String? error;
}

/// Signature du lanceur d'URL (injectable pour les tests).
typedef UrlLauncher = Future<bool> Function(Uri uri, LaunchMode mode);

/// Service d'ouverture de WhatsApp via deep link (`wa.me`).
///
/// - construit le lien universel `https://wa.me/<numéro>?text=<message>` ;
/// - normalise les numéros (espaces, parenthèses, tirets, « + ») ;
/// - ne fait jamais planter l'application si WhatsApp est absent :
///   renvoie un [WhatsAppOpenResult.failure] avec un message clair,
///   l'interface proposant alors de copier le message.
///
/// Utilisé par la fiche produit (contacter le vendeur) et par le récapitulatif
/// de commande (phase « WhatsApp »).
class WhatsAppService {
  WhatsAppService({UrlLauncher? launcher})
      : _launcherOverride = launcher;

  /// Lanceur injectable (tests) ; par défaut [launchUrl] de url_launcher.
  final UrlLauncher? _launcherOverride;

  Future<bool> _launch(Uri uri, LaunchMode mode) async {
    final UrlLauncher? override = _launcherOverride;
    if (override != null) return override(uri, mode);
    return launchUrl(uri, mode: mode);
  }

  /// Normalise un numéro pour `wa.me` : chiffres uniquement.
  ///
  /// « +257 79 00-11 » → « 257790011 ». Le « + » initial est retiré
  /// (wa.me attend l'indicatif international sans signe).
  static String normalizePhoneNumber(String raw) {
    final String digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
    return digits;
  }

  /// Construit l'URI de conversation WhatsApp avec message prérempli.
  static Uri buildChatUri({required String phone, required String message}) {
    return Uri.https('wa.me', '/$phone', <String, dynamic>{'text': message});
  }

  /// Ouvre une conversation WhatsApp avec [phone] et [message].
  ///
  /// Renvoie un résultat typé — ne lève jamais d'exception vers l'interface.
  Future<WhatsAppOpenResult> openChat({
    required String phone,
    required String message,
  }) async {
    final String normalized = normalizePhoneNumber(phone);
    if (normalized.length < 8) {
      return const WhatsAppOpenResult.failure(
        'Le numéro WhatsApp de ce vendeur est invalide ou incomplet.',
      );
    }

    final Uri uri = buildChatUri(phone: normalized, message: message);

    try {
      final bool launched = await _launch(uri, LaunchMode.externalApplication);
      if (launched) return const WhatsAppOpenResult.success();
      return const WhatsAppOpenResult.failure(
        "Impossible d'ouvrir WhatsApp. Vérifiez qu'il est installé sur cet "
        'appareil, ou copiez le message ci-dessous.',
      );
    } catch (_) {
      return const WhatsAppOpenResult.failure(
        "Impossible d'ouvrir WhatsApp sur cet appareil. Vous pouvez copier "
        'le message ci-dessous.',
      );
    }
  }

  /// Message de prise de contact d'un client pour un produit précis.
  static String productInquiryMessage(ProductModel product) {
    final String price = MoneyFormatter.format(product.price, product.currency);
    return 'Bonjour ${product.sellerName}, je suis intéressé(e) par votre '
        'produit « ${product.name} » affiché à $price sur SokoMarket. '
        'Est-il toujours disponible ?';
  }
}

// ---------------------------------------------------------------------------
// Récapitulatif de commande (phase « WhatsApp »)
// ---------------------------------------------------------------------------

extension WhatsAppOrderMessages on WhatsAppService {
  /// Construit le message récapitulatif « NOUVELLE COMMANDE » envoyé au
  /// vendeur après confirmation (produits, montants, livraison, paiement).
  static String orderSummary(OrderModel order) {
    final StringBuffer buffer = StringBuffer()
      ..writeln('🛍️ NOUVELLE COMMANDE — SokoMarket')
      ..writeln()
      ..writeln('📋 Commande : #${order.orderId.substring(0, 8).toUpperCase()}')
      ..writeln('👤 Client : ${order.clientName}')
      ..writeln('📞 Téléphone : ${order.clientPhone.isNotEmpty ? order.clientPhone : '—'}')
      ..writeln()
      ..writeln('🧺 Produits :');

    for (final OrderItemModel item in order.items) {
      buffer.writeln(
        '• ${item.productName} × ${item.quantity} — '
        '${MoneyFormatter.format(item.lineTotal, item.currency)}',
      );
    }

    buffer
      ..writeln()
      ..writeln('Sous-total : ${MoneyFormatter.format(order.subtotal, order.currency)}')
      ..writeln(
        order.isStorePickup
            ? 'Retrait boutique : ${MoneyFormatter.format(0, order.currency)}'
            : 'Livraison : ${MoneyFormatter.format(order.deliveryFee, order.currency)}',
      )
      ..writeln('💰 Total : ${MoneyFormatter.format(order.total, order.currency)}')
      ..writeln()
      ..writeln(
        order.isStorePickup
            ? '🏪 Mode : Retrait en boutique'
            : '🚚 Mode : Livraison à domicile\n📍 ${order.delivery.locationLabel}',
      )
      ..writeln(
        '💳 Paiement : ${order.payment.method.label} (${order.payment.status.label})',
      )
      ..writeln('🔑 Réf. : ${order.payment.transactionReference}');

    return buffer.toString();
  }

  /// Ouvre WhatsApp sur le numéro du vendeur avec le récapitulatif complet.
  Future<WhatsAppOpenResult> sendOrderSummary(OrderModel order) {
    return openChat(
      phone: order.sellerWhatsappNumber,
      message: WhatsAppOrderMessages.orderSummary(order),
    );
  }
}