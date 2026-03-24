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

  @override
  Widget build(BuildContext context) {
    final dynamic args = ModalRoute.of(context)?.settings.arguments;
    double screenWidth = MediaQuery.of(context).size.width;
    bool isWeb = screenWidth > 600;

    if (args == null || args is! Map) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    final Map p = args;
    final primaryColor = Colors.pink.shade300;
    final String productId = p['id'].toString();

    return Scaffold(
      resizeToAvoidBottomInset: false, // 🔥 FIX QUAN TRỌNG
      backgroundColor: Colors.white,
      body: Stack(
        children: [
          // ================= CONTENT =================
          SingleChildScrollView(
            child: Column(
              children: [
                // 🔥 IMAGE
                Container(
                  height: 380,
                  width: double.infinity,
                  color: Colors.pink.shade50.withOpacity(0.5),
                  child: Hero(
                    tag: productId,
                    child: Image.network(
                      p['image'] ?? '',
                      fit: BoxFit.cover, // 🔥 ẢNH FULL ĐẸP
                    ),
                  ),
                ),

                // 🔥 CONTENT
                Transform.translate(
                  offset: const Offset(0, -25),
                  child: Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(22),
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(35),
                        topRight: Radius.circular(35),
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // NAME + PRICE
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Expanded(
                              child: Text(
                                p['name'] ?? '',
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Text(
                              formatCurrency((p['price'] ?? 0).toDouble()),
                              style: TextStyle(
                                fontSize: 20,
                                color: primaryColor,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 12),

                        // ⭐ RATING
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 4,
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
                                    size: 16,
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
                            const SizedBox(width: 12),
                            Text(
                              p['category']?.toString().toUpperCase() ??
                                  "PANCAKE",
                              style: const TextStyle(
                                color: Colors.grey,
                                letterSpacing: 1.2,
                                fontSize: 11,
                              ),
                            ),
                          ],
                        ),

                        const SizedBox(height: 20),

                        const Text(
                          "Description",
                          style: TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.bold,
                          ),
                        ),

                        const SizedBox(height: 8),

                        Text(
                          p['description'] ??
                              "Món bánh thơm ngon dành cho bạn.",
                          style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: 15,
                            height: 1.6,
                          ),
                        ),

                        const SizedBox(height: 80), // 🔥 CHỈ ĐỂ NHẸ
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // 🔙 BACK BUTTON
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

          // ================= BOTTOM BAR =================
          
        ],
      ),bottomNavigationBar: Container(
    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
    decoration: BoxDecoration(
      color: Colors.white,
      boxShadow: [
        BoxShadow(
          color: Colors.black.withOpacity(0.05),
          blurRadius: 10,
          offset: const Offset(0, -5),
        ),
      ],
    ),
    child: SafeArea( // 🛡️ Giúp nút không bị vạch ngang iPhone đè lên
      child: Row(
        children: [
          // ❤️ NÚT TRÁI TIM (Giữ nguyên logic của bạn)
          Consumer<FavoriteProvider>(
            builder: (context, favProvider, child) {
              final bool isFav = favProvider.isFavorite(productId);
              return GestureDetector(
                onTap: () => favProvider.toggleFavorite(
                  Map<String, dynamic>.from(p),
                ),
                child: Container(
                  height: 55,
                  width: 55,
                  decoration: BoxDecoration(
                    color: isFav ? Colors.red.shade50 : Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(
                    isFav ? Icons.favorite : Icons.favorite_border,
                    color: isFav ? Colors.red : primaryColor,
                    size: 26,
                  ),
                ),
              );
            },
          ),

          const SizedBox(width: 15),

          // 🛒 NÚT ADD TO CART
          Expanded(
            child: SizedBox(
              height: 55,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: primaryColor,
                  elevation: 0, // Nút phẳng cho sang
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
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
);
    
  }
}
