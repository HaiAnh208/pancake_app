import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../providers/cart_provider.dart';

class CartScreen extends StatelessWidget {
  const CartScreen({super.key});

  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "en_US");
    return "${format.format(amount).replaceAll(',', '.')}đ";
  }

  @override
  Widget build(BuildContext context) {
    final cart = Provider.of<CartProvider>(context);
    final primaryColor = Colors.pink.shade300;
    final backgroundColor = const Color(0xFFFFF0F5);

    // Logic để nhóm các sản phẩm trùng nhau và đếm số lượng
    Map<String, int> itemCounts = {};
    for (var item in cart.items) {
      itemCounts[item.id] = (itemCounts[item.id] ?? 0) + 1;
    }

    // Lấy danh sách sản phẩm duy nhất để hiển thị
    final uniqueItems = cart.items.fold<List<dynamic>>([], (list, item) {
      if (!list.any((element) => element.id == item.id)) {
        list.add(item);
      }
      return list;
    });

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          "My Cart",
          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: cart.items.isEmpty
                ? const Center(child: Text("Your cart is empty 🥞"))
                : ListView.builder(
                    itemCount: uniqueItems.length,
                    padding: const EdgeInsets.all(20),
                    itemBuilder: (ctx, i) {
                      final item = uniqueItems[i];
                      final quantity = itemCounts[item.id] ?? 0;

                      return Container(
                        margin: const EdgeInsets.only(bottom: 15),
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Row(
                          children: [
                            ClipRRect(
                              borderRadius: BorderRadius.circular(15),
                              child: Image.network(
                                item.image,
                                width: 70,
                                height: 70,
                                fit: BoxFit.cover,
                              ),
                            ),
                            const SizedBox(width: 15),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    item.name,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  const SizedBox(height: 5),
                                  Text(
                                    formatCurrency(item.price),
                                    style: TextStyle(
                                      color: primaryColor,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // 🔥 BỘ TĂNG GIẢM SỐ LƯỢNG +/-
                            Container(
                              decoration: BoxDecoration(
                                color: Colors.pink.shade50,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: Row(
                                children: [
                                  IconButton(
                                    icon: const Icon(
                                      Icons.remove,
                                      size: 18,
                                      color: Colors.pink,
                                    ),
                                    onPressed: () =>
                                        cart.updateQuantity(item.id, false),
                                  ),
                                  Text(
                                    "$quantity",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(
                                      Icons.add,
                                      size: 18,
                                      color: Colors.pink,
                                    ),
                                    onPressed: () =>
                                        cart.updateQuantity(item.id, true),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
          ),
          _buildSummarySection(context, cart, primaryColor),
        ],
      ),
    );
  }

  Widget _buildSummarySection(
    BuildContext context,
    CartProvider cart,
    Color primaryColor,
  ) {
    return Container(
      padding: const EdgeInsets.only(left: 30, right: 30, top: 25, bottom: 40),
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(30)),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 15)],
      ),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                "Total",
                style: TextStyle(fontSize: 18, color: Colors.grey),
              ),
              Text(
                formatCurrency(cart.totalAmount),
                style: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                  color: primaryColor,
                ),
              ),
            ],
          ),
          const SizedBox(height: 25),
          SizedBox(
            width: double.infinity,
            height: 60,
            child: ElevatedButton(
              onPressed: () async {
                try {
                  await cart.checkout();
                  if (context.mounted) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(
                        content: Text("Order placed! 🥞"),
                        backgroundColor: Colors.green,
                      ),
                    );
                    Navigator.of(
                      context,
                    ).pushNamedAndRemoveUntil('/home', (route) => false);
                  }
                } catch (e) {
                  if (context.mounted) {
                    ScaffoldMessenger.of(
                      context,
                    ).showSnackBar(SnackBar(content: Text("Error: $e")));
                  }
                }
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: primaryColor,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(15),
                ),
                elevation: 0,
              ),
              child: const Text(
                "CHECKOUT NOW",
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
