import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';

class AuthService {
  // 根据平台自动选择baseURL
  static String get baseUrl {
    return 'http://localhost:3001/api/auth';
  }

  // 全局请求状态保护
  static bool _isLoginInProgress = false;
  static bool _isRegisterInProgress = false;

  // 创建配置了代理的HTTP客户端（仅在调试模式下）
  static http.Client _createHttpClient() {
    // 只有在调试模式下才配置代理
    if (kDebugMode && !kIsWeb) {
      // 获取宿主机的真实IP地址，而不是使用 10.0.2.2
      // 您需要将此IP替换为您电脑的实际局域网IP地址
      const proxyHost = '192.168.8.119'; // 您电脑的实际IP
      const proxyPort = 9090; // Proxyman默认端口

      print('🔧 配置代理: $proxyHost:$proxyPort');

      // 设置全局代理
      HttpOverrides.global = _ProxyHttpOverride(proxyHost, proxyPort);
    }
    return http.Client();
  }

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // 注册
  static Future<Map<String, dynamic>> register({
    required String email,
    required String password,
    String? username,
  }) async {
    final client = _createHttpClient();

    try {
      final requestBody = {
        'email': email,
        'password': password,
        if (username != null) 'username': username,
      };

      print('--- 注册请求 ---');
      print('URL: $baseUrl/register');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        Uri.parse('$baseUrl/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- 注册响应 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        return {
          'success': true,
          'message': data['message'],
          'user': data['data']['user'],
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '注册失败',
        };
      }
    } catch (e) {
      print('--- 注册异常 ---');
      print(e.toString());
      return {
        'success': false,
        'message': '网络错误，请检查连接: ${e.toString()}',
      };
    } finally {
      client.close();
    }
  }

  // 登录
  static Future<Map<String, dynamic>> login({
    required String email,
    required String password,
  }) async {
    final requestId = DateTime.now().millisecondsSinceEpoch;
    print('=== 登录请求开始 [ID: $requestId] ===');
    print('当前登录状态: _isLoginInProgress = $_isLoginInProgress');

    // 全局防重复提交保护
    if (_isLoginInProgress) {
      print('❌ 拒绝重复登录请求 [ID: $requestId]');
      return {
        'success': false,
        'message': '登录请求正在处理中，请稍候...',
      };
    }

    _isLoginInProgress = true;
    print('✅ 设置登录状态为进行中 [ID: $requestId]');

    final client = _createHttpClient();

    try {
      final requestBody = {
        'email': email,
        'password': password,
      };

      print('--- 登录请求 [ID: $requestId] ---');
      print('URL: $baseUrl/login');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        Uri.parse('$baseUrl/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- 登录响应 [ID: $requestId] ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 保存token和用户信息
        await _saveAuthData(data['data']['token'], data['data']['user']);

        print('✅ 登录成功 [ID: $requestId]');
        return {
          'success': true,
          'message': data['message'],
          'token': data['data']['token'],
          'user': User.fromJson(data['data']['user']),
        };
      } else {
        print('❌ 登录失败 [ID: $requestId]');
        return {
          'success': false,
          'message': data['message'] ?? '登录失败',
        };
      }
    } catch (e) {
      print('--- 登录异常 [ID: $requestId] ---');
      print(e.toString());
      return {
        'success': false,
        'message': '网络错误，请检查连接: ${e.toString()}',
      };
    } finally {
      _isLoginInProgress = false;
      print('🔄 重置登录状态 [ID: $requestId]');
      client.close();
    }
  }

  // 验证邮箱
  static Future<Map<String, dynamic>> verifyEmail(String token) async {
    final client = _createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/verify-email'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'token': token,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    } finally {
      client.close();
    }
  }

  // 重新发送验证邮件
  static Future<Map<String, dynamic>> resendVerification(String email) async {
    final client = _createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('$baseUrl/resend-verification'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode({
          'email': email,
        }),
      );

      final data = jsonDecode(response.body);

      return {
        'success': response.statusCode == 200,
        'message': data['message'],
      };
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    } finally {
      client.close();
    }
  }

  // 获取当前用户信息
  static Future<Map<String, dynamic>> getCurrentUser() async {
    final client = _createHttpClient();

    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': '未登录',
        };
      }

      final response = await client.get(
        Uri.parse('$baseUrl/me'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        return {
          'success': true,
          'user': User.fromJson(data['data']['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '获取用户信息失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    } finally {
      client.close();
    }
  }

  // 更新用户资料
  static Future<Map<String, dynamic>> updateProfile({
    String? username,
    String? avatar,
  }) async {
    final client = _createHttpClient();

    try {
      final token = await getToken();
      if (token == null) {
        return {
          'success': false,
          'message': '未登录',
        };
      }

      final body = <String, dynamic>{};
      if (username != null) body['username'] = username;
      if (avatar != null) body['avatar'] = avatar;

      final response = await client.put(
        Uri.parse('$baseUrl/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 200) {
        // 更新本地存储的用户信息
        await _saveUserData(data['data']['user']);

        return {
          'success': true,
          'message': data['message'],
          'user': User.fromJson(data['data']['user']),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '更新失败',
        };
      }
    } catch (e) {
      return {
        'success': false,
        'message': '网络错误: $e',
      };
    } finally {
      client.close();
    }
  }

  // 退出登录
  static Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(tokenKey);
    await prefs.remove(userKey);
  }

  // 检查是否已登录
  static Future<bool> isLoggedIn() async {
    final token = await getToken();
    return token != null;
  }

  // 获取保存的token
  static Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(tokenKey);
  }

  // 获取保存的用户信息
  static Future<User?> getSavedUser() async {
    final prefs = await SharedPreferences.getInstance();
    final userJson = prefs.getString(userKey);
    if (userJson != null) {
      return User.fromJson(jsonDecode(userJson));
    }
    return null;
  }

  // 保存认证数据
  static Future<void> _saveAuthData(String token, Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(tokenKey, token);
    await prefs.setString(userKey, jsonEncode(userData));
  }

  // 保存用户数据
  static Future<void> _saveUserData(Map<String, dynamic> userData) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(userKey, jsonEncode(userData));
  }
}

// 代理配置类（仅在调试模式下使用）
class _ProxyHttpOverride extends HttpOverrides {
  final String proxyHost;
  final int proxyPort;

  _ProxyHttpOverride(this.proxyHost, this.proxyPort);

  @override
  HttpClient createHttpClient(SecurityContext? context) {
    return super.createHttpClient(context)
      ..findProxy = (uri) {
        return "PROXY $proxyHost:$proxyPort;";
      }
      ..badCertificateCallback = (X509Certificate cert, String host, int port) => true;
  }
}
