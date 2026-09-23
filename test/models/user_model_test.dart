import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;
import 'package:flutter_test/flutter_test.dart';

import 'package:taillorbook/core/constants/app_enums.dart';
import 'package:taillorbook/models/user_model.dart';

void main() {
  group('UserModel sérialisation', () {
    test('toMap → fromMap conserve toutes les données (vendeur)', () {
      final DateTime createdAt = DateTime(2026, 1, 15, 10, 30);
      final UserModel seller = UserModel(
        id: 'user-1',
        name: 'Niyonkuru Boutique',
        email: 'seller@soko.bi',
        phone: '+25779000001',
        role: UserRole.seller,
        whatsappNumber: '+25779000001',
        createdAt: createdAt,
      );

      final UserModel decoded = UserModel.fromMap(seller.toMap(), id: 'user-1');

      expect(decoded.id, 'user-1');
      expect(decoded.name, 'Niyonkuru Boutique');
      expect(decoded.email, 'seller@soko.bi');
      expect(decoded.phone, '+25779000001');
      expect(decoded.role, UserRole.seller);
      expect(decoded.whatsappNumber, '+25779000001');
      expect(decoded.hasWhatsApp, isTrue);
      expect(decoded.createdAt, createdAt);
    });

    test('le rôle client est le repli par défaut', () {
      final UserModel decoded = UserModel.fromMap(<String, dynamic>{
        'name': 'Client Test',
        'role': 'inconnu',
      }, id: 'user-2');

      expect(decoded.role, UserRole.client);
      expect(decoded.hasWhatsApp, isFalse);
    });

    test('createdAt accepte un Timestamp Firestore', () {
      final DateTime date = DateTime.utc(2026, 3, 1);
      final Map<String, dynamic> map = <String, dynamic>{
        'name': 'A',
        'createdAt': Timestamp.fromDate(date),
      };

      expect(UserModel.fromMap(map, id: 'x').createdAt, date);
    });

    test('copyWith ne change que le rôle', () {
      const UserModel client = UserModel(
        id: 'u',
        name: 'A',
        email: 'a@b.c',
        phone: '+25779000000',
      );

      final UserModel upgraded = client.copyWith(
        role: UserRole.seller,
        whatsappNumber: '+25779000000',
      );

      expect(upgraded.role, UserRole.seller);
      expect(upgraded.name, 'A');
      expect(upgraded.email, 'a@b.c');
      expect(upgraded.hasWhatsApp, isTrue);
    });
  });

  group('UserRole.fromName', () {
    test('reconnaît les rôles connus et replie sinon', () {
      expect(UserRole.fromName('seller'), UserRole.seller);
      expect(UserRole.fromName('client'), UserRole.client);
      expect(UserRole.fromName(null), UserRole.client);
      expect(UserRole.fromName('nimporte-quoi'), UserRole.client);
    });
  });
}
