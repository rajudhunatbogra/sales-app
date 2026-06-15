class MemoModel {
  String sl;
  String customerName;
  String phone;
  String address;
  String date;
  double totalBill;
  double dueAmount;
  String paymentStatus;

  MemoModel({
    required this.sl,
    required this.customerName,
    required this.phone,
    required this.address,
    required this.date,
    required this.totalBill,
    required this.dueAmount,
    required this.paymentStatus,
  });

  Map<String, dynamic> toMap() {
    return {
      'sl': sl,
      'customerName': customerName,
      'phone': phone,
      'address': address,
      'date': date,
      'totalBill': totalBill,
      'dueAmount': dueAmount,
      'paymentStatus': paymentStatus,
    };
  }

  factory MemoModel.fromMap(Map<String, dynamic> map) {
    return MemoModel(
      sl: map['sl'] ?? '',
      customerName: map['customerName'] ?? '',
      phone: map['phone'] ?? '',
      address: map['address'] ?? '',
      date: map['date'] ?? '',
      totalBill: (map['totalBill'] ?? 0).toDouble(),
      dueAmount: (map['dueAmount'] ?? 0).toDouble(),
      paymentStatus: map['paymentStatus'] ?? '',
    );
  }
}
