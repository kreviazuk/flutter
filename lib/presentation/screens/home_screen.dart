import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import '../theme/app_colors.dart';
import '../widgets/permission_dialog.dart';
import '../../core/services/permission_service.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user.dart';
import 'countdown_screen.dart';
import 'auth_screen.dart';

/// 🏠 主页面 - 带用户认证功能
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _hasPermissions = false;
  bool _isCheckingPermissions = true;
  Position? _currentPosition;
  bool _isGettingLocation = false;
  String _locationStatus = '';

  // 用户认证相关
  User? _currentUser;
  bool _isLoggedIn = false;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  /// 初始化应用
  Future<void> _initializeApp() async {
    // 并行检查认证状态和权限
    await Future.wait([
      _checkAuthStatus(),
      _checkPermissions(),
    ]);
  }

  /// 检查用户认证状态
  Future<void> _checkAuthStatus() async {
    setState(() {
      _isCheckingAuth = true;
    });

    try {
      final isLoggedIn = await AuthService.isLoggedIn();
      if (isLoggedIn) {
        final savedUser = await AuthService.getSavedUser();
        setState(() {
          _isLoggedIn = true;
          _currentUser = savedUser;
        });
      } else {
        setState(() {
          _isLoggedIn = false;
          _currentUser = null;
        });
      }
    } catch (e) {
      print('检查认证状态失败: $e');
      setState(() {
        _isLoggedIn = false;
        _currentUser = null;
      });
    }

    setState(() {
      _isCheckingAuth = false;
    });
  }

  Future<void> _checkPermissions() async {
    final hasPermissions = await PermissionService.hasAllRequiredPermissions();
    setState(() {
      _hasPermissions = hasPermissions;
      _isCheckingPermissions = false;
    });

    // 如果权限已授权，立即开始获取位置
    if (hasPermissions) {
      _startGettingLocation();
    }
  }

  Future<void> _startGettingLocation() async {
    setState(() {
      _isGettingLocation = true;
      _locationStatus = '正在获取位置...';
    });

    try {
      // 检查GPS服务
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = 'GPS服务未开启';
          _isGettingLocation = false;
        });
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
        timeLimit: const Duration(seconds: 15),
      );

      setState(() {
        _currentPosition = position;
        _isGettingLocation = false;
        _locationStatus = '位置已就绪';
      });
    } catch (e) {
      setState(() {
        _locationStatus = '获取位置失败';
        _isGettingLocation = false;
      });
    }
  }

  Future<void> _showPermissionDialog() async {
    final result = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (context) => const PermissionDialog(),
    );

    if (result == true) {
      // 权限授权成功，重新检查权限状态
      await _checkPermissions();
    }
  }

  /// 显示登录页面
  Future<void> _showAuthScreen() async {
    final result = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );

    if (result != null) {
      // 登录成功，更新用户状态
      setState(() {
        _isLoggedIn = true;
        _currentUser = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('欢迎回来，${result.username}！'),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// 显示用户菜单
  void _showUserMenu() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户信息
            ListTile(
              leading: CircleAvatar(
                backgroundColor: AppColors.primary,
                child: Text(
                  _currentUser?.username?.substring(0, 1).toUpperCase() ?? 'U',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                ),
              ),
              title: Text(_currentUser?.username ?? '用户'),
              subtitle: Text(_currentUser?.email ?? ''),
            ),
            const Divider(),
            // 退出登录
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: const Text('退出登录'),
              onTap: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                setState(() {
                  _isLoggedIn = false;
                  _currentUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('已退出登录'),
                    backgroundColor: AppColors.info,
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _startRunning() async {
    // 检查登录状态
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('请先登录后再开始跑步'),
          backgroundColor: AppColors.warning,
        ),
      );
      await _showAuthScreen();
      return;
    }

    if (!_hasPermissions) {
      await _showPermissionDialog();
      return;
    }

    // 权限已授权，开始倒计时，并传递位置信息
    if (mounted) {
      Navigator.of(context).push(
        MaterialPageRoute(
          builder: (context) => CountdownScreen(
            currentPosition: _currentPosition, // 传递位置信息
          ),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isCheckingPermissions || _isCheckingAuth) {
      return const Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              CircularProgressIndicator(
                color: AppColors.primary,
              ),
              SizedBox(height: 16),
              Text(
                '正在初始化应用...',
                style: TextStyle(
                  fontSize: 16,
                  color: AppColors.textSecondary,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('🏃‍♂️ 跑步追踪器'),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        elevation: 0,
        actions: [
          // 用户头像或登录按钮
          if (_isLoggedIn && _currentUser != null)
            GestureDetector(
              onTap: _showUserMenu,
              child: Container(
                margin: const EdgeInsets.only(right: 16),
                child: CircleAvatar(
                  backgroundColor: Colors.white,
                  child: Text(
                    _currentUser!.username.substring(0, 1).toUpperCase(),
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            )
          else
            TextButton.icon(
              onPressed: _showAuthScreen,
              icon: const Icon(Icons.login, color: Colors.white),
              label: const Text('登录', style: TextStyle(color: Colors.white)),
            ),

          if (!_hasPermissions)
            IconButton(
              onPressed: _showPermissionDialog,
              icon: const Icon(
                Icons.security,
                color: AppColors.warning,
              ),
              tooltip: '权限设置',
            ),
        ],
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              AppColors.primary,
              AppColors.secondary,
            ],
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // 用户欢迎信息
              if (_isLoggedIn && _currentUser != null) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 20),
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(25),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.verified_user,
                        color: Colors.white,
                        size: 20,
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '欢迎，${_currentUser!.username}！',
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 主图标
              Container(
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: Icon(
                  _hasPermissions ? Icons.directions_run : Icons.security,
                  size: 120,
                  color: Colors.white,
                ),
              ),

              const SizedBox(height: 32),

              // 主标题
              Text(
                _getMainTitle(),
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 16),

              // 副标题
              Text(
                _getSubTitle(),
                style: const TextStyle(
                  fontSize: 16,
                  color: Colors.white70,
                ),
                textAlign: TextAlign.center,
              ),

              const SizedBox(height: 40),

              // 位置状态指示器
              if (_hasPermissions && _isLoggedIn) ...[
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (_isGettingLocation)
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      else
                        Icon(
                          _currentPosition != null ? Icons.location_on : Icons.location_off,
                          color: _currentPosition != null ? Colors.white : AppColors.warning,
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _locationStatus.isEmpty
                            ? (_currentPosition != null ? '位置已就绪' : '位置获取中...')
                            : _locationStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],

              // 主按钮
              ElevatedButton(
                onPressed: _startRunning,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: AppColors.primary,
                  padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  elevation: 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      _getButtonIcon(),
                      size: 24,
                    ),
                    const SizedBox(width: 12),
                    Text(
                      _getButtonText(),
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
              ),

              // 底部提示
              if (!_isLoggedIn) ...[
                const SizedBox(height: 24),
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 20),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: Colors.white.withOpacity(0.3)),
                  ),
                  child: Row(
                    children: [
                      const Icon(
                        Icons.info,
                        color: Colors.white70,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: const Text(
                          '请先登录账户，记录你的跑步数据',
                          style: TextStyle(
                            color: Colors.white70,
                            fontSize: 14,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  String _getMainTitle() {
    if (!_isLoggedIn) return '欢迎使用跑步追踪器！';
    if (!_hasPermissions) return '需要权限才能开始跑步';
    return '准备开始你的跑步之旅！';
  }

  String _getSubTitle() {
    if (!_isLoggedIn) return '登录账户，开始记录你的精彩跑步历程';
    if (!_hasPermissions) return '请授权位置权限以使用跑步功能';
    return '点击下方按钮开始你的健康运动';
  }

  IconData _getButtonIcon() {
    if (!_isLoggedIn) return Icons.login;
    if (!_hasPermissions) return Icons.security;
    return Icons.play_arrow;
  }

  String _getButtonText() {
    if (!_isLoggedIn) return '立即登录';
    if (!_hasPermissions) return '授权权限';
    return '开始跑步';
  }
}
