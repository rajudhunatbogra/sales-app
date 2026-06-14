import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(primaryColor: Colors.amber, primarySwatch: Colors.amber),
      home: const SalesPage(),
    ));

class ProductItem {
  TextEditingController nameCt = TextEditingController();
  TextEditingController voriCt = TextEditingController();
  TextEditingController anaCt = TextEditingController();
  TextEditingController ratiCt = TextEditingController();
  TextEditingController pointCt = TextEditingController();
  TextEditingController gramCt = TextEditingController();
  TextEditingController rateCt = TextEditingController();
  TextEditingController totalPriceCt = TextEditingController();
  
  String metalType = 'স্বর্ণ'; 
  String carat = '২১ ক্যারেট হলমার্ক';
  String khath = 'উৎপাদিত নতুন গহনা';
  bool isGramInput = false;
}

class SalesPage extends StatefulWidget {
  const SalesPage({super.key});
  @override
  _SalesPageState createState() => _SalesPageState();
}
class _SalesPageState extends State<SalesPage> {
  final Map<String, TextEditingController> ct = {
    'sl': TextEditingController(), 'name': TextEditingController(),
    'address': TextEditingController(), 'phone': TextEditingController(),
    'totalW': TextEditingController(), 'voriW': TextEditingController(), 
    'fixedW': TextEditingController(), 'customK': TextEditingController(), 
    'totalBill': TextEditingController(), 'cashPaid': TextEditingController(), 
    'bankPaid': TextEditingController(), 'advancePaid': TextEditingController(), 
    'dueAmount': TextEditingController(), 'paymentStatus': TextEditingController(),
    'oldItemName': TextEditingController(),
    'oldVori': TextEditingController(), 'oldAna': TextEditingController(),
    'oldRati': TextEditingController(), 'oldPoint': TextEditingController(), 'oldGram': TextEditingController(),
    'oldRate': TextEditingController(), 'oldGoldPrice': TextEditingController(),
    'pakaVori': TextEditingController(), 'pakaAna': TextEditingController(),
    'pakaRati': TextEditingController(), 'pakaPoint': TextEditingController(), 'pakaGram': TextEditingController(),
    'pakaRate': TextEditingController(), 'pakaGoldPrice': TextEditingController(),
    'itemTotalPrice': TextEditingController(),
  };

  bool isEnglish = false; 
  String oldMetalType = 'স্বর্ণ';
  String pakaMetalType = 'স্বর্ণ';
  final List<String> khathOptions = ['উৎপাদিত নতুন গহনা', 'কেনা নতুন গহনা', 'পুরাতন গহনা', 'বন্ধকী গহনা', 'অন্যান্য খাত (নিচে লিখুন)'];
  final List<String> caratOptions = ['১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক', '২২ ক্যারেট হলমার্ক'];
  
  List<Map<String, dynamic>> savedSalesList = [];
  List<Map<String, dynamic>> filteredSalesList = [];
  List<ProductItem> products = [ProductItem()];
  List<String> appActionLogs = []; 
  TextEditingController searchCt = TextEditingController();
  bool _isListenerBlocked = false;
  int? editingIndex;
  bool isOldRateChecked = false;
  bool isPakaRateChecked = false;
  bool isOldGramInput = false;
  bool isPakaGramInput = false;
  @override
  void initState() {
    super.initState();
    List<String> keys = ['voriW', 'fixedW', 'totalBill', 'cashPaid', 'bankPaid', 'advancePaid', 'oldVori', 'oldAna', 'oldRati', 'oldPoint', 'oldRate', 'pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint', 'pakaRate'];
    for (var k in keys) {
      ct[k]?.addListener(_calculate);
    }
    _addProductListeners(products.first);
    _setupOldAndPakaListeners();
    searchCt.addListener(_runSearch);
  }

  void _addProductListeners(ProductItem item) {
    void listenVori() {
      if (_isListenerBlocked || item.isGramInput) return;
      double v = double.tryParse(item.voriCt.text) ?? 0;
      double a = double.tryParse(item.anaCt.text) ?? 0;
      double r = double.tryParse(item.ratiCt.text) ?? 0;
      double p = double.tryParse(item.pointCt.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      _isListenerBlocked = true;
      item.gramCt.text = (v == 0 && a == 0 && r == 0 && p == 0) ? '' : (totalVori * 11.664).toStringAsFixed(3);
      _isListenerBlocked = false;
      _calculate();
    }

    void listenGram() {
      if (_isListenerBlocked || item.gramCt.text.isEmpty) return;
      item.isGramInput = true;
      double gram = double.tryParse(item.gramCt.text) ?? 0;
      double totalVori = gram / 11.664;
      int vori = totalVori.floor();
      double remainingVori = totalVori - vori;
      double totalAna = remainingVori * 16;
      int ana = totalAna.floor();
      double totalRati = (totalAna - ana) * 6;
      int rati = totalRati.floor();
      int point = ((totalRati - rati) * 10).round();

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
    item.rateCt.addListener(() => _calculate());
  }
  void _setupOldAndPakaListeners() {
    void listenOldVori() {
      if (_isListenerBlocked || isOldGramInput) return;
      double v = double.tryParse(ct['oldVori']!.text) ?? 0;
      double a = double.tryParse(ct['oldAna']!.text) ?? 0;
      double r = double.tryParse(ct['oldRati']!.text) ?? 0;
      double p = double.tryParse(ct['oldPoint']!.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      _isListenerBlocked = true;
      ct['oldGram']!.text = (v == 0 && a == 0 && r == 0 && p == 0) ? '' : (totalVori * 11.664).toStringAsFixed(3);
      _isListenerBlocked = false;
      _calculate();
    }

    void listenOldGram() {
      if (_isListenerBlocked || ct['oldGram']!.text.isEmpty) return;
      isOldGramInput = true;
      _convertGramToVoriManual('oldGram', 'oldVori', 'oldAna', 'oldRati', 'oldPoint');
      isOldGramInput = false;
    }

    void listenPakaVori() {
      if (_isListenerBlocked || isPakaGramInput) return;
      double v = double.tryParse(ct['pakaVori']!.text) ?? 0;
      double a = double.tryParse(ct['pakaAna']!.text) ?? 0;
      double r = double.tryParse(ct['pakaRati']!.text) ?? 0;
      double p = double.tryParse(ct['pakaPoint']!.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      _isListenerBlocked = true;
      ct['pakaGram']!.text = (v == 0 && a == 0 && r == 0 && p == 0) ? '' : (totalVori * 11.664).toStringAsFixed(3);
      _isListenerBlocked = false;
      _calculate();
    }

    void listenPakaGram() {
      if (_isListenerBlocked || ct['pakaGram']!.text.isEmpty) return;
      isPakaGramInput = true;
      _convertGramToVoriManual('pakaGram', 'pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint');
      isPakaGramInput = false;
    }

    ct['oldVori']!.addListener(listenOldVori);
    ct['oldAna']!.addListener(listenOldVori);
    ct['oldRati']!.addListener(listenOldVori);
    ct['oldPoint']!.addListener(listenOldVori);
    ct['oldGram']!.addListener(listenOldGram);
    ct['pakaVori']!.addListener(listenPakaVori);
    ct['pakaAna']!.addListener(listenPakaVori);
    ct['pakaRati']!.addListener(listenPakaVori);
    ct['pakaPoint']!.addListener(listenPakaVori);
    ct['pakaGram']!.addListener(listenPakaGram);
  }

  void _convertGramToVoriManual(String gramKey, String vKey, String aKey, String rKey, String pKey) {
    _isListenerBlocked = true;
    double gram = double.tryParse(ct[gramKey]!.text) ?? 0;
    double totalVori = gram / 11.664;
    int vori = totalVori.floor();
    double remainingVori = totalVori - vori;
    double totalAna = remainingVori * 16;
    int ana = totalAna.floor();
    double totalRati = (totalAna - ana) * 6;
    int rati = totalRati.floor();
    int point = ((totalRati - rati) * 10).round();

    ct[vKey]!.text = vori > 0 ? vori.toString() : '';
    ct[aKey]!.text = ana > 0 ? ana.toString() : '';
    ct[rKey]!.text = rati > 0 ? rati.toString() : '';
    ct[pKey]!.text = point > 0 ? point.toString() : '';
    _isListenerBlocked = false;
    _calculate();
  }
  void _calculate() {
    if (_isListenerBlocked) return;
    _isListenerBlocked = true;

    double sumNewVori = 0;
    double totalCombinedItemPrice = 0;

    for (var prod in products) {
      double v = double.tryParse(prod.voriCt.text) ?? 0;
      double a = double.tryParse(prod.anaCt.text) ?? 0;
      double r = double.tryParse(prod.ratiCt.text) ?? 0;
      double p = double.tryParse(prod.pointCt.text) ?? 0;
      double prodRate = double.tryParse(prod.rateCt.text) ?? 0;

      double prodVori = v + (a / 16) + (r / 96) + (p / 960);
      sumNewVori += prodVori;

      double prodPrice = prodVori * prodRate;
      totalCombinedItemPrice += prodPrice;
      prod.totalPriceCt.text = prodPrice > 0 ? prodPrice.toStringAsFixed(2) : '';
    }

    double ov = double.tryParse(ct['oldVori']!.text) ?? 0;
    double oa = double.tryParse(ct['oldAna']!.text) ?? 0;
    double or = double.tryParse(ct['oldRati']!.text) ?? 0;
    double op = double.tryParse(ct['oldPoint']!.text) ?? 0;
    double oRate = double.tryParse(ct['oldRate']!.text) ?? 0;
    double totalOldVori = ov + (oa / 16) + (or / 96) + (op / 960);
    double oldPrice = totalOldVori * oRate;
    ct['oldGoldPrice']!.text = oldPrice > 0 ? oldPrice.toStringAsFixed(2) : '';

    double pv = double.tryParse(ct['pakaVori']!.text) ?? 0;
    double pa = double.tryParse(ct['pakaAna']!.text) ?? 0;
    double pr = double.tryParse(ct['pakaRati']!.text) ?? 0;
    double pp = double.tryParse(ct['pakaPoint']!.text) ?? 0;
    double pRate = double.tryParse(ct['pakaRate']!.text) ?? 0;
    double totalPakaVori = pv + (pa / 16) + (pr / 96) + (pp / 960);
    double pakaPrice = totalPakaVori * pRate;
    ct['pakaGoldPrice']!.text = pakaPrice > 0 ? pakaPrice.toStringAsFixed(2) : '';

    double netMetalPrice = totalCombinedItemPrice;
    if (totalPakaVori > 0 && !isPakaRateChecked) {
      double avgRate = sumNewVori > 0 ? totalCombinedItemPrice / sumNewVori : 0;
      double pakaWeightDeductionPrice = totalPakaVori * avgRate;
      netMetalPrice = totalCombinedItemPrice - pakaWeightDeductionPrice;
      if (netMetalPrice < 0) netMetalPrice = 0;
    }

    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;
    double totalWages = (sumNewVori * vw) + fw;

    ct['itemTotalPrice']!.text = netMetalPrice > 0 ? netMetalPrice.toStringAsFixed(2) : '';
    ct['totalW']!.text = totalWages > 0 ? totalWages.toStringAsFixed(2) : '';

    double cash = double.tryParse(ct['cashPaid']!.text) ?? 0;
    double bank = double.tryParse(ct['bankPaid']!.text) ?? 0;
    double adv = double.tryParse(ct['advancePaid']!.text) ?? 0;

    double bill = netMetalPrice + totalWages;
    if (ct['totalBill']!.text.isEmpty || bill > 0) {
      ct['totalBill']!.text = bill > 0 ? bill.toStringAsFixed(2) : '';
    }

    double currentBill = double.tryParse(ct['totalBill']!.text) ?? 0;
    double oldDeduction = isOldRateChecked ? oldPrice : 0;
    double pakaDeduction = isPakaRateChecked ? pakaPrice : 0;
    
    double due = currentBill - (cash + bank + adv + oldDeduction + pakaDeduction);
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

  void _logAction(String action) {
    String time = DateTime.now().toString().substring(11, 16);
    setState(() { appActionLogs.insert(0, '$time - $action'); });
  }

  void _submit() {
    if (ct['phone']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEnglish ? 'Enter Phone Number!' : 'মোবাইল নাম্বার লিখুন!'), backgroundColor: Colors.red));
      return;
    }
    String oldTag = isOldRateChecked ? '(পুরাতন মূল্য সমন্বয়)' : '(পুরাতন ওজন জমা)';
    String pakaTag = isPakaRateChecked ? '(খাঁটি মূল্য সমন্বয়)' : '(খাঁটি ওজন কর্তন)';
    String productDetailsText = '';
    double totalCombinedGram = 0;
    List<Map<String, String>> serializedProducts = [];

    for (int i = 0; i < products.length; i++) {
      double v = double.tryParse(products[i].voriCt.text) ?? 0;
      double a = double.tryParse(products[i].anaCt.text) ?? 0;
      double r = double.tryParse(products[i].ratiCt.text) ?? 0;
      double p = double.tryParse(products[i].pointCt.text) ?? 0;
      double g = double.tryParse(products[i].gramCt.text) ?? 0;
      double itemGram = g > 0 ? g : (v + (a / 16) + (r / 96) + (p / 960)) * 11.664;
      totalCombinedGram += itemGram;

      productDetailsText += '${i + 1}. ${products[i].nameCt.text.isEmpty ? (isEnglish ? "Jewelry" : "গহনা") : products[i].nameCt.text} '
          '(${products[i].metalType}, ${products[i].carat}) (${isEnglish ? "Source:" : "খাত:"} ${products[i].khath}) - '
          '[${products[i].voriCt.text.isEmpty ? "0" : products[i].voriCt.text} vori/ভরি, '
          '${itemGram.toStringAsFixed(3)} g/গ্রাম]\n';

      serializedProducts.add({
        'name': products[i].nameCt.text, 'vori': products[i].voriCt.text, 'ana': products[i].anaCt.text,
        'rati': products[i].ratiCt.text, 'point': products[i].pointCt.text, 'gram': products[i].gramCt.text,
        'metalType': products[i].metalType, 'carat': products[i].carat, 'khath': products[i].khath,
        'rate': products[i].rateCt.text, 'totalPrice': products[i].totalPriceCt.text,
      });
    }

    Map<String, dynamic> memoData = {
      'sl': ct['sl']!.text.isEmpty ? (savedSalesList.length + 1).toString() : ct['sl']!.text,
      'date': DateTime.now().toString().substring(0, 16),
      'name': ct['name']!.text, 'address': ct['address']!.text, 'phone': ct['phone']!.text,
      'productsText': productDetailsText.trim(), 'serializedProducts': serializedProducts,
      'gram': totalCombinedGram.toStringAsFixed(3), 'itemPrice': ct['itemTotalPrice']!.text, 'wages': ct['totalW']!.text,
      'totalBill': ct['totalBill']!.text, 'cashPaid': ct['cashPaid']!.text, 'bankPaid': ct['bankPaid']!.text, 'advancePaid': ct['advancePaid']!.text,
      'dueAmount': ct['dueAmount']!.text, 'paymentStatus': ct['paymentStatus']!.text,
      'oldItemName': ct['oldItemName']!.text, 'oldGoldPrice': ct['oldGoldPrice']!.text, 'oldTag': oldTag,
      'oldWeightText': '${ct['oldVori']!.text} ভরি, ${ct['oldAna']!.text} আনা (${ct['oldGram']!.text} gram)',
      'pakaGoldPrice': ct['pakaGoldPrice']!.text, 'pakaTag': pakaTag,
      'pakaWeightText': '${ct['pakaVori']!.text} ভরি, ${ct['pakaAna']!.text} আনা (${ct['pakaGram']!.text} gram)',
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
    _showSuccessDialog(memoData['sl']);
  }
  void _editMemo(int index) {
    Map<String, dynamic> memo = filteredSalesList[index];
    int originalIndex = savedSalesList.indexOf(memo);
    setState(() {
      editingIndex = originalIndex;
      ct['sl']!.text = memo['sl'] ?? ''; ct['name']!.text = memo['name'] ?? ''; ct['address']!.text = memo['address'] ?? ''; ct['phone']!.text = memo['phone'] ?? '';
      ct['totalBill']!.text = memo['totalBill'] ?? ''; ct['cashPaid']!.text = memo['cashPaid'] ?? ''; ct['bankPaid']!.text = memo['bankPaid'] ?? ''; ct['advancePaid']!.text = memo['advancePaid'] ?? '';
      ct['oldItemName']!.text = memo['oldItemName'] ?? '';
      if (memo['serializedProducts'] != null) {
        products.clear();
        for (var prodData in memo['serializedProducts']) {
          ProductItem p = ProductItem();
          p.nameCt.text = prodData['name'] ?? ''; p.voriCt.text = prodData['vori'] ?? ''; p.anaCt.text = prodData['ana'] ?? '';
          p.ratiCt.text = prodData['rati'] ?? ''; p.pointCt.text = prodData['point'] ?? ''; p.gramCt.text = prodData['gram'] ?? '';
          p.rateCt.text = prodData['rate'] ?? ''; p.totalPriceCt.text = prodData['totalPrice'] ?? '';
          p.metalType = prodData['metalType'] ?? 'স্বর্ণ'; p.carat = prodData['carat'] ?? '২১ ক্যারেট হলমার্ক'; p.khath = prodData['khath'] ?? 'উৎপাদিত নতুন গহনা';
          products.add(p); _addProductListeners(p);
        }
      }
    });
    Navigator.pop(context);
  }

  void _clear() {
    _isListenerBlocked = true;
    for (var c in ct.values) { c.clear(); }
    products = [ProductItem()];
    isOldRateChecked = false; isPakaRateChecked = false;
    _isListenerBlocked = false;
    setState(() {});
  }
  void _showSuccessDialog(String sl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Success!' : 'মেমো সফল হয়েছে!', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        content: Text(isEnglish ? 'Memo saved offline successfully.' : 'মেমো সফলভাবে সংরক্ষিত হয়েছে।'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); _clear(); }, child: Text(isEnglish ? 'OK' : 'ঠিক আছে'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Jewelry Ledger' : 'জুয়েলারি বিক্রয় ও হিসাব', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        actions: [
          TextButton(
            onPressed: () { setState(() { isEnglish = !isEnglish; _logAction(isEnglish ? 'Language: English' : 'ভাষা পরিবর্তন: বাংলা'); }); },
            child: Text(isEnglish ? 'বাংলা' : 'English', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(
            icon: const Icon(Icons.list_alt, color: Colors.white),
            onPressed: () {
              setState(() { filteredSalesList = List.from(savedSalesList); });
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => Scaffold(
                appBar: AppBar(title: Text(isEnglish ? 'Memo Records' : 'বিক্রয় ও পরিপাটি মেমো তালিকা'), backgroundColor: Colors.amber),
                body: StatefulBuilder(
                  builder: (context, setModalState) => Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: searchCt, onChanged: (v) { setModalState(() { _runSearch(); }); },
                          decoration: InputDecoration(labelText: isEnglish ? 'Search by SL, Name, Mobile' : 'ক্রমিক নং, তারিখ, নাম বা মোবাইল দিয়ে খুঁজুন', prefixIcon: const Icon(Icons.search), border: OutlineInputBorder(borderRadius: BorderRadius.circular(10))),
                        ),
                      ),
                      Expanded(
                        child: filteredSalesList.isEmpty 
                            ? Center(child: Text(isEnglish ? 'No Memos Found!' : 'কোনো মেমো খুঁজে পাওয়া যায়নি!')) 
                            : ListView.builder(
                                itemCount: filteredSalesList.length,
                                itemBuilder: (c, i) => Card(
                                  margin: const EdgeInsets.all(10), elevation: 6,
                                  child: Padding(padding: const EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('${isEnglish ? "Memo SL:" : "ক্রমিক নং:"} ${filteredSalesList[i]['sl']}', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                                      Text('${isEnglish ? "Date:" : "তারিখ:"} ${filteredSalesList[i]['date']}', style: const TextStyle(color: Colors.grey)),
                                    ]),
                                    const Divider(thickness: 1.5),
                                    Text('${isEnglish ? "Name:" : "ক্রেতার নাম:"} ${filteredSalesList[i]['name']}', style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('${isEnglish ? "Phone:" : "মোবাইল:"} ${filteredSalesList[i]['phone']} | ${isEnglish ? "Address:" : "ঠিকানা:"} ${filteredSalesList[i]['address']}'),
                                    const Divider(),
                                    Text(isEnglish ? '📦 Sold Items Breakdown & Weight:' : '📦 বিক্রয়কৃত গহনাসমূহের তালিকা ও বিবরণ:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                    Text(filteredSalesList[i]['productsText'] ?? '', style: const TextStyle(fontSize: 13, height: 1.4)),
                                    const SizedBox(height: 5),
                                    Container(
                                      padding: const EdgeInsets.all(10), color: Colors.grey.shade50,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(isEnglish ? '📊 Billing Breakdown (1 Glance):' : '📊 হিসাবের বিবরণী (১ নজরে যোগ-বিয়োগ):', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                          Text('[+] ${isEnglish ? "Gold/Silver Net Price:" : "নিট সোনা/রুপার মূল্য:"} ৳${filteredSalesList[i]['itemPrice']}'),
                                          Text('[+] ${isEnglish ? "Total Wages Added:" : "মোট মজুরি বাবদ যোগ:"} ৳${filteredSalesList[i]['wages']}'),
                                          if (filteredSalesList[i]['oldItemName'].toString().isNotEmpty)
                                            Text('[-] ${isEnglish ? "Old Metal Valuation" : "পুরাতন জমার বিবরণ"} ${filteredSalesList[i]['oldTag']}: ৳${filteredSalesList[i]['oldGoldPrice']} (${filteredSalesList[i]['oldWeightText']})', style: const TextStyle(color: Colors.brown)),
                                          if (filteredSalesList[i]['pakaWeightText'].toString().contains('ভরি') && !filteredSalesList[i]['pakaWeightText'].toString().startsWith('0 ভরি'))
                                            Text('[-] ${isEnglish ? "Paka Metal Weight Cutting" : "খাঁটি/পাকা সোনা বিবরণ"} ${filteredSalesList[i]['pakaTag']}: ৳${filteredSalesList[i]['pakaGoldPrice']} (${filteredSalesList[i]['pakaWeightText']})', style: const TextStyle(color: Colors.green)),
                                          Text('[-] ${isEnglish ? "Cash Received:" : "নগদ টাকা জমা:"} ৳${filteredSalesList[i]['cashPaid']}'),
                                          Text('[-] ${isEnglish ? "Bank/Mobile Transfer:" : "ব্যাংক বা সরাসরি জমা:"} ৳${filteredSalesList[i]['bankPaid']}'),
                                          Text('[-] ${isEnglish ? "Advance Booking Paid:" : "অগ্রিম বুকিং জমা:"} ৳${filteredSalesList[i]['advancePaid']}'),
                                        ],
                                      ),
                                    ),
                                    const Divider(thickness: 1.5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('${isEnglish ? "Total Due/Remaining:" : "মোট বাকি/অবशिष्ट:"} ৳${filteredSalesList[i]['dueAmount']}', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                                      Container(padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5), color: filteredSalesList[i]['paymentStatus'] == 'পরিশোধিত' ? Colors.green : Colors.orange, child: Text(filteredSalesList[i]['paymentStatus'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    ]),
                                    const Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton.icon(onPressed: () { _editMemo(i); }, icon: const Icon(Icons.edit, size: 16), label: Text(isEnglish ? 'Edit' : 'এডিট করুন')),
                                        ElevatedButton.icon(onPressed: () { ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEnglish ? 'Memo details copied!' : 'মেমোর বিবরণ ক্লিপবোর্ডে কপি হয়েছে!'))); }, icon: const Icon(Icons.share, size: 16), label: Text(isEnglish ? 'Send' : 'মেমো পাঠান')),
                                      ],
                                    ),
                                  ])),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              ))),
            },
          ),
          IconButton(
            icon: const Icon(Icons.history_toggle_off, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => Scaffold(
                appBar: AppBar(title: Text(isEnglish ? 'Live Action Logs' : 'লাইভ অ্যাকশন লগ (সিরিয়াল শীট)'), backgroundColor: Colors.amber),
                body: appActionLogs.isEmpty 
                  ? Center(child: Text(isEnglish ? 'No logs recorded.' : 'কোনো লগ রেকর্ড পাওয়া যায়নি।'))
                  : ListView.builder(itemCount: appActionLogs.length, itemBuilder: (context, index) => ListTile(leading: CircleAvatar(child: Text('${index + 1}')), title: Text(appActionLogs[index], style: const TextStyle(fontSize: 14)))),
              )));
            },
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (editingIndex != null)
              Container(
                width: double.infinity, color: Colors.red.shade100, padding: const EdgeInsets.all(8),
                child: Text(isEnglish ? '⚠️ Editing Memo SL #${ct['sl']!.text}!' : '⚠️ আপনি এখন ক্রমিক নং ${ct['sl']!.text} এর মেমোটি এডিট করছেন!', style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            Card(elevation: 3, child: Padding(padding: const EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['sl'], decoration: InputDecoration(labelText: isEnglish ? '1. Memo Serial Number (Auto)' : '১. ক্রমিক নাম্বার (ফাঁকা রাখলে অটো)')),
              TextField(controller: ct['name'], decoration: InputDecoration(labelText: isEnglish ? 'Customer Name' : 'ক্রেতার নাম')),
              TextField(controller: ct['address'], decoration: InputDecoration(labelText: isEnglish ? 'Address' : 'ঠিকানা')),
              TextField(controller: ct['phone'], decoration: InputDecoration(labelText: isEnglish ? 'Mobile Number' : 'মোবাইল নাম্বার'), keyboardType: TextInputType.phone),
            ]))),
            const SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEnglish ? '2. Product Description:' : '২. পণ্যের বিবরণ ও ওজনসমূহ:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 15)),
                Builder(builder: (context) {
                  double totalV = 0;
                  for (var prod in products) {
                    double v = double.tryParse(prod.voriCt.text) ?? 0;
                    double a = double.tryParse(prod.anaCt.text) ?? 0;
                    double r = double.tryParse(prod.ratiCt.text) ?? 0;
                    double p = double.tryParse(prod.pointCt.text) ?? 0;
                    totalV += v + (a / 16) + (r / 96) + (p / 960);
                  }
                  return Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: Colors.pink,
                    child: Text(isEnglish ? 'Total: ${totalV.toStringAsFixed(2)} vori' : 'লাইভ মোট ওজন: ${totalV.toStringAsFixed(2)} ভরি', style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11)),
                  );
                }),
              ],
            ),
            ListView.builder(
              shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: products.length,
              itemBuilder: (ctx, index) {
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 5), color: Colors.grey.shade50,
                  child: Padding(
                    padding: const EdgeInsets.all(10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${isEnglish ? "Product No:" : "পণ্য নম্বর:"} ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                        TextField(controller: products[index].nameCt, decoration: InputDecoration(labelText: isEnglish ? 'Item Name' : 'পণ্যের নাম (যেমন: চেন, দুল, আংটি)')),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Expanded(child: DropdownButton<String>(value: products[index].metalType, items: ['স্বর্ণ', 'রুপা', 'অন্যান্য'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(), onChanged: (val) { setState(() { products[index].metalType = val!; }); })),
                            Expanded(child: DropdownButton<String>(value: products[index].carat, items: caratOptions.map((c) => DropdownMenuItem(value: c, child: Text(c))).toList(), onChanged: (val) { setState(() { products[index].carat = val!; }); })),
                            Expanded(child: DropdownButton<String>(value: products[index].khath, items: khathOptions.map((k) => DropdownMenuItem(value: k, child: Text(k))).toList(), onChanged: (val) { setState(() { products[index].khath = val!; }); })),
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(child: TextField(controller: products[index].rateCt, decoration: InputDecoration(labelText: isEnglish ? 'Rate/ভরি দর' : 'ভরি দর (৳)'), keyboardType: TextInputType.number)),
                            Expanded(child: TextField(controller: products[index].totalPriceCt, readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Price/দাম' : 'মোট দাম (৳)'))),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Text(isEnglish ? 'Weight (Vori, Ana, Rati, Point, Gram):' : 'ওজন হিসাব (ভরি, আনা, রতি, পয়েন্ট):', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 13)),
                        Row(children: [
                          Expanded(child: TextField(controller: products[index].voriCt, decoration: InputDecoration(labelText: isEnglish ? 'V' : 'ভরি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: ct['customK']!, decoration: InputDecoration(labelText: isEnglish ? 'A' : 'আনা'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].ratiCt, decoration: InputDecoration(labelText: isEnglish ? 'R' : 'রতি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].pointCt, decoration: const InputDecoration(labelText: 'Pt'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].gramCt, decoration: InputDecoration(labelText: isEnglish ? 'Gram' : 'গ্রাম'), keyboardType: TextInputType.number)),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: () { setState(() { var p = ProductItem(); products.add(p); _addProductListeners(p); }); },
              icon: const Icon(Icons.add_circle, color: Colors.green), label: Text(isEnglish ? 'Add More Item' : 'আরো পণ্য ও ওজন যোগ করুন', style: const TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            const SizedBox(height: 15),
            TextField(controller: ct['voriW'], decoration: InputDecoration(labelText: isEnglish ? 'Wages (Per Vori ৳)' : 'ভরি প্রতি মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['fixedW'], decoration: InputDecoration(labelText: isEnglish ? 'Fixed Wages ৳' : 'ফিক্সড মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['totalW'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Total Wages ৳' : 'মোট মজুরি (৳)')),
            TextField(controller: ct['itemTotalPrice'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Net Metal Value ৳' : 'নিট সোনা/রুপার মূল্য (৳)'), style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            const SizedBox(height: 20),
            Card(
              color: const Color(0xFFEFEBE9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEnglish ? '6. Old Metal Deposit:' : '৬. পুরাতন স্বর্ণ/রুপা জমার বিবরণ:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                        Row(children: [Text(isEnglish ? 'Price Adjust?' : 'দাম বাদ?', style: const TextStyle(fontSize: 11)), Checkbox(value: isOldRateChecked, onChanged: (v) { setState(() { isOldRateChecked = v!; _calculate(); }); })]),
                      ],
                    ),
                    TextField(controller: ct['oldItemName'], decoration: InputDecoration(labelText: isEnglish ? 'Item Name' : 'পুরাতন জমার জিনিসের নাম')),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: ct['oldVori'], decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['oldAna'], decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['oldGram'], decoration: const InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: ct['oldRate'], decoration: const InputDecoration(labelText: 'জমা দর (৳)'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['oldGoldPrice'], readOnly: true, decoration: const InputDecoration(labelText: 'মোট মূল্য (৳)'))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 15),
            Card(
              color: const Color(0xFFE8F5E9),
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(isEnglish ? 'Khati/Paka Deposit:' : 'খাঁটি/পাকা স্বর্ণ/রুপার বিবরণ:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                        Row(children: [Text(isEnglish ? 'Price Adjust?' : 'দাম বাদ?', style: const TextStyle(fontSize: 11)), Checkbox(value: isPakaRateChecked, onChanged: (v) { setState(() { isPakaRateChecked = v!; _calculate(); }); })]),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: ct['pakaVori'], decoration: const InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['pakaAna'], decoration: const InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['pakaGram'], decoration: const InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
                      ],
                    ),
                    Row(
                      children: [
                        Expanded(child: TextField(controller: ct['pakaRate'], decoration: const InputDecoration(labelText: 'পাকা দর (৳)'), keyboardType: TextInputType.number)),
                        Expanded(child: TextField(controller: ct['pakaGoldPrice'], readOnly: true, decoration: const InputDecoration(labelText: 'মোট মূল্য (৳)'))),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            Text(isEnglish ? 'Bill Payments:' : 'বিল ও পেমেন্ট হিসাব:', style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: ct['totalBill'], decoration: InputDecoration(labelText: isEnglish ? '3. Total Bill' : '৩. মোট বিল (টাকা)'), keyboardType: TextInputType.number),
                    TextField(controller: ct['cashPaid'], decoration: InputDecoration(labelText: isEnglish ? '4. Cash Paid' : '৪. নগদ টাকা জমা দেওয়ার পরিমাণ'), keyboardType: TextInputType.number),
                    TextField(controller: ct['bankPaid'], decoration: InputDecoration(labelText: isEnglish ? '5. Bank Paid' : '৫. মোবাইল ব্যাংক বা সরাসরি ব্যাংকে জমা'), keyboardType: TextInputType.number),
                    TextField(controller: ct['advancePaid'], decoration: InputDecoration(labelText: isEnglish ? '7. Advance Paid' : '৭. অগ্রিম জমা (যদি থাকে)'), keyboardType: TextInputType.number),
                    TextField(controller: ct['dueAmount'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? '8. Remaining Due' : '৮. মোট বাকি/অবशिष्ट')),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _submit,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber),
                child: Text(editingIndex != null ? (isEnglish ? 'Update Memo' : 'মেমো আপডেট নিশ্চিত করুন') : (isEnglish ? 'Create Memo' : 'বিক্রয় নিশ্চিত ও মেমো তৈরি করুন'), style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
