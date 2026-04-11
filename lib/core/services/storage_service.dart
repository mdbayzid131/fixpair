import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class StorageService extends GetxService {
  //===========================> Get Data <========================
  static Future<String> getString(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getString(key) ?? "";
  }

  static Future<bool?> getBool(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getBool(key);
  }

  static Future<int> getInt(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getInt(key) ?? -1;
  }

  static Future<double?> getDouble(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.getDouble(key);
  }

  //=============================> Save Data <========================
  static Future<bool> setString(String key, String value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setString(key, value);
  }

  static Future<bool> setBool(String key, bool value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setBool(key, value);
  }

  static Future<bool> setInt(String key, int value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setInt(key, value);
  }

  static Future<bool> setDouble(String key, double value) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.setDouble(key, value);
  }

  //===============================> Remove Value <==================================
  static Future<bool> remove(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.remove(key);
  }

  //==============================> Clear All <============================
  static Future<bool> clearAll() async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.clear();
  }

  //==============================> Check Key Exists <============================
  static Future<bool> containsKey(String key) async {
    final preferences = await SharedPreferences.getInstance();
    return preferences.containsKey(key);
  }
}


