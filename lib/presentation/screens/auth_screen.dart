import 'package:flutter/material.dart';
import 'dart:async';
import '../theme/app_colors.dart';
import '../../core/services/auth_service.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  final PageController _pageController = PageController();
  bool _isLogin = true;
  bool _isLoading = false;
  bool _isSubmitting = false;

  // 注册步骤状态
  bool _isRegisterStep1 = true; // true: 输入邮箱，false: 输入验证码和密码
  Timer? _countdownTimer;
  int _countdown = 0;
  String? _pendingEmail;

  // 登录表单
  final _loginFormKey = GlobalKey<FormState>();
  final _loginEmailController = TextEditingController();
  final _loginPasswordController = TextEditingController();
  bool _rememberMe = true;

  // 注册表单 - 第一步
  final _registerStep1FormKey = GlobalKey<FormState>();
  final _registerEmailController = TextEditingController();

  // 注册表单 - 第二步
  final _registerStep2FormKey = GlobalKey<FormState>();
  final _verificationCodeController = TextEditingController();
  final _registerPasswordController = TextEditingController();
  final _registerUsernameController = TextEditingController();
  final _confirmPasswordController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSavedCredentials();
  }

  Future<void> _loadSavedCredentials() async {
    final remember = await AuthService.getRememberMe();
    final savedEmail = await AuthService.getSavedEmail();
    final savedPassword = await AuthService.getSavedPassword();
    if (!mounted) return;
    setState(() {
      _rememberMe = remember;
      if (remember) {
        if (savedEmail != null) _loginEmailController.text = savedEmail;
        if (savedPassword != null) _loginPasswordController.text = savedPassword;
      }
    });
  }

  @override
  void dispose() {
    _pageController.dispose();
    _countdownTimer?.cancel();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _registerEmailController.dispose();
    _verificationCodeController.dispose();
    _registerPasswordController.dispose();
    _registerUsernameController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  void _switchAuthMode() {
    setState(() {
      _isLogin = !_isLogin;
      // 重置注册步骤
      if (!_isLogin) {
        _isRegisterStep1 = true;
        _pendingEmail = null;
        _countdown = 0;
        _countdownTimer?.cancel();
      }
    });
    _pageController.animateToPage(
      _isLogin ? 0 : 1,
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
    );
  }

  void _startCountdown() {
    setState(() {
      _countdown = 60;
    });
    _countdownTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (_countdown > 0) {
          _countdown--;
        } else {
          timer.cancel();
        }
      });
    });
  }

  void _showMessage(String message, {bool isError = false}) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: isError ? AppColors.error : AppColors.success,
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _handleLogin() async {
    if (!_loginFormKey.currentState!.validate()) return;

    // 双重防重复提交保护
    if (_isLoading || _isSubmitting) return;

    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    try {
      final result = await AuthService.login(
        email: _loginEmailController.text.trim(),
        password: _loginPasswordController.text,
      );

      if (result['success']) {
        await AuthService.saveLoginCredentials(
          email: _loginEmailController.text.trim(),
          password: _loginPasswordController.text,
          rememberMe: _rememberMe,
        );
        _showMessage('登录成功！欢迎回来 🎉');
        if (mounted) {
          Navigator.of(context).pop(result['user']);
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitting = false;
        });
      }
    }
  }

  // 发送验证码（注册第一步）
  Future<void> _sendVerificationCode() async {
    if (!_registerStep1FormKey.currentState!.validate()) return;

    if (_isLoading || _isSubmitting) return;

    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    try {
      final result = await AuthService.sendVerificationCode(
        _registerEmailController.text.trim(),
      );

      if (result['success']) {
        setState(() {
          _pendingEmail = _registerEmailController.text.trim();
          _isRegisterStep1 = false;
        });
        _startCountdown();
        _showMessage(result['message']);

        // 如果是测试环境，显示验证码
        if (result['testCode'] != null) {
          _showMessage('测试验证码: ${result['testCode']}', isError: false);
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitting = false;
        });
      }
    }
  }

  // 完成注册（注册第二步）
  Future<void> _handleRegister() async {
    if (!_registerStep2FormKey.currentState!.validate()) return;

    if (_isLoading || _isSubmitting) return;

    setState(() {
      _isLoading = true;
      _isSubmitting = true;
    });

    try {
      final result = await AuthService.register(
        email: _pendingEmail!,
        code: _verificationCodeController.text.trim(),
        password: _registerPasswordController.text,
        username: _registerUsernameController.text.trim().isEmpty
            ? null
            : _registerUsernameController.text.trim(),
      );

      if (result['success']) {
        _showMessage(result['message']);
        if (mounted) {
          Navigator.of(context).pop(result['user']);
        }
      } else {
        _showMessage(result['message'], isError: true);
      }
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _isSubmitting = false;
        });
      }
    }
  }

  // 返回第一步
  void _backToStep1() {
    setState(() {
      _isRegisterStep1 = true;
      _pendingEmail = null;
      _countdown = 0;
      _countdownTimer?.cancel();
      _verificationCodeController.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      resizeToAvoidBottomInset: true, // 确保键盘弹出时调整布局
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: AppColors.textDark),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Column(
        children: [
          // 标题和切换器
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
            child: Column(
              children: [
                const Text(
                  '🏃‍♂️ 跑步追踪器',
                  style: TextStyle(
                    fontSize: 28,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                const Text(
                  '记录你的每一步精彩！',
                  style: TextStyle(
                    fontSize: 16,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 24),
                // 切换器
                Container(
                  decoration: BoxDecoration(
                    color: AppColors.cardBackground,
                    borderRadius: BorderRadius.circular(30),
                  ),
                  padding: const EdgeInsets.all(4),
                  child: Row(
                    children: [
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (!_isLogin) _switchAuthMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: _isLogin ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              '登录',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: _isLogin ? Colors.white : AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Expanded(
                        child: GestureDetector(
                          onTap: () {
                            if (_isLogin) _switchAuthMode();
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            decoration: BoxDecoration(
                              color: !_isLogin ? AppColors.primary : Colors.transparent,
                              borderRadius: BorderRadius.circular(25),
                            ),
                            child: Text(
                              '注册',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                color: !_isLogin ? Colors.white : AppColors.textMedium,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // 表单内容
          Expanded(
            child: PageView(
              controller: _pageController,
              onPageChanged: (index) {
                setState(() {
                  _isLogin = index == 0;
                });
              },
              children: [
                _buildLoginForm(),
                _buildRegisterForm(),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildLoginForm() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '欢迎回来',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '请输入您的登录信息',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 32),

            Form(
              key: _loginFormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 邮箱输入
                  TextFormField(
                    controller: _loginEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱地址',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱地址';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '请输入有效的邮箱地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),

                  // 密码输入
                  TextFormField(
                    controller: _loginPasswordController,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: '密码',
                      prefixIcon: Icon(Icons.lock_outline),
                      border: OutlineInputBorder(),
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入密码';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 登录按钮
                  ElevatedButton(
                    onPressed: _isLoading ? null : _handleLogin,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('登录中...'),
                            ],
                          )
                        : const Text(
                            '登录',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),

                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Checkbox(
                        value: _rememberMe,
                        onChanged: (val) {
                          if (val == null) return;
                          setState(() {
                            _rememberMe = val;
                          });
                        },
                      ),
                      const Text('记住我（保存账号与密码）'),
                    ],
                  ),
                ],
              ),
            ),

            // 底部安全间距
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterForm() {
    return _isRegisterStep1 ? _buildRegisterStep1() : _buildRegisterStep2();
  }

  Widget _buildRegisterStep1() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              '创建账户',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: AppColors.textDark,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              '首先验证您的邮箱地址',
              style: TextStyle(
                fontSize: 16,
                color: AppColors.textMedium,
              ),
            ),
            const SizedBox(height: 32),

            Form(
              key: _registerStep1FormKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // 邮箱输入
                  TextFormField(
                    controller: _registerEmailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: const InputDecoration(
                      labelText: '邮箱地址',
                      prefixIcon: Icon(Icons.email_outlined),
                      border: OutlineInputBorder(),
                      helperText: '我们将向此邮箱发送验证码',
                    ),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return '请输入邮箱地址';
                      }
                      if (!RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(value)) {
                        return '请输入有效的邮箱地址';
                      }
                      return null;
                    },
                  ),
                  const SizedBox(height: 32),

                  // 发送验证码按钮
                  ElevatedButton(
                    onPressed: _isLoading ? null : _sendVerificationCode,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8),
                      ),
                    ),
                    child: _isLoading
                        ? const Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                                ),
                              ),
                              SizedBox(width: 12),
                              Text('发送中...'),
                            ],
                          )
                        : const Text(
                            '发送验证码',
                            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                          ),
                  ),
                ],
              ),
            ),

            // 底部安全间距
            SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
          ],
        ),
      ),
    );
  }

  Widget _buildRegisterStep2() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: ConstrainedBox(
        constraints: BoxConstraints(
          minHeight: MediaQuery.of(context).size.height - 200,
        ),
        child: IntrinsicHeight(
          child: Form(
            key: _registerStep2FormKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // 返回按钮
                Row(
                  children: [
                    IconButton(
                      onPressed: _backToStep1,
                      icon: const Icon(Icons.arrow_back_ios, color: AppColors.primary),
                      padding: EdgeInsets.zero,
                    ),
                    const Text(
                      '返回',
                      style: TextStyle(
                        color: AppColors.primary,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 16),

                const Text(
                  '验证邮箱',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: AppColors.textDark,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  '验证码已发送到 ${_pendingEmail ?? ''}',
                  style: const TextStyle(
                    fontSize: 16,
                    color: AppColors.textMedium,
                  ),
                ),
                const SizedBox(height: 32),

                // 验证码输入
                TextFormField(
                  controller: _verificationCodeController,
                  keyboardType: TextInputType.number,
                  textAlign: TextAlign.center,
                  maxLength: 6,
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    letterSpacing: 8,
                  ),
                  decoration: const InputDecoration(
                    labelText: '验证码',
                    prefixIcon: Icon(Icons.verified_user_outlined),
                    border: OutlineInputBorder(),
                    helperText: '请输入6位数字验证码',
                    counterText: '',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入验证码';
                    }
                    if (value.length != 6) {
                      return '验证码必须是6位数字';
                    }
                    if (!RegExp(r'^\d{6}$').hasMatch(value)) {
                      return '验证码只能包含数字';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 重新发送验证码
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text('没有收到验证码？'),
                    TextButton(
                      onPressed: _countdown > 0 ? null : _sendVerificationCode,
                      child: Text(
                        _countdown > 0 ? '${_countdown}s后重新发送' : '重新发送',
                        style: TextStyle(
                          color: _countdown > 0 ? AppColors.textMedium : AppColors.primary,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),

                // 用户名输入（可选）
                TextFormField(
                  controller: _registerUsernameController,
                  decoration: const InputDecoration(
                    labelText: '用户名（可选）',
                    prefixIcon: Icon(Icons.person_outline),
                    border: OutlineInputBorder(),
                    helperText: '留空将使用邮箱前缀作为用户名',
                  ),
                  validator: (value) {
                    if (value != null && value.isNotEmpty && value.length < 2) {
                      return '用户名至少需要2个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 密码输入
                TextFormField(
                  controller: _registerPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '密码',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                    helperText: '至少6个字符',
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请输入密码';
                    }
                    if (value.length < 6) {
                      return '密码至少需要6个字符';
                    }
                    return null;
                  },
                ),
                const SizedBox(height: 16),

                // 确认密码
                TextFormField(
                  controller: _confirmPasswordController,
                  obscureText: true,
                  decoration: const InputDecoration(
                    labelText: '确认密码',
                    prefixIcon: Icon(Icons.lock_outline),
                    border: OutlineInputBorder(),
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return '请确认密码';
                    }
                    if (value != _registerPasswordController.text) {
                      return '两次输入的密码不一致';
                    }
                    return null;
                  },
                ),

                // 动态间距，确保按钮在底部
                const Spacer(),
                const SizedBox(height: 32),

                // 完成注册按钮
                ElevatedButton(
                  onPressed: _isLoading ? null : _handleRegister,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(8),
                    ),
                  ),
                  child: _isLoading
                      ? const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            SizedBox(
                              width: 20,
                              height: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            ),
                            SizedBox(width: 12),
                            Text('注册中...'),
                          ],
                        )
                      : const Text(
                          '完成注册',
                          style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600),
                        ),
                ),

                // 底部安全间距
                SizedBox(height: MediaQuery.of(context).viewInsets.bottom + 24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
