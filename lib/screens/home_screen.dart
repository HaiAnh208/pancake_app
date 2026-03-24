import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:pancake_app/page/login_page.dart';
import 'package:pancake_app/providers/favorite_provider.dart';
import 'package:provider/provider.dart';
import 'dart:ui';
import 'dart:async';
import '../providers/cart_provider.dart';
import 'package:font_awesome_flutter/font_awesome_flutter.dart';
// Nhớ có import này ở đầu file
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String searchQuery = "";
  String selectedCategory = "All";
  Timer? _debounce;
  Set<String> favoriteIds = {};

   final List<Map<String, dynamic>> categories = [
    {'name': 'All', 'icon': Icons.tune_rounded},
    {
      'name': 'Sweet Pancakes', // Đổi tên cho ngắn gọn giống ảnh bạn gửi
      'icon': Icons.cake_rounded,
    },
    {
      'name': 'Diet Pancakes', // Đổi từ Savory thành Diet
      'icon': Icons.bakery_dining_rounded, // Icon hình bánh xốp cực đẹp
    },
    {'name': 'Drinks', 'icon': Icons.local_drink_rounded},
  ];

  // ✅ FORMAT TIỀN VIỆT
  String formatCurrency(double amount) {
    final format = NumberFormat("#,###", "vi_VN");
    return "${format.format(amount)}đ";
  }

  // ✅ SEARCH DEBOUNCE
  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 400), () {
      setState(() {
        searchQuery = query;
      });
    });
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

String selectedType =
      'Sweet Pancakes'; // Khai báo biến này ở đầu hàm _showAddProductDialog

  void _showAddProductDialog(BuildContext context) {
    final nameController = TextEditingController();
    final priceController = TextEditingController();
    final imgController = TextEditingController();
    final descController = TextEditingController();

    // 🔴 CHỖ 1: Sửa giá trị mặc định này cho khớp với danh sách bên dưới
    String selectedType = 'Sweet Pancakes'; // <-- Phải viết ĐẦY ĐỦ tên mới

    showDialog(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setState) => AlertDialog(
          title: const Text("Thêm món mới 🥞"),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                DropdownButtonFormField<String>(
                  value: selectedType,
                  decoration: const InputDecoration(labelText: "Phân loại"),

                  // 🔴 CHỖ 2: Đảm bảo danh sách này cũng là tên ĐẦY ĐỦ
                  items: ['Sweet Pancakes', 'Diet Pancakes', 'Drinks'].map((
                    cat,
                  ) {
                    return DropdownMenuItem(value: cat, child: Text(cat));
                  }).toList(),

                  onChanged: (value) => setState(() => selectedType = value!),
                ),
                const SizedBox(height: 10),
                // 2. CÁC Ô NHẬP THÔNG TIN
                TextField(
                  controller: nameController,
                  decoration: const InputDecoration(
                    labelText: "Tên sản phẩm ",
                  ),
                ),
                TextField(
                  controller: priceController,
                  decoration: const InputDecoration(labelText: "Giá tiền"),
                  keyboardType: TextInputType.number,
                ),
                TextField(
                  controller: imgController,
                  decoration: const InputDecoration(
                    labelText: "Link ảnh (URL)",
                  ),
                ),
                TextField(
                  controller: descController,
                  decoration: const InputDecoration(
                    labelText: "Mô tả",
                  ),
                  maxLines: 2,
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("Hủy"),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(backgroundColor: Colors.pink),
              onPressed: () {
                // GỌI HÀM LƯU (Truyền đủ 6 tham số)
                _saveProductToFirebase(
                  context,
                  nameController.text,
                  priceController.text,
                  imgController.text,
                  descController.text,
                  selectedType,
                );
              },
              child: const Text(
                "Lưu lại",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
Future<void> _saveProductToFirebase(
    BuildContext context,
    String name,
    String price,
    String img,
    String desc,
    String category
  ) async {
    // Kiểm tra xem có bỏ trống ô nào quan trọng không
    if (name.isEmpty || price.isEmpty || img.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Hải Anh ơi, nhập thiếu Tên hoặc Giá rồi!"),
        ),
      );
      return;
    }
    // ... bên trong hàm
    await FirebaseFirestore.instance.collection('products').add({
      'name': name,
      'price': double.parse(price),
      'image': img,
      'description': desc,
      'category':
          category, // <-- Dòng 167 sẽ hết lỗi khi bạn thêm 'String category' ở trên
      'createdAt': FieldValue.serverTimestamp(),
    });

    try {
      // 1. Hiện vòng xoay Loading (để thầy thấy app đang xử lý xịn xò)
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => const Center(child: CircularProgressIndicator()),
      );

      // 2. Lệnh "Bay" lên Firebase Firestore
      await FirebaseFirestore.instance.collection('products').add({
        'name': name,
        'price': double.parse(price), // Chuyển chữ thành số
        'image': img,
        'description': desc, // Lưu mô tả vào Database
        'category': 'All', // Mặc định là All
        'createdAt': FieldValue.serverTimestamp(), // Lưu thời gian thêm
      });

      // 3. Đóng vòng xoay và đóng bảng nhập liệu
      Navigator.pop(context); // Tắt loading
      Navigator.pop(context); // Tắt Dialog

      // 4. Thông báo thành công
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text("Bánh đã 'bay' lên Firebase thành công! 🚀"),
        ),
      );
    } catch (e) {
      Navigator.pop(context); // Tắt loading nếu lỗi
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text("Lỗi rồi Hải Anh ơi: $e")));
    }
  }
  @override
  Widget build(BuildContext context) {
    final primaryColor = Colors.pink.shade300;
    final bgColor = const Color(0xFFFFF0F5);
    Future<void> _saveProductToFirebase(
      BuildContext context,
      String name,
      String price,
      String img,
      String desc,
    ) async {
      // Kiểm tra xem có bỏ trống ô nào quan trọng không
      if (name.isEmpty || price.isEmpty || img.isEmpty) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Hải Anh ơi, nhập thiếu Tên hoặc Giá rồi!"),
          ),
        );
        return;
      }

      try {
        // 1. Hiện vòng xoay Loading (để thầy thấy app đang xử lý xịn xò)
        showDialog(
          context: context,
          barrierDismissible: false,
          builder: (context) =>
              const Center(child: CircularProgressIndicator()),
        );

        // 2. Lệnh "Bay" lên Firebase Firestore
        await FirebaseFirestore.instance.collection('products').add({
          'name': name,
          'price': double.parse(price), // Chuyển chữ thành số
          'image': img,
          'description': desc, // Lưu mô tả vào Database
          'category': 'All', // Mặc định là All
          'createdAt': FieldValue.serverTimestamp(), // Lưu thời gian thêm
        });

        // 3. Đóng vòng xoay và đóng bảng nhập liệu
        Navigator.pop(context); // Tắt loading
        Navigator.pop(context); // Tắt Dialog

        // 4. Thông báo thành công
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Bánh đã 'bay' lên Firebase thành công! 🚀"),
          ),
        );
      } catch (e) {
        Navigator.pop(context); // Tắt loading nếu lỗi
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text("Lỗi rồi Hải Anh ơi: $e")));
      }
    }

return Scaffold(
  backgroundColor: bgColor,
  // 1. THÊM NÚT BẤM (+) CHỈ HIỆN KHI LÀ ADMIN
  
  body: Stack(
    children: [
      SingleChildScrollView(
        padding: const EdgeInsets.only(top: 130),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // ... (Giữ nguyên phần SEARCH và Category của bạn)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: TextField(
                onChanged: _onSearchChanged,
                decoration: InputDecoration(
                  hintText: "Search pancake...",
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: Colors.white,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            _buildCategoryList(primaryColor),
            const SizedBox(height: 25),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: Text(
                selectedCategory == "All" ? "Menu" : selectedCategory,
                style: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            const SizedBox(height: 15),
            _buildProductGrid(primaryColor),
            const SizedBox(height: 50),
          ],
        ),
      ),
      // 2. CẬP NHẬT APPBAR ĐỂ CÓ NÚT LOGIN
      _buildAppBar(context, primaryColor, bgColor),
    ],
  ),
  floatingActionButton: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            return FutureBuilder<DocumentSnapshot>(
              // Tìm đúng cái UID của người đang đăng nhập
              future: FirebaseFirestore.instance
                  .collection('users')
                  .doc(snapshot.data!.uid)
                  .get(),
              builder: (context, userSnapshot) {
                // Kiểm tra: Có data + Document có tồn tại + Role đúng là admin
                if (userSnapshot.hasData &&
                    userSnapshot.data!.exists &&
                    userSnapshot.data!.get('role') == 'admin') {
                  return FloatingActionButton(
                    backgroundColor: Colors.pink,
                    onPressed: () => _showAddProductDialog(context),
                    child: const Icon(Icons.add, color: Colors.white),
                  );
                }
                return const SizedBox.shrink();
              },
            );
          }
          return const SizedBox.shrink();
        },
      ),
);

  }

  // ================= GRID =================
  Widget _buildProductGrid(Color primaryColor) {
    return StreamBuilder<QuerySnapshot>(
      stream: FirebaseFirestore.instance.collection('products').snapshots(),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          // Thay vì hiện chữ Lỗi kết nối, mình chỉ hiện một khoảng trống hoặc Loading nhẹ
          return const Center(child: SizedBox());
        }

        final docs = snapshot.data!.docs;

        // 1. BỘ LỌC (SEARCH & CATEGORY)
        final filteredDocs = docs.where((doc) {
          final data = doc.data() as Map<String, dynamic>;

          final name = (data['name'] ?? "").toString().toLowerCase().trim();
          final category = (data['category'] ?? "All").toString();
          final query = searchQuery.toLowerCase().trim();

          bool matchesSearch = query.isEmpty || name.contains(query);
          bool matchesCategory =
              (selectedCategory == "All" || category == selectedCategory);

          return matchesSearch && matchesCategory;
        }).toList();

        // Nếu không tìm thấy bánh nào
       if (snapshot.data!.docs.isEmpty) {
          // Logic: Nếu đang chọn Drinks thì hiện "No drinks found", còn lại hiện "No cakes found"
          String message = selectedCategory == "Drinks"
              ? "No drinks found... ☕"
              : "No cakes found... 🥞";

          return Center(
            child: Text(
              message,
              style: const TextStyle(color: Colors.grey, fontSize: 18),
            ),
          );
        }
       const Spacer();

        // 2. HIỂN THỊ DANH SÁCH (GRID VIEW)
        return GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),

          // 🔥 THAY ĐỔI QUAN TRỌNG Ở ĐÂY:
         gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
            maxCrossAxisExtent: 200,
            childAspectRatio:
                0.7, // <--- SỐ NÀY CÀNG NHỎ THÌ CÁI CARD CÀNG DÀI RA
            crossAxisSpacing: 15,
            mainAxisSpacing: 15,
          ),
          itemCount: filteredDocs.length,
          itemBuilder: (context, index) {
            final data = filteredDocs[index].data() as Map<String, dynamic>;

            final p = {
              'id': filteredDocs[index].id,
              'name': data['name'] ?? 'Pancake',
              'price': (data['price'] ?? 0).toDouble(),
              'image': data['image'] ?? '',
              'category': data['category'] ?? 'All',
              'description': data['description'] ?? '',
              'rating': (data['rating'] ?? 0.0).toDouble(),
            };

            return _buildCard(context, p, primaryColor);
          },
        );
      },
    );
  }
  // ================= CARD =================
  Widget _buildCard(BuildContext context, Map p, Color primaryColor) {
    final cart = Provider.of<CartProvider>(context, listen: false);

    // Dùng InkWell để tạo hiệu ứng chạm (Ripple Effect)
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/ProductDetail', arguments: p);
      },
      borderRadius: BorderRadius.circular(18),
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(18),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
          // 🖼️ PHẦN ẢNH (Dùng Contain để hiện trọn vẹn)
            SizedBox(
              height: 120, // Giữ nguyên chiều cao khung
              width: double.infinity,
              child: Image.network(
                p['image'],
                // 🛠️ THAY cover BẰNG contain:
                fit: BoxFit.contain,
              ),
            ),

            // 📛 TÊN BÁNH
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10),
              child: Text(
                p['name'] ?? 'Pancake',
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 14,
                ),
              ),
            ),

            // ⭐ RATING (SAO)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
              child: Row(
                children: [
                  const Icon(Icons.star_rounded, color: Colors.amber, size: 14),
                  const SizedBox(width: 4),
                  Text(
                    "${p['rating'] ?? 0.0}",
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black87,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),

            // Khoảng trống đẩy cụm Giá & Nút xuống dưới cùng Card
            const Spacer(),

            // 💰 GIÁ & CỤM NÚT (TIM + THÊM)
            Padding(
              padding: const EdgeInsets.all(10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  // ⬅️ BÊN TRÁI: HIỂN THỊ GIÁ
                  Text(
                    formatCurrency((p['price'] ?? 0).toDouble()),
                    style: TextStyle(
                      color: primaryColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),

                  // ➡️ BÊN PHẢI: GOM NÚT TIM VÀ NÚT ADD VÀO MỘT NHÓM
                  Row(
                    mainAxisSize:
                        MainAxisSize.min, // 🔥 Lệnh này ép 2 nút sát nhau
                    children: [
                      // ❤️ NÚT TRÁI TIM (Lấy từ Kho FavoriteProvider)
                      Consumer<FavoriteProvider>(
                        builder: (context, favProvider, child) {
                          final bool isFav = favProvider.isFavorite(
                            p['id'].toString(),
                          );
                          return GestureDetector(
                            onTap: () {
                              favProvider.toggleFavorite(
                                Map<String, dynamic>.from(p),
                              );
                            },
                            child: Container(
                              padding: const EdgeInsets.all(
                                6,
                              ), // Thu nhỏ cho bằng nút Add
                              decoration: BoxDecoration(
                                color: Colors.white,
                                border: Border.all(
                                  color: isFav
                                      ? Colors.red.shade100
                                      : Colors.pink.shade100,
                                ),
                                borderRadius: BorderRadius.circular(8),
                              ),
                              child: Icon(
                                isFav ? Icons.favorite : Icons.favorite_border,
                                color: isFav ? Colors.red : primaryColor,
                                size: 16,
                              ),
                            ),
                          );
                        },
                      ),

                      const SizedBox(
                        width: 6,
                      ), // Khoảng cách nhỏ xíu giữa Tim và (+)
                      // ➕ NÚT ADD TO CART
                      GestureDetector(
                        onTap: () {
                          cart.addItem(
                            p['id'].toString(),
                            p['name'],
                            (p['price'] ?? 0).toDouble(),
                            p['image'],
                          );
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text("Đã thêm vào giỏ! 🥞"),
                              duration: Duration(seconds: 1),
                            ),
                          );
                        },
                        child: Container(
                          padding: const EdgeInsets.all(6),
                          decoration: BoxDecoration(
                            color: primaryColor,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(
                            Icons.add,
                            color: Colors.white,
                            size: 16,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
  // ================= CATEGORY =================
Widget _buildCategoryList(Color primaryColor) {
    return SizedBox(
      height: 100, // Tăng nhẹ chiều cao để không bị cấn chữ
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        itemCount: categories.length,
        padding: const EdgeInsets.only(left: 20, right: 20),
        itemBuilder: (context, index) {
          final cat = categories[index];
          final isSelected = selectedCategory == cat['name'];

          return GestureDetector(
            onTap: () => setState(() => selectedCategory = cat['name']),
            child: AnimatedContainer(
              // Dùng AnimatedContainer cho nó mượt
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(right: 12, top: 5, bottom: 5),
              width: 90, // Tăng nhẹ chiều rộng
              decoration: BoxDecoration(
                color: isSelected ? primaryColor : Colors.white,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  if (!isSelected)
                    BoxShadow(
                      color: Colors.black.withOpacity(0.05),
                      blurRadius: 10,
                      offset: const Offset(0, 5),
                    ),
                ],
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    cat['icon'],
                    size: 28, // Cho icon to rõ ràng
                    color: isSelected ? Colors.white : Colors.grey[600],
                  ),
                  const SizedBox(height: 8),
                  Text(
                    cat['name'],
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: isSelected
                          ? FontWeight.bold
                          : FontWeight.normal,
                      color: isSelected ? Colors.white : Colors.black87,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
  
  // ================= APPBAR =================
  Widget _buildAppBar(BuildContext context, Color primaryColor, Color bg) {
  final cart = Provider.of<CartProvider>(context);

  return Positioned(
    top: 0,
    left: 0,
    right: 0,
    child: Container(
      height: 120,
      padding: const EdgeInsets.only(top: 50, left: 10, right: 10),
      decoration: BoxDecoration(
        color: bg.withOpacity(0.95),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.03),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            // 🛡️ 1. NÚT ADMIN / LOGOUT (GÓC TRÁI)
            StreamBuilder<User?>(
              stream: FirebaseAuth.instance.authStateChanges(),
              builder: (context, snapshot) {
                return IconButton(
                  icon: const Icon(
                    Icons.logout_rounded,
                    color: Colors.red,
                    size: 28,
                  ),
                  onPressed: () async {
                    // 1. Đăng xuất Firebase (nếu đang là Admin)
                    await FirebaseAuth.instance.signOut();

                    // 2. 🚀 CHUYỂN TRANG: Bay về màn hình Welcome Back màu hồng
                    // Dùng pushAndRemoveUntil để dọn sạch lỗi kết nối Firebase
                    Navigator.of(context).pushAndRemoveUntil(
                      MaterialPageRoute(
                        builder: (context) => const LoginScreen(),
                      ), // Nhớ đổi thành LoginScreen hoặc LoginPage tùy tên file của bạn
                      (route) => false,
                    );
                  },
                );
              },
            ),
             
          // 🥞 TIÊU ĐỀ GIỮ NGUYÊN
          Expanded(
            child: Text(
              "Pancakes Shop 🥞",
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: 28,
                fontWeight: FontWeight.w900,
                color: Colors.black,
                letterSpacing: 1.0,
              ),
            ),
          ),

          // ❤️ Yêu thích, 🛒 Lịch sử & Giỏ hàng (GIỮ NGUYÊN 100%)
          Row(
            children: [
              IconButton(
                icon: const Icon(
                  Icons.favorite_outline_rounded,
                  color: Colors.pink,
                  size: 26,
                ),
                onPressed: () => Navigator.pushNamed(context, '/favorites'),
              ),
              IconButton(
                icon: const Icon(
                  Icons.history_rounded,
                  color: Colors.black87,
                  size: 26,
                ),
                onPressed: () => Navigator.pushNamed(context, '/orders'),
              ),
              GestureDetector(
                onTap: () => Navigator.pushNamed(context, '/cart'),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    Icon(
                      Icons.shopping_bag_outlined,
                      color: primaryColor,
                      size: 28,
                    ),
                    if (cart.itemCount > 0)
                      Positioned(
                        top: 0,
                        right: 0,
                        child: Container(
                          padding: const EdgeInsets.all(4),
                          decoration: const BoxDecoration(
                            color: Colors.red,
                            shape: BoxShape.circle,
                          ),
                          child: Text(
                            "${cart.itemCount}",
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 9,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 5),
            ],
          ),
        ],
      ),
    ),
  );
}
}
