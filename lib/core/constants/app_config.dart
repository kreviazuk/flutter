import 'package:flutter/foundation.dart';

/// 应用配置类，管理不同环境的配置
/// 类似于 Vite 项目中的 .env 配置管理
class AppConfig {
  // 私有构造函数，防止实例化
  AppConfig._();

  /// 从环境变量获取当前环境，默认为开发环境
  static const String _environment = String.fromEnvironment('ENV', defaultValue: 'development');

  /// 开发环境配置 - 使用线上服务器
  static const String _devApiUrl = 'https://proxy.lawrencezhouda.xyz:8443/api/auth';
  static const String _devApiUrlAndroid = 'https://proxy.lawrencezhouda.xyz:8443/api/auth';

  /// 生产环境配置 - VPS 服务器地址 (HTTPS)
  static const String _prodApiUrl = 'https://proxy.lawrencezhouda.xyz:8443/api/auth';

  /// 测试环境配置 - VPS 服务器地址 (HTTPS)
  static const String _testApiUrl = 'https://proxy.lawrencezhouda.xyz:8443/api/auth';

  /// 代理配置
  static const String _proxyHost = '192.168.8.119';
  static const int _proxyPort = 9090;

  /// 获取当前环境的API基础URL
  static String get apiBaseUrl {
    // 支持环境变量覆盖
    const envApiUrl = String.fromEnvironment('API_BASE_URL');
    if (envApiUrl.isNotEmpty) {
      return envApiUrl;
    }

    // 根据环境和平台自动选择
    switch (_environment) {
      case 'production':
      case 'prod':
        return _prodApiUrl;
      case 'test':
      case 'testing':
        return _testApiUrl;
      case 'development':
      case 'dev':
      default:
        if (kIsWeb) {
          return _devApiUrl; // Web端使用线上服务器
        } else {
          return _devApiUrlAndroid; // Android/iOS端使用线上服务器
        }
    }
  }

  /// 获取代理主机地址
  static String get proxyHost {
    const envProxyHost = String.fromEnvironment('PROXY_HOST');
    return envProxyHost.isNotEmpty ? envProxyHost : _proxyHost;
  }

  /// 获取代理端口
  static int get proxyPort {
    const envProxyPort = int.fromEnvironment('PROXY_PORT', defaultValue: _proxyPort);
    return envProxyPort;
  }

  /// 是否启用代理（仅在调试模式下启用）
  static bool get isProxyEnabled {
    const forceProxy = bool.fromEnvironment('FORCE_PROXY', defaultValue: false);
    return forceProxy || (kDebugMode && !kIsWeb);
  }

  /// 当前环境名称
  static String get environmentName => _environment;

  /// 是否为开发环境
  static bool get isDevelopment => _environment == 'development' || _environment == 'dev';

  /// 是否为生产环境
  static bool get isProduction => _environment == 'production' || _environment == 'prod';

  /// 是否为测试环境
  static bool get isTest => _environment == 'test' || _environment == 'testing';

  /// 打印当前配置信息
  static void printConfig() {
    // 总是打印基本信息，即使在生产环境
    print('🔧 ==================== App Config ====================');
    print('Environment: $environmentName');
    print('API Base URL: $apiBaseUrl');
    print('Platform: ${kIsWeb ? 'Web' : 'Mobile'}');
    print('Debug Mode: $kDebugMode');
    print(
        '🌍 Using ${isProduction ? 'PRODUCTION' : isDevelopment ? 'DEVELOPMENT' : 'TEST'} Environment');
    print('=====================================================');

    // 详细信息仅在调试模式下显示
    if (kDebugMode) {
      print('Proxy Enabled: $isProxyEnabled');
      if (isProxyEnabled) {
        print('Proxy: $proxyHost:$proxyPort');
      }
      print('🚂 Railway API: ${apiBaseUrl.contains('railway') ? 'YES' : 'NO'}');
    }
  }

  /// 获取所有配置的Map，用于调试
  static Map<String, dynamic> toMap() {
    return {
      'environment': environmentName,
      'apiBaseUrl': apiBaseUrl,
      'proxyHost': proxyHost,
      'proxyPort': proxyPort,
      'isProxyEnabled': isProxyEnabled,
      'platform': kIsWeb ? 'web' : 'mobile',
      'debugMode': kDebugMode,
      'isDevelopment': isDevelopment,
      'isProduction': isProduction,
      'isTest': isTest,
      'usingRailwayAPI': apiBaseUrl.contains('railway'),
    };
  }
}
