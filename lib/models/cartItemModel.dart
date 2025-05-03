import 'package:foodorderapplication/models/foodcardModel.dart';

class CartItem {
  final FoodCard food;
  int quantity;

  CartItem({required this.food, this.quantity = 1});

  // Calculate total price
  int get totalPrice => food.price * quantity;

  // Convert to Map for saving to storage or database
  Map<String, dynamic> toMap() {
    return {'food': food.toMap(), 'quantity': quantity};
  }

  // Create from Map
  factory CartItem.fromMap(Map<String, dynamic> map) {
    return CartItem(
      food: FoodCard.fromMap(map['food']),
      quantity: map['quantity'] ?? 1,
    );
  }
}
