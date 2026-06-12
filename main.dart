import 'package:flutter/material.dart';

void main() => runApp(MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(primaryColor: Colors.amber),
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
    'customK': TextEditingController(), 'vori': TextEditingController(), 
    'ana': TextEditingController(), 'rati': TextEditingController(), 
    'point': TextEditingController(), 'gram': TextEditingController(),
    'stonePrice': TextEditingController(), 'vatPrice': TextEditingController(),
    'otherExpense': TextEditingController(), 'totalBill': TextEditingController(), 
    'cashPaid': TextEditingController(), 'bankPaid': TextEditingController(), 
    'oldVori': TextEditingController(), 'oldAna': TextEditingController(),
    'oldRati': TextEditingController(), 'oldPoint': TextEditingController(),
    'oldGram': TextEditingController(), 'oldRate': TextEditingController(), 
    'oldGoldPrice': TextEditingController(), 'advancePaid': TextEditingController(), 
    'dueAmount': TextEditingController(), 'paymentStatus': TextEditingController()
  };

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = ['উৎপাদিত নতুন গহনা', 'কেনা নতুন গহনা', 'পুরাতন গহনা', 'বন্ধকী গহনা', 'অন্যান্য খাত (নিচে লিখুন)'];
  
  String selectedCarat = '২১ ক্যারেট হলমার্ক';
  final List<String> caratOptions = ['১৮ ক্যারেট বাংলা', '১৮ ক্যারেট কেডিয়াম', '২১ ক্যারেট বাংলা', '২১ ক্যারেট কেডিয়াম', '২১ ক্যারেট হলমার্ক', '২২ ক্যারেট হলমার্ক'];
  
  List<Map<String, dynamic>> savedSalesList = [];

  @override
  void initState() {
    super.initState();
    for (var k in ['vori', 'ana', 'rati', 'point', 'rate', 'voriW', 'fixedW', 'stonePrice', 'vatPrice', 'otherExpense', 'cashPaid', 'bankPaid', 'oldVori', 'oldAna', 'oldRati', 'oldPoint', 'oldRate', 'advancePaid']) {
      ct[k]?.addListener(_calculate);
    }
  }

  void _calculate() {
    // নতুন গহনার ওজন হিসাব
    double v = double.tryParse(ct['vori']!.text) ?? 0;
    double a = double.tryParse(ct['ana']!.text) ?? 0;
    double r = double.tryParse(ct['rati']!.text) ?? 0;
    double p = double.tryParse(ct['point']!.text) ?? 0;
    double rate = double.tryParse(ct['rate']!.text) ?? 0;
    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;

    double totalVori = v + (a / 16) + (r / 96) + (p / 960);
    double totalGram = totalVori * 11.664;
    double itemPrice = totalVori * rate;
    double totalWages = (totalVori * vw) + fw;

    ct['gram']!.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
    ct['itemTotalPrice']!.text = itemPrice > 0 ? itemPrice.toStringAsFixed(2) : '';
    ct['totalW']!.text = totalWages > 0 ? totalWages.toStringAsFixed(2) : '';

    // পুরাতন গহনার ভরি, আনা, রতি, পয়েন্ট ওজন ও দাম হিসাব
    double ov = double.tryParse(ct['oldVori']!.text) ?? 0;
    double oa = double.tryParse(ct['oldAna']!.text) ?? 0;
    double or = double.tryParse(ct['oldRati']!.text) ?? 0;
    double op = double.tryParse(ct['oldPoint']!.text) ?? 0;
    double oRate = double.tryParse(ct['oldRate']!.text) ?? 0;

    double oldTotalVori = ov + (oa / 16) + (or / 96) + (op / 960);
    double oldTotalGram = oldTotalVori * 11.664;
    double oldPrice = oldTotalVori * oRate;

    ct['oldGram']!.text = oldTotalGram > 0 ? oldTotalGram.toStringAsFixed(3) : '';
    ct['oldGoldPrice']!.text = oldPrice > 0 ? oldPrice.toStringAsFixed(2) : '';

    // আপনার নতুন ব্যবসায়িক সূত্র: মোট বিল = সোনার দাম + মোট মজুরি + পাথর + ভ্যাট + অন্যান্য খরচ
    double stone = double.tryParse(ct['stonePrice']!.text) ?? 0;
    double vat = double.tryParse(ct['vatPrice']!.text) ?? 0;
    double otherEx = double.tryParse(ct['otherExpense']!.text) ?? 0;
    
    double calculatedBill = itemPrice + totalWages + stone + vat + otherEx;
    ct['totalBill']!.text = calculatedBill > 0 ? calculatedBill.toStringAsFixed(2) : '';

    // বিল থেকে সমস্ত জমা বাদ দিয়ে বাকি (Due) হিসাব
    double cash = double.tryParse(ct['cashPaid']!.text) ?? 0;
    double bank = double.tryParse(ct['bankPaid']!.text) ?? 0;
    double adv = double.tryParse(ct['advancePaid']!.text) ?? 0;

    double due = calculatedBill - (cash + bank + oldPrice + adv);
    ct['dueAmount']!.text = calculatedBill > 0 ? due.toStringAsFixed(2) : '';
    ct['paymentStatus']!.text = calculatedBill > 0 && due <= 0 ? 'পরিশোধিত' : 'বাকি আছে';
  }
  void _submit() {
    if (ct['phone']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মোবাইল নাম্বার লিখুন!'), backgroundColor: Colors.red));
      return;
    }
    setState(() {
      savedSalesList.add({
        'sl': ct['sl']!.text.isEmpty ? (savedSalesList.length + 1).toString() : ct['sl']!.text,
        'date': DateTime.now().toString().substring(0, 16), 'name': ct['name']!.text, 'address': ct['address']!.text, 
        'phone': ct['phone']!.text, 'itemName': ct['itemName']!.text, 'carat': selectedCarat,
        'khath': selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)' ? ct['customK']!.text : selectedKhath,
        'weightText': '${ct['vori']!.text.isEmpty ? "০" : ct['vori']!.text} ভরি, ${ct['ana']!.text.isEmpty ? "০" : ct['ana']!.text} আনা, ${ct['rati']!.text.isEmpty ? "০" : ct['rati']!.text} রতি, ${ct['point']!.text.isEmpty ? "০" : ct['point']!.text} পয়েন্ট',
        'gram': ct['gram']!.text, 'rate': ct['rate']!.text, 'itemPrice': ct['itemTotalPrice']!.text, 'wages': ct['totalW']!.text, 'totalBill': ct['totalBill']!.text, 
        'cashPaid': ct['cashPaid']!.text, 'bankPaid': ct['bankPaid']!.text, 
        'oldWeightText': '${ct['oldVori']!.text.isEmpty ? "০" : ct['oldVori']!.text} ভরি, ${ct['oldAna']!.text.isEmpty ? "০" : ct['oldAna']!.text} আনা, ${ct['oldRati']!.text.isEmpty ? "০" : ct['oldRati']!.text} রতি, ${ct['oldPoint']!.text.isEmpty ? "০" : ct['oldPoint']!.text} পয়েন্ট',
        'oldGram': ct['oldGram']!.text, 'oldRate': ct['oldRate']!.text, 'oldGoldPrice': ct['oldGoldPrice']!.text, 
        'advancePaid': ct['advancePaid']!.text, 'dueAmount': ct['dueAmount']!.text, 'paymentStatus': ct['paymentStatus']!.text
      });
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('মেমো সফল হয়েছে!'),
        content: Text('ক্রমিক নং: ${ct['sl']!.text}\nক্রেতা: ${ct['name']!.text}\nমোট বিল অটো: ৳${ct['totalBill']!.text}\nঅবস্থা: ${ct['paymentStatus']!.text}'),
        actions: [TextButton(onPressed: () { Navigator.pop(ctx); _clear(); }, child: Text('ঠিক আছে'))],
      ),
    );
  }

  void _clear() => ct.values.forEach((c) => c.clear());

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
              appBar: AppBar(title: Text('বিক্রয় ও মেমো তালিকা'), backgroundColor: Colors.amber),
              body: savedSalesList.isEmpty ? Center(child: Text('কোনো মেমো তৈরি করা হয়নি!')) : ListView.builder(
                itemCount: savedSalesList.length,
                itemBuilder: (c, i) => Card(
                  margin: EdgeInsets.all(10), elevation: 4,
                  child: Padding(padding: EdgeInsets.all(12.0), child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('ক্রমিক নং: ${savedSalesList[i]['sl']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
                      Text('তারিখ: ${savedSalesList[i]['date']}', style: TextStyle(color: Colors.grey)),
                    ]),
                    Divider(),
                    Text('ক্রেতার নাম: ${savedSalesList[i]['name']}', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                    Text('মোবাইল: ${savedSalesList[i]['phone']} | ঠিকানা: ${savedSalesList[i]['address']}'),
                    Text('পণ্যের নাম: ${savedSalesList[i]['itemName']} (${savedSalesList[i]['carat']})'),
                    Divider(),
                    Text('গহনার ওজন (রতিসহ): ${savedSalesList[i]['weightText']}', style: TextStyle(color: Colors.amber, fontWeight: FontWeight.bold)),
                    Text('গ্রামের হিসাবে: ${savedSalesList[i]['gram']} গ্রাম | ভরি দর: ৳${savedSalesList[i]['rate']} | সোনার দাম: ৳${savedSalesList[i]['itemPrice']}'),
                    Text('মোট মজুরি: ৳${savedSalesList[i]['wages']}'),
                    Divider(),
                    Text('১. মোট বিল (অটো সূত্র): ৳${savedSalesList[i]['totalBill']}', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.purple, fontSize: 15)),
                    Text('২. নগদ জমা: ৳${savedSalesList[i]['cashPaid']} | ৩. ব্যাংক জমা: ৳${savedSalesList[i]['bankPaid']}'),
                    Text('৪. পুরাতন সোনা ওজন: ${savedSalesList[i]['oldWeightText']} (${savedSalesList[i]['oldGram']} গ্রাম)'),
                    Text('   পুরাতন সোনা দর: ৳${savedSalesList[i]['oldRate']} | মোট মূল্য: ৳${savedSalesList[i]['oldGoldPrice']}'),
                    Text('৫. অগ্রিম জমা: ৳${savedSalesList[i]['advancePaid']}'),
                    Divider(),
                    Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
                      Text('বাকি/অবशिष्ट: ৳${savedSalesList[i]['dueAmount']}', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold, fontSize: 15)),
                      Container(padding: EdgeInsets.symmetric(horizontal: 8, vertical: 4), color: savedSalesList[i]['paymentStatus'] == 'পরিশোধিত' ? Colors.green : Colors.orange, child: Text(savedSalesList[i]['paymentStatus'], style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold))),
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
            Card(child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['sl'], decoration: InputDecoration(labelText: '১. ক্রমিক নাম্বার (ফাঁকা রাখলে অটো বসবে)')),
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
            Text('ওজন হিসাব (ভরি, আনা, রতি, পয়েন্ট):', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.amber)),
            Row(children: [
              Expanded(child: TextField(controller: ct['vori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['ana'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['rati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['point'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['gram'], readOnly: true, decoration: InputDecoration(labelText: 'গ্রাম (অটো)'))),
            ]),
            SizedBox(height: 15),
            TextField(controller: ct['rate'], decoration: InputDecoration(labelText: 'সোনার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['itemTotalPrice'], readOnly: true, decoration: InputDecoration(labelText: 'সোনার মোট দাম অটো (৳)')),
            TextField(controller: ct['voriW'], decoration: InputDecoration(labelText: 'ভরি প্রতি মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['fixedW'], decoration: InputDecoration(labelText: 'ফিক্সড মজুরি (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['totalW'], readOnly: true, decoration: InputDecoration(labelText: 'মোট মজুরি অটো (৳)')),
            TextField(controller: ct['stonePrice'], decoration: InputDecoration(labelText: 'পাথর/ডায়মন্ড মূল্য (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['vatPrice'], decoration: InputDecoration(labelText: 'ভ্যাট বা ট্যাক্স (৳)'), keyboardType: TextInputType.number),
            TextField(controller: ct['otherExpense'], decoration: InputDecoration(labelText: 'অন্যান্য খরচ (৳)'), keyboardType: TextInputType.number),
            
            SizedBox(height: 15),
            DropdownButton<String>(
              value: selectedKhath, isExpanded: true,
              items: khathOptions.map((v) => DropdownMenuItem(value: v, child: Text(v))).toList(),
              onChanged: (n) => setState(() => selectedKhath = n!),
            ),
            if (selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)') TextField(controller: ct['customK'], decoration: InputDecoration(labelText: 'খাতের নাম')),
            SizedBox(height: 15),
            Text('বিল ও পেমেন্ট হিসাব:', style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blue)),
            Card(child: Padding(padding: EdgeInsets.all(12.0), child: Column(children: [
              TextField(controller: ct['totalBill'], readOnly: true, decoration: InputDecoration(labelText: '৩. মোট বিল অটো সূত্র (৳)', labelStyle: TextStyle(color: Colors.purple, fontWeight: FontWeight.bold))),
              TextField(controller: ct['cashPaid'], decoration: InputDecoration(labelText: '৪. নগদ টাকা জমা দেওয়ার পরিমাণ'), keyboardType: TextInputType.number),
              TextField(controller: ct['bankPaid'], decoration: InputDecoration(labelText: '৫. মোবাইল ব্যাংক বা সরাসরি ব্যাংকে জমা'), keyboardType: TextInputType.number),
              SizedBox(height: 10),
              Text('৬. পুরাতন স্বর্ণ/রুপা জমা ওজন:', style: TextStyle(fontSize: 13, color: Colors.grey)),
              Row(children: [
                Expanded(child: TextField(controller: ct['oldVori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldAna'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldRati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldPoint'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
                Expanded(child: TextField(controller: ct['oldGram'], readOnly: true, decoration: InputDecoration(labelText: 'গ্রাম'))),
              ]),
              TextField(controller: ct['oldRate'], decoration: InputDecoration(labelText: 'পুরাতন স্বর্ণ/রুপা জমা দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
              TextField(controller: ct['oldGoldPrice'], readOnly: true, decoration: InputDecoration(labelText: 'পুরাতন স্বর্ণ/রুপার মোট মূল্য অটো (৳)')),
              TextField(controller: ct['advancePaid'], decoration: InputDecoration(labelText: '৭. অগ্রিম জমা (যদি থাকে)'), keyboardType: TextInputType.number),
              TextField(controller: ct['dueAmount'], readOnly: true, decoration: InputDecoration(labelText: '৮. মোট বাকি/অবশিষ্ট (অটো)')),
              TextField(controller: ct['paymentStatus'], readOnly: true, decoration: InputDecoration(labelText: '৯. পরিশোধ স্ট্যাটাস (অটো)')),
            ]))),
            SizedBox(height: 25),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text('বিক্রয় নিশ্চিত ও মেমো তৈরি করুন', style: TextStyle(color: Colors.white, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber)))
          ],
        ),
      ),
    );
  }
}
