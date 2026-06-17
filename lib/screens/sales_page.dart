import 'package:flutter/material.dart';
import '../models/jewelry_item.dart';
import '../models/memo_model.dart';
import '../database/database_helper.dart';

class SalesPage extends StatefulWidget {
  const SalesPage({Key? key}) : super(key: key);

  @override
  State<SalesPage> createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final _formKey = GlobalKey<FormState>();
  
  final _customerNameController = TextEditingController();
  final _customerPhoneController = TextEditingController();
  final _customerAddressController = TextEditingController();
  final _memoNoController = TextEditingController();
  final _discountController = TextEditingController(text: '0');
  final _paidAmountController = TextEditingController(text: '0');

  final _itemNameController = TextEditingController();
  final _voriController = TextEditingController(text: '0');
  final _anaController = TextEditingController(text: '0');
  final _ratiController = TextEditingController(text: '0');
  final _pointController = TextEditingController(text: '0');
  final _gramController = TextEditingController(text: '0');
  final _rateController = TextEditingController(text: '0');
  final _makingChargeController = TextEditingController(text: '0');

  final _exNameController = TextEditingController();
  final _exVoriController = TextEditingController(text: '0');
  final _exAnaController = TextEditingController(text: '0');
  final _exRatiController = TextEditingController(text: '0');
  final _exPointController = TextEditingController(text: '0');
  final _exGramController = TextEditingController(text: '0');
  final _exRateController = TextEditingController(text: '0');

  String _selectedItemType = 'সোনা';
  String _selectedKarat = '২২ ক্যারেট হলমার্ক';
  String _exItemType = 'সোনা';
  String _exType = 'পাকা/খাঁটি';

  List<JewelryItem> _boughtItems = [];
  List<JewelryItem> _exchangedItems = [];

  double _subTotal = 0.0;
  double _grandTotal = 0.0;
  double _dueAmount = 0.0;
  double _totalBoughtVori = 0.0;
  double _totalPureExchangedVori = 0.0;
  double _totalExchangedCash = 0.0;

  final List<String> _karatList = [
    '১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '১৮ ক্যারেট হলমার্ক',
    '২০ ক্যারেট বাংলা', '২০ ক্যারেট কেডিয়াম',
    '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক',
    '২২ ক্যারেট কেডিয়াম', '২২ ক্যারেট হলমার্ক'
  ];

  @override
  void initState() {
    super.initState();
    _memoNoController.text = 'MEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
    _updateAutoRate(_selectedKarat); // শুরুতে ডিফল্ট রেট লোড হবে
  }

  // ডাটাবেজ থেকে রেট এনে অটোমেটিক বক্সে বসানোর মূল লিঙ্কিং মেথড
  Future<void> _updateAutoRate(String karat) async {
    double savedRate = await DatabaseHelper.instance.getRateByKarat(karat);
    setState(() {
      _rateController.text = savedRate.toStringAsFixed(0);
    });
  }
  void _calculateInvoice() {
    double boughtVoriSum = 0.0;
    double boughtPriceSum = 0.0;
    double pureExVoriSum = 0.0;
    double exCashSum = 0.0;

    for (var item in _boughtItems) {
      boughtVoriSum += item.totalVori;
      boughtPriceSum += item.totalPrice;
    }

    for (var item in _exchangedItems) {
      if (item.exchangeType == 'পাকা/খাঁটি') {
        pureExVoriSum += item.totalVori;
      } else {
        exCashSum += item.exchangeAmount;
      }
    }

    double remainingVori = boughtVoriSum - pureExVoriSum;
    if (remainingVori < 0) remainingVori = 0;

    double discount = double.tryParse(_discountController.text) ?? 0;
    double paid = double.tryParse(_paidAmountController.text) ?? 0;

    double adjustedSubTotal = boughtPriceSum;
    if (pureExVoriSum > 0 && boughtVoriSum > 0) {
      double ratio = remainingVori / boughtVoriSum;
      adjustedSubTotal = boughtPriceSum * ratio;
    }

    double grandTotal = adjustedSubTotal - exCashSum - discount;
    if (grandTotal < 0) grandTotal = 0;

    double due = grandTotal - paid;

    setState(() {
      _totalBoughtVori = boughtVoriSum;
      _totalPureExchangedVori = pureExVoriSum;
      _totalExchangedCash = exCashSum;
      _subTotal = boughtPriceSum;
      _grandTotal = grandTotal;
      _dueAmount = due;
    });
  }

  void _addBoughtItem() {
    double vori = double.tryParse(_voriController.text) ?? 0;
    double ana = double.tryParse(_anaController.text) ?? 0;
    double rati = double.tryParse(_ratiController.text) ?? 0;
    double point = double.tryParse(_pointController.text) ?? 0;
    double gram = double.tryParse(_gramController.text) ?? 0;
    double rate = double.tryParse(_rateController.text) ?? 0;
    double making = double.tryParse(_makingChargeController.text) ?? 0;

    double totalVori = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0) + (gram / 11.664);
    double totalPrice = (totalVori * rate) + making;

    if (_itemNameController.text.isNotEmpty && totalVori > 0) {
      setState(() {
        _boughtItems.add(JewelryItem(
          name: _itemNameController.text,
          itemType: _selectedItemType,
          karat: _selectedKarat,
          vori: vori, ana: ana, rati: rati, point: point, gram: gram,
          totalVori: totalVori,
          pricePerVori: rate,
          makingCharge: making,
          totalPrice: totalPrice,
        ));
        _itemNameController.clear();
        _voriController.text = '0'; _anaController.text = '0';
        _ratiController.text = '0'; _pointController.text = '0';
        _gramController.text = '0'; _rateController.text = '0';
        _makingChargeController.text = '0';
      });
      _calculateInvoice();
    }
  }

  void _addExchangeItem() {
    double vori = double.tryParse(_exVoriController.text) ?? 0;
    double ana = double.tryParse(_exAnaController.text) ?? 0;
    double rati = double.tryParse(_exRatiController.text) ?? 0;
    double point = double.tryParse(_exPointController.text) ?? 0;
    double gram = double.tryParse(_exGramController.text) ?? 0;
    double rate = double.tryParse(_exRateController.text) ?? 0;

    double totalVori = vori + (ana / 16.0) + (rati / 96.0) + (point / 960.0) + (gram / 11.664);
    double amount = totalVori * rate;

    if (_exNameController.text.isNotEmpty && totalVori > 0) {
      setState(() {
        _exchangedItems.add(JewelryItem(
          name: _exNameController.text,
          itemType: _exItemType,
          vori: vori, ana: ana, rati: rati, point: point, gram: gram,
          totalVori: totalVori,
          isExchange: true,
          exchangeType: _exType,
          exchangeRate: rate,
          exchangeAmount: _exType == 'দাম অনুযায়ী' ? amount : 0,
        ));
        _exNameController.clear();
        _exVoriController.text = '0'; _exAnaController.text = '0';
        _exRatiController.text = '0'; _exPointController.text = '0';
        _exGramController.text = '0'; _exRateController.text = '0';
      });
      _calculateInvoice();
    }
  }

  Future<void> _saveInvoice() async {
    if (_formKey.currentState!.validate() && _boughtItems.isNotEmpty) {
      final newMemo = Memo(
        memoNo: _memoNoController.text,
        customerName: _customerNameController.text,
        customerPhone: _customerPhoneController.text,
        customerAddress: _customerAddressController.text,
        date: DateTime.now().toString().substring(0, 10),
        subTotal: _subTotal,
        discount: double.tryParse(_discountController.text) ?? 0,
        grandTotal: _grandTotal,
        paidAmount: double.tryParse(_paidAmountController.text) ?? 0,
        dueAmount: _dueAmount,
        items: _boughtItems,
        exchangeItems: _exchangedItems,
      );

      await DatabaseHelper.instance.insertMemo(newMemo);
      
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('মেমোটি সফলভাবে ডেটাবেজে সেভ হয়েছে!')),
      );

      setState(() {
        _boughtItems.clear();
        _exchangedItems.clear();
        _customerNameController.clear();
        _customerPhoneController.clear();
        _customerAddressController.clear();
        _discountController.text = '0';
        _paidAmountController.text = '0';
        _memoNoController.text = 'MEMO-${DateTime.now().millisecondsSinceEpoch.toString().substring(7)}';
      });
      _calculateInvoice();
    }
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('সেলস বিলিং কাউন্টার'),
        backgroundColor: Colors.amber.shade900,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                color: Colors.white,
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('কাস্টমার বিবরণী:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _memoNoController, decoration: const InputDecoration(labelText: 'মেমো নং'))),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _customerNameController, decoration: const InputDecoration(labelText: 'নাম'), validator: (v) => v!.isEmpty ? 'নাম দিন' : null)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _customerPhoneController, decoration: const InputDecoration(labelText: 'মোবাইল'), keyboardType: TextInputType.phone, validator: (v) => v!.isEmpty ? 'মোবাইল দিন' : null)),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _customerAddressController, decoration: const InputDecoration(labelText: 'ঠিকানা'), validator: (v) => v!.isEmpty ? 'ঠিকানা দিন' : null)),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('১. নতুন বিক্রিত গহনা:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.blue)),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedItemType,
                              decoration: const InputDecoration(labelText: 'মেটাল'),
                              items: ['সোনা', 'রূপা', 'অন্যান্য'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setState(() => _selectedItemType = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _selectedKarat,
                              decoration: const InputDecoration(labelText: 'ক্যারেট'),
                              items: _karatList.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(),
                              onChanged: (val) {
                                setState(() => _selectedKarat = val!);
                                _updateAutoRate(val!);
                              },
                            ),
                          ),
                        ],
                      ),
                      TextFormField(controller: _itemNameController, decoration: const InputDecoration(labelText: 'গহনার নাম/বিবরণ')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _voriController, decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _anaController, decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _ratiController, decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _pointController, decoration: const InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _gramController, decoration: const InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
                        ],
                      ),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _rateController, decoration: const InputDecoration(labelText: 'দর (অটো/হাতে লিখুন)'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 10),
                          Expanded(child: TextFormField(controller: _makingChargeController, decoration: const InputDecoration(labelText: 'মজুরি'), keyboardType: TextInputType.number)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _addBoughtItem,
                        icon: const Icon(Icons.add_shopping_cart, color: Colors.white),
                        label: const Text('তালিকায় যুক্ত করুন', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.blue.shade700),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Card(
                elevation: 3,
                child: Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text('২. পুরাতন গহনা/পাকা মেটাল জমা:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: Colors.deepOrange)),
                      const Divider(),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _exItemType,
                              decoration: const InputDecoration(labelText: 'মেটাল টাইপ'),
                              items: ['সোনা', 'রূপা', 'অন্যান্য'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setState(() => _exItemType = val!),
                            ),
                          ),
                          const SizedBox(width: 10),
                          Expanded(
                            child: DropdownButtonFormField<String>(
                              value: _exType,
                              decoration: const InputDecoration(labelText: 'জমার ধরন'),
                              items: ['পাকা/খাঁটি', 'দাম অনুযায়ী'].map((t) => DropdownMenuItem(value: t, child: Text(t))).toList(),
                              onChanged: (val) => setState(() => _exType = val!),
                            ),
                          ),
                        ],
                      ),
                      TextFormField(controller: _exNameController, decoration: const InputDecoration(labelText: 'পুরাতন বিবরণ')),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          Expanded(child: TextFormField(controller: _exVoriController, decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _exAnaController, decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _exRatiController, decoration: const InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _exPointController, decoration: const InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                          const SizedBox(width: 5),
                          Expanded(child: TextFormField(controller: _exGramController, decoration: const InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
                        ],
                      ),
                      TextFormField(controller: _exRateController, decoration: const InputDecoration(labelText: 'দর (দাম অনুযায়ী হলে)'), keyboardType: TextInputType.number),
                      const SizedBox(height: 10),
                      ElevatedButton.icon(
                        onPressed: _addExchangeItem,
                        icon: const Icon(Icons.add_moderator, color: Colors.white),
                        label: const Text('পুরাতন তালিকাভুক্ত করুন', style: TextStyle(color: Colors.white)),
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.deepOrange.shade700),
                      )
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),

              if (_boughtItems.isNotEmpty) ...[
                const Text('বিক্রিত পণ্যের তালিকা:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                ..._boughtItems.map((item) => ListTile(
                  title: Text('${item.name} (${item.karat})'),
                  subtitle: Text('${item.totalVori.toStringAsFixed(3)} ভরি @ ${item.pricePerVori.toStringAsFixed(0)} ৳'),
                  trailing: Text('${item.totalPrice.toStringAsFixed(0)} ৳'),
                )).toList(),
              ],
              const Divider(),
              if (_exchangedItems.isNotEmpty) ...[
                const Text('জমা হওয়া মালের তালিকা:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                ..._exchangedItems.map((item) => ListTile(
                  title: Text('${item.name} (${item.exchangeType})'),
                  subtitle: Text('${item.totalVori.toStringAsFixed(3)} ভরি ${item.exchangeRate > 0 ? "@ ${item.exchangeRate.toStringAsFixed(0)} ৳" : "(ওজন বিয়োগ)"}'),
                  trailing: Text(item.exchangeType == 'দাম অনুযায়ী' ? '-${item.exchangeAmount.toStringAsFixed(0)} ৳' : 'ওজন জমা', style: const TextStyle(color: Colors.red)),
                )).toList(),
              ],
              const SizedBox(height: 25),

              Card(
                color: Colors.amber.shade50,
                elevation: 4,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    children: [
                      _buildSummaryRow('মোট অর্ডারের মূল্য:', '${_subTotal.toStringAsFixed(2)} ৳'),
                      _buildSummaryRow('পাকা সোনা জমা (ওজন বিয়োগ):', '${_totalPureExchangedVori.toStringAsFixed(3)} ভরি'),
                      _buildSummaryRow('পুরাতন মাল বাবদ জমা টাকা:', '${_totalExchangedCash.toStringAsFixed(2)} ৳'),
                      TextFormField(controller: _discountController, decoration: const InputDecoration(labelText: 'ডিসকাউন্ট (টাকা)'), keyboardType: TextInputType.number, onChanged: (_) => _calculateInvoice()),
                      const Divider(),
                      _buildSummaryRow('সর্বমোট বিল (Grand Total):', '${_grandTotal.toStringAsFixed(2)} ৳', isBold: true),
                      TextFormField(controller: _paidAmountController, decoration: const InputDecoration(labelText: 'নগদ গ্রহণ (টাকা)'), keyboardType: TextInputType.number, onChanged: (_) => _calculateInvoice()),
                      const Divider(),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('বাকি/Due Amount:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _dueAmount > 0 ? Colors.red : Colors.green)),
                          Text('${_dueAmount.toStringAsFixed(2)} ৳', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: _dueAmount > 0 ? Colors.red : Colors.green)),
                        ],
                      ),
                      const SizedBox(height: 20),
                      ElevatedButton(
                        onPressed: _saveInvoice,
                        style: ElevatedButton.styleFrom(backgroundColor: Colors.amber.shade900, minimumSize: const Size(double.infinity, 45)),
                        child: const Text('ফাইনাল মেমো প্রিন্ট ও সেভ করুন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSummaryRow(String label, String value, {bool isBold = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4.0),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(label, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
          Text(value, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        ],
      ),
    );
  }
}
