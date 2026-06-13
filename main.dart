import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(primaryColor: Colors.amber, primarySwatch: Colors.amber),
      home: SalesPage(),
    ));

// একাধিক পণ্য এবং তাদের কাস্টম ওজন ট্র্যাক করার মডেল
class ProductItem {
  TextEditingController nameCt = TextEditingController();
  TextEditingController voriCt = TextEditingController();
  TextEditingController anaCt = TextEditingController();
  TextEditingController ratiCt = TextEditingController();
  TextEditingController pointCt = TextEditingController();
  TextEditingController gramCt = TextEditingController();
  bool isGramInput = false; // কোন মোডে ইনপুট হচ্ছে তা চেনার জন্য
}

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final Map<String, TextEditingController> ct = {
    'sl': TextEditingController(), 'name': TextEditingController(),
    'address': TextEditingController(), 'phone': TextEditingController(),
    'rate': TextEditingController(), 'itemTotalPrice': TextEditingController(), 
    'totalW': TextEditingController(), 'voriW': TextEditingController(), 
    'fixedW': TextEditingController(), 'customK': TextEditingController(), 
    'totalBill': TextEditingController(), 'cashPaid': TextEditingController(), 
    'bankPaid': TextEditingController(), 'advancePaid': TextEditingController(), 
    'dueAmount': TextEditingController(), 'paymentStatus': TextEditingController(),
    // পুরাতন স্বর্ণ/রুপার কন্ট্রোলার
    'oldItemName': TextEditingController(),
    'oldVori': TextEditingController(), 'oldAna': TextEditingController(),
    'oldRati': TextEditingController(), 'oldPoint': TextEditingController(), 'oldGram': TextEditingController(),
    'oldRate': TextEditingController(), 'oldGoldPrice': TextEditingController(),
    // খাঁটি/পাকা স্বর্ণ/রুপার কন্ট্রোলার
    'pakaVori': TextEditingController(), 'pakaAna': TextEditingController(),
    'pakaRati': TextEditingController(), 'pakaPoint': TextEditingController(), 'pakaGram': TextEditingController(),
    'pakaRate': TextEditingController(), 'pakaGoldPrice': TextEditingController(),
  };

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = ['উৎপাদিত নতুন গহনা', 'কেনা নতুন গহনা', 'পুরাতন গহনা', 'বন্ধকী গহনা', 'অন্যান্য খাত (নিচে লিখুন)'];
  String selectedCarat = '২১ ক্যারেট হলমার্ক';
  final List<String> caratOptions = ['১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক', '২২ ক্যারেট হলমার্ক'];
  
  List<Map<String, dynamic>> savedSalesList = [];
  List<Map<String, dynamic>> filteredSalesList = []; // সার্চিং এর জন্য
  List<ProductItem> products = [ProductItem()]; // ডিফল্ট ১টি পণ্য
  
  TextEditingController searchCt = TextEditingController();
  bool _isListenerBlocked = false;
  int? editingIndex; // মেমো এডিটিং ট্র্যাক করার জন্য কাস্টম ভেরিয়েবল

  @override
  void initState() {
    super.initState();
    List<String> keys = [
      'rate', 'voriW', 'fixedW', 'totalBill', 'cashPaid', 'bankPaid', 'advancePaid',
      'oldVori', 'oldAna', 'oldRati', 'oldPoint', 'oldRate',
      'pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint', 'pakaRate'
    ];
    for (var k in keys) {
      ct[k]?.addListener(_calculate);
    }
    _addProductListeners(products[0]);
    
    ct['oldGram']?.addListener(() => _convertGramToVoriManual('oldGram', ['oldVori', 'oldAna', 'oldRati', 'oldPoint']));
    ct['pakaGram']?.addListener(() => _convertGramToVoriManual('pakaGram', ['pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint']));
    
    searchCt.addListener(_runSearch);
  }
  void _addProductListeners(ProductItem item) {
    // ভরি, আনা, রতি পরিবর্তন হলে গ্রামে কনভার্ট হবে
    void listenVori() {
      if (_isListenerBlocked || item.isGramInput) return;
      double v = double.tryParse(item.voriCt.text) ?? 0;
      double a = double.tryParse(item.anaCt.text) ?? 0;
      double r = double.tryParse(item.ratiCt.text) ?? 0;
      double p = double.tryParse(item.pointCt.text) ?? 0;
      
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      double totalGram = totalVori * 11.664;
      
      _isListenerBlocked = true;
      // যদি সব ইনপুট ফাঁকা করে দেওয়া হয়, তবে গ্রামও ফাঁকা হবে
      if (item.voriCt.text.isEmpty && item.anaCt.text.isEmpty && item.ratiCt.text.isEmpty && item.pointCt.text.isEmpty) {
        item.gramCt.text = '';
      } else {
        item.gramCt.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
      }
      _isListenerBlocked = false;
      _calculate();
    }

    // গ্রামের ঘরে সরাসরি লিখলে ভরি, আনা, রতিতে কনভার্ট হবে
    void listenGram() {
      if (_isListenerBlocked) return;
      if (item.gramCt.text.isEmpty) {
        _isListenerBlocked = true;
        item.voriCt.text = ''; item.anaCt.text = ''; item.ratiCt.text = ''; item.pointCt.text = '';
        _isListenerBlocked = false;
        _calculate();
        return;
      }
      item.isGramInput = true;
      double gram = double.tryParse(item.gramCt.text) ?? 0;
      double totalVori = gram / 11.664;
      int vori = totalVori.floor();
      double remainingVori = totalVori - vori;
      double totalAna = remainingVori * 16;
      int ana = totalAna.floor();
      double remainingAna = totalAna - ana;
      double totalRati = remainingAna * 6;
      int rati = totalRati.floor();
      double remainingRati = totalRati - rati;
      int point = (remainingRati * 10).round();

      _isListenerBlocked = true;
      item.voriCt.text = vori > 0 ? vori.toString() : '';
      item.anaCt.text = ana > 0 ? ana.toString() : '';
      item.ratiCt.text = rati > 0 ? rati.toString() : '';
      item.pointCt.text = point > 0 ? point.toString() : '';
      _isListenerBlocked = false;
      _calculate();
    }

    item.voriCt.addListener(listenVori);
    item.anaCt.addListener(listenVori);
    item.ratiCt.addListener(listenVori);
    item.pointCt.addListener(listenVori);
    item.gramCt.addListener(listenGram);
    
    // গ্রামে টাচ বা ক্লিক করলে ফ্ল্যাগ রিসেট হবে যেন একে অপরের পরিপূরক হিসেবে কাজ করে
    item.voriCt.addListener(() { if(item.voriCt.text.isNotEmpty) item.isGramInput = false; });
  }

  void _convertGramToVoriManual(String gramKey, List<String> voriKeys) {
    if (_isListenerBlocked) return;
    if (ct[gramKey]!.text.isEmpty) {
      _isListenerBlocked = true;
      for (var k in voriKeys) ct[k]!.text = '';
      _isListenerBlocked = false;
      _calculate();
      return;
    }
    _isListenerBlocked = true;
    double gram = double.tryParse(ct[gramKey]!.text) ?? 0;
    double totalVori = gram / 11.664;
    int vori = totalVori.floor();
    double remainingVori = totalVori - vori;
    double totalAna = remainingVori * 16;
    int ana = totalAna.floor();
    double remainingAna = totalAna - ana;
    double totalRati = remainingAna * 6;
    int rati = totalRati.floor();
    double remainingRati = totalRati - rati;
    int point = (remainingRati * 10).round();

    ct[voriKeys[0]]!.text = vori > 0 ? vori.toString() : '';
    ct[voriKeys[1]]!.text = ana > 0 ? ana.toString() : '';
    ct[voriKeys[2]]!.text = rati > 0 ? rati.toString() : '';
    ct[voriKeys[3]]!.text = point > 0 ? point.toString() : '';
    _isListenerBlocked = false;
    _calculate();
  }
  void _calculate() {
    if (_isListenerBlocked) return;
    _isListenerBlocked = true;

    double sumNewVori = 0;
    // ১ নম্বর রিকোয়ারমেন্ট: সব প্রোডাক্টের ওজন একত্রে যোগ করা হচ্ছে
    for (var prod in products) {
      double v = double.tryParse(prod.voriCt.text) ?? 0;
      double a = double.tryParse(prod.anaCt.text) ?? 0;
      double r = double.tryParse(prod.ratiCt.text) ?? 0;
      double p = double.tryParse(prod.pointCt.text) ?? 0;
      sumNewVori += v + (a / 16) + (r / 96) + (p / 960);
    }

    // পুরাতন জমার হিসাব
    double ov = double.tryParse(ct['oldVori']!.text) ?? 0;
    double oa = double.tryParse(ct['oldAna']!.text) ?? 0;
    double or = double.tryParse(ct['oldRati']!.text) ?? 0;
    double op = double.tryParse(ct['oldPoint']!.text) ?? 0;
    double oRate = double.tryParse(ct['oldRate']!.text) ?? 0;
    double totalOldVori = ov + (oa / 16) + (or / 96) + (op / 960);
    double oldPrice = totalOldVori * oRate;
    ct['oldGoldPrice']!.text = oldPrice > 0 ? oldPrice.toStringAsFixed(2) : '';

    // ৩ নম্বর রিকোয়ারমেন্ট: পাকা/খাঁটি সোনার ওজনের উপর ভিত্তি করে বিবরণ ও হিসাব
    double pv = double.tryParse(ct['pakaVori']!.text) ?? 0;
    double pa = double.tryParse(ct['pakaAna']!.text) ?? 0;
    double pr = double.tryParse(ct['pakaRati']!.text) ?? 0;
    double pp = double.tryParse(ct['pakaPoint']!.text) ?? 0;
    double pRate = double.tryParse(ct['pakaRate']!.text) ?? 0;
    double totalPakaVori = pv + (pa / 16) + (pr / 96) + (pp / 960);
    double pakaPrice = totalPakaVori * pRate;
    ct['pakaGoldPrice']!.text = pakaPrice > 0 ? pakaPrice.toStringAsFixed(2) : '';

    // ওজন কর্তন লজিক
    double payableVori = sumNewVori;
    if (totalPakaVori > 0) {
      payableVori = sumNewVori - totalPakaVori;
      if (payableVori < 0) payableVori = 0;
    }

    double rate = double.tryParse(ct['rate']!.text) ?? 0;
    double itemPrice = payableVori * rate;
    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;
    double totalWages = (sumNewVori * vw) + fw; // মজুরি মোট ওজনের ওপর হবে

    ct['itemTotalPrice']!.text = itemPrice > 0 ? itemPrice.toStringAsFixed(2) : '';
    ct['totalW']!.text = totalWages > 0 ? totalWages.toStringAsFixed(2) : '';

    double cash = double.tryParse(ct['cashPaid']!.text) ?? 0;
    double bank = double.tryParse(ct['bankPaid']!.text) ?? 0;
    double adv = double.tryParse(ct['advancePaid']!.text) ?? 0;

    double bill = itemPrice + totalWages;
    if (ct['totalBill']!.text.isEmpty || bill > 0) {
      ct['totalBill']!.text = bill > 0 ? bill.toStringAsFixed(2) : '';
    }

    double currentBill = double.tryParse(ct['totalBill']!.text) ?? 0;
    // খাঁটি সোনা থাকলে শুধু মজুরি কাউন্ট হবে, পুরাতন থাকলে বিল থেকে প্রাইস বাদ যাবে
    double due = currentBill - (cash + bank + adv + (totalPakaVori > 0 ? 0 : oldPrice));
    
    ct['dueAmount']!.text = currentBill > 0 ? due.toStringAsFixed(2) : '';
    ct['paymentStatus']!.text = currentBill > 0 && due <= 0 ? 'পরিশোধিত' : 'বাকি আছে';

    _isListenerBlocked = false;
  }
  void _runSearch() {
    String query = searchCt.text.toLowerCase().trim();
    setState(() {
      if (query.isEmpty) {
        filteredSalesList = List.from(savedSalesList);
      } else {
        filteredSalesList = savedSalesList.where((memo) {
          return memo['sl'].toString() == query ||
              memo['date'].toString().contains(query) ||
              memo['name'].toString().toLowerCase().contains(query) ||
              memo['address'].toString().toLowerCase().contains(query) ||
              memo['phone'].toString().contains(query);
        }).toList();
      }
    });
  }

  void _submit() {
    if (ct['phone']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মোবাইল নাম্বার লিখুন!'), backgroundColor: Colors.red));
      return;
    }

    double pakaCheck = double.tryParse(ct['pakaGoldPrice']!.text) ?? 0;
    String tagLabel = pakaCheck > 0 ? '(খাঁটি/পাকা ওজন কর্তনকৃত)' : '(পুরাতন)';

    String productDetailsText = '';
    double totalCombinedGram = 0;
    for (int i = 0; i < products.length; i++) {
      double v = double.tryParse(products[i].voriCt.text) ?? 0;
      double a = double.tryParse(products[i].anaCt.text) ?? 0;
      double r = double.tryParse(products[i].ratiCt.text) ?? 0;
      double p = double.tryParse(products[i].pointCt.text) ?? 0;
      double g = double.tryParse(products[i].gramCt.text) ?? 0;
      totalCombinedGram += g > 0 ? g : (v + (a / 16) + (r / 96) + (p / 960)) * 11.664;

      productDetailsText += '${i + 1}. ${products[i].nameCt.text.isEmpty ? "গহনা" : products[i].nameCt.text} '
          '[${products[i].voriCt.text.isEmpty ? "0" : products[i].voriCt.text} ভরি, '
          '${products[i].anaCt.text.isEmpty ? "0" : products[i].anaCt.text} আনা, '
          '${products[i].ratiCt.text.isEmpty ? "0" : products[i].ratiCt.text} রতি, '
          '${products[i].pointCt.text.isEmpty ? "0" : products[i].pointCt.text} পয়েন্ট (${g.toStringAsFixed(3)} গ্রাম)]\n';
    }

    Map<String, dynamic> memoData = {
      'sl': ct['sl']!.text.isEmpty ? (savedSalesList.length + 1).toString() : ct['sl']!.text,
      'date': DateTime.now().toString().substring(0, 16),
      'name': ct['name']!.text, 'address': ct['address']!.text, 'phone': ct['phone']!.text,
      'carat': selectedCarat, 'khath': selectedKhath,
      'productsText': productDetailsText.trim(),
      'gram': totalCombinedGram.toStringAsFixed(3),
      'rate': ct['rate']!.text, 'itemPrice': ct['itemTotalPrice']!.text, 'wages': ct['totalW']!.text,
      'totalBill': ct['totalBill']!.text, 'cashPaid': ct['cashPaid']!.text, 'bankPaid': ct['bankPaid']!.text, 'advancePaid': ct['advancePaid']!.text,
      'dueAmount': ct['dueAmount']!.text, 'paymentStatus': ct['paymentStatus']!.text,
      'oldItemName': ct['oldItemName']!.text, 'oldGoldPrice': ct['oldGoldPrice']!.text, 'goldTag': tagLabel,
      'oldWeightText': '${ct['oldVori']!.text.isEmpty ? "0" : ct['oldVori']!.text} ভরি, ${ct['oldAna']!.text.isEmpty ? "0" : ct['oldAna']!.text} আনা, ${ct['oldRati']!.text.isEmpty ? "0" : ct['oldRati']!.text} রতি, ${ct['oldPoint']!.text.isEmpty ? "0" : ct['oldPoint']!.text} পয়েন্ট (${ct['oldGram']!.text} গ্রাম)',
      'pakaGoldPrice': ct['pakaGoldPrice']!.text,
      'pakaWeightText': '${ct['pakaVori']!.text.isEmpty ? "0" : ct['pakaVori']!.text} ভরি, ${ct['pakaAna']!.text.isEmpty ? "0" : ct['pakaAna']!.text} আনা, ${ct['pakaRati']!.text.isEmpty ? "0" : ct['pakaRati']!.text} রতি, ${ct['pakaPoint']!.text.isEmpty ? "0" : ct['pakaPoint']!.text} পয়েন্ট (${ct['pakaGram']!.text} গ্রাম)',
    };

    setState(() {
      if (editingIndex != null) {
        savedSalesList[editingIndex!] = memoData;
        editingIndex = null;
      } else {
        savedSalesList.add(memoData);
      }
      filteredSalesList = List.from(savedSalesList);
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('মেমো সফল হয়েছে!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        content: Text('ক্রমিক নং: ${ct['sl']!.text}\nক্রেতা: ${ct['name']!.text}\nমোট বিল: ৳${ct['totalBill']!.text}\nঅবস্থা: ${ct['paymentStatus']!.text}\n(ডাটা মেমরিতে অফলাইনে সুরক্ষিত রাখা হয়েছে)'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); _clear(); }, child: Text('ঠিক আছে'))],
      ),
    );
  }

  void _clear() {
    _isListenerBlocked = true;
    ct.values.forEach((c) => c.clear());
    products = [ProductItem()];
    _isListenerBlocked = false;
    setState(() {});
  }
  void _editMemo(int index) {
    Map<String, dynamic> memo = filteredSalesList[index];
    int originalIndex = savedSalesList.indexOf(memo);
    
    setState(() {
      editingIndex = originalIndex;
      ct['sl']!.text = memo['sl'] ?? '';
      ct['name']!.text = memo['name'] ?? '';
      ct['address']!.text = memo['address'] ?? '';
      ct['phone']!.text = memo['phone'] ?? '';
      selectedCarat = memo['carat'] ?? '২১ ক্যারেট হলমার্ক';
      selectedKhath = memo['khath'] ?? 'উৎপাদিত নতুন গহনা';
      ct['rate']!.text = memo['rate'] ?? '';
      ct['totalBill']!.text = memo['totalBill'] ?? '';
      ct['cashPaid']!.text = memo['cashPaid'] ?? '';
      ct['bankPaid']!.text = memo['bankPaid'] ?? '';
      ct['advancePaid']!.text = memo['advancePaid'] ?? '';
      products = [ProductItem()];
    });
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মেমো ডাটা এডিটর ফরমে লোড হয়েছে!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('জুয়েলারি বিক্রয় ও হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        actions: [
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.white),
            onPressed: () {
              setState(() { filteredSalesList = List.from(savedSalesList); });
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => StatefulBuilder(
                builder: (context, setModalState) => Scaffold(
                  appBar: AppBar(title: Text('বিক্রয় ও পরিপাটি মেমো তালিকা'), backgroundColor: Colors.amber),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: searchCt,
                          onChanged: (v) { setModalState(() { _runSearch(); }); },
                          decoration: InputDecoration(
                            labelText: 'ক্রমিক নং, তারিখ, নাম বা ঠিকানা দিয়ে খুঁজুন',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredSalesList.isEmpty 
                            ? Center(child: Text('কোনো মেমো খুঁজে পাওয়া যায়নি!')) 
                            : ListView.builder(
                                itemCount: filteredSalesList.length,
                                itemBuilder: (c, i) => Card(
                                  margin: EdgeInsets.all(10), elevation: 6,
                                  child: Padding(padding: EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('ক্রমিক নং: ${filteredSalesList[i]['sl']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                                      Text('তারিখ: ${filteredSalesList[i]['date']}', style: TextStyle(color: Colors.grey)),
                                    ]),
                                    Divider(thickness: 1.5),
                                    Text('ক্রেতার নাম: ${filteredSalesList[i]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('মোবাইল: ${filteredSalesList[i]['phone']} | ঠিকানা: ${filteredSalesList[i]['address']}'),
                                    Text('গহনার ক্যারেট: ${filteredSalesList[i]['carat']} | খাত: ${filteredSalesList[i]['khath']}'),
                                    Divider(),
                                    Text('📦 বিক্রয়কৃত গহনাসমূহের তালিকা ও বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                    Text(filteredSalesList[i]['productsText'] ?? '', style: TextStyle(fontSize: 13, height: 1.4)),
                                    Text('সব মিলিয়ে মোট নতুন ওজন: [ ${filteredSalesList[i]['gram']} গ্রাম ]', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo)),
                                    Text('ভরি প্রতি বিক্রয় দর: ৳${filteredSalesList[i]['rate']}'),
                                    Text('সোনা/রুপার নেট মূল্য ${filteredSalesList[i]['goldTag']}: ৳${filteredSalesList[i]['itemPrice']}'),
                                    Text('মোট মজুরি বাবদ যোগ: ৳${filteredSalesList[i]['wages']}'),
                                    if (filteredSalesList[i]['pakaWeightText'].toString().contains('ভরি') && !filteredSalesList[i]['pakaWeightText'].toString().startsWith('0 ভরি, 0 আনা')) ...[
                                      Divider(),
                                      Text('🌟 খাঁটি/পাকা स्वर्ण/রুপা জমার বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                                      Text('জমা খাঁটি ওজন: [ ${filteredSalesList[i]['pakaWeightText']} ]'),
                                      Text('খাঁটি স্বর্ণ/রুপার মূল্য (যা নতুন ওজন ও মূল্য থেকে কর্তন করা হয়েছে): ৳${filteredSalesList[i]['pakaGoldPrice']}'),
                                    ],
                                    if (filteredSalesList[i]['oldItemName'].toString().isNotEmpty) ...[
                                      Divider(),
                                      Text('🍂 পুরাতন স্বর্ণ/রুপা জমার বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                                      Text('জমা জিনিসের নাম: ${filteredSalesList[i]['oldItemName']}'),
                                      Text('পুরাতন গহনার ওজন: [ ${filteredSalesList[i]['oldWeightText']} ]'),
                                      Text('পুরাতন সোনা বাবদ ফাইনাল বাদ: ৳${filteredSalesList[i]['oldGoldPrice']}'),
                                    ],
                                    Divider(thickness: 1.5),
                                    Text('⚙️ বিলের সম্পূর্ণ হিসাব বিবরণী (যোগ-বিয়োগ ডিটেইল):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                    Text('• সর্বমোট বিল (নেট সোনার মূল্য + মজুরি): ৳${filteredSalesList[i]['totalBill']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.black)),
                                    Text('• [বাদ] নগদ জমা: ৳${filteredSalesList[i]['cashPaid']} | • [বাদ] ব্যাংক জমা: ৳${filteredSalesList[i]['bankPaid']}'),
                                    Text('• [বাদ] অগ্রিম জমা: ৳${filteredSalesList[i]['advancePaid']}'),
                                    Divider(),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('মোট বকেয়া/বাকি: ৳${filteredSalesList[i]['dueAmount']}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                                      Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), color: filteredSalesList[i]['paymentStatus'] == 'পরিশোধিত' ? Colors.green : Colors.orange, child: Text(filteredSalesList[i]['paymentStatus'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    ]),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () { _editMemo(i); },
                                          icon: Icon(Icons.edit, size: 16),
                                          label: Text('এডিট করুন'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.blue, foregroundColor: Colors.white),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            String shareText = 'মেমো নং: ${filteredSalesList[i]['sl']}\nক্রেতা: ${filteredSalesList[i]['name']}\nফোন: ${filteredSalesList[i]['phone']}\nমোট বিল: ৳${filteredSalesList[i]['totalBill']}\nবাকি: ৳${filteredSalesList[i]['dueAmount']}';
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মেমোর বিবরণ ক্লিপবোর্ডে কপি হয়েছে! আপনি এখন যেকোনো ইমেইল বা মেসেঞ্জারে পেস্ট করতে পারেন।')));
                                          },
                                          icon: Icon(Icons.share, size: 16),
                                          label: Text('মেমো পাঠান'),
                                          style: ElevatedButton.styleFrom(backgroundColor: Colors.purple, foregroundColor: Colors.white),
                                        ),
                                      ],
                                    )
                                  ])),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              )));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editingIndex != null)
              Container(
                width: double.infinity, color: Colors.red.shade100, padding: EdgeInsets.all(8),
                child: Text('⚠️ আপনি এখন ক্রমিক নং ${ct['sl']!.text} এর মেমোটি এডিট করছেন!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            Card(elevation: 3, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['sl'], decoration: InputDecoration(labelText: '১. ক্রমিক নাম্বার (ফাঁকা রাখলে অটো)')),
              TextField(controller: ct['name'], decoration: InputDecoration(labelText: 'ক্রেতার নাম')),
              TextField(controller: ct['address'], decoration: InputDecoration(labelText: 'ঠিকানা')),
              TextField(controller: ct['phone'], decoration: InputDecoration(labelText: 'মোবাইল নাম্বার'), keyboardType: TextInputType.phone),
            ]))),
            SizedBox(height: 15),
            Text('২. পণ্যের বিবরণ ও ওজনসমূহ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
            ListView.builder(
              shrinkWrap: true,
              physics: NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (ctx, index) {
                return Card(
                  margin: EdgeInsets.symmetric(vertical: 5),
                  color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text('পণ্য নম্বর: ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                            if (products.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () { setState(() { products.removeAt(index); _calculate(); }); },
                              )
                          ],
                        ),
                        TextField(controller: products[index].nameCt, decoration: InputDecoration(labelText: 'পণ্যের নাম (যেমন: চেন, আংটি, দুল)')),
                        SizedBox(height: 8),
                        Text('ওজন হিসাব (ভরি, আনা, রতি, পয়েন্ট):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 13)),
                        Row(children: [
                          Expanded(child: TextField(controller: products[index].voriCt, decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].anaCt, decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].ratiCt, decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].pointCt, decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].gramCt, decoration: InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: () { setState(() { var p = ProductItem(); products.add(p); _addProductListeners(p); }); },
              icon: Icon(Icons.add_circle, color: Colors.green),
              label: Text('আরো পণ্য ও ওজন যোগ করুন', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 15),
            TextField(controller: ct['rate'], decoration: InputDecoration(labelText: 'সোনা/রুপার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['itemTotalPrice'], readOnly: true, decoration: InputDecoration(labelText: 'সোনা/রুপার মোট দাম (৳)'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            TextField(controller: ct['voriW'], decoration: InputDecoration(labelText: 'ভরি প্রতি মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['fixedW'], decoration: InputDecoration(labelText: 'ফিক্সড মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['totalW'], readOnly: true, decoration: InputDecoration(labelText: 'মোট মজুরি (৳)')),
            SizedBox(height: 15),
            DropdownButton<String>(
              value: selectedKhath, isExpanded: true,
              items: khathOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (n) => setState(() => selectedKhath = n!),
            ),
            if (selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)') TextField(controller: ct['customK'], decoration: InputDecoration(labelText: 'খাতের নাম')),
            SizedBox(height: 20),
            Text('৬. পুরাতন স্বর্ণ/রুপা জমার বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
            Card(color: Colors.brown.shade50, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['oldItemName'], decoration: InputDecoration(labelText: 'পুরাতন স্বর্ণ/রুপা জমা জিনিসের নাম')),
              Row(children: [
                Expanded(child: TextField(controller: ct['oldVori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldAna'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldRati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldPoint'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldGram'], decoration: InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
              ]),
              TextField(controller: ct['oldRate'], decoration: InputDecoration(labelText: 'পুরাতন স্বর্ণ/রুপা জমা দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
              TextField(controller: ct['oldGoldPrice'], readOnly: true, decoration: InputDecoration(labelText: 'পুরাতন স্বর্ণ/রুপার মোট মূল্য (৳)')),
            ]))),
            SizedBox(height: 15),
            Text('খাঁটি/পাকা স্বর্ণ/রুপার বিবরণ (ওজন সরাসরি কর্তন হবে):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            Card(color: Colors.green.shade50, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              Row(children: [
                Expanded(child: TextField(controller: ct['pakaVori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaAna'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaRati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaPoint'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaGram'], decoration: InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
              ]),
              TextField(controller: ct['pakaRate'], decoration: InputDecoration(labelText: 'খাঁটি/পাকা স্বর্ণ/রুপার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
              TextField(controller: ct['pakaGoldPrice'], readOnly: true, decoration: InputDecoration(labelText: 'খাঁটি/পাকা স্বর্ণ/রুপার মোট মূল্য (৳)')),
            ]))),
            SizedBox(height: 20),
            Text('বিল ও পেমেন্ট হিসাব:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Card(child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['totalBill'], decoration: InputDecoration(labelText: '৩. মোট বিল (টাকা)'), keyboardType: TextInputType.number),
              TextField(controller: ct['cashPaid'], decoration: InputDecoration(labelText: '৪. নগদ টাকা জমা দেওয়ার পরিমাণ'), keyboardType: TextInputType.number),
              TextField(controller: ct['bankPaid'], decoration: InputDecoration(labelText: '৫. মোবাইল ব্যাংক বা সরাসরি ব্যাংকে জমা'), keyboardType: TextInputType.number),
              TextField(controller: ct['advancePaid'], decoration: InputDecoration(labelText: '৭. অগ্রিম জমা (যদি থাকে)'), keyboardType: TextInputType.number),
              TextField(controller: ct['dueAmount'], readOnly: true, decoration: InputDecoration(labelText: '৮. মোট বাকি/অবशिष्ट')),
              TextField(controller: ct['paymentStatus'], readOnly: true, decoration: InputDecoration(labelText: '৯. পরিশোধ স্ট্যাটাস')),
            ]))),
            SizedBox(height: 25),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text(editingIndex != null ? 'মেমো আপডেট নিশ্চিত করুন' : 'বিক্রয় নিশ্চিত ও মেমো তৈরি করুন', style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber)))
          ],
        ),
      ),
    );
  }
}
