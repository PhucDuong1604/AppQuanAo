class Product {
  final String id;
  final String name;
  final String imageUrl;
  final String category;
  final double price;
  final double rating;
  final int reviewCount;
  final String description;
  final double? oldPrice; 
  final List<String> sizes; 
  final List<String> colors; 

  Product({
    required this.id,
    required this.name,
    required this.imageUrl,
    required this.price,
    required this.category,
    this.rating = 0.0,
    this.reviewCount = 0,
    this.description = '',
    this.oldPrice,
    this.sizes = const [],
    this.colors = const [],
  });
}