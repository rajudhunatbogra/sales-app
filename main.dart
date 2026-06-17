import 'package:flutter/material.dart';
import 'package:sales_app/screens/dashboard_page.dart'; // নতুন ড্যাশবোর্ড পেজ ইমপোর্ট করা হলো

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const JewelryPosApp());
}

class JewelryPosApp extends StatelessWidget {
  const JewelryPosApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Jewelry POS Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.amber,
        useMaterial3: true,
      ),
      home: const DashboardPage(), // অ্যাপ চালু হলে এখন প্রথমে ড্যাশবোর্ড পেজ আসবে
    );
  }
}
