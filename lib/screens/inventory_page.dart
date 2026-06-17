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
  final _gramController = TextEditingController(text: '0');
  final _pricePerVoriController = TextEditingController(text: '0');
  final _wastageController = TextEditingController(text: '0');
  final _makingChargeController = TextEditingController(text: '0');
  final _stockController = TextEditingController(text: '1');

  String _selectedType = 'সোনা'; // সোনা বা রূপা সিলেকশন
  String _selectedKarat = '২২ ক্যারেট হলমার্ক'; // আপনার দেওয়া তালিকার ডিফল্ট
  double _totalVori = 0.0;
  double _totalPrice = 0.0;

  List<JewelryItem> _inventoryItems = [];

  // আপনার দেওয়া ১০টি ক্যারেটের নিখুঁত তালিকা
  final List<String> _karatList = [
    '১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '১৮ ক্যারেট হলমার্ক',
    '২০ ক্যারেট বাংলা', '২০ ক্যারেট কেডিয়াম',
    '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক',
    '২২ ক্যারেট কেডিয়াম', '২২ ক্যারেট হলমার্ক'
  ];

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
    double gram = double.tryParse(_gramController.text) ?? 0;
    double pricePerVori = double.tryParse(_pricePerVoriController.text) ?? 0;
    double wastage = double.tryParse(_wastageController.text) ?? 0;
    double makingCharge = double.tryParse(_makingChargeController.text) ?? 0;

    // গ্রাম থেকে ভরির কনভার্সন (১ ভরি = ১১.৬৬৪ গ্রাম)
    double voriFromGram = gram / 11.664;

    // ট্র্যাডিশনাল ভরি-আনা-রতি-পয়েন্ট এর সর্বমোট ভরি হিসাব
    double calculatedTotalVori = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0) + voriFromGram;
    
    // ওয়েস্টেজ বা ক্ষয় সহ কার্যকর ভরি
    double effectiveVori = calculatedTotalVori + wastage;
    
    // মোট মূল্য হিসাব
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
        itemType: _selectedType,
        karat: _selectedKarat,
        vori: double.tryParse(_voriController.text) ?? 0,
        ana: double.tryParse(_anaController.text) ?? 0,
        rati: double.tryParse(_ratiController.text) ?? 0,
        point: double.tryParse(_pointController.text) ?? 0,
        gram: double.tryParse(_gramController.text) ?? 0,
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
      _gramController.text = '0';
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
        const SnackBar(content: Text('পণ্যটি সফলভাবে ইনভেন্টরিতে যুক্ত হয়েছে!')),
      );
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('জুয়েলারি স্টক এন্ট্রি ও ইনভেন্টরি'),
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
                      DropdownButtonFormField<String>(
                        value: _selectedType,
                        decoration: const InputDecoration(labelText: 'মেটাল বা পণ্যের ধরন'),
                        items: ['সোনা', 'রূপা', 'অন্যান্য']
                            .map((t) => DropdownMenuItem(value: t, child: Text(t)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedType = val!),
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _nameController,
                        decoration: const InputDecoration(labelText: 'গহনার নাম বা ডিজাইনের বিবরণ'),
                        validator: (value) => value!.isEmpty ? 'নাম লিখুন' : null,
                      ),
                      const SizedBox(height: 10),
                      DropdownButtonFormField<String>(
                        value: _selectedKarat,
                        decoration: const InputDecoration(labelText: 'ক্যারেটের সুনির্দিষ্ট ধরন'),
                        items: _karatList
                            .map((k) => DropdownMenuItem(value: k, child: Text(k)))
                            .toList(),
                        onChanged: (val) => setState(() => _selectedKarat = val!),
                      ),
                      const SizedBox(height: 10),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _voriController, decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 6),
                          Expanded(child: TextFormField(controller: _anaController, decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 6),
                          Expanded(child: TextFormField(controller: _ratiController, decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 6),
                          Expanded(child: TextFormField(controller: _pointController, decoration: const InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                          const SizedBox(width: 6),
                          Expanded(child: TextFormField(controller: _gramController, decoration: const InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number, onChanged: (_) => _calculateTotal())),
                        ],
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _pricePerVoriController,
                        decoration: const InputDecoration(labelText: 'প্রতি ভরির দর/মূল্য (টাকা হাতে লিখুন)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _wastageController,
                        decoration: const InputDecoration(labelText: 'ক্ষয় বা ওয়েস্টেজ (ভরি)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _makingChargeController,
                        decoration: const InputDecoration(labelText: 'মজুরি বা মেকিং চার্জ (টাকা)'),
                        keyboardType: TextInputType.number,
                        onChanged: (_) => _calculateTotal(),
                      ),
                      TextFormField(
                        controller: _stockController,
                        decoration: const InputDecoration(labelText: 'স্টক পরিমাণ (পিস/সংখ্যা)'),
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
                            Text('মোট মূল্য: ${_totalPrice.toStringAsFixed(2)} ৳', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      ElevatedButton(
                        onPressed: _saveItem,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade800),
                        child: const Text('স্টক এন্ট্রি নিশ্চিত করুন', style: TextStyle(color: Colors.white)),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Text('বর্তমান জুয়েলারি স্টক তালিকা:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
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
                      leading: CircleAvatar(
                        backgroundColor: item.itemType == 'সোনা' ? Colors.amber.shade100 : Colors.grey.shade300,
                        child: Text(item.itemType[0], style: const TextStyle(fontWeight: FontWeight.bold)),
                      ),
                      title: Text('${item.name} (${item.karat})'),
                      subtitle: Text('ওজন: ${item.totalVori.toStringAsFixed(3)} ভরি | স্টক: ${item.stockQuantity} পিস'),
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
