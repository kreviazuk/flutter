import 'package:shared_preferences/shared_preferences.dart';

/// GPS设置服务
class GpsSettingsService {
  static const String _simulateGpsKey = 'simulate_gps';

  /// 获取是否启用GPS模拟
  static Future<bool> getSimulateGpsEnabled() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      return prefs.getBool(_simulateGpsKey) ?? false; // 默认不启用模拟
    } catch (e) {
      print('获取GPS模拟设置失败: $e');
      return false;
    }
  }

  /// 设置是否启用GPS模拟
  static Future<void> setSimulateGpsEnabled(bool enabled) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool(_simulateGpsKey, enabled);
    } catch (e) {
      print('保存GPS模拟设置失败: $e');
    }
  }
} 