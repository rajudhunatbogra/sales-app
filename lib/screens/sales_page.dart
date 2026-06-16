import 'package:flutter/material.dart';
import 'package:sales_app/models/jewelry_item.dart';
import 'package:sales_app/models/memo_model.dart';
import 'package:sales_app/database/database_helper.dart';
import 'package:sales_app/services/storage_service.dart';
import 'package:sales_app/services/calculator_service.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _formKey = GlobalKey<FormState>();
  final _memoNoController = TextEditingController();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();
  final _discountController = TextEditingController();
  final _paidController = TextEditingController();

  final List<JewelryItem> _items = [];
  double _subTotal = 0.0;
  double _grandTotal = 0.0;
  double _dueAmount = 0.0;

  @override
  void initState() {
    super.initState();
    _loadInitialData();
  }

  void _loadInitialData() {
    _generateMemoNumber();
    _items.add(JewelryItem(name: "স্বর্ণালঙ্কার"));
  }

  Future<void> _generateMemoNumber() async {
    int lastNo = await StorageService.getLastMemoNumber();
    setState(() {
      _memoNoController.text = "MEMO-$lastNo";
    });
  }

  void _updateRow(int index) {
    setState(() {
      _items[index].totalPrice = CalculatorService.calculateItemTotalPrice(_items[index]);
      _items[index].totalVori = CalculatorService.calculateTotalVori(
        _items[index].vori, _items[index].ana, _items[index].rati, _items[index].point
      );
      _calculateFinalTotals();
    });
  }

  void _calculateFinalTotals() {
    double sub = 0.0;
    for (var item in _items) {
      sub += item.totalPrice;
    }
    double discount = double.tryParse(_discountController.text) ?? 0.0;
    double paid = double.tryParse(_paidController.text) ?? 0.0;
    double grand = sub - discount;

    setState(() {
      _subTotal = sub;
      _grandTotal = grand;
      _dueAmount = grand - paid;
    });
  }

  Future<void> _saveInvoice() async {
    if (!_formKey.currentState!.validate() || _items.isEmpty) return;

    final newMemo = Memo(
      memoNo: _memoNoController.text,
      customerName: _nameController.text,
      customerPhone: _phoneController.text,
      customerAddress: _addressController.text,
      date: DateTime.now().toString().split(' '),
      items: _items,
      subTotal: _subTotal,
      discount: double.tryParse(_discountController.text) ?? 0.0,
      grandTotal: _grandTotal,
      paidAmount: double.tryParse(_paidController.text) ?? 0.0,
      dueAmount: _dueAmount,
    );

    await DatabaseHelper.instance.insertMemo(newMemo);
    int currentNo = int.parse(_memoNoController.text.split('-'));
    await StorageService.incrementMemoNumber(currentNo);

    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মেমো সফলভাবে পিওএস ডাটাবেজে সেভ হয়েছে!')),
      );
      _resetForm();
    }
  }

  void _resetForm() {
    _nameController.clear();
    _phoneController.clear();
    _addressController.clear();
    _discountController.clear();
    _paidController.clear();
    _items.clear();
    _loadInitialData();
    _calculateFinalTotals();
  }

  @override
  void dispose() {
    _memoNoController.dispose();
    _nameController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    _discountController.dispose();
    _paidController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('জুয়েলারি প্রফেশনাল পিওএস'), backgroundColor: Colors.amber),
      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            children: [
              TextFormField(controller: _memoNoController, decoration: const InputDecoration(labelText: 'মেমো নাম্বার'), readOnly: true),
              TextFormField(controller: _nameController, decoration: const InputDecoration(labelText: 'গ্রাহকের নাম'), validator: (v) => v!.isEmpty ? 'নাম দিন' : null),
              TextFormField(controller: _phoneController, decoration: const InputDecoration(labelText: 'মোবাইল'), keyboardType: TextInputType.phone),
              const SizedBox(height: 15),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _items.length,
                itemBuilder: (context, idx) => Card(
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: Column(
                      children: [
                        TextFormField(initialValue: _items[idx].name, decoration: const InputDecoration(labelText: 'আইটেম নাম'), onChanged: (v) => _items[idx].name = v),
                        Row(
                          children: [
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].vori = double.tryParse(v) ?? 0; _updateRow(idx); })),
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].ana = double.tryParse(v) ?? 0; _updateRow(idx); })),
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].rati = double.tryParse(v) ?? 0; _updateRow(idx); })),
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].point = double.tryParse(v) ?? 0; _updateRow(idx); })),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'ভরি রেট'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].pricePerVori = double.tryParse(v) ?? 0; _updateRow(idx); })),
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'অপচয়'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].wastage = double.tryParse(v) ?? 0; _updateRow(idx); })),
                            Expanded(child: TextFormField(decoration: const InputDecoration(labelText: 'মজুরি'), keyboardType: TextInputType.number, onChanged: (v) { _items[idx].makingCharge = double.tryParse(v) ?? 0; _updateRow(idx); })),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text('মোট ভরি: ${_items[idx].totalVori} | মোট মূল্য: ${_items[idx].totalPrice} টাকা', style: const TextStyle(fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ),
                ),
              ),
              ElevatedButton(onPressed: () { setState(() { _items.add(JewelryItem(name: "নতুন গহনা")); }); }, child: const Text('আইটেম যোগ করুন')),
              const SizedBox(height: 15),
              Text('সাবটোটাল: $_subTotal টাকা', style: const TextStyle(fontSize: 16)),
              TextFormField(controller: _discountController, decoration: const InputDecoration(labelText: 'ছাড় (টাকা)'), keyboardType: TextInputType.number, onChanged: (v) => _calculateFinalTotals()),
              Text('মোট প্রদেয়: $_grandTotal টাকা', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 18)),
              TextFormField(controller: _paidController, decoration: const InputDecoration(labelText: 'জমা টাকা'), keyboardType: TextInputType.number, onChanged: (v) => _calculateFinalTotals()),
              Text('অবशिष्ट বাকি: $_dueAmount টাকা', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
              const SizedBox(height: 20),
              ElevatedButton(onPressed: _saveInvoice, child: const Text('মেমো সেভ করুন')),
            ],
          ),
        ),
      ),
    );
  }
}
