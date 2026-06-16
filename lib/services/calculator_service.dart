import '../models/jewelry_item.dart';

class CalculatorService {
  static double calculateTotalVori(double vori, double ana, double rati, double point) {
    double total = vori + (ana / 16) + (rati / 96) + (point / 960);
    return double.parse(total.toStringAsFixed(4));
  }

  static double calculateItemTotalPrice(JewelryItem item) {
    double totalVori = calculateTotalVori(item.vori, item.ana, item.rati, item.point);
    double basePrice = (totalVori + item.wastage) * item.pricePerVori;
    double finalPrice = basePrice + item.makingCharge;
    return double.parse(finalPrice.toStringAsFixed(2));
  }
}
