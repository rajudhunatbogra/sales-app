import 'jewelry_item.dart';

class Memo {
  int? id;
  String memoNo;
  String customerName;
  String customerPhone;
  String customerAddress;
  String date;
  List<JewelryItem> items;
  double subTotal;
  double discount;
  double grandTotal;
  double paidAmount;
  double dueAmount;

  Memo({
    this.id,
    required this.memoNo,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.date,
    required this.items,
    required this.subTotal,
    required this.discount,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'memoNo': memoNo,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'date': date,
      'subTotal': subTotal,
      'discount': discount,
      'grandTotal': grandTotal,
      'paidAmount': paidAmount,
      'dueAmount': dueAmount,
    };
  }
}
