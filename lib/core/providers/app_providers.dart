import 'package:flutter_riverpod/flutter_riverpod.dart';

// Mock Product Model
class Product {
  final String id;
  final String name;
  final String collection;
  final String imageUrl;
  final String description;
  final bool isFavorite;

  Product({
    required this.id,
    required this.name,
    required this.collection,
    required this.imageUrl,
    required this.description,
    this.isFavorite = false,
  });

  Product copyWith({bool? isFavorite}) {
    return Product(
      id: id,
      name: name,
      collection: collection,
      imageUrl: imageUrl,
      description: description,
      isFavorite: isFavorite ?? this.isFavorite,
    );
  }
}

// Products Provider
final productsProvider = StateProvider<List<Product>>((ref) {
  return [
    Product(
      id: '1',
      name: 'Robe de Soirée Étoilée',
      collection: 'Été 2024',
      imageUrl:
          'https://images.pexels.com/photos/6347547/pexels-photo-6347547.jpeg',
      description: 'Une création en soie sauvage avec cristaux brodés main.',
    ),
    Product(
      id: '2',
      name: 'Veste Tailleur Sculptée',
      collection: 'Hiver 2024',
      imageUrl:
          'https://images.pexels.com/photos/6347548/pexels-photo-6347548.jpeg',
      description: 'Laines nobles et coupe architecturale.',
    ),
  ];
});

// Favorites Provider
final favoriteProductsProvider = Provider<List<Product>>((ref) {
  final products = ref.watch(productsProvider);
  return products.where((p) => p.isFavorite).toList();
});
