import 'package:cloud_firestore/cloud_firestore.dart';

class Product {
  final String id;
  final String name;
  final double price;
  final String image;
  final String category;
  final String description;
  final double rating;

  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.image,
    required this.category,
    required this.description,
    required this.rating,
  });

  // Hàm này để chuyển dữ liệu từ Firebase thành Object trong Flutter
  factory Product.fromFirestore(Map<String, dynamic> data, String id) {
    return Product(
      id: id,
      name: data['name'] ?? '',
      // Cách xử lý số (price & rating) an toàn nhất để không bị crash
      price: (data['price'] ?? 0).toDouble(),
      image: data['image'] ?? '',
      category: data['category'] ?? '',
      description: data['description'] ?? '',
      rating: (data['rating'] ?? 0).toDouble(),
    );
  }
}

// Tách hàm lấy dữ liệu ra ngoài hoặc để trong Service/Provider
// Nhưng để khớp với HomeScreen của bạn, mình để ở đây hoặc bạn copy vào HomeScreen nhé
Stream<List<Product>> getProductsStream() {
  return FirebaseFirestore.instance.collection('products').snapshots().map((
    snapshot,
  ) {
    return snapshot.docs.map((doc) {
      return Product.fromFirestore(doc.data(), doc.id);
    }).toList();
  });
}
