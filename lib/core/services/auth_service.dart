import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../data/models/user.dart';
import '../constants/app_config.dart';

/// 认证服务
class AuthService {
  // 全局请求状态保护
  static bool _isLoginInProgress = false;
  static bool _isRegisterInProgress = false;

  // 创建配置了代理的HTTP客户端（仅在调试模式下）
  static http.Client _createHttpClient() {
    // 只有在调试模式下才配置代理
    if (AppConfig.isProxyEnabled) {
      print('🔧 配置代理: ${AppConfig.proxyHost}:${AppConfig.proxyPort}');

      // 设置全局代理
      HttpOverrides.global = _ProxyHttpOverride(AppConfig.proxyHost, AppConfig.proxyPort);
    }
    return http.Client();
  }

  static const String tokenKey = 'auth_token';
  static const String userKey = 'user_data';

  // 发送注册验证码
  static Future<Map<String, dynamic>> sendVerificationCode(String email) async {
    final client = _createHttpClient();

    try {
      final response = await client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/send-verification-code'),
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
        'testCode': data['testCode'], // 测试环境的验证码
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

  // 注册（需要验证码）
  static Future<Map<String, dynamic>> register({
    required String email,
    required String code,
    required String password,
    String? username,
  }) async {
    final client = _createHttpClient();

    try {
      final requestBody = {
        'email': email,
        'code': code,
        'password': password,
        if (username != null && username.isNotEmpty) 'username': username,
      };

      final response = await client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/register'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      final data = jsonDecode(response.body);

      if (response.statusCode == 201) {
        // 注册成功，保存token和用户信息
        final token = data['data']['token'];
        final userData = data['data']['user'];

        await _saveAuthData(token, userData);

        return {
          'success': true,
          'message': data['message'],
          'token': token,
          'user': User.fromJson(userData),
        };
      } else {
        return {
          'success': false,
          'message': data['message'] ?? '注册失败',
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
      print('URL: ${AppConfig.apiBaseUrl}/login');
      print('Body: ${jsonEncode(requestBody)}');

      final response = await client.post(
        Uri.parse('${AppConfig.apiBaseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
        },
        body: jsonEncode(requestBody),
      );

      print('--- 登录响应 [ID: $requestId] ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

      // 添加响应体检查
      if (response.body.isEmpty) {
        print('❌ 响应体为空 [ID: $requestId]');
        return {
          'success': false,
          'message': '服务器响应为空',
        };
      }

      Map<String, dynamic> data;
      try {
        data = jsonDecode(response.body);
        print('✅ JSON解析成功 [ID: $requestId]');
        print('解析后的数据: $data');
      } catch (e) {
        print('❌ JSON解析失败 [ID: $requestId]: $e');
        return {
          'success': false,
          'message': 'JSON解析失败: $e',
        };
      }

      if (response.statusCode == 200) {
        try {
          // 详细检查响应数据结构
          print('🔍 检查响应数据结构 [ID: $requestId]');

          if (data['data'] == null) {
            print('❌ data字段为null [ID: $requestId]');
            return {
              'success': false,
              'message': '响应数据格式错误：缺少data字段',
            };
          }

          final responseData = data['data'] as Map<String, dynamic>;
          print('✅ data字段存在: $responseData');

          if (responseData['token'] == null) {
            print('❌ token字段为null [ID: $requestId]');
            return {
              'success': false,
              'message': '响应数据格式错误：缺少token字段',
            };
          }

          if (responseData['user'] == null) {
            print('❌ user字段为null [ID: $requestId]');
            return {
              'success': false,
              'message': '响应数据格式错误：缺少user字段',
            };
          }

          final token = responseData['token'] as String;
          final userData = responseData['user'] as Map<String, dynamic>;

          print('✅ Token: ${token.substring(0, 20)}...');
          print('✅ User Data: $userData');

          // 保存token和用户信息
          await _saveAuthData(token, userData);

          print('✅ 登录成功 [ID: $requestId]');
          return {
            'success': true,
            'message': data['message'] ?? '登录成功',
            'token': token,
            'user': User.fromJson(userData),
          };
        } catch (e, stackTrace) {
          print('❌ 登录成功数据处理失败 [ID: $requestId]');
          print('错误: $e');
          print('堆栈: $stackTrace');
          return {
            'success': false,
            'message': '数据处理失败: $e',
          };
        }
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
        Uri.parse('${AppConfig.apiBaseUrl}/verify-email'),
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
        Uri.parse('${AppConfig.apiBaseUrl}/resend-verification'),
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
        Uri.parse('${AppConfig.apiBaseUrl}/me'),
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
    String? bio,
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
      if (bio != null) body['bio'] = bio;

      print('--- 更新个人资料请求 ---');
      print('URL: ${AppConfig.apiBaseUrl}/profile');
      print('Body: ${jsonEncode(body)}');

      final response = await client.put(
        Uri.parse('${AppConfig.apiBaseUrl}/profile'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode(body),
      );

      print('--- 更新个人资料响应 ---');
      print('Status Code: ${response.statusCode}');
      print('Response Body: ${response.body}');

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
      print('--- 更新个人资料异常 ---');
      print(e.toString());
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
