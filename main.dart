import 'package:flutter/material.dart';
import 'package:sales_app/screens/sales_page.dart';

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
