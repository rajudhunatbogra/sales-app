import 'package:flutter/material.dart';
import 'lib/screens/sales_page.dart'; // পাথটি ফিক্স করা হলো

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
        useMaterialDesign: true,
      ),
      home: const SalesPage(),
    );
  }
}
