import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/cart_provider.dart';
import '../providers/favorite_provider.dart';
import 'package:intl/intl.dart';

class ProductDetailScreen extends StatefulWidget {
  const ProductDetailScreen({super.key});

  @override
  State<ProductDetailScreen> createState() => _ProductDetailScreenState();
}

class _ProductDetailScreenState extends State<ProductDetailScreen> {
  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "en_US");
    return "${format.format(amount).replaceAll(',', '.')}đ";
  }
  Widget _buildActionButtons(Color primaryColor) {
    return Padding(
      padding: const EdgeInsets.only(
        left: 20,
        right: 20,
        bottom: 30,
      ), // Bottom 30 để không bị dính sát mép màn hình
      child: Row(
        children: [
          // Nút Trái tim (Yêu thích)
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.grey.shade300),
              borderRadius: BorderRadius.circular(15),
            ),
            child: const Icon(
              Icons.favorite_border_rounded,
              color: Colors.pink,
            ),
          ),
          const SizedBox(width: 15),
          // Nút Add to Cart (To và Dài)
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(
                  // <--- PHẢI CÓ CÁI NÀY BỌC NGOÀI
                  borderRadius: BorderRadius.circular(15),
                ),
              ),
              onPressed: () => print("Added to cart!"),
              child: const Text(
                "Add to Cart", // Tiếng Anh cho "pro" luôn nhé!
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // 🛡️ PHÒNG THỦ CHỐNG MÀN HÌNH :
    final dynamic args = ModalRoute.of(context)?.settings.arguments;

    if (args == null || args is! Map) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Map p = args;
    final primaryColor = Colors.pink.shade300;
    final String productId = p['id'].toString();

    return Scaffold(
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                // 1. HÌNH ẢNH
                // 1. HÌNH ẢNH (Cái ảnh Hero to ở trên cùng)
                Container(
                  height: 400, // Khung ảnh to
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.pink.shade50.withOpacity(0.5),
                  ),
                  child: Hero(
                    tag: productId,
                    child: Image.network(
                      p['image'] ?? '',
                      // 🛠️ THAY cover BẰNG contain:
                      fit: BoxFit.contain,
                    ),
                  ),
                ),

                // 2. NỘI DUNG
                Transform.translate(
                  offset: const Offset(0, -30),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(30),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(40),
                        topRight: Radius.circular(40),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 26,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              formatCurrency((p['price'] ?? 0).toDouble()),
                              style: TextStyle(
                                fontSize: 22,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 15),
                        // Rating & Category
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 5,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.amber.shade50,
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Row(
                                children: [
                                  const Icon(
                                    Icons.star,
                                    color: Colors.amber,
                                    size: 18,
                                  ),
                                  Text(
                                    " ${p['rating'] ?? 4.5}",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 15),
                            Text(
                              p['category']?.toString().toUpperCase() ??
                                  "PANCAKE",
                              style: const TextStyle(
                                color: Colors.grey,
                                letterSpacing: 1.2,
                                fontSize: 12,
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 30),
                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 18,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          p['description'] ??
                              "Món bánh thơm ngon dành cho bạn.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 16,
                            height: 1.6,
                          ),
                        ),
                        const SizedBox(height: 120),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
const Spacer(),
          // 3. NÚT BACK
          Positioned(
            top: 50,
            left: 20,
            child: CircleAvatar(
              backgroundColor: Colors.white,
              child: IconButton(
                icon: const Icon(
                  Icons.arrow_back_ios_new,
                  color: Colors.black,
                  size: 18,
                ),
                onPressed: () => Navigator.pop(context),
              ),
            ),
          ),

          // 4. THANH ĐIỀU KHIỂN (TIM + MUA)
          Positioned(
            bottom: 0,
            left: 0,
            right: 0,
            child: Container(
              padding: const EdgeInsets.all(20),
              color: Colors.white,
              child: Row(
                children: [
                  // ❤️ NÚT YÊU THÍCH (Dùng Consumer để lấy dữ liệu p an toàn)
                  Consumer<FavoriteProvider>(
                    builder: (context, favProvider, child) {
                      final bool isFav = favProvider.isFavorite(productId);
                      return GestureDetector(
                        onTap: () => favProvider.toggleFavorite(
                          Map<String, dynamic>.from(p),
                        ),
                        child: Container(
                          height: 60,
                          width: 60,
                          decoration: BoxDecoration(
                            border: Border.all(
                              color: isFav
                                  ? Colors.red.shade100
                                  : Colors.pink.shade100,
                            ),
                            borderRadius: BorderRadius.circular(20),
                          ),
                          child: Icon(
                            isFav ? Icons.favorite : Icons.favorite_border,
                            color: isFav ? Colors.red : primaryColor,
                            size: 28,
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(width: 20),
                  // 🛒 NÚT MUA
                  Expanded(
                    child: SizedBox(
                      height: 60,
                      child: ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(20),
                          ),
                          elevation: 0,
                        ),
                        onPressed: () {
                          context.read<CartProvider>().addItem(
                            productId,
                            p['name'],
                            (p['price'] ?? 0).toDouble(),
                            p['image'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text("Added to cart! 🥞")),
                          );
                        },
                        child: const Text(
                          "ADD TO CART",
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
