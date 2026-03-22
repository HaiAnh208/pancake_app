import 'package:flutter/material.dart';

class FavoriteProvider with ChangeNotifier {
  // Lưu danh sách ID các món đã thả tim
  final List<Map<String, dynamic>> _favoriteItems = [];

  List<Map<String, dynamic>> get favoriteItems => _favoriteItems;

  // Kiểm tra xem món này đã thích chưa
  bool isFavorite(String productId) {
    return _favoriteItems.any((item) => item['id'] == productId);
  }

  // Bấm tim: Nếu có rồi thì bỏ, chưa có thì thêm
  void toggleFavorite(Map<String, dynamic> product) {
    final index = _favoriteItems.indexWhere(
      (item) => item['id'] == product['id'],
    );
    if (index >= 0) {
      _favoriteItems.removeAt(index);
    } else {
      _favoriteItems.add(product);
    }
    notifyListeners(); // Thông báo cho tất cả màn hình cập nhật lại màu tim
  }
}
