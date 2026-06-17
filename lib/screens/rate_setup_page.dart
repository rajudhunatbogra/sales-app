import 'package:flutter/material.dart';
import '../database/database_helper.dart';

class RateSetupPage extends StatefulWidget {
  const RateSetupPage({Key? key}) : super(key: key);

  @override
  State<RateSetupPage> createState() => _RateSetupPageState();
}

class _RateSetupPageState extends State<RateSetupPage> {
  final _formKey = GlobalKey<FormState>();
  bool _isLoading = true;

  // আপনার দেওয়া ১০টি ক্যারেটের নিখুঁত তালিকা অনুযায়ী কন্ট্রোলার ম্যাপ
  final Map<String, TextEditingController> _controllers = {
    '১৮ ক্যারেট বাংলা': TextEditingController(text: '0'),
    '১৮ ক্যারেট কেডিয়াম': TextEditingController(text: '0'),
    '১৮ ক্যারেট হলমার্ক': TextEditingController(text: '0'),
    '২০ ক্যারেট বাংলা': TextEditingController(text: '0'),
    '২০ ক্যারেট কেডিয়াম': TextEditingController(text: '0'),
    '২১ ক্যারেট বাংলা': TextEditingController(text: '0'),
    '২১ ক্যারেট কেডিয়াম': TextEditingController(text: '0'),
    '২১ ক্যারেট হলমার্ক': TextEditingController(text: '0'),
    '২২ ক্যারেট কেডিয়াম': TextEditingController(text: '0'),
    '২২ ক্যারেট হলমার্ক': TextEditingController(text: '0'),
  };

  @override
  void initState() {
    super.initState();
    _loadExistingRates();
  }

  // ডাটাবেজে আগে থেকে কোনো রেট সেভ করা থাকলে তা বক্সে লোড করার মেথড
  Future<void> _loadExistingRates() async {
    final savedRates = await DatabaseHelper.instance.fetchAllRates();
    if (savedRates.isNotEmpty) {
      savedRates.forEach((karat, rate) {
        if (_controllers.containsKey(karat)) {
          _controllers[karat]!.text = rate.toStringAsFixed(0);
        }
      });
    }
    setState(() => _isLoading = false);
  }
  // ১০টি ক্যারেটের রেট একসাথে ডাটাবেজে সেভ করার মেথড
  Future<void> _saveAllRates() async {
    if (_formKey.currentState!.validate()) {
      setState(() => _isLoading = true);
      
      for (var entry in _controllers.entries) {
        double rate = double.tryParse(entry.value.text) ?? 0.0;
        await DatabaseHelper.instance.saveRate(entry.key, rate);
      }
      
      setState(() => _isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('আজকের বাজুস/আঞ্চলিক রেট সফলভাবে আপডেট হয়েছে!')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('প্রতিদিনের মূল্য/রেট সেটআপ'),
        backgroundColor: Colors.amber.shade900,
        actions: [
          if (!_isLoading)
            IconButton(
              icon: const Icon(Icons.save, color: Colors.white),
              onPressed: _saveAllRates,
            )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Card(
                      color: Colors.amber.shade50,
                      child: const Padding(
                        padding: EdgeInsets.all(12.0),
                        child: Row(
                          children: [
                            Icon(Icons.info, color: Colors.amber),
                            SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                'এখানে আপনার তালিকা অনুযায়ী ১০টি ক্যারেটের আজকের বাজার দর (প্রতি ভরি) ইনপুট দিন। বিল করার সময় এই দর স্বয়ংক্রিয়ভাবে চলে যাবে, তবে প্রয়োজনে বিলের ঘরেও দাম হাতে পরিবর্তন করা যাবে।',
                                style: TextStyle(fontSize: 13, color: Colors.black87),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 15),
                    const Text(
                      'ক্যারেট ও মূল্য তালিকা (ভরি প্রতি টাকা):',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                    const Divider(),
                    const SizedBox(height: 10),
                    // ১০টি ক্যারেটের জন্য ডাইনামিক ইনপুট বক্স জেনারেটর
                    ..._controllers.entries.map((entry) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 12.0),
                        child: Row(
                          children: [
                            Expanded(
                              flex: 2,
                              child: Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.grey.shade100,
                                  borderRadius: BorderRadius.circular(8),
                                  border: Border.all(color: Colors.grey.shade300),
                                ),
                                child: Text(
                                  entry.key,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              flex: 3,
                              child: TextFormField(
                                controller: entry.value,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: 'মূল্য (টাকা)',
                                  suffixText: '৳',
                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
                                ),
                                validator: (val) {
                                  if (val == null || val.isEmpty) return 'দাম লিখুন';
                                  if (double.tryParse(val) == null) return 'সঠিক সংখ্যা দিন';
                                  return null;
                                },
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                    const SizedBox(height: 25),
                    ElevatedButton.icon(
                      onPressed: _saveAllRates,
                      icon: const Icon(Icons.check_circle, color: Colors.white),
                      label: const Text('আজকের রেট সংরক্ষণ করুন', style: TextStyle(color: Colors.white, fontSize: 16)),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.amber.shade900,
                        minimumSize: const Size(double.infinity, 50),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                      ),
                    ),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
    );
  }

  @override
  void dispose() {
    for (var controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }
}
