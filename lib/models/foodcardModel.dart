class FoodCard {
  final int id;
  final String name;
  final String imageUrl;
  final int price;
  final double rating;
  final String description;
  final String flavor;
  final String category;

  FoodCard({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.rating,
    required this.description,
    required this.flavor,
    required this.category,
  });

  // Convert a FoodCard object to a Map (useful for JSON encoding or database storage)
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'imageUrl': imageUrl,
      'price': price,
      'rating': rating,
      'description': description,
      'flavor': flavor,
      'category': category,
    };
  }

  // Create a FoodCard object from a Map (useful for JSON decoding or database retrieval)
  factory FoodCard.fromMap(Map<String, dynamic> map) {
    return FoodCard(
      id: map['id'] as int,
      name: map['name'] as String,
      imageUrl: map['imageUrl'] as String,
      price: map['price'],
      rating: map['rating'],
      description: map['description'] as String,
      flavor: map['flavor'] as String,
      category: map['category'] ?? '',
    );
  }
}
