import 'package:firebase_auth/firebase_auth.dart' show User;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:taillorbook/core/constants/app_enums.dart';

import '../../core/errors/app_exceptions.dart';
import '../../models/order_model.dart';
import '../../repositories/order_repository.dart';
import '../auth/auth_providers.dart'
    show currentUserProvider, firestoreServiceProvider, userProfileProvider;
import '../seller/seller_providers.dart' show currentSellerIdProvider;

// Réexport du dépôt (découvre les écrans de l'implémentation).
export '../../repositories/order_repository.dart' show OrderRepository;

/// Dépôt des commandes.
final Provider<OrderRepository> orderRepositoryProvider =
    Provider<OrderRepository>(
        (Ref ref) => OrderRepository(ref.watch(firestoreServiceProvider)));

/// Historique des commandes du client connecté (temps réel).
/// Émet `null` si visiteur.
final StreamProvider<List<OrderModel>?> clientOrdersProvider =
    StreamProvider<List<OrderModel>?>((Ref ref) {
  final User? user = ref.watch(currentUserProvider);
  if (user == null) return Stream<List<OrderModel>?>.value(null);
  return ref.watch(orderRepositoryProvider).watchClientOrders(user.uid);
});

/// Commande par identifiant (temps réel, auto-disposé).
final AutoDisposeStreamProviderFamily<OrderModel?, String> orderByIdProvider =
    StreamProvider.autoDispose.family<OrderModel?, String>(
        (Ref ref, String orderId) =>
            ref.watch(orderRepositoryProvider).watchOrder(orderId));

/// Commandes reçues par le vendeur connecté (temps réel).
/// Émet `null` hors contexte vendeur.
final StreamProvider<List<OrderModel>?> sellerOrdersProvider =
    StreamProvider<List<OrderModel>?>((Ref ref) {
  final String? sellerId = ref.watch(currentSellerIdProvider);
  if (sellerId == null) return Stream<List<OrderModel>?>.value(null);
  return ref.watch(orderRepositoryProvider).watchSellerOrders(sellerId);
});

/// Résultat d'une action vendeur sur une commande.
class OrderActionResult {
  const OrderActionResult({required this.success, this.error});

  final bool success;
  final String? error;
}

/// Change le statut d'une commande (espace vendeur).
///
/// Renvoie un [OrderActionResult] : `success` true si Firestore a accepté
/// l'écriture (champs orderStatus + updatedAt uniquement), sinon un message
/// d'erreur lisible (règles refusées, Firebase absent…).
Future<OrderActionResult> updateOrderStatus(
  WidgetRef ref, {
  required String orderId,
  required OrderStatus status,
}) async {
  try {
    await ref
        .read(orderRepositoryProvider)
        .updateOrderStatus(orderId: orderId, status: status);
    return const OrderActionResult(success: true);
  } on AppException catch (error) {
    return OrderActionResult(success: false, error: error.message);
  } catch (_) {
    return const OrderActionResult(
      success: false,
      error:
          "Impossible de changer le statut (base de données). Réessayez.",
    );
  }
}

/// Persistance d'une commande confirmée.
///
/// Renvoie `null` en cas de succès, sinon un message d'erreur lisible.
/// (Utilisé par le checkout après un paiement réussi.)
Future<String?> persistConfirmedOrder(Ref ref, OrderModel order) async {
  try {
    await ref.read(orderRepositoryProvider).createOrder(order);
    return null;
  } on AppException catch (error) {
    return error.message;
  }
}