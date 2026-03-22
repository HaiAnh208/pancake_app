import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/favorite_provider.dart';

class FavoriteScreen extends StatelessWidget {
  // 🔥 Phiên bản mới này chỉ có super.key, không đòi hỏi required arguments nữa!
  const FavoriteScreen({super.key});

  // Hàm định dạng tiền VNĐ
  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "en_US");
    return "${format.format(amount).replaceAll(',', '.')}đ";
  }

  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.pink.shade300;

    return Scaffold(
      backgroundColor: Colors.grey.shade50,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        iconTheme: const IconThemeData(color: Colors.black), 
        title: const Text(
          "My Favorites ❤️",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
      ),
      
      // Dùng Consumer để lắng nghe sự thay đổi từ Kho Yêu Thích
      body: Consumer<FavoriteProvider>(
        builder: (context, favProvider, child) {
          final items = favProvider.favoriteItems;

          if (items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_border, size: 80, color: Colors.grey.shade300),
                  const SizedBox(height: 16),
                  Text(
                    "You haven't liked any of the cakes yet!\n Go outside and choose one! 🥞",
                    textAlign: TextAlign.center,
                    style: TextStyle(color: Colors.grey.shade600, fontSize: 16),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: items.length,
            itemBuilder: (context, index) {
              final p = items[index];

              return Card(
                elevation: 0,
                margin: const EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(color: Colors.pink.shade50, width: 2),
                ),
                child: InkWell(
                  borderRadius: BorderRadius.circular(16),
                  onTap: () {
                    Navigator.pushNamed(context, '/ProductDetail', arguments: p);
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Row(
                      children: [
                        // 🖼️ ẢNH BÁNH
                        ClipRRect(
                          borderRadius: BorderRadius.circular(10),
                          child: Image.network(
                            p['image'],
                            width: 80,
                            height: 80,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) =>
                                Container(width: 80, height: 80, color: Colors.grey.shade200, child: const Icon(Icons.image)),
                          ),
                        ),
                        const SizedBox(width: 16),

                        // 📝 THÔNG TIN BÁNH
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                p['name'],
                                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                              const SizedBox(height: 8),
                              Text(
                                formatCurrency((p['price'] ?? 0).toDouble()),
                                style: TextStyle(color: primaryColor, fontWeight: FontWeight.bold, fontSize: 14),
                              ),
                            ],
                          ),
                        ),

                        // 🗑️ NÚT XÓA KHỎI YÊU THÍCH
                        IconButton(
                          icon: const Icon(Icons.favorite, color: Colors.red),
                          onPressed: () {
                            favProvider.toggleFavorite(p);
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text("Unfavorite 💔"),
                                duration: Duration(seconds: 1),
                              ),
                            );
                          },
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}