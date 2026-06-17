class JewelryItem {
  int? id;
  String name; // গহনার নাম/ডিজাইন
  String itemType; // 'সোনা' নাকি 'রূপা' বা 'অন্যান্য'
  String karat; // আপনার দেওয়া ১০টি ক্যারেটের যেকোনো একটি
  
  // ওজনের হিসাব (ভরি, আনা, রতি, পয়েন্ট, গ্রাম)
  double vori;
  double ana;
  double rati;
  double point;
  double gram;
  double totalVori;
  double pricePerVori;
  double wastage;
  double makingCharge;
  double totalPrice;
  int stockQuantity;

  // ওল্ড গোল্ড এক্সচেঞ্জ (পুরাতন গহনা) এবং পাকা/খাঁটি মেটালের হিসাব
  bool isExchange; // এটি পুরাতন গহনা বা এক্সচেঞ্জ কিনা
  String exchangeType; // 'পাকা/খাঁটি' নাকি 'দাম অনুযায়ী'
  double exchangeRate; // পুরাতন বা পাকা মেটালের দর
  double exchangeAmount; // পুরাতন বা পাকা মেটালের মোট মূল্য

  JewelryItem({
    this.id,
    required this.name,
    this.itemType = 'সোনা', // ডিফল্ট সোনা রাখা হলো
    this.karat = '২২ ক্যারেট হলমার্ক', // ডিফল্ট আপনার তালিকা থেকে রাখা হলো
    this.vori = 0,
    this.ana = 0,
    this.rati = 0,
    this.point = 0,
    this.gram = 0,
    this.totalVori = 0,
    this.pricePerVori = 0,
    this.wastage = 0,
    this.makingCharge = 0,
    this.totalPrice = 0,
    this.stockQuantity = 1,
    this.isExchange = false,
    this.exchangeType = 'পাকা/খাঁটি',
    this.exchangeRate = 0,
    this.exchangeAmount = 0,
  });
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'itemType': itemType,
      'karat': karat,
      'vori': vori,
      'ana': ana,
      'rati': rati,
      'point': point,
      'gram': gram,
      'totalVori': totalVori,
      'pricePerVori': pricePerVori,
      'wastage': wastage,
      'makingCharge': makingCharge,
      'totalPrice': totalPrice,
      'stockQuantity': stockQuantity,
      'isExchange': isExchange ? 1 : 0,
      'exchangeType': exchangeType,
      'exchangeRate': exchangeRate,
      'exchangeAmount': exchangeAmount,
    };
  }
  factory JewelryItem.fromMap(Map<String, dynamic> map) {
    return JewelryItem(
      id: map['id'],
      name: map['name'] ?? '',
      itemType: map['itemType'] ?? 'সোনা',
      karat: map['karat'] ?? '২২ ক্যারেট হলমার্ক',
      vori: (map['vori'] ?? 0).toDouble(),
      ana: (map['ana'] ?? 0).toDouble(),
      rati: (map['rati'] ?? 0).toDouble(),
      point: (map['point'] ?? 0).toDouble(),
      gram: (map['gram'] ?? 0).toDouble(),
      totalVori: (map['totalVori'] ?? 0).toDouble(),
      pricePerVori: (map['pricePerVori'] ?? 0).toDouble(),
      wastage: (map['wastage'] ?? 0).toDouble(),
      makingCharge: (map['makingCharge'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 1,
      isExchange: (map['isExchange'] ?? 0) == 1,
      exchangeType: map['exchangeType'] ?? 'পাকা/খাঁটি',
      exchangeRate: (map['exchangeRate'] ?? 0).toDouble(),
      exchangeAmount: (map['exchangeAmount'] ?? 0).toDouble(),
    );
  }
}
