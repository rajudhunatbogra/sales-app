import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(primaryColor: Colors.amber, primarySwatch: Colors.amber),
      home: SalesPage(),
    ));

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final Map<String, TextEditingController> ct = {
    'sl': TextEditingController(), 'name': TextEditingController(),
    'address': TextEditingController(), 'phone': TextEditingController(),
    'itemName': TextEditingController(), 'rate': TextEditingController(),
    'itemTotalPrice': TextEditingController(), 'totalW': TextEditingController(), 
    'voriW': TextEditingController(), 'fixedW': TextEditingController(), 
    'customK': TextEditingController(), 
    // বিক্রয় গহনা ওজন
    'vori': TextEditingController(), 'ana': TextEditingController(), 
    'rati': TextEditingController(), 'point': TextEditingController(), 'gram': TextEditingController(),
    // বিল ও পেমেন্ট
    'totalBill': TextEditingController(), 'cashPaid': TextEditingController(), 
    'bankPaid': TextEditingController(), 'advancePaid': TextEditingController(), 
    'dueAmount': TextEditingController(), 'paymentStatus': TextEditingController(),
    // পুরাতন স্বর্ণ/রুপার বিস্তারিত ঘরসমূহ
    'oldItemName': TextEditingController(),
    'oldVori': TextEditingController(), 'oldAna': TextEditingController(),
    'oldRati': TextEditingController(), 'oldPoint': TextEditingController(), 'oldGram': TextEditingController(),
    'oldRate': TextEditingController(), 'oldGoldPrice': TextEditingController(),
    // খাঁটি/পাকা স্বর্ণ/রুপার ঘরসমূহ
    'pakaVori': TextEditingController(), 'pakaAna': TextEditingController(),
    'pakaRati': TextEditingController(), 'pakaPoint': TextEditingController(), 'pakaGram': TextEditingController(),
    'pakaRate': TextEditingController(), 'pakaGoldPrice': TextEditingController(),
  };

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = ['উৎপাদিত নতুন গহনা', 'কেনা নতুন গহনা', 'পুরাতন গহনা', 'বন্ধকী গহনা', 'অন্যান্য খাত (নিচে লিখুন)'];
  
  String selectedCarat = '২১ ক্যারেট হলমার্ক';
  final List<String> caratOptions = ['১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক', '২২ ক্যারেট হলমার্ক'];
  
  List<Map<String, dynamic>> savedSalesList = [];
  bool _isListenerBlocked = false;

  @override
  void initState() {
    super.initState();
    List<String> keys = [
      'vori', 'ana', 'rati', 'point', 'rate', 'voriW', 'fixedW', 
      'totalBill', 'cashPaid', 'bankPaid', 'advancePaid',
      'oldVori', 'oldAna', 'oldRati', 'oldPoint', 'oldRate',
      'pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint', 'pakaRate'
    ];
    for (var k in keys) {
      ct[k]?.addListener(_calculate);
    }
    
    ct['gram']?.addListener(() => _convertGramToVori('gram', ['vori', 'ana', 'rati', 'point']));
    ct['oldGram']?.addListener(() => _convertGramToVori('oldGram', ['oldVori', 'oldAna', 'oldRati', 'oldPoint']));
    ct['pakaGram']?.addListener(() => _convertGramToVori('pakaGram', ['pakaVori', 'pakaAna', 'pakaRati', 'pakaPoint']));
  }
  void _convertGramToVori(String gramKey, List<String> voriKeys) {
    if (_isListenerBlocked) return;
    double gram = double.tryParse(ct[gramKey]!.text) ?? 0;
    if (gram == 0) return;
    
    _isListenerBlocked = true;
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
  }

  void _calculate() {
    if (_isListenerBlocked) return;
    _isListenerBlocked = true;

    double v = double.tryParse(ct['vori']!.text) ?? 0;
    double a = double.tryParse(ct['ana']!.text) ?? 0;
    double r = double.tryParse(ct['rati']!.text) ?? 0;
    double p = double.tryParse(ct['point']!.text) ?? 0;
    double rate = double.tryParse(ct['rate']!.text) ?? 0;
    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;

    double totalNewVori = v + (a / 16) + (r / 96) + (p / 960);
    double totalNewGram = totalNewVori * 11.664;
    if (totalNewGram > 0 && ct['gram']!.text.isEmpty) ct['gram']!.text = totalNewGram.toStringAsFixed(3);

    double ov = double.tryParse(ct['oldVori']!.text) ?? 0;
    double oa = double.tryParse(ct['oldAna']!.text) ?? 0;
    double or = double.tryParse(ct['oldRati']!.text) ?? 0;
    double op = double.tryParse(ct['oldPoint']!.text) ?? 0;
    double oRate = double.tryParse(ct['oldRate']!.text) ?? 0;

    double totalOldVori = ov + (oa / 16) + (or / 96) + (op / 960);
    double totalOldGram = totalOldVori * 11.664;
    if (totalOldGram > 0 && ct['oldGram']!.text.isEmpty) ct['oldGram']!.text = totalOldGram.toStringAsFixed(3);
    double oldPrice = totalOldVori * oRate;
    ct['oldGoldPrice']!.text = oldPrice > 0 ? oldPrice.toStringAsFixed(2) : '';

    double pv = double.tryParse(ct['pakaVori']!.text) ?? 0;
    double pa = double.tryParse(ct['pakaAna']!.text) ?? 0;
    double pr = double.tryParse(ct['pakaRati']!.text) ?? 0;
    double pp = double.tryParse(ct['pakaPoint']!.text) ?? 0;
    double pRate = double.tryParse(ct['pakaRate']!.text) ?? 0;

    double totalPakaVori = pv + (pa / 16) + (pr / 96) + (pp / 960);
    double totalPakaGram = totalPakaVori * 11.664;
    if (totalPakaGram > 0 && ct['pakaGram']!.text.isEmpty) ct['pakaGram']!.text = totalPakaGram.toStringAsFixed(3);
    double pakaPrice = totalPakaVori * pRate;
    ct['pakaGoldPrice']!.text = pakaPrice > 0 ? pakaPrice.toStringAsFixed(2) : '';

    double payableVori = totalNewVori;
    if (totalPakaVori > 0) {
      payableVori = totalNewVori - totalPakaVori;
      if (payableVori < 0) payableVori = 0;
    }

    double itemPrice = payableVori * rate;
    double totalWages = (totalNewVori * vw) + fw;
    
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
    double finalDeduction = totalPakaVori > 0 ? pakaPrice : oldPrice; 
    double due = currentBill - (cash + bank + adv + (totalPakaVori > 0 ? 0 : finalDeduction)); 
    
    ct['dueAmount']!.text = currentBill > 0 ? due.toStringAsFixed(2) : '';
    ct['paymentStatus']!.text = currentBill > 0 && due <= 0 ? 'পরিশোধিত' : 'বাকি আছে';
    
    _isListenerBlocked = false;
  }

  void _submit() {
    if (ct['phone']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মোবাইল নাম্বার লিখুন!'), backgroundColor: Colors.red));
      return;
    }
    
    double pakaCheck = double.tryParse(ct['pakaGoldPrice']!.text) ?? 0;
    String tagLabel = pakaCheck > 0 ? '(খাঁটি/পাকা ওজন কর্তনকৃত)' : '(পুরাতন)';

    setState(() {
      savedSalesList.add({
        'sl': ct['sl']!.text.isEmpty ? (savedSalesList.length + 1).toString() : ct['sl']!.text,
        'date': DateTime.now().toString().substring(0, 16),
        'name': ct['name']!.text, 'address': ct['address']!.text, 'phone': ct['phone']!.text,
        'itemName': ct['itemName']!.text, 'carat': selectedCarat, 'khath': selectedKhath,
        'weightText': '${ct['vori']!.text.isEmpty ? "0" : ct['vori']!.text} ভরি, ${ct['ana']!.text.isEmpty ? "0" : ct['ana']!.text} আনা, ${ct['rati']!.text.isEmpty ? "0" : ct['rati']!.text} রতি, ${ct['point']!.text.isEmpty ? "0" : ct['point']!.text} পয়েন্ট',
        'gram': ct['gram']!.text, 'rate': ct['rate']!.text, 'itemPrice': ct['itemTotalPrice']!.text, 'wages': ct['totalW']!.text,
        'totalBill': ct['totalBill']!.text, 'cashPaid': ct['cashPaid']!.text, 'bankPaid': ct['bankPaid']!.text, 'advancePaid': ct['advancePaid']!.text,
        'dueAmount': ct['dueAmount']!.text, 'paymentStatus': ct['paymentStatus']!.text,
        'oldItemName': ct['oldItemName']!.text, 'oldGoldPrice': ct['oldGoldPrice']!.text, 'goldTag': tagLabel,
        'oldWeightText': '${ct['oldVori']!.text.isEmpty ? "0" : ct['oldVori']!.text} ভরি, ${ct['oldAna']!.text.isEmpty ? "0" : ct['oldAna']!.text} আনা, ${ct['oldRati']!.text.isEmpty ? "0" : ct['oldRati']!.text} রতি, ${ct['oldPoint']!.text.isEmpty ? "0" : ct['oldPoint']!.text} পয়েন্ট (${ct['oldGram']!.text} গ্রাম)',
        'pakaGoldPrice': ct['pakaGoldPrice']!.text,
        'pakaWeightText': '${ct['pakaVori']!.text.isEmpty ? "0" : ct['pakaVori']!.text} ভরি, ${ct['pakaAna']!.text.isEmpty ? "0" : ct['pakaAna']!.text} আনা, ${ct['pakaRati']!.text.isEmpty ? "0" : ct['pakaRati']!.text} রতি, ${ct['pakaPoint']!.text.isEmpty ? "0" : ct['pakaPoint']!.text} পয়েন্ট (${ct['pakaGram']!.text} গ্রাম)',
      });
    });

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('মেমো সফল হয়েছে!', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.green)),
        content: Text('ক্রমিক নং: ${ct['sl']!.text}\nক্রেতা: ${ct['name']!.text}\nমোট বিল: ৳${ct['totalBill']!.text}\nঅবস্থা: ${ct['paymentStatus']!.text}'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); _clear(); }, child: Text('ঠিক আছে'))],
      ),
    );
  }

  void _clear() {
    _isListenerBlocked = true;
    ct.values.forEach((c) => c.clear());
    _isListenerBlocked = false;
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
            onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (ctx) => Scaffold(
              appBar: AppBar(title: Text('বিক্রয় ও পরিপাটি মেমো তালিকা'), backgroundColor: Colors.amber),
              body: savedSalesList.isEmpty ? Center(child: Text('কোনো মেমো তৈরি করা হয়নি!')) : ListView.builder(
                itemCount: savedSalesList.length,
                itemBuilder: (c, i) => Card(
                  margin: EdgeInsets.all(10), elevation: 6,
                  child: Padding(padding: EdgeInsets.all(14.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('ক্রমিক নং: ${savedSalesList[i]['sl']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue, fontSize: 16)),
                      Text('তারিখ: ${savedSalesList[i]['date']}', style: TextStyle(color: Colors.grey)),
                    ]),
                    Divider(thickness: 1.5),
                    Text('ক্রেতার নাম: ${savedSalesList[i]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('মোবাইল: ${savedSalesList[i]['phone']} | ঠিকানা: ${savedSalesList[i]['address']}'),
                    Text('পণ্যের নাম: ${savedSalesList[i]['itemName']} (${savedSalesList[i]['carat']}) | খাত: ${savedSalesList[i]['khath']}'),
                    Divider(),
                    Text('নতুন গহনার মোট ওজন: [ ${savedSalesList[i]['weightText']} ]', style: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold)),
                    Text('গ্রামের হিসাবে: ${savedSalesList[i]['gram']} গ্রাম | দর: ৳${savedSalesList[i]['rate']}'),
                    Text('সোনা/রুপার নেট মূল্য ${savedSalesList[i]['goldTag']}: ৳${savedSalesList[i]['itemPrice']}'),
                    Text('মোট মজুরি বাবদ যোগ: ৳${savedSalesList[i]['wages']}'),
                    if (savedSalesList[i]['oldItemName'].toString().isNotEmpty) ...[
                      Divider(),
                      Text('পুরাতন জমার বিবরণ: ${savedSalesList[i]['oldItemName']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.brown)),
                      Text('পুরাতন গহনার ওজন: [ ${savedSalesList[i]['oldWeightText']} ]'),
                      Text('পুরাতন সোনা বাবদ বাদ: ৳${savedSalesList[i]['oldGoldPrice']}'),
                    ],
                    if ((double.tryParse(savedSalesList[i]['pakaGoldPrice']) ?? 0) > 0) ...[
                      Text('খাঁটি/পাকা ওজনের বিবরণ (কর্তনকৃত): [ ${savedSalesList[i]['pakaWeightText']} ]', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold)),
                    ],
                    Divider(thickness: 1.5),
                    Text('⚙️ বিলের সম্পূর্ণ হিসাব বিবরণী:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueGrey)),
                    Text('• সর্বমোট বিল (সোনা + মজুরি): ৳${savedSalesList[i]['totalBill']}', style: TextStyle(fontWeight: FontWeight.bold)),
                    Text('• [বাদ] নগদ জমা: ৳${savedSalesList[i]['cashPaid']} | • [বাদ] ব্যাংক জমা: ৳${savedSalesList[i]['bankPaid']}'),
                    Text('• [বাদ] অগ্রিম জমা: ৳${savedSalesList[i]['advancePaid']}'),
                    Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('মোট বকেয়া/বাকি: ৳${savedSalesList[i]['dueAmount']}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 16)),
                      Container(padding: EdgeInsets.symmetric(horizontal: 10, vertical: 5), color: savedSalesList[i]['paymentStatus'] == 'পরিশোধিত' ? Colors.green : Colors.orange, child: Text(savedSalesList[i]['paymentStatus'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
                    ]),
                  ])),
                ),
              ),
            ))),
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(elevation: 3, child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['sl'], decoration: InputDecoration(labelText: '১. ক্রমিক নাম্বার')),
              TextField(controller: ct['name'], decoration: InputDecoration(labelText: 'ক্রেতার নাম')),
              TextField(controller: ct['address'], decoration: InputDecoration(labelText: 'ঠিকানা')),
              TextField(controller: ct['phone'], decoration: InputDecoration(labelText: 'মোবাইল নাম্বার'), keyboardType: TextInputType.phone),
              TextField(controller: ct['itemName'], decoration: InputDecoration(labelText: '২. পণ্যের নাম')),
              SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedCarat, decoration: InputDecoration(labelText: 'গহনার ক্যারেট সিলেক্ট করুন'),
                items: caratOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
                onChanged: (n) => setState(() => selectedCarat = n!),
              ),
            ]))),
            SizedBox(height: 15),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () {}, child: Text('পণ্যের ছবি (অচল)'))),
              SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () {}, child: Text('বিক্রেতার আইডি (অচল)', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.grey))),
            ]),
            SizedBox(height: 15),
            Text('ওজন হিসাব (ভরি, আনা, রতি, পয়েন্ট):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.pink, fontSize: 15)),
            Row(children: [
              Expanded(child: TextField(controller: ct['vori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['ana'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['rati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['point'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['gram'], decoration: InputDecoration(labelText: 'গ্রাম'), keyboardType: TextInputType.number)),
            ]),
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
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text('বিক্রয় নিশ্চিত ও মেমো তৈরি করুন', style: TextStyle(color: Colors.white, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber)))
          ],
        ),
      ),
    );
  }
}
