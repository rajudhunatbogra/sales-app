import 'package:flutter/material.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'জুয়েলারি বিক্রয় ও হিসাব',
      theme: ThemeData(
        primaryColor: Colors.amber,
      ),
      home: SalesPage(),
    );
  }
}

class SalesPage extends StatefulWidget {
  @override
  _SalesPageState createState() => _SalesPageState();
}

class _SalesPageState extends State<SalesPage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController addressController = TextEditingController();
  final TextEditingController phoneController = TextEditingController();
  final TextEditingController rateController = TextEditingController();
  final TextEditingController totalWagesController = TextEditingController();
  final TextEditingController voriWagesController = TextEditingController();
  final TextEditingController fixedWagesController = TextEditingController();
  final TextEditingController customKhathController = TextEditingController();

  final TextEditingController voriController = TextEditingController();
  final TextEditingController anaController = TextEditingController();
  final TextEditingController ratiController = TextEditingController();
  final TextEditingController pointController = TextEditingController();
  final TextEditingController gramController = TextEditingController();

  String selectedKhath = 'উৎপাদিত নতুন গহনা';
  final List<String> khathOptions = [
    'উৎপাদিত নতুন গহনা',
    'কেনা নতুন গহনা',
    'পুরাতন গহনা',
    'বন্ধকী গহনা',
    'অন্যান্য খাত (নিচে লিখুন)'
  ];

  List<Map<String, dynamic>> savedSalesList = [];

  void _showUploadMessage(String type) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('$type আপলোড ফিচারটি ডেভেলপমেন্ট মোডে আছে।')),
    );
  }

  @override
  void initState() {
    super.initState();
    voriController.addListener(_calculateGramAndWages);
    anaController.addListener(_calculateGramAndWages);
    ratiController.addListener(_calculateGramAndWages);
    pointController.addListener(_calculateGramAndWages);
    voriWagesController.addListener(_calculateGramAndWages);
    fixedWagesController.addListener(_calculateGramAndWages);
  }

  void _calculateGramAndWages() {
    double vori = double.tryParse(voriController.text) ?? 0;
    double ana = double.tryParse(anaController.text) ?? 0;
    double rati = double.tryParse(ratiController.text) ?? 0;
    double point = double.tryParse(pointController.text) ?? 0;
    double voriWages = double.tryParse(voriWagesController.text) ?? 0;
    double fixedWages = double.tryParse(fixedWagesController.text) ?? 0;

    double totalVori = vori + (ana / 16) + (rati / (16 * 6)) + (point / (16 * 6 * 10));
    double totalGram = totalVori * 11.664;
    double totalWages = (totalVori * voriWages) + fixedWages;

    if (gramController.text != totalGram.toStringAsFixed(3)) {
      gramController.text = totalGram > 0 ? totalGram.toStringAsFixed(3) : '';
    }
    if (totalWagesController.text != totalWages.toStringAsFixed(2)) {
      totalWagesController.text = totalWages > 0 ? totalWages.toStringAsFixed(2) : '';
    }
  }

  void _submitDataAndCreateMemo() {
    if (phoneController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('অনুগ্রহ করে মোবাইল নাম্বারটি লিখুন!'), backgroundColor: Colors.red),
      );
      return;
    }

    Map<String, dynamic> newSale = {
      'name': nameController.text,
      'address': addressController.text,
      'phone': phoneController.text,
      'weight': '${voriController.text} ভরি, ${anaController.text} আনা, ${ratiController.text} রতি',
      'gram': gramController.text,
      'rate': rateController.text,
      'wages': totalWagesController.text,
      'khath': selectedKhath == 'অন্যান্য খাত (নিচে লিখুন)' ? customKhathController.text : selectedKhath,
      'date': DateTime.now().toString().substring(0, 16),
    };

    setState(() {
      savedSalesList.add(newSale);
    });

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('মেমো তৈরি সফল হয়েছে!'),
        content: Text('ক্রেতা: ${nameController.text}\nমোবাইল: ${phoneController.text}\nমোট ওজন: ${gramController.text} গ্রাম\nমোট মজুরি: ৳${totalWagesController.text}\n\nতথ্যটি সেভ হয়েছে। ওপরের লিস্ট আইকন থেকে দেখতে পারবেন।'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _clearForm();
            },
            child: Text('ঠিক আছে'),
          )
        ],
      ),
    );
  }

  void _clearForm() {
    nameController.clear();
    addressController.clear();
    phoneController.clear();
    voriController.clear();
    anaController.clear();
    ratiController.clear();
    pointController.clear();
    gramController.clear();
    rateController.clear();
    voriWagesController.clear();
    fixedWagesController.clear();
    totalWagesController.clear();
    customKhathController.clear();
  }

  void _viewSavedList() {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Scaffold(
          appBar: AppBar(title: Text('বিক্রয় ও মেমো তালিকা'), backgroundColor: Colors.amber),
          body: savedSalesList.isEmpty
              ? Center(child: Text('এখনো কোনো মেমো তৈরি করা হয়নি!'))
              : ListView.builder(
                  itemCount: savedSalesList.length,
                  itemBuilder: (context, index) {
                    final item = savedSalesList[index];
                    return Card(
                      margin: EdgeInsets.all(8),
                      child: ListTile(
                        title: Text('ক্রেতা: ${item['name']} (${item['phone']})'),
                        subtitle: Text('ওজন: ${item['gram']} গ্রাম | মজুরি: ৳${item['wages']}\nখাত: ${item['khath']} | তারিখ: ${item['date']}'),
                        trailing: Icon(Icons.receipt_long, color: Colors.amber),
                      ),
                    );
                  },
                ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    addressController.dispose();
    phoneController.dispose();
    rateController.dispose();
    totalWagesController.dispose();
    voriWagesController.dispose();
    fixedWagesController.dispose();
    customKhathController.dispose();
    voriController.dispose();
    anaController.dispose();
    ratiController.dispose();
    pointController.dispose();
    gramController.dispose();
    super.dispose();
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
            onPressed: _viewSavedList,
            tooltip: 'সব মেমো লিস্ট দেখুন',
          )
        ],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              elevation: 4,
              child: Padding(
                padding: EdgeInsets.all(12.0),
                child: Column(
                  children: [
                    TextField(controller: nameController, decoration: InputDecoration(labelText: 'ক্রেতার নাম', icon: Icon(Icons.person))),
                    TextField(controller: addressController, decoration: InputDecoration(labelText: 'ঠিকানা', icon: Icon(Icons.location_on))),
                    TextField(controller: phoneController, decoration: InputDecoration(labelText: 'মোবাইল নাম্বার', icon: Icon(Icons.phone)), keyboardType: TextInputType.phone),
                  ],
                ),
              ),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUploadMessage('পণ্যের ছবি'),
                    icon: Icon(Icons.camera_alt, color: Colors.white),
                    label: Text('পণ্যের ছবি', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.blue),
                  ),
                ),
                SizedBox(width: 8),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () => _showUploadMessage('বিক্রেতার আইডি'),
                    icon: Icon(Icons.credit_card, color: Colors.white),
                    label: Text('বিক্রেতার আইডি', style: TextStyle(color: Colors.white)),
                    style: ElevatedButton.styleFrom(backgroundColor: Colors.green),
                  ),
                ),
              ],
            ),
            SizedBox(height: 15),
            Text('পণ্যের ওজন হিসাব:', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            SizedBox(height: 5),
            Row(
              children: [
                Expanded(child: TextField(controller: voriController, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'ভরি'), keyboardType: TextInputType.number)),
                SizedBox(width: 4),
                Expanded(child: TextField(controller: anaController, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'আনা'), keyboardType: TextInputType.number)),
                SizedBox(width: 4),
                Expanded(child: TextField(controller: ratiController, decoration: InputDecoration(border: OutlineInputBorder(), labelText: 'রতি'), keyboardType: TextInputType.number)),
                SizedBox(width: 4),
