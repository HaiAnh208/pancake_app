import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../models/product.dart';

class CartProvider with ChangeNotifier {
  void updateQuantity(String productId, bool isIncrement) {
    final index = _items.indexWhere((item) => item.id == productId);
    if (index >= 0) {
      if (isIncrement) {
        // Vì Product của bạn có thể không có trường quantity,
        // nếu muốn làm chuẩn bạn nên thêm trường 'quantity' vào model Product.
        // Tạm thời ở đây mình sẽ dùng logic thêm mới 1 cái y hệt nếu tăng
        _items.add(_items[index]);
      } else {
        _items.removeAt(index);
      }
      notifyListeners();
    }
  }
  // Dùng List để chứa các món ăn
  final List<Product> _items = [];

  List<Product> get items => [..._items];

  // 1. Sửa tên thành 'itemCount' để khớp với HomeScreen
  int get itemCount => _items.length;

  double get totalAmount {
    double total = 0.0;
    for (var item in _items) {
      total += item.price;
    }
    return total;
  }

  // 2. Sửa hàm addItem để nhận 4 tham số rời rạc
  void addItem(String id, String name, double price, String image) {
    // 🔥 PHẢI THÊM category, description, rating vào đây mới hết lỗi đỏ
    final newProduct = Product(
      id: id,
      name: name,
      price: price,
      image: image,
      category: "Pancake", // Thêm giá trị mặc định
      description: "Delicious", // Thêm giá trị mặc định
      rating: 5.0, // Thêm giá trị mặc định
    );

    _items.add(newProduct);
    notifyListeners();
  }

  void clear() {
    _items.clear();
    notifyListeners();
  }

  void removeItem(int index) {
    if (index >= 0 && index < _items.length) {
      _items.removeAt(index);
      notifyListeners();
    }
  }

  Future<void> checkout() async {
    if (_items.isEmpty) return;
    final user = FirebaseAuth.instance.currentUser;

    try {
      final orderData = {
        'userId': user?.uid ?? 'anonymous',
        'items': _items
            .map(
              (p) => {
                'id': p.id,
                'name': p.name,
                'price': p.price,
                'image': p.image,
              },
            )
            .toList(),
        'totalAmount': totalAmount,
        'timestamp': FieldValue.serverTimestamp(),
        'status': 'Pending',
      };

      await FirebaseFirestore.instance.collection('orders').add(orderData);
      clear();
    } catch (error) {
      print("Error at Provider: $error");
      rethrow;
    }
  }
}
