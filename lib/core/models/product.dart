class Product {
  final String id;
  final String name;
  final String
      category; // 'Regular Pads', 'Organic Pads', 'Tampons', 'Menstrual Cups'
  final double rating;
  final int reviews;
  final double price;
  final String description;
  final List<String> features;
  final String buyUrl;
  final String imageUrl;
  final bool active;

  Product({
    required this.id,
    required this.name,
    required this.category,
    required this.rating,
    required this.reviews,
    required this.price,
    required this.description,
    required this.features,
    required this.buyUrl,
    this.imageUrl = '',
    this.active = true,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'category': category,
      'rating': rating,
      'reviews': reviews,
      'price': price,
      'description': description,
      'features': features,
      'buyUrl': buyUrl,
      'imageUrl': imageUrl,
      'active': active,
    };
  }

  factory Product.fromMap(Map<String, dynamic> map) {
    return Product(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      category: map['category'] ?? '',
      rating: map['rating']?.toDouble() ?? 0.0,
      reviews: map['reviews']?.toInt() ?? 0,
      price: map['price']?.toDouble() ?? 0.0,
      description: map['description'] ?? '',
      features: List<String>.from(map['features'] ?? []),
      buyUrl: map['buyUrl'] ?? '',
      imageUrl: map['imageUrl'] ?? '',
      active: map['active'] ?? true,
    );
  }
}
