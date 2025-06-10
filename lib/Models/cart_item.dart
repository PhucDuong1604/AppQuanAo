// appquanao/models/cart_item.dart
import 'package:flutter/material.dart'; // Make sure this is imported if you're using Color
import 'package:appquanao/models/product.dart'; // Assuming Product is defined here

class CartItem {
  final Product product;
  int quantity;
  final String selectedSize;
  final Color selectedColor;
  bool isSelected; // <--- Add this line

  CartItem({
    required this.product,
    required this.quantity,
    required this.selectedSize,
    required this.selectedColor,
    this.isSelected = true, // Default to true when added to cart
  });

  double get totalPrice => product.price * quantity;
}