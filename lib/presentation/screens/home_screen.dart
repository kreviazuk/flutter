import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'dart:convert';
import 'dart:async';
import '../theme/app_colors.dart';
import '../../core/services/auth_service.dart';
import '../../data/models/user.dart';
import '../../l10n/app_localizations.dart';
import 'countdown_screen.dart';
import 'auth_screen.dart';
import 'profile_screen.dart';
import 'settings_screen.dart';
// import 'flutter_learning_screen.dart'; // 已注释

/// 🏠 主页面 - 带用户认证功能
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Position? _currentPosition;
  bool _isGettingLocation = false;
  String _locationStatus = '';
  Timer? _locationRetryTimer;

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
    await _checkAuthStatus();
    // 启动时开始获取位置
    _startGettingLocation();
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

  Future<void> _startGettingLocation() async {
    final l10n = AppLocalizations.of(context)!;

    setState(() {
      _isGettingLocation = true;
      _locationStatus = l10n.gettingLocation;
    });

    try {
      // 检查GPS服务
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        setState(() {
          _locationStatus = l10n.gpsNotEnabled;
          _isGettingLocation = false;
        });
        return;
      }

      // 检查位置权限
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          setState(() {
            _locationStatus = l10n.locationFailed;
            _isGettingLocation = false;
          });
          // 用户取消位置授权时，安排重试获取位置
          _scheduleLocationRetry();
          return;
        }
      }

      if (permission == LocationPermission.deniedForever) {
        setState(() {
          _locationStatus = l10n.locationFailed;
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
        // 定位成功不展示文案
        _locationStatus = '';
      });
      // 成功后取消可能存在的重试定时器
      _locationRetryTimer?.cancel();
    } catch (e) {
      setState(() {
        _locationStatus = l10n.locationFailed;
        _isGettingLocation = false;
      });
    }
  }

  void _scheduleLocationRetry() {
    _locationRetryTimer?.cancel();
    _locationRetryTimer = Timer(const Duration(seconds: 10), () {
      if (mounted) {
        _startGettingLocation();
      }
    });
  }

  /// 显示登录页面
  Future<void> _showAuthScreen() async {
    final result = await Navigator.of(context).push<User>(
      MaterialPageRoute(
        builder: (context) => const AuthScreen(),
      ),
    );

    if (result != null) {
      final l10n = AppLocalizations.of(context)!;
      // 登录成功，更新用户状态
      setState(() {
        _isLoggedIn = true;
        _currentUser = result;
      });

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.welcomeBack(result.username)),
          backgroundColor: AppColors.success,
        ),
      );
    }
  }

  /// 显示用户菜单
  void _showUserMenu() {
    final l10n = AppLocalizations.of(context)!;

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // 用户信息
            ListTile(
              leading: _buildUserAvatar(_currentUser!, 40),
              title: Text(_currentUser?.username ?? l10n.welcome),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(_currentUser?.email ?? ''),
                  if (_currentUser?.bio != null && _currentUser!.bio!.isNotEmpty)
                    Text(
                      _currentUser!.bio!,
                      style: TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: 12,
                        fontStyle: FontStyle.italic,
                      ),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                ],
              ),
            ),
            const Divider(),
            // 编辑个人资料
            ListTile(
              leading: const Icon(Icons.edit, color: AppColors.info),
              title: Text(l10n.editProfile),
              onTap: () async {
                Navigator.of(context).pop();
                final result = await Navigator.of(context).push<User>(
                  MaterialPageRoute(
                    builder: (context) => ProfileScreen(user: _currentUser!),
                  ),
                );

                if (result != null) {
                  // 更新用户信息
                  setState(() {
                    _currentUser = result;
                  });

                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(l10n.profileUpdated),
                      backgroundColor: AppColors.success,
                    ),
                  );
                }
              },
            ),
            // 设置
            ListTile(
              leading: const Icon(Icons.settings, color: AppColors.textSecondary),
              title: Text(l10n.settingsTitle),
              onTap: () {
                Navigator.of(context).pop();
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (context) => const SettingsScreen(),
                  ),
                );
              },
            ),
            // 退出登录
            ListTile(
              leading: const Icon(Icons.logout, color: AppColors.error),
              title: Text(l10n.logout),
              onTap: () async {
                Navigator.of(context).pop();
                await AuthService.logout();
                setState(() {
                  _isLoggedIn = false;
                  _currentUser = null;
                });
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text(l10n.loggedOut),
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
    final l10n = AppLocalizations.of(context)!;

    // 检查登录状态
    if (!_isLoggedIn) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(l10n.pleaseLoginFirst),
          backgroundColor: AppColors.warning,
        ),
      );
      await _showAuthScreen();
      return;
    }

    // 直接开始跑步，权限检查会在需要时进行
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
    final l10n = AppLocalizations.of(context)!;

    if (_isCheckingAuth) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const CircularProgressIndicator(
                color: AppColors.primary,
              ),
              const SizedBox(height: 16),
              Text(
                l10n.initializingApp,
                style: const TextStyle(
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
        title: Text(l10n.appTitle),
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
                child: _buildUserAvatar(_currentUser!, 36),
              ),
            )
          else
            TextButton.icon(
              onPressed: _showAuthScreen,
              icon: const Icon(Icons.login, color: Colors.white),
              label: Text(l10n.login, style: const TextStyle(color: Colors.white)),
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
                        l10n.welcomeBack(_currentUser!.username),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 16,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 位置状态显示
              if (_locationStatus.isNotEmpty) ...[
                Container(
                  margin: const EdgeInsets.only(bottom: 30),
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
                          color: Colors.white,
                          size: 16,
                        ),
                      const SizedBox(width: 8),
                      Text(
                        _locationStatus,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 14,
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              // 开始跑步按钮
              Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withOpacity(0.3),
                      blurRadius: 20,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Material(
                  color: Colors.white,
                  shape: const CircleBorder(),
                  child: InkWell(
                    onTap: _startRunning,
                    borderRadius: BorderRadius.circular(100),
                    child: Container(
                      width: 200,
                      height: 200,
                      decoration: const BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            AppColors.secondary,
                            AppColors.primary,
                          ],
                        ),
                      ),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(
                            Icons.directions_run,
                            size: 60,
                            color: Colors.white,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            l10n.startRunning,
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // 🎓 Flutter学习页面跳转按钮 - 已注释
              // const SizedBox(height: 40), // 与上方主按钮的间距
              // Container(
              //   margin: const EdgeInsets.symmetric(horizontal: 40), // 左右边距
              //   child: ElevatedButton.icon(
              //     // 🔗 点击事件：导航到Flutter学习页面
              //     onPressed: () {
              //       Navigator.of(context).push(
              //         MaterialPageRoute(
              //           builder: (context) => const FlutterLearning(),
              //         ),
              //       );
              //     },
              //     // 📱 按钮图标：代码符号
              //     icon: const Icon(Icons.code, color: AppColors.primary),
              //     // 🏷️ 按钮文字
              //     label: const Text(
              //       'Flutter 学习页面',
              //       style: TextStyle(
              //         color: AppColors.primary, // 主题色文字
              //         fontSize: 16, // 字体大小
              //         fontWeight: FontWeight.w600, // 字体粗细
              //       ),
              //     ),
              //     // 🎨 按钮样式配置
              //     style: ElevatedButton.styleFrom(
              //       backgroundColor: Colors.white, // 白色背景
              //       foregroundColor: AppColors.primary, // 主题色前景
              //       padding: const EdgeInsets.symmetric(
              //           // 内边距
              //           horizontal: 24,
              //           vertical: 12),
              //       shape: RoundedRectangleBorder(
              //         // 圆角矩形
              //         borderRadius: BorderRadius.circular(30),
              //       ),
              //       elevation: 5, // 阴影高度
              //     ),
              //   ),
              // ),
            ],
          ),
        ),
      ),
    );
  }

  /// 构建用户头像
  Widget _buildUserAvatar(User user, double size) {
    if (user.avatar != null && user.avatar!.isNotEmpty) {
      try {
        final avatarBytes = base64Decode(user.avatar!);
        return Container(
          width: size,
          height: size,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            image: DecorationImage(
              image: MemoryImage(avatarBytes),
              fit: BoxFit.cover,
            ),
          ),
        );
      } catch (e) {
        print('头像解析失败: $e');
      }
    }

    // 默认头像
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        color: AppColors.secondary,
        border: Border.all(color: Colors.white, width: 2),
      ),
      child: Icon(
        Icons.person,
        color: Colors.white,
        size: size * 0.6,
      ),
    );
  }

  @override
  void dispose() {
    _locationRetryTimer?.cancel();
    super.dispose();
  }
}
