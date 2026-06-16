class JewelryItem {
  String name;
  double vori;
  double ana;
  double rati;
  double point;
  double totalVori;
  double pricePerVori;
  double wastage;
  double makingCharge;
  double totalPrice;

  JewelryItem({
    required this.name,
    this.vori = 0,
    this.ana = 0,
    this.rati = 0,
    this.point = 0,
    this.totalVori = 0,
    this.pricePerVori = 0,
    this.wastage = 0,
    this.makingCharge = 0,
    this.totalPrice = 0,
  });

  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'vori': vori,
      'ana': ana,
      'rati': rati,
      'point': point,
      'totalVori': totalVori,
      'pricePerVori': pricePerVori,
      'wastage': wastage,
      'makingCharge': makingCharge,
      'totalPrice': totalPrice,
    };
  }

  factory JewelryItem.fromMap(Map<String, dynamic> map) {
    return JewelryItem(
      name: map['name'] ?? '',
      vori: (map['vori'] ?? 0).toDouble(),
      ana: (map['ana'] ?? 0).toDouble(),
      rati: (map['rati'] ?? 0).toDouble(),
      point: (map['point'] ?? 0).toDouble(),
      totalVori: (map['totalVori'] ?? 0).toDouble(),
      pricePerVori: (map['pricePerVori'] ?? 0).toDouble(),
      wastage: (map['wastage'] ?? 0).toDouble(),
      makingCharge: (map['makingCharge'] ?? 0).toDouble(),
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
    );
  }
}
