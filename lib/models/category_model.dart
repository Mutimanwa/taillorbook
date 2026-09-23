import 'package:cloud_firestore/cloud_firestore.dart';

import '../core/utils/timestamp_utils.dart';

/// Catégorie de la marketplace (`categories/{categoryId}`).
class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.imageUrl,
    this.sortOrder = 0,
    this.isActive = true,
    this.createdAt,
  });

  final String id;
  final String name;

  /// Identifiant textuel stable (utile pour les URLs et la recherche).
  final String slug;

  /// Image d'illustration (URL publique — ImgBB ou CDN de démonstration).
  final String imageUrl;
  final int sortOrder;
  final bool isActive;
  final DateTime? createdAt;

  CategoryModel copyWith({
    String? id,
    String? name,
    String? slug,
    String? imageUrl,
    int? sortOrder,
    bool? isActive,
    DateTime? createdAt,
  }) {
    return CategoryModel(
      id: id ?? this.id,
      name: name ?? this.name,
      slug: slug ?? this.slug,
      imageUrl: imageUrl ?? this.imageUrl,
      sortOrder: sortOrder ?? this.sortOrder,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'name': name,
      'slug': slug,
      'imageUrl': imageUrl,
      'sortOrder': sortOrder,
      'isActive': isActive,
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  factory CategoryModel.fromMap(Map<String, dynamic> map, {required String id}) {
    return CategoryModel(
      id: id,
      name: map['name'] as String? ?? '',
      slug: map['slug'] as String? ?? '',
      imageUrl: map['imageUrl'] as String? ?? '',
      sortOrder: (map['sortOrder'] as num?)?.toInt() ?? 0,
      isActive: map['isActive'] as bool? ?? true,
      createdAt: TimestampUtils.toDateTime(map['createdAt']),
    );
  }
}
