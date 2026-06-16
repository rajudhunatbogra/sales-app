import 'package:shared_preferences/shared_preferences.dart';

class StorageService {
  static const String _memoKey = 'jewelry_last_memo_no';

  static Future<int> getLastMemoNumber() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getInt(_memoKey) ?? 2000; 
  }

  static Future<void> incrementMemoNumber(int currentNumber) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(_memoKey, currentNumber + 1);
  }
}
