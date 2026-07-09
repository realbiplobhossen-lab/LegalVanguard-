import 'package:flutter/material.dart';
import 'app_features.dart'; // আমাদের তৈরি করা ফিচার ফাইলটি লিংক করা হলো

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const LegalVanguardApp());
}

class LegalVanguardApp extends StatelessWidget {
  const LegalVanguardApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'LegisMate',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        primaryColor: const Color(0xFF0A192F), // রাজকীয় রয়েল নেভি ব্লু
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF0A192F),
          primary: const Color(0xFF0A192F),
          secondary: const Color(0xFFD4AF37), // প্রিমিয়াম গোল্ডেন টাচ
        ),
      ),
      home: const AdvancedDashboard(), // ২৪টি ফিচারের মেইন ড্যাশবোর্ড স্ক্রিন ওপেন হবে
    );
  }
}

