import 'package:flutter/material.dart';
import '../models/memo_model.dart';
import '../database/database_helper.dart';

class MemoHistoryPage extends StatefulWidget {
  const MemoHistoryPage({Key? key}) : super(key: key);

  @override
  State<MemoHistoryPage> createState() => _MemoHistoryPageState();
}

class _MemoHistoryPageState extends State<MemoHistoryPage> {
  final _searchController = TextEditingController();
  List<Memo> _allMemos = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadMemos();
  }

  // সব মেমো ডাটাবেজ থেকে লোড করার মেথড
  Future<void> _loadMemos() async {
    setState(() => _isLoading = true);
    final memos = await DatabaseHelper.instance.fetchMemos();
    setState(() {
      _allMemos = memos;
      _isLoading = false;
    });
  }

  // নাম, মোবাইল, ঠিকানা বা মেমো নাম্বার দিয়ে অ্যাডভান্সড লাইভ সার্চ মেথড
  Future<void> _searchMemos(String text) async {
    if (text.isEmpty) {
      _loadMemos();
      return;
    }
    final filteredMemos = await DatabaseHelper.instance.searchMemos(text);
    setState(() {
      _allMemos = filteredMemos;
    });
  }

  // মেমো ডিলিট করার মেথড
  Future<void> _deleteMemo(int id) async {
    await DatabaseHelper.instance.deleteMemo(id);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('মেমোটি সফলভাবে ডিলিট করা হয়েছে')),
    );
    _loadMemos();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('মেমো সার্চ ও ইতিহাস'),
        backgroundColor: Colors.amber.shade900,
      ),
      body: Column(
        children: [
          // অ্যাডভান্সড সার্চ ফিল্ড কন্টেইনার
          Container(
            padding: const EdgeInsets.all(12.0),
            color: Colors.amber.shade50,
            child: TextField(
              controller: _searchController,
              onChanged: (value) => _searchMemos(value),
              decoration: InputDecoration(
                labelText: 'নাম, মোবাইল, ঠিকানা বা মেমো নং দিয়ে সার্চ করুন...',
                hintText: 'উদা: রাজু, ০১৭xxxxxxxx, বগুড়া',
                prefixIcon: const Icon(Icons.search, color: Colors.amber),
                suffixIcon: _searchController.text.isNotEmpty
                    ? IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          _loadMemos();
                        },
                      )
                    : null,
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                fillColor: Colors.white,
                filled: true,
              ),
            ),
          ),
          
          // লাইভ মেমো লিস্ট ভিউ
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _allMemos.isEmpty
                    ? const Center(child: Text('কোনো মেমো বা বিল খুঁজে পাওয়া যায়নি!'))
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _allMemos.length,
                        itemBuilder: (context, index) {
                          final memo = _allMemos[index];
                          return Card(
                            elevation: 3,
                            margin: const EdgeInsets.only(bottom: 12),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: ExpansionTile(
                              leading: CircleAvatar(
                                backgroundColor: Colors.amber.shade800,
                                child: const Icon(Icons.description, color: Colors.white),
                              ),
                              title: Text(memo.customerName, style: const TextStyle(fontWeight: FontWeight.bold)),
                              subtitle: Text('মেমো: ${memo.memoNo}\nমোবাইল: ${memo.customerPhone}\nতারিখ: ${memo.date}'),
                              trailing: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text('${memo.grandTotal.toStringAsFixed(0)} ৳', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green, fontSize: 15)),
                                  if (memo.dueAmount > 0)
                                    Text('বাকি: ${memo.dueAmount.toStringAsFixed(0)} ৳', style: const TextStyle(color: Colors.red, fontSize: 11, fontWeight: FontWeight.bold))
                                  else
                                    const Text('পরিশোধিত', style: TextStyle(color: Colors.blue, fontSize: 11)),
                                ],
                              ),
                              children: [
                                const Divider(),
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text('ঠিকানা: ${memo.customerAddress}', style: const TextStyle(color: Colors.black87)),
                                      const SizedBox(height: 6),
                                      Text('মোট বিল: ${memo.subTotal.toStringAsFixed(0)} ৳ | ছাড়: ${memo.discount.toStringAsFixed(0)} ৳', style: const TextStyle(fontWeight: FontWeight.bold)),
                                      Text('নগদ গ্রহণ: ${memo.paidAmount.toStringAsFixed(0)} ৳', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                                      const SizedBox(height: 8),
                                      const Text('পণ্যসমূহের বিবরণী:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                                      ...memo.items.map((item) => Text('- ${item.name} (${item.karat}): ${item.totalVori.toStringAsFixed(3)} ভরি @ ${item.pricePerVori.toStringAsFixed(0)} ৳')).toList(),
                                      
                                      // যদি এই মেমোতে কোনো পুরাতন/পাকা গহনা জমা থাকে
                                      if (memo.exchangeItems.isNotEmpty) ...[
                                        const SizedBox(height: 8),
                                        const Text('জমা/এক্সচেঞ্জ বিবরণী:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepOrange)),
                                        ...memo.exchangeItems.map((item) => Text('- ${item.name} (${item.exchangeType}): ${item.totalVori.toStringAsFixed(3)} ভরি ${item.exchangeAmount > 0 ? "(${item.exchangeAmount.toStringAsFixed(0)} ৳)" : "(ওজন বিয়োগ)"}')).toList(),
                                      ],
                                      const Divider(),
                                      Align(
                                        alignment: Alignment.centerRight,
                                        child: IconButton(
                                          icon: const Icon(Icons.delete_forever, color: Colors.red),
                                          onPressed: () {
                                            showDialog(
                                              context: context,
                                              builder: (ctx) => AlertDialog(
                                                title: const Text('মেমো ডিলিট নিশ্চিতকরণ'),
                                                content: const Text('আপনি কি নিশ্চিতভাবেই এই মেমোটি চিরতরে ডিলিট করতে চান?'),
                                                actions: [
                                                  TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('না')),
                                                  TextButton(
                                                    onPressed: () {
                                                      Navigator.pop(ctx);
                                                      _deleteMemo(memo.id!);
                                                    },
                                                    child: const Text('হ্যাঁ, ডিলিট করুন', style: TextStyle(color: Colors.red)),
                                                  ),
                                                ],
                                              ),
                                            );
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
