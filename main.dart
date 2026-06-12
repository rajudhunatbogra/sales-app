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
    'name': TextEditingController(), 'address': TextEditingController(), 'phone': TextEditingController(),
    'rate': TextEditingController(), 'totalW': TextEditingController(), 'voriW': TextEditingController(),
    'fixedW': TextEditingController(), 'customK': TextEditingController(), 'vori': TextEditingController(),
    'ana': TextEditingController(), 'rati': TextEditingController(), 'point': TextEditingController(),
    'gram': TextEditingController()
  };

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = ['উৎপাদিত নতুন গহনা', 'কেনা নতুন গহনা', 'পুরাতন গহনা', 'বন্ধকী গহনা', 'অন্যান্য খাত (নিচে লিখুন)'];
  List<Map<String, dynamic>> savedSalesList = [];

  @override
  void initState() {
    super.initState();
    for (var k in ['vori', 'ana', 'rati', 'point', 'voriW', 'fixedW']) {
      ct[k]?.addListener(_calculate);
    }
  }

  void _calculate() {
    double v = double.tryParse(ct['vori']!.text) ?? 0;
    double a = double.tryParse(ct['ana']!.text) ?? 0;
    double r = double.tryParse(ct['rati']!.text) ?? 0;
    double p = double.tryParse(ct['point']!.text) ?? 0;
    double vw = double.tryParse(ct['voriW']!.text) ?? 0;
    double fw = double.tryParse(ct['fixedW']!.text) ?? 0;

    double totalVori = v + (a / 16) + (r / 96) + (p / 960);
    double totalGram = totalVori * 11.664;
    double totalWages = (totalVori * vw) + fw;

    ct['gram']!.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
    ct['totalW']!.text = totalWages > 0 ? totalWages.toStringAsFixed(2) : '';
  }

  void _submit() {
    if (ct['phone']!.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('মোবাইল নাম্বার লিখুন!'), backgroundColor: Colors.red));
      return;
    }
    setState(() {
      savedSalesList.add({
        'name': ct['name']!.text, 'phone': ct['phone']!.text, 'gram': ct['gram']!.text, 'wages': ct['totalW']!.text,
        'khath': selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)' ? ct['customK']!.text : selectedKhath, 'date': DateTime.now().toString().substring(0, 16)
      });
    });
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text('মেমো সফল হয়েছে!'),
        content: Text('ক্রেতা: ${ct['name']!.text}\nমোট ওজন: ${ct['gram']!.text} গ্রাম\nমোট মজুরি: ৳${ct['totalW']!.text}\n\nলোকাল লিস্টে সেভ হয়েছে।'),
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
              appBar: AppBar(title: Text('মেমো তালিকা'), backgroundColor: Colors.amber),
              body: savedSalesList.isEmpty ? Center(child: Text('কোনো মেমো তৈরি করা হয়নি!')) : ListView.builder(
                itemCount: savedSalesList.length,
                itemBuilder: (c, i) => Card(child: ListTile(
                  title: Text('ক্রেতা: ${savedSalesList[i]['name']} (${savedSalesList[i]['phone']})'),
                  subtitle: Text('ওজন: ${savedSalesList[i]['gram']} গ্রাম | মজুরি: ৳${savedSalesList[i]['wages']}\nখাত: ${savedSalesList[i]['khath']}'),
                )),
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
              TextField(controller: ct['name'], decoration: InputDecoration(labelText: 'ক্রেতার নাম')),
              TextField(controller: ct['address'], decoration: InputDecoration(labelText: 'ঠিকানা')),
              TextField(controller: ct['phone'], decoration: InputDecoration(labelText: 'মোবাইল নাম্বার'), keyboardType: TextInputType.phone),
            ]))),
            SizedBox(height: 15),
            Row(children: [
              Expanded(child: ElevatedButton(onPressed: () {}, child: Text('পণ্যের ছবি'))),
              SizedBox(width: 8),
              Expanded(child: ElevatedButton(onPressed: () {}, child: Text('বিক্রেতার আইডি', style: TextStyle(color: Colors.white)), style: ElevatedButton.styleFrom(backgroundColor: Colors.green))),
            ]),
            SizedBox(height: 15),
            Text('ওজন হিসাব (অটো কনভার্ট):', style: TextStyle(fontWeight: FontWeight.bold)),
            Row(children: [
              Expanded(child: TextField(controller: ct['vori'], decoration: InputDecoration(labelText: 'ভরি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['ana'], decoration: InputDecoration(labelText: 'আনা'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['rati'], decoration: InputDecoration(labelText: 'রতি'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['point'], decoration: InputDecoration(labelText: 'পয়েন্ট'), keyboardType: TextInputType.number)),
              Expanded(child: TextField(controller: ct['gram'], readOnly: true, decoration: InputDecoration(labelText: 'গ্রাম'))),
            ]),
            SizedBox(height: 15),
            TextField(controller: ct['rate'], decoration: InputDecoration(labelText: 'সোনার দর (প্রতি ভরি ৳)'), keyboardType: TextInputType.number),
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
            SizedBox(height: 25),
            SizedBox(width: double.infinity, height: 50, child: ElevatedButton(onPressed: _submit, child: Text('মেমো তৈরি করুন', style: TextStyle(color: Colors.white, fontSize: 16)), style: ElevatedButton.styleFrom(backgroundColor: Colors.amber)))
          ],
        ),
      ),
    );
  }
}
