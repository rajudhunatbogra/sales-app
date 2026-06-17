class JewelryItem {
  int? id; // ডেটাবেজ আইডির জন্য (নতুন আইটেমের ক্ষেত্রে null হতে পারে)
  String name;
  String karat; // ২২, ২১, ১৮ ক্যারেট বা সনাতন (নতুন ফিল্ড)
  double vori;
  double ana;
  double rati;
  double point;
  double totalVori;
  double pricePerVori;
  double wastage;
  double makingCharge;
  double totalPrice;
  int stockQuantity; // স্টকে কয়টি আছে ট্র্যাক করার জন্য (নতুন ফিল্ড)

  JewelryItem({
    this.id,
    required this.name,
    this.karat = '22K', // ডিফল্ট ২২ ক্যারেট রাখা হলো
    this.vori = 0,
    this.ana = 0,
    this.rati = 0,
    this.point = 0,
    this.totalVori = 0,
    this.pricePerVori = 0,
    this.wastage = 0,
    this.makingCharge = 0,
    this.totalPrice = 0,
    this.stockQuantity = 1, // ডিফল্ট স্টক ১টি ধরা হলো
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'karat': karat,
      'vori': vori,
      'ana': ana,
      'rati': rati,
      'point': point,
      'totalVori': totalVori,
      'pricePerVori': pricePerVori,
      'wastage': wastage,
      'makingCharge': makingCharge,
      'totalPrice': totalPrice,
      'stockQuantity': stockQuantity,
    };
  }

  factory JewelryItem.fromMap(Map<String, dynamic> map) {
    return JewelryItem(
      id: map['id'],
      name: map['name'] ?? '',
      karat: map['karat'] ?? '22K',
      vori: (map['vori'] ?? 0).toDouble(),
      ana: (map['ana'] ?? 0).toDouble(),
      rati: (map['rati'] ?? 0).toDouble(),
      point: (map['point'] ?? 0).toDouble(),
      totalVori: (map['totalVori'] ?? 0).toDouble(),
      pricePerVori: (map['pricePerVori'] ?? 0).toDouble(),
      wastage: (map['wastage'] ?? 0).toDouble(),
      makingCharge: (map['makingCharge'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      stockQuantity: map['stockQuantity'] ?? 1,
    );
  }
}
