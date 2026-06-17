import 'jewelry_item.dart';

class Memo {
  int? id;
  String memoNo;
  String customerName;
  String customerPhone;
  String customerAddress;
  String date;
  
  double subTotal;
  double discount;
  double grandTotal;
  double paidAmount;
  double dueAmount;
  
  List<JewelryItem> items; // বিক্রিত নতুন গহনার তালিকা
  List<JewelryItem> exchangeItems; // কাস্টমারের জমা দেওয়া পুরাতন/পাকা গহনার তালিকা (নতুন যুক্ত হলো)

  Memo({
    this.id,
    required this.memoNo,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.date,
    required this.subTotal,
    required this.discount,
    required this.grandTotal,
    required this.paidAmount,
    required this.dueAmount,
    required this.items,
    required this.exchangeItems, // বাধ্যতামূলক করা হলো
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
