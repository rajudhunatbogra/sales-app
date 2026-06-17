import 'package:flutter/material.dart';
import '../models/jewelry_item.dart';
import '../database/database_helper.dart';

class InventoryPage extends StatefulWidget {
  const InventoryPage({Key? key}) : super(key: key);

  @override
  State<InventoryPage> createState() => _InventoryPageState();
}

class _InventoryPageState extends State<InventoryPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _nameController = TextEditingController();
  final _voriController = TextEditingController(text: '0');
  final _anaController = TextEditingController(text: '0');
  final _ratiController = TextEditingController(text: '0');
  final _pointController = TextEditingController(text: '0');
  final _pricePerVoriController = TextEditingController(text: '0');
  final _wastageController = TextEditingController(text: '0');
  final _makingChargeController = TextEditingController(text: '0');
  final _stockController = TextEditingController(text: '1');

  String _selectedKarat = '22K';
  double _totalVori = 0.0;
  double _totalPrice = 0.0;

  List<JewelryItem> _inventoryItems = [];

  @override
  void initState() {
    super.initState();
    _loadInventory();
  }

  Future<void> _loadInventory() async {
    final items = await DatabaseHelper.instance.fetchJewelryItems();
    setState(() {
      _inventoryItems = items;
    });
  }

  void _calculateTotal() {
    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double rati = double.tryParse(_ratiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;
    double pricePerVori = double.tryParse(_pricePerVoriController.text) ?? 0;
    double wastage = double.tryParse(_wastageController.text) ?? 0;
    double makingCharge = double.tryParse(_makingChargeController.text) ?? 0;

    double calculatedTotalVori = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0);
    double effectiveVori = calculatedTotalVori + wastage;
    double calculatedTotalPrice = (effectiveVori * pricePerVori) + makingCharge;

    setState(() {
      _totalVori = calculatedTotalVori;
      _totalPrice = calculatedTotalPrice;
    });
  }

  Future<void> _saveItem() async {
    if (_formKey.currentState!.validate()) {
      _calculateTotal();

      final newItem = JewelryItem(
        name: _nameController.text,
        karat: _selectedKarat,
        vori: double.tryParse(_voriController.text) ?? 0,
        ana: double.tryParse(_anaController.text) ?? 0,
        rati: double.tryParse(_ratiController.text) ?? 0,
        point: double.tryParse(_pointController.text) ?? 0,
        totalVori: _totalVori,
        pricePerVori: double.tryParse(_pricePerVoriController.text) ?? 0,
        wastage: double.tryParse(_wastageController.text) ?? 0,
        makingCharge: double.tryParse(_makingChargeController.text) ?? 0,
        totalPrice: _totalPrice,
        stockQuantity: int.tryParse(_stockController.text) ?? 1,
      );

      await DatabaseHelper.instance.insertJewelryItem(newItem);
      
      _nameController.clear();
      _voriController.text = '0';
      _anaController.text = '0';
      _ratiController.text = '0';
      _pointController.text = '0';
      _pricePerVoriController.text = '0';
      _wastageController.text = '0';
      _makingChargeController.text = '0';
      _stockController.text = '1';
      
      setState(() {
        _totalVori = 0.0;
        _totalPrice = 0.0;
      });

      _loadInventory();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('প্রোডাক্ট সফলভাবে ইনভেন্টরিতে যোগ হয়েছে!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জুয়েলারি ইনভেন্টরি ম্যানেজমেন্ট'),
        backgroundColor: Colors.amber.shade800,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'গহনার নাম/ডিজাইন'),
                        validator: (value) => value!.isEmpty ? 'নাম লিখুন' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedKarat,
                        decoration: const InputDecoration(labelText: 'ক্যারেট (Karat)'),
                        items: ['22K', '21K', '18K', 'Traditional']
                            .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedKarat = val!),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _voriController, decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _anaController, decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _ratiController, decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 8),
                          Expanded(child: TextFormField(controller: _pointController, decoration: const InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pricePerVoriController,
                        decoration: const InputDecoration(labelText: 'প্রতি ভরির মূল্য (টাকা)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _wastageController,
                        decoration: const InputDecoration(labelText: 'ক্ষয়/ওয়েস্টেজ (ভরি)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _makingChargeController,
                        decoration: const InputDecoration(labelText: 'মজুরি/মেকিং চার্জ (টাকা)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'স্টক সংখ্যা (Quantity)'),
                        keyboardType: TextInputType.number,
                      ),
                      const SizedBox(height: 15),
                      Container(
                        padding: const EdgeInsets.all(12),
                        color: Colors.amber.shade50,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('মোট ভরি: ${_totalVori.toStringAsFixed(3)}', style: const TextStyle(fontWeight: FontWeight.bold)),
                            Text('মোট মূল্য: ${_totalPrice.toStringAsFixed(2)} টাকা', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                        child: const Text('স্টক ইনপুট দিন', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('বর্তমান স্টক তালিকা:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _inventoryItems.length,
                itemBuilder: (context, index) {
                  final item = _inventoryItems[index];
                  return Card(
                    margin: const EdgeInsets.only(bottom: 8),
                    child: ListTile(
                      title: Text('${item.name} (${item.karat})'),
                      subtitle: Text('ওজন: ${item.vori} ভরি ${item.ana} আনা | স্টক: ${item.stockQuantity} টি'),
                      trailing: Text('${item.totalPrice.toStringAsFixed(0)} ৳', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
