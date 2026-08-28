import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

abstract final class LocalStorage {
  static Future<List<Map<String, dynamic>>?> readList(String key) async {
    final preferences = await SharedPreferences.getInstance();
    final value = preferences.getString(key);
    if (value == null) return null;
    final decoded = jsonDecode(value) as List<dynamic>;
    return decoded.cast<Map<String, dynamic>>();
  }

  static Future<void> writeList(
    String key,
    List<Map<String, dynamic>> value,
  ) async {
    final preferences = await SharedPreferences.getInstance();
    await preferences.setString(key, jsonEncode(value));
  }

  static String householdKey(String section, String householdName) {
    final normalized = householdName.trim().toLowerCase();
    return 'household.$normalized.$section';
  }
}
