import 'package:cloud_firestore/cloud_firestore.dart' show FirebaseException, QuerySnapshot, QueryDocumentSnapshot, DocumentSnapshot;

import '../config/firebase/firebase_bootstrap.dart';
import '../core/constants/firestore_collections.dart';
import '../core/errors/app_exceptions.dart';
import '../models/order_model.dart';
import '../services/firestore_service.dart';

/// Accès aux commandes (`orders`).
///
/// v1 : une commande concerne un seul vendeur (champ `sellerId` dénormalisé)
/// — une égalité simple suffit aux requêtes client ET vendeur, sans index
/// composite, et correspond exactement au modèle de sécurité Firestore
/// (le vendeur ne lit que les commandes « à lui » ; phase Sécurité).
class OrderRepository {
  OrderRepository(this._service);

  final FirestoreService _service;

  /// Enregistre une commande confirmée (document id = [OrderModel.orderId]).
  Future<void> createOrder(OrderModel order) async {
    try {
      await _service
          .collection(FirestoreCollections.orders)
          .doc(order.orderId)
          .set(order.toMap());
    } on FirebaseException catch (error) {
      throw FirestoreException( error.code);
    }
  }

  /// Écoute en temps réel de l'historique des commandes d'un client
  /// (plus récentes d'abord).
  Stream<List<OrderModel>> watchClientOrders(String clientId) {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<OrderModel>>.value(const <OrderModel>[]);
    }
    return _service
        .collection(FirestoreCollections.orders)
        .where('clientId', isEqualTo: clientId)
        .snapshots()
        .map<List<OrderModel>>(
      (QuerySnapshot<Map<String, dynamic>> snapshot) => _sorted(snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              OrderModel.fromMap(doc.data(), id: doc.id))
          .toList()),
    );
  }

  /// Écoute en temps réel des commandes d'un vendeur.
  Stream<List<OrderModel>> watchSellerOrders(String sellerId) {
    if (!FirebaseBootstrap.isReady) {
      return Stream<List<OrderModel>>.value(const <OrderModel>[]);
    }
    return _service
        .collection(FirestoreCollections.orders)
        .where('sellerId', isEqualTo: sellerId)
        .snapshots()
        .map<List<OrderModel>>(
      (QuerySnapshot<Map<String, dynamic>> snapshot) => _sorted(snapshot.docs
          .map((QueryDocumentSnapshot<Map<String, dynamic>> doc) =>
              OrderModel.fromMap(doc.data(), id: doc.id))
          .toList()),
    );
  }

  /// Écoute en temps réel d'une commande (détails + suivi de statut).
  /// Émet `null` si le document n'existe pas.
  Stream<OrderModel?> watchOrder(String orderId) {
    if (!FirebaseBootstrap.isReady) {
      return Stream<OrderModel?>.value(null);
    }
    return _service
        .document('${FirestoreCollections.orders}/$orderId')
        .snapshots()
        .map<OrderModel?>(
      (DocumentSnapshot<Map<String, dynamic>> snapshot) =>
          snapshot.exists && snapshot.data() != null
              ? OrderModel.fromMap(snapshot.data()!, id: snapshot.id)
              : null,
    );
  }

  List<OrderModel> _sorted(List<OrderModel> orders) {
    orders.sort((OrderModel a, OrderModel b) =>
        (b.createdAt ?? DateTime(1970)).compareTo(a.createdAt ?? DateTime(1970)));
    return orders;
  }
}