import 'package:cloud_firestore/cloud_firestore.dart' show Timestamp;

import '../core/constants/app_enums.dart';

/// Profil utilisateur stocké dans Firestore (`users/{uid}`).
///
/// Le document Firestore ne contient pas l'identifiant : celui-ci correspond
/// à l'identifiant du document. Le rôle détermine les fonctionnalités
/// accessibles (client ou vendeur).
class UserModel {
  const UserModel({
    required this.id,
    required this.name,
    required this.email,
    required this.phone,
    this.role = UserRole.client,
    this.whatsappNumber = '',
    this.profileImageUrl,
    this.createdAt,
  });

  final String id;
  final String name;
  final String email;
  final String phone;
  final UserRole role;

  /// Numéro WhatsApp du vendeur (requis à l'inscription vendeur).
  final String whatsappNumber;
  final String? profileImageUrl;
  final DateTime? createdAt;

  /// `true` si le numéro WhatsApp du vendeur est renseigné.
  bool get hasWhatsApp => whatsappNumber.trim().isNotEmpty;

  UserModel copyWith({
    String? id,
    String? name,
    String? email,
    String? phone,
    UserRole? role,
    String? whatsappNumber,
    String? profileImageUrl,
    DateTime? createdAt,
  }) {
    return UserModel(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      role: role ?? this.role,
      whatsappNumber: whatsappNumber ?? this.whatsappNumber,
      profileImageUrl: profileImageUrl ?? this.profileImageUrl,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  /// Sérialisation vers Firestore. Si [createdAt] est absent, le dépôt le
  /// remplace par un timestamp serveur (`FieldValue.serverTimestamp()`).
  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'email': email,
      'phone': phone,
      'role': role.name,
      'whatsappNumber': whatsappNumber,
      if (profileImageUrl != null) 'profileImageUrl': profileImageUrl,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory UserModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return UserModel(
      id: id,
      name: map['name'] as String? ?? '',
      email: map['email'] as String? ?? '',
      phone: map['phone'] as String? ?? '',
      role: UserRole.fromName(map['role'] as String?),
      whatsappNumber: map['whatsappNumber'] as String? ?? '',
      profileImageUrl: map['profileImageUrl'] as String?,
      createdAt: _toDateTime(map['createdAt']),
    );
  }

  static DateTime? _toDateTime(Object? value) {
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    if (value is String) return DateTime.tryParse(value);
    return null;
  }
}
