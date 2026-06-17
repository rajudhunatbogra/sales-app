import 'package:flutter/material.dart';
import 'package:sales_app/screens/sales_page.dart';
import 'package:sales_app/screens/inventory_page.dart'; // নতুন ইনভেন্টরি পেজ ইমপোর্ট করা হলো

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
      home: const InventoryPage(), // অ্যাপ চালু হলে এখন প্রথমে ইনভেন্টরি পেজ আসবে
    );
  }
}

