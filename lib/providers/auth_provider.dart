import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// 认证状态管理
class AuthProvider with ChangeNotifier {
  bool _isLoggedIn = false;
  String? _userId;
  String? _token;
  bool _isLoading = false;
  String? _errorMessage;

  // Getters
  bool get isLoggedIn => _isLoggedIn;
  String? get userId => _userId;
  String? get token => _token;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  /// 初始化认证状态
  Future<void> initialize() async {
    try {
      _isLoading = true;
      notifyListeners();

      final prefs = await SharedPreferences.getInstance();
      _isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
      _userId = prefs.getString('userId');
      _token = prefs.getString('token');
    } catch (e) {
      _errorMessage = '初始化失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 发送验证码
  /// [phoneNumber] 手机号码
  Future<bool> sendVerificationCode(String phoneNumber) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 模拟API调用
      await Future.delayed(const Duration(seconds: 1));
      
      // TODO: 这里应该调用真实的API
      // 临时返回成功，用于测试
      return true;

    } catch (e) {
      _errorMessage = '发送验证码失败: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登录
  /// [phoneNumber] 手机号码
  /// [verificationCode] 验证码
  Future<bool> login(String phoneNumber, String verificationCode) async {
    try {
      _isLoading = true;
      _errorMessage = null;
      notifyListeners();

      // 模拟API调用
      await Future.delayed(const Duration(seconds: 2));
      
      // TODO: 这里应该调用真实的API
      // 临时模拟登录成功
      if (verificationCode == '1234') {
        _isLoggedIn = true;
        _userId = phoneNumber;
        _token = 'mock_token_${DateTime.now().millisecondsSinceEpoch}';

        // 保存到本地存储
        final prefs = await SharedPreferences.getInstance();
        await prefs.setBool('isLoggedIn', true);
        await prefs.setString('userId', _userId!);
        await prefs.setString('token', _token!);

        return true;
      } else {
        _errorMessage = '验证码错误，请重试';
        return false;
      }

    } catch (e) {
      _errorMessage = '登录失败: $e';
      return false;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 登出
  Future<void> logout() async {
    try {
      _isLoading = true;
      notifyListeners();

      // 清除本地存储
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('isLoggedIn');
      await prefs.remove('userId');
      await prefs.remove('token');

      // 重置状态
      _isLoggedIn = false;
      _userId = null;
      _token = null;
      _errorMessage = null;

    } catch (e) {
      _errorMessage = '登出失败: $e';
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  /// 静态方法：检查是否登录
  static Future<bool> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool('isLoggedIn') ?? false;
  }

  /// 静态方法：获取当前用户ID
  static Future<String?> getCurrentUserId() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('userId');
  }

  /// 静态方法：获取当前Token
  static Future<String?> getCurrentToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }
} 