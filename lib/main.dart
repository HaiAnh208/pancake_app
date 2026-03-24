import 'package:flutter/material.dart';
import 'package:pancake_app/providers/favorite_provider.dart';
import 'package:pancake_app/screens/favorite_screen.dart';
import 'package:pancake_app/screens/product_detail_screen.dart';
import 'package:pancake_app/screens/register_screen.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/order_history_screen.dart';

// Import cấu hình Firebase
import 'firebase_options.dart';

// Import Providers
import 'providers/cart_provider.dart';
// Lưu ý: Đảm bảo đường dẫn này khớp với tên thư mục của bạn
// import 'providers/favorite_provider.dart'; (Đã import ở trên cùng rồi)

// Import Screens
import 'screens/home_screen.dart';
import 'screens/cart_screen.dart';
import 'screens/login_screen.dart';

void main() async {
  // 1. Đảm bảo các dịch vụ hệ thống đã sẵn sàng
  WidgetsFlutterBinding.ensureInitialized();

  // 2. Khởi tạo Firebase
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    // 🔥 BƯỚC QUAN TRỌNG NHẤT: Dùng MultiProvider để khai báo nhiều kho cùng lúc
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CartProvider()), // Kho Giỏ hàng
        ChangeNotifierProvider(
          create: (_) => FavoriteProvider(),
        ), // Kho Yêu thích
      ],
      child: MaterialApp(
        title: 'Pancake App',
        debugShowCheckedModeBanner: false, // Tắt cái nhãn Debug màu đỏ cho đẹp
        theme: ThemeData(
          primarySwatch: Colors.orange,
          useMaterial3: false, // Để giữ giao diện quen thuộc
        ),

        // 🛠️ DÙNG STREAMBUILDER ĐỂ TỰ ĐỘNG CHUYỂN MÀN HÌNH
        home: StreamBuilder<User?>(
          stream: FirebaseAuth.instance.authStateChanges(),
          builder: (context, snapshot) {
            // Nếu đang kiểm tra dữ liệu thì hiện vòng xoay
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Scaffold(
                body: Center(child: CircularProgressIndicator()),
              );
            }

            // Nếu snapshot có dữ liệu (User != null) -> Đã Login -> Vào Home
            if (snapshot.hasData) {
              return const HomeScreen();
            }

            // Ngược lại -> Chưa Login -> Vào LoginScreen
            return const LoginScreen();
          },
        ),

        // 🛠️ KHAI BÁO CÁC ĐƯỜNG DẪN (ROUTES)
        routes: {
          '/login': (context) => const LoginScreen(),
          '/home': (context) => const HomeScreen(),
          '/cart': (context) => const CartScreen(),
          '/orders': (context) => const OrderHistoryScreen(),
          '/ProductDetail': (context) => const ProductDetailScreen(),
          '/favorites': (context) => const FavoriteScreen(),
          '/register': (context) => const RegisterScreen(),
        },
      ),
    );
  }
}
