import 'package:shared_preferences/shared_preferences.dart';

class StorageUtils {
  static SharedPreferences? _prefs;

  // 初始化
  static Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
  }

  // 保存字符串
  static Future<bool> setString(String key, String value) async {
    return await _prefs?.setString(key, value) ?? false;
  }

  // 获取字符串
  static String? getString(String key, {String? defaultValue}) {
    return _prefs?.getString(key) ?? defaultValue;
  }

  // 保存整数
  static Future<bool> setInt(String key, int value) async {
    return await _prefs?.setInt(key, value) ?? false;
  }

  // 获取整数
  static int? getInt(String key, {int? defaultValue}) {
    return _prefs?.getInt(key) ?? defaultValue;
  }

  // 保存布尔值
  static Future<bool> setBool(String key, bool value) async {
    return await _prefs?.setBool(key, value) ?? false;
  }

  // 获取布尔值
  static bool? getBool(String key, {bool? defaultValue}) {
    return _prefs?.getBool(key) ?? defaultValue;
  }

  // 保存双精度浮点数
  static Future<bool> setDouble(String key, double value) async {
    return await _prefs?.setDouble(key, value) ?? false;
  }

  // 获取双精度浮点数
  static double? getDouble(String key, {double? defaultValue}) {
    return _prefs?.getDouble(key) ?? defaultValue;
  }

  // 保存字符串列表
  static Future<bool> setStringList(String key, List<String> value) async {
    return await _prefs?.setStringList(key, value) ?? false;
  }

  // 获取字符串列表
  static List<String>? getStringList(String key) {
    return _prefs?.getStringList(key);
  }

  // 删除指定键的数据
  static Future<bool> remove(String key) async {
    return await _prefs?.remove(key) ?? false;
  }

  // 清空所有数据
  static Future<bool> clear() async {
    return await _prefs?.clear() ?? false;
  }

  // 检查是否包含指定键
  static bool containsKey(String key) {
    return _prefs?.containsKey(key) ?? false;
  }

  // 获取所有键
  static Set<String>? getKeys() {
    return _prefs?.getKeys();
  }
} 