import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;
import 'dart:convert';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(primaryColor: Colors.amber, primarySwatch: Colors.amber),
      home: SalesPage(),
    ));

class ProductItem {
  TextEditingController nameCt = TextEditingController();
  TextEditingController voriCt = TextEditingController();
  TextEditingController anaCt = TextEditingController();
  TextEditingController ratiCt = TextEditingController();
  TextEditingController pointCt = TextEditingController();
  TextEditingController gramCt = TextEditingController();
  String metalType = 'স্বর্ণ'; 
  String carat = '২১ ক্যারেট হলমার্ক';
  bool isGramInput = false;
}

class SalesPage extends StatefulWidget {

      final Map<String, TextEditingController> ct = {
    'sl': TextEditingController(), 'name': TextEditingController(),
    'address': TextEditingController(), 'phone': TextEditingController(),
    'rate': TextEditingController(), 'itemTotalPrice': TextEditingController(), 
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
  };

  bool isEnglish = false; 
  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  String selectedCarat = '২১ ক্যারেট হলমার্ক';
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
           saveToGoogleSheet(ct);

    List<String> keys = ['rate', 'voriW', 'fixedW', 'totalBill', 'cashPaid', 'bankPaid', 'advancePaid', 'oldVori', 'oldAna', 'oldRati', 'oldPoint', 'oldRate', 'pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint', 'pakaRate'];
    for (var k in keys) ct[k]?.addListener(_calculate);
    _addProductListeners(products.first);
    _setupOldAndPakaListeners();
    searchCt.addListener(_runSearch);
    appActionLogs.add('${DateTime.now().toString().substring(11, 16)} - অ্যাপ চালু করা হয়েছে (App Started)');
  }
  void _addProductListeners(ProductItem item) {
    void listenVori() {
      if (_isListenerBlocked || item.isGramInput) return;
      double v = double.tryParse(item.voriCt.text) ?? 0;
      double a = double.tryParse(item.anaCt.text) ?? 0;
      double r = double.tryParse(item.ratiCt.text) ?? 0;
      double p = double.tryParse(item.pointCt.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      double totalGram = totalVori * 11.664;
      _isListenerBlocked = true;
      if (item.voriCt.text.isEmpty && item.anaCt.text.isEmpty && item.ratiCt.text.isEmpty && item.pointCt.text.isEmpty) {
        item.gramCt.text = '';
      } else {
        item.gramCt.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
      }
      _isListenerBlocked = false;
      _calculate();
    }

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
  }

  void _setupOldAndPakaListeners() {
    void listenOldVori() {
      if (_isListenerBlocked || isOldGramInput) return;
      double v = double.tryParse(ct['oldVori']!.text) ?? 0;
      double a = double.tryParse(ct['oldAna']!.text) ?? 0;
      double r = double.tryParse(ct['oldRati']!.text) ?? 0;
      double p = double.tryParse(ct['oldPoint']!.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      double totalGram = totalVori * 11.664;
      _isListenerBlocked = true;
      if (ct['oldVori']!.text.isEmpty && ct['oldAna']!.text.isEmpty && ct['oldRati']!.text.isEmpty && ct['oldPoint']!.text.isEmpty) {
        ct['oldGram']!.text = '';
      } else {
        ct['oldGram']!.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
      }
      _isListenerBlocked = false;
      _calculate();
    }

    void listenOldGram() {
      if (_isListenerBlocked) return;
      if (ct['oldGram']!.text.isEmpty) {
        _isListenerBlocked = true;
        ct['oldVori']!.text = ''; ct['oldAna']!.text = ''; ct['oldRati']!.text = ''; ct['oldPoint']!.text = '';
        _isListenerBlocked = false;
        _calculate();
        return;
      }
      isOldGramInput = true;
      _convertGramToVoriManual('oldGram', ['oldVori', 'oldAna', 'oldRati', 'oldPoint']);
      isOldGramInput = false;
    }

    void listenPakaVori() {
      if (_isListenerBlocked || isPakaGramInput) return;
      double v = double.tryParse(ct['pakaVori']!.text) ?? 0;
      double a = double.tryParse(ct['pakaAna']!.text) ?? 0;
      double r = double.tryParse(ct['pakaRati']!.text) ?? 0;
      double p = double.tryParse(ct['pakaPoint']!.text) ?? 0;
      double totalVori = v + (a / 16) + (r / 96) + (p / 960);
      double totalGram = totalVori * 11.664;
      _isListenerBlocked = true;
      if (ct['pakaVori']!.text.isEmpty && ct['pakaAna']!.text.isEmpty && ct['pakaRati']!.text.isEmpty && ct['pakaPoint']!.text.isEmpty) {
        ct['pakaGram']!.text = '';
      } else {
        ct['pakaGram']!.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
      }
      _isListenerBlocked = false;
      _calculate();
    }

    void listenPakaGram() {
      if (_isListenerBlocked) return;
      if (ct['pakaGram']!.text.isEmpty) {
        _isListenerBlocked = true;
        ct['pakaVori']!.text = ''; ct['pakaAna']!.text = ''; ct['pakaRati']!.text = ''; ct['pakaPoint']!.text = '';
        _isListenerBlocked = false;
        _calculate();
        return;
      }
      isPakaGramInput = true;
      _convertGramToVoriManual('pakaGram', ['pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint']);
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

  void _convertGramToVoriManual(String gramKey, List<String> voriKeys) {
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

    ct[voriKeys]!.text = vori > 0 ? vori.toString() : '';
    ct[voriKeys]!.text = ana > 0 ? ana.toString() : '';
    ct[voriKeys]!.text = rati > 0 ? rati.toString() : '';
    ct[voriKeys]!.text = point > 0 ? point.toString() : '';
    _isListenerBlocked = false;
    _calculate();
  }

  void _calculate() {
    if (_isListenerBlocked) return;
    _isListenerBlocked = true;

    double sumNewVori = 0;
    for (var prod in products) {
      double v = double.tryParse(prod.voriCt.text) ?? 0;
      double a = double.tryParse(prod.anaCt.text) ?? 0;
      double r = double.tryParse(prod.ratiCt.text) ?? 0;
      double p = double.tryParse(prod.pointCt.text) ?? 0;
      sumNewVori += v + (a / 16) + (r / 96) + (p / 960);
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

    double payableVori = sumNewVori;
    if (totalPakaVori > 0 && !isPakaRateChecked) {
      payableVori = sumNewVori - totalPakaVori; 
      if (payableVori < 0) payableVori = 0;
    }

    double rate = double.tryParse(ct['rate']!.text) ?? 0;
    double itemPrice = payableVori * rate;
    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;
    double totalWages = (sumNewVori * vw) + fw;

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
      totalCombinedGram += g > 0 ? g : (v + (a / 16) + (r / 96) + (p / 960)) * 11.664;

      productDetailsText += '${i + 1}. ${products[i].nameCt.text.isEmpty ? (isEnglish ? "Jewelry" : "গহনা") : products[i].nameCt.text} '
          '[${products[i].metalType}, ${products[i].carat}] - [${products[i].voriCt.text} ভরি, ${g.toStringAsFixed(3)} গ্রাম]\n';

      serializedProducts.add({
        'name': products[i].nameCt.text, 'vori': products[i].voriCt.text, 'ana': products[i].anaCt.text,
        'rati': products[i].ratiCt.text, 'point': products[i].pointCt.text, 'gram': products[i].gramCt.text,
        'metalType': products[i].metalType, 'carat': products[i].carat,
      });
    }

    Map<String, dynamic> memoData = {
      'sl': ct['sl']!.text.isEmpty ? (savedSalesList.length + 1).toString() : ct['sl']!.text,
      'date': DateTime.now().toString().substring(0, 16),
      'name': ct['name']!.text, 'address': ct['address']!.text, 'phone': ct['phone']!.text,
      'productsText': productDetailsText.trim(), 'serializedProducts': serializedProducts,
      'gram': totalCombinedGram.toStringAsFixed(3), 'rate': ct['rate']!.text, 'itemPrice': ct['itemTotalPrice']!.text, 'wages': ct['totalW']!.text,
      'totalBill': ct['totalBill']!.text, 'cashPaid': ct['cashPaid']!.text, 'bankPaid': ct['bankPaid']!.text, 'advancePaid': ct['advancePaid']!.text,
      'dueAmount': ct['dueAmount']!.text, 'paymentStatus': ct['paymentStatus']!.text,
      'oldItemName': ct['oldItemName']!.text, 'oldGoldPrice': ct['oldGoldPrice']!.text, 'oldTag': oldTag,
      'oldWeightText': '${ct['oldVori']!.text} ভরি (${ct['oldGram']!.text} গ্রাম)',
      'pakaGoldPrice': ct['pakaGoldPrice']!.text, 'pakaTag': pakaTag,
      'pakaWeightText': '${ct['pakaVori']!.text} ভরি (${ct['pakaGram']!.text} গ্রাম)',
    };

    setState(() {
      if (editingIndex != null) { savedSalesList[editingIndex!] = memoData; _logAction('মেমো আপডেট #SL: ${memoData['sl']}'); editingIndex = null; }
      else { savedSalesList.add(memoData); _logAction('নতুন মেমো #SL: ${memoData['sl']}'); }
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
      ct['rate']!.text = memo['rate'] ?? ''; ct['totalBill']!.text = memo['totalBill'] ?? ''; ct['cashPaid']!.text = memo['cashPaid'] ?? ''; ct['bankPaid']!.text = memo['bankPaid'] ?? ''; ct['advancePaid']!.text = memo['advancePaid'] ?? '';
      ct['oldItemName']!.text = memo['oldItemName'] ?? '';
      if (memo['serializedProducts'] != null) {
        products.clear();
        for (var prodData in memo['serializedProducts']) {
          ProductItem p = ProductItem();
          p.nameCt.text = prodData['name'] ?? ''; p.voriCt.text = prodData['vori'] ?? ''; p.anaCt.text = prodData['ana'] ?? '';
          p.ratiCt.text = prodData['rati'] ?? ''; p.pointCt.text = prodData['point'] ?? ''; p.gramCt.text = prodData['gram'] ?? '';
          p.metalType = prodData['metalType'] ?? 'স্বর্ণ'; p.carat = prodData['carat'] ?? '২১ ক্যারেট হলমার্ক';
          products.add(p); _addProductListeners(p);
        }
      }
    });
    Navigator.pop(context);
  }

  void _clear() {
    _isListenerBlocked = true;
    ct.values.forEach((c) => c.clear());
    products = [ProductItem()];
    isOldRateChecked = false; isPakaRateChecked = false;
    _isListenerBlocked = false;
    setState(() {});
  }
  void _showSuccessDialog(String sl) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(isEnglish ? 'Success!' : 'মেমো সফল হয়েছে!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(isEnglish ? 'Memo has been created successfully.' : 'মেমো সফলভাবে সংরক্ষিত হয়েছে।'),
            SizedBox(height: 10),
            Container(
              padding: EdgeInsets.all(8),
              color: Colors.grey.shade100,
              child: Text(
                isEnglish 
                  ? '📂 Save Location:\nInternal Storage > JewelryApp_Memos > sl_$sl.xlsx'
                  : '📂 ফাইল সেভ লোকেশন:\nInternal Storage > JewelryApp_Memos > sl_$sl.xlsx',
                style: TextStyle(fontSize: 12, color: Colors.blueGrey, fontWeight: FontWeight.bold),
              ),
            ),
          ],
        ),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); _clear(); }, child: Text(isEnglish ? 'OK' : 'ঠিক আছে'))],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(isEnglish ? 'Jewelry Sales & Accounts' : 'জুয়েলারি বিক্রয় ও হিসাব', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        backgroundColor: Colors.amber,
        actions: [
          TextButton(
            onPressed: () {
              setState(() {
                isEnglish = !isEnglish;
                _logAction(isEnglish ? 'Language changed to English' : 'ভাষা পরিবর্তন করে বাংলা করা হয়েছে');
              });
            },
            child: Text(isEnglish ? 'বাংলা' : 'English', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
          ),
          IconButton(
            icon: Icon(Icons.list_alt, color: Colors.white),
            onPressed: () {
              setState(() { filteredSalesList = List.from(savedSalesList); });
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => StatefulBuilder(
                builder: (context, setModalState) => Scaffold(
                  appBar: AppBar(title: Text(isEnglish ? 'Memo Records' : 'বিক্রয় ও পরিপাটি মেমো তালিকা'), backgroundColor: Colors.amber),
                  body: Column(
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(10.0),
                        child: TextField(
                          controller: searchCt,
                          onChanged: (v) { setModalState(() { _runSearch(); }); },
                          decoration: InputDecoration(
                            labelText: isEnglish ? 'Search by SL, Name, Mobile or Date' : 'ক্রমিক নং, তারিখ, নাম বা মোবাইল দিয়ে খুঁজুন',
                            prefixIcon: Icon(Icons.search),
                            border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                          ),
                        ),
                      ),
                      Expanded(
                        child: filteredSalesList.isEmpty 
                            ? Center(child: Text(isEnglish ? 'No Memos Found!' : 'কোনো মেমো খুঁজে পাওয়া যায়নি!')) 
                            : ListView.builder(
                                itemCount: filteredSalesList.length,
                                itemBuilder: (c, i) => Card(
                                  margin: EdgeInsets.all(10), elevation: 6,
                                  child: Padding(padding: EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('${isEnglish ? "Memo SL:" : "ক্রমিক নং:"} ${filteredSalesList[i]['sl']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                                      Text('${isEnglish ? "Date:" : "তারিখ:"} ${filteredSalesList[i]['date']}', style: TextStyle(color: Colors.grey)),
                                    ]),
                                    Divider(thickness: 1.5),
                                    Text('${isEnglish ? "Name:" : "ক্রেতার নাম:"} ${filteredSalesList[i]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                                    Text('${isEnglish ? "Phone:" : "মোবাইল:"} ${filteredSalesList[i]['phone']} | ${isEnglish ? "Address:" : "ঠিকানা:"} ${filteredSalesList[i]['address']}'),
                                    Divider(),
                                    Text(isEnglish ? '📦 Sold Items Breakdown:' : '📦 বিক্রয়কৃত গহনাসমূহের তালিকা ও বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple)),
                                    Text(filteredSalesList[i]['productsText'] ?? '', style: TextStyle(fontSize: 13, height: 1.4)),
                                    SizedBox(height: 5),
                                    Container(
                                      padding: EdgeInsets.all(10),
                                      color: Colors.grey.shade50,
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(isEnglish ? '📊 Billing Breakdown:' : '📊 হিসাবের বিবরণী (১ নজরে যোগ-বিয়োগ):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                                          Text('[+] ${isEnglish ? "Net Metal Price:" : "নিট সোনা/রুপার মূল্য:"} ৳${filteredSalesList[i]['itemPrice']}'),
                                          Text('[+] ${isEnglish ? "Total Wages Added:" : "মোট মজুরি বাবদ যোগ:"} ৳${filteredSalesList[i]['wages']}'),
                                          if (filteredSalesList[i]['oldItemName'].toString().isNotEmpty)
                                            Text('[-] ${isEnglish ? "Old Metal Valuation" : "পুরাতন জমার দর মূল্য"} ${filteredSalesList[i]['oldTag']}: ৳${filteredSalesList[i]['oldGoldPrice']}', style: TextStyle(color: Colors.brown)),
                                          if (filteredSalesList[i]['pakaWeightText'].toString().contains('ভরি') && !filteredSalesList[i]['pakaWeightText'].toString().startsWith('0 ভরি'))
                                            Text('[-] ${isEnglish ? "Khati Paka Metal Weight Cutting" : "খাঁটি/পাকা সোনা ওজন কর্তন"} ${filteredSalesList[i]['pakaTag']}: ৳${filteredSalesList[i]['pakaGoldPrice']}', style: TextStyle(color: Colors.green)),
                                          Text('[-] ${isEnglish ? "Cash Received:" : "নগদ টাকা জমা:"} ৳${filteredSalesList[i]['cashPaid']}'),
                                          Text('[-] ${isEnglish ? "Bank/Mobile Transfer:" : "ব্যাংক বা সরাসরি জমা:"} ৳${filteredSalesList[i]['bankPaid']}'),
                                          Text('[-] ${isEnglish ? "Advance Booking Paid:" : "অগ্রিম বুকিং জমা:"} ৳${filteredSalesList[i]['advancePaid']}'),
                                        ],
                                      ),
                                    ),
                                    Divider(thickness: 1.5),
                                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                                      Text('${isEnglish ? "Total Due:" : "মোট বাকি/অবशिष्ट:"} ৳${filteredSalesList[i]['dueAmount']}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                                      Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), color: filteredSalesList[i]['paymentStatus'] == 'পরিশোধিত' ? Colors.green : Colors.orange, child: Text(filteredSalesList[i]['paymentStatus'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                                    ]),
                                    Divider(),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                                      children: [
                                        ElevatedButton.icon(
                                          onPressed: () { _editMemo(i); },
                                          icon: Icon(Icons.edit, size: 16),
                                          label: Text(isEnglish ? 'Edit' : 'এডিট করুন'),
                                        ),
                                        ElevatedButton.icon(
                                          onPressed: () {
                                            ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(isEnglish ? 'Memo copied!' : 'মেমোর বিবরণ ক্লিপবোর্ডে কপি হয়েছে!')));
                                          },
                                          icon: Icon(Icons.share, size: 16),
                                          label: Text(isEnglish ? 'Send Memo' : 'মেমো পাঠান'),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 5),
                                    Text('📂 Location: Internal Storage > JewelryApp_Memos', style: TextStyle(fontSize: 10, color: Colors.grey)),
                                  ])),
                                ),
                              ),
                      ),
                    ],
                  ),
                ),
              )));
            },
          ),
          IconButton(
            icon: Icon(Icons.history_toggle_off, color: Colors.white),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (ctx) => Scaffold(
                appBar: AppBar(title: Text(isEnglish ? 'Live Action Logs' : 'লাইভ অ্যাকশন লগ (সিরিয়াল শীট)'), backgroundColor: Colors.amber),
                body: appActionLogs.isEmpty 
                  ? Center(child: Text(isEnglish ? 'No logs recorded.' : 'কোনো লগ রেকর্ড পাওয়া যায়নি।'))
                  : ListView.builder(
                      itemCount: appActionLogs.length,
                      itemBuilder: (context, index) => ListTile(
                        leading: CircleAvatar(child: Text('${index + 1}')),
                        title: Text(appActionLogs[index], style: TextStyle(fontSize: 14)),
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
                child: Text(isEnglish ? '⚠️ Editing Memo SL #${ct['sl']!.text}!' : '⚠️ আপনি এখন ক্রমিক নং ${ct['sl']!.text} এর মেমোটি এডিট করছেন!', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
              ),
            Card(elevation: 3, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['sl'], decoration: InputDecoration(labelText: isEnglish ? '1. Memo Serial Number (Auto)' : '১. ক্রমিক নাম্বার (ফাঁকা রাখলে অটো)')),
              TextField(controller: ct['name'], decoration: InputDecoration(labelText: isEnglish ? 'Customer Name' : 'ক্রেতার নাম')),
              TextField(controller: ct['address'], decoration: InputDecoration(labelText: isEnglish ? 'Address' : 'ঠিকানা')),
              TextField(controller: ct['phone'], decoration: InputDecoration(labelText: isEnglish ? 'Mobile Number' : 'মোবাইল নাম্বার'), keyboardType: TextInputType.phone),
            ]))),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEnglish ? '2. Product Description & Weights:' : '২. পণ্যের বিবরণ ও ওজনসমূহ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.indigo, fontSize: 16)),
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
                    padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: Colors.pink,
                    child: Text(
                      isEnglish ? 'Live Total: ${(totalV * 11.664).toStringAsFixed(2)}g' : 'লাইভ মোট ওজন: ${totalV.toStringAsFixed(2)} ভরি',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 11),
                    ),
                  );
                }),
              ],
            ),
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
                            Text('${isEnglish ? "Product No:" : "পণ্য নম্বর:"} ${index + 1}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber.shade900)),
                            if (products.length > 1)
                              IconButton(
                                icon: Icon(Icons.delete, color: Colors.red),
                                onPressed: () { setState(() { products.removeAt(index); _calculate(); _logAction('পণ্য নম্বর ${index + 1} তালিকা থেকে ডিলিট করা হয়েছে'); }); },
                              )
                          ],
                        ),
                        Row(
                          children: [
                            Expanded(flex: 2, child: TextField(controller: products[index].nameCt, decoration: InputDecoration(labelText: isEnglish ? 'Item Name (Chain, Ring)' : 'পণ্যের নাম (যেমন: চেন, আংটি)'))),
                            SizedBox(width: 5),
                            DropdownButton<String>(
                              value: products[index].metalType,
                              items: ['স্বর্ণ', 'রুপা', 'অন্যান্য'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                              onChanged: (val) { setState(() { products[index].metalType = val!; }); },
                            ),
                          ],
                        ),
                        SizedBox(height: 8),
                        Text(isEnglish ? 'Weight Breakdown (Vori, Ana, Rati, Point):' : 'ওজন হিসাব (ভরি, আনা, রতি, পয়েন্ট):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 13)),
                        Row(children: [
                          Expanded(child: TextField(controller: products[index].voriCt, decoration: InputDecoration(labelText: isEnglish ? 'Vori' : 'ভরি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].anaCt, decoration: InputDecoration(labelText: isEnglish ? 'Ana' : 'আনা'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].ratiCt, decoration: InputDecoration(labelText: isEnglish ? 'Rati' : 'রতি'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].pointCt, decoration: InputDecoration(labelText: 'Pt/পয়েন্ট'), keyboardType: TextInputType.number)),
                          Expanded(child: TextField(controller: products[index].gramCt, decoration: InputDecoration(labelText: isEnglish ? 'Gram' : 'গ্রাম'), keyboardType: TextInputType.number)),
                        ]),
                      ],
                    ),
                  ),
                );
              },
            ),
            TextButton.icon(
              onPressed: () { setState(() { var p = ProductItem(); products.add(p); _addProductListeners(p); _logAction('তালিকায় নতুন পণ্য ইনপুট রো যোগ করা হয়েছে'); }); },
              icon: Icon(Icons.add_circle, color: Colors.green),
              label: Text(isEnglish ? 'Add More Item & Weight' : 'আরো পণ্য ও ওজন যোগ করুন', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
            ),
            SizedBox(height: 15),
            TextField(controller: ct['rate'], decoration: InputDecoration(labelText: isEnglish ? 'Metal Rate (Per Vori ৳)' : 'সোনা/রুপার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['itemTotalPrice'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Net Metal Price ৳' : 'নিট সোনা/রুপার মূল্য (৳)'), style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
            TextField(controller: ct['voriW'], decoration: InputDecoration(labelText: isEnglish ? 'Wages (Per Vori ৳)' : 'ভরি প্রতি মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['fixedW'], decoration: InputDecoration(labelText: isEnglish ? 'Fixed Wages ৳' : 'ফিক্সড মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['totalW'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Total Wages ৳' : 'মোট মজুরি (৳)')),
            SizedBox(height: 15),
            DropdownButtonFormField<String>(
              value: selectedCarat, decoration: InputDecoration(labelText: isEnglish ? 'Select Metal Carat' : 'গহনার ক্যারেট সিলেক্ট করুন'),
              items: caratOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (n) => setState(() => selectedCarat = n!),
            ),
            SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedKhath, isExpanded: true,
              items: khathOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (n) => setState(() => selectedKhath = n!),
            ),
            if (selectedKhath.contains('অন্যান্য')) TextField(controller: ct['customK'], decoration: InputDecoration(labelText: isEnglish ? 'Khath Name' : 'খাতের নাম')),
            SizedBox(height: 20),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEnglish ? '6. Old Metal Deposit Description:' : '৬. পুরাতন স্বর্ণ/রুপা জমার বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                Row(
                  children: [
                    Text(isEnglish ? 'Adjust Price?' : 'দর অনুযায়ী দাম বাদ?', style: TextStyle(fontSize: 12, color: Colors.brown, fontWeight: FontWeight.bold)),
                    Checkbox(
                      value: isOldRateChecked, 
                      onChanged: (val) { setState(() { isOldRateChecked = val!; _calculate(); _logAction('পুরাতন জমার দর মূল্য সমন্বয় টিক বক্স পরিবর্তন করা হয়েছে: $val'); }); }
                    ),
                  ],
                )
              ],
            ),
            Card(color: Colors.brown.shade50, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              Row(
                children: [
                  Expanded(child: TextField(controller: ct['oldItemName'], decoration: InputDecoration(labelText: isEnglish ? 'Old Item Name' : 'পুরাতন জমার জিনিসের নাম'))),
                  DropdownButton<String>(
                    value: oldMetalType,
                    items: ['স্বর্ণ', 'রুপা'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) { setState(() { oldMetalType = val!; }); },
                  )
                ],
              ),
              Row(children: [
                Expanded(child: TextField(controller: ct['oldVori'], decoration: InputDecoration(labelText: isEnglish ? 'Vori' : 'ভরি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldAna'], decoration: InputDecoration(labelText: isEnglish ? 'Ana' : 'আনা'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldRati'], decoration: InputDecoration(labelText: isEnglish ? 'Rati' : 'রতি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldPoint'], decoration: InputDecoration(labelText: 'Pt'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldGram'], decoration: InputDecoration(labelText: isEnglish ? 'Gram' : 'গ্রাম'), keyboardType: TextInputType.number)),
              ]),
              TextField(controller: ct['oldRate'], decoration: InputDecoration(labelText: isEnglish ? 'Old Metal Deposit Rate' : 'পুরাতন স্বর্ণ/রুপা জমা দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
              TextField(controller: ct['oldGoldPrice'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Old Metal Total Price' : 'পুরাতন স্বর্ণ/রুপার মোট মূল্য (৳)')),
            ]))),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(isEnglish ? 'Khati/Paka Metal Deposit Description:' : 'খাঁটি/পাকা স্বর্ণ/রুপার বিবরণ:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
                Row(
                  children: [
                    Text(isEnglish ? 'Adjust Price?' : 'দর অনুযায়ী দাম বাদ?', style: TextStyle(fontSize: 12, color: Colors.green, fontWeight: FontWeight.bold)),
                    Checkbox(
                      value: isPakaRateChecked, 
                      onChanged: (val) { setState(() { isPakaRateChecked = val!; _calculate(); _logAction('পাকা জমার দর মূল্য সমন্বয় টিক বক্স পরিবর্তন করা হয়েছে: $val'); }); }
                    ),
                  ],
                )
              ],
            ),
            Card(color: Colors.green.shade50, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(isEnglish ? 'Select Paka Metal Type' : 'পাকা ধাতুর প্রকার সিলেক্ট করুন:', style: TextStyle(fontSize: 12)),
                  DropdownButton<String>(
                    value: pakaMetalType,
                    items: ['স্বর্ণ', 'রুপা'].map((m) => DropdownMenuItem(value: m, child: Text(m))).toList(),
                    onChanged: (val) { setState(() { pakaMetalType = val!; }); },
                  )
                ],
              ),
              Row(children: [
                Expanded(child: TextField(controller: ct['pakaVori'], decoration: InputDecoration(labelText: isEnglish ? 'Vori' : 'ভরি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaAna'], decoration: InputDecoration(labelText: isEnglish ? 'Ana' : 'আনা'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaRati'], decoration: InputDecoration(labelText: isEnglish ? 'Rati' : 'রতি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaPoint'], decoration: InputDecoration(labelText: 'Pt'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['pakaGram'], decoration: InputDecoration(labelText: isEnglish ? 'Gram' : 'গ্রাম'), keyboardType: TextInputType.number)),
              ]),
              TextField(controller: ct['pakaRate'], decoration: InputDecoration(labelText: isEnglish ? 'Paka Deposit Rate' : 'খাঁটি/পাকা স্বর্ণ/রুপার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
              TextField(controller: ct['pakaGoldPrice'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? 'Paka Total Valuation' : 'খাঁটি/পাকা স্বর্ণ/রুপার মোট মূল্য (৳)')),
            ]))),
            SizedBox(height: 20),
            Text(isEnglish ? 'Bill & Payment Accounts:' : 'বিল ও পেমেন্ট হিসাব:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Card(child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['totalBill'], decoration: InputDecoration(labelText: isEnglish ? '3. Total Bill (Amount ৳)' : '৩. মোট বিল (টাকা)'), keyboardType: TextInputType.number),
              TextField(controller: ct['cashPaid'], decoration: InputDecoration(labelText: isEnglish ? '4. Cash Payment Received' : '৪. নগদ টাকা জমা দেওয়ার পরিমাণ'), keyboardType: TextInputType.number),
              TextField(controller: ct['bankPaid'], decoration: InputDecoration(labelText: isEnglish ? '5. Mobile Bank or Direct Bank Paid' : '৫. মোবাইল ব্যাংক বা সরাসরি ব্যাংকে জমা'), keyboardType: TextInputType.number),
              TextField(controller: ct['advancePaid'], decoration: InputDecoration(labelText: isEnglish ? '7. Advance/Booking Amount' : '৭. অগ্রিম জমা (যদি থাকে)'), keyboardType: TextInputType.number),
              TextField(controller: ct['dueAmount'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? '8. Remaining Due Balance' : '৮. মোট বাকি/অবशिष्ट')),
              TextField(controller: ct['paymentStatus'], readOnly: true, decoration: InputDecoration(labelText: isEnglish ? '9. Payment Status' : '৯. পরিশোধ স্ট্যাটাস')),
            ]))),
            SizedBox(height: 25),
            SizedBox(
              width: double.infinity, 
              height: 50, 
              child: ElevatedButton(
                onPressed: _submit, 
                child: Text(editingIndex != null ? (isEnglish ? 'Confirm Update Memo' : 'মেমো আপডেট নিশ্চিত করুন') : (isEnglish ? 'Confirm Sale & Create Memo' : 'বিক্রয় নিশ্চিত ও মেমো তৈরি করুন'), style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)), 
                style: ElevatedButton.styleFrom(backgroundColor: Colors.amber)
              )
            )
          ],
        ),
      ),
    );
  }
}

// গুগল শিটে মেমোর সব তথ্য অটোমেটিক পাঠানোর জন্য তৈরি করা ফাংশন
Future<void> saveToGoogleSheet(Map<String, TextEditingController> ct) async {
  try {
    await http.post(
      Uri.parse('https://script.google.com/macros/s/AKfycbw12G6OuAgNTW6GAKIWJLBydbXv7K2VAnpuYQvt0iXC98YdiOPmdDq7UbQYEqbsvoar/exec'),
      body: json.encode({
        'memoNo': ct['sl']!.text,
        'name': ct['name']!.text,
        'mobile': ct['phone']!.text,
        'items': 'Address: ${ct['address']!.text}, Weight: ${ct['totalW']!.text}',
        'total': ct['totalBill']!.text,
        'discount': '0',
        'advanced': ct['advancePaid']!.text,
        'due': ct['dueAmount']!.text,
      }),
    );
  } catch (e) {
    print("Error: $e");
  }
}
