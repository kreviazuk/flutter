import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import '../providers/auth_provider.dart';

/// 登录页面
/// StatefulWidget：有状态的Widget，可以在运行时改变UI
/// 比如按钮文字变化、输入框内容变化等
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

/// 登录页面的状态类
/// 这里管理页面的所有动态数据和用户交互
class _LoginScreenState extends State<LoginScreen> {
  // ========== 📋 表单控制器和焦点节点 ==========

  /// 表单的全局键，用于验证整个表单的输入是否正确
  final _formKey = GlobalKey<FormState>();

  /// 手机号输入框的控制器，用于获取和设置输入框的文本内容
  final _phoneController = TextEditingController();

  /// 验证码输入框的控制器
  final _codeController = TextEditingController();

  /// 手机号输入框的焦点节点，控制输入框是否获得焦点（光标是否在这里）
  final _phoneFocusNode = FocusNode();

  /// 验证码输入框的焦点节点
  final _codeFocusNode = FocusNode();

  // ========== 🕐 倒计时相关状态 ==========

  /// 是否已发送验证码，用于控制发送按钮的状态
  bool _isCodeSent = false;

  /// 倒计时秒数，用于防止频繁发送验证码
  int _countdown = 0;

  /// 计时器对象，用于实现倒计时功能
  Timer? _timer;

  // ========== 🧹 资源清理 ==========

  /// dispose方法：页面销毁时调用，用于释放资源，防止内存泄漏
  @override
  void dispose() {
    // 释放文本控制器占用的内存
    _phoneController.dispose();
    _codeController.dispose();

    // 释放焦点节点占用的内存
    _phoneFocusNode.dispose();
    _codeFocusNode.dispose();

    // 取消计时器，防止页面销毁后还在运行
    _timer?.cancel();

    // 调用父类的dispose方法
    super.dispose();
  }

  // ========== ⏰ 倒计时功能 ==========

  /// 开始60秒倒计时，防止用户频繁点击发送验证码
  void _startCountdown() {
    // setState：通知Flutter重新绘制UI
    setState(() {
      _countdown = 60; // 设置倒计时为60秒
      _isCodeSent = true; // 标记验证码已发送
    });

    // 创建一个每秒执行一次的计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_countdown <= 1) {
        // 倒计时结束，取消计时器
        timer.cancel();
        setState(() {
          _countdown = 0;
          _isCodeSent = false; // 重置状态，允许再次发送
        });
      } else {
        // 倒计时减1
        setState(() {
          _countdown--;
        });
      }
    });
  }

  // ========== 📱 发送验证码功能 ==========

  /// 发送验证码的异步方法
  Future<void> _sendVerificationCode() async {
    // 验证表单输入是否正确
    if (!_formKey.currentState!.validate()) return;

    // 获取认证提供者（AuthProvider），用于处理登录逻辑
    // listen: false 表示这里不监听状态变化
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 调用发送验证码方法，传入手机号（去掉前后空格）
    final success = await authProvider.sendVerificationCode(_phoneController.text.trim());

    if (success) {
      // 发送成功，开始倒计时
      _startCountdown();

      // mounted 检查：确保页面还在屏幕上，防止页面已销毁但代码还在执行
      if (mounted) {
        // 显示成功消息
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('验证码已发送，请注意查收'),
            backgroundColor: Colors.green,
          ),
        );
        // 将焦点移动到验证码输入框，方便用户直接输入
        _codeFocusNode.requestFocus();
      }
    } else {
      // 发送失败，显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '发送验证码失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========== 🔐 登录功能 ==========

  /// 用户登录的异步方法
  Future<void> _login() async {
    // 先验证表单输入
    if (!_formKey.currentState!.validate()) return;

    // 获取认证提供者
    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    // 调用登录方法，传入手机号和验证码
    final success = await authProvider.login(
      _phoneController.text.trim(),
      _codeController.text.trim(),
    );

    if (success) {
      // 登录成功
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('登录成功'),
            backgroundColor: Colors.green,
          ),
        );
        // 跳转到主页，并替换当前页面（用户不能返回到登录页）
        Navigator.of(context).pushReplacementNamed('/home');
      }
    } else {
      // 登录失败，显示错误消息
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(authProvider.errorMessage ?? '登录失败'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  // ========== 🎨 UI构建方法 ==========

  /// build方法：构建页面UI的核心方法
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Scaffold：提供页面基础结构的Widget
      body: Container(
        // Container：可以设置背景、边距等属性的容器Widget
        child: SafeArea(
          // SafeArea：确保内容不被状态栏等系统UI遮挡
          child: Consumer<AuthProvider>(
            // Consumer：监听AuthProvider状态变化
            builder: (context, authProvider, child) {
              return SingleChildScrollView(
                // SingleChildScrollView：让页面可以滚动
                padding: const EdgeInsets.all(24.0), // 设置内边距
                child: Form(
                  // Form：表单Widget，用于统一管理表单验证
                  key: _formKey, // 绑定表单键
                  child: Column(
                    // Column：垂直排列子Widget
                    mainAxisAlignment: MainAxisAlignment.center, // 子Widget在主轴（垂直）居中
                    children: [
                      const SizedBox(height: 80), // SizedBox：用于创建空白间距

                      // ========== 🏫 Logo区域 ==========
                      Container(
                        width: 120,
                        height: 120,
                        decoration: BoxDecoration(
                          // 装饰容器：设置背景色、圆角、阴影等
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(60), // 圆角半径，60让它变成圆形
                          boxShadow: [
                            // 阴影效果，让Logo看起来有立体感
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1), // 半透明黑色阴影
                              blurRadius: 20, // 模糊半径
                              offset: const Offset(0, 10), // 阴影偏移（x, y）
                            ),
                          ],
                        ),
                        child: const Icon(
                          // 图标Widget
                          Icons.school, // 学校图标
                          size: 60,
                          color: Color(0xFF2196F3), // 蓝色
                        ),
                      ),

                      const SizedBox(height: 32),

                      // ========== 📝 标题文字 ==========
                      const Text(
                        '🎯 托育机构管理系统 🏫',
                        style: TextStyle(
                          // 文字样式
                          fontSize: 28,
                          fontWeight: FontWeight.bold, // 粗体
                          color: Colors.white,
                        ),
                      ),

                      const SizedBox(height: 8),

                      const Text(
                        '🚀 请输入手机号码进行登录 📱',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white70, // 半透明白色
                        ),
                      ),

                      const SizedBox(height: 48),

                      // ========== 📋 登录表单区域 ==========
                      Container(
                        padding: const EdgeInsets.all(24), // 内边距
                        decoration: BoxDecoration(
                          color: Colors.white, // 白色背景
                          borderRadius: BorderRadius.circular(16), // 圆角
                          boxShadow: [
                            // 阴影让表单看起来浮在页面上
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 20,
                              offset: const Offset(0, 10),
                            ),
                          ],
                        ),
                        child: Column(
                          children: [
                            // ========== 📱 手机号输入框 ==========
                            TextFormField(
                              // 带验证功能的文本输入框
                              controller: _phoneController, // 绑定控制器
                              focusNode: _phoneFocusNode, // 绑定焦点节点
                              keyboardType: TextInputType.phone, // 显示数字键盘
                              inputFormatters: [
                                // 输入格式化器
                                FilteringTextInputFormatter.digitsOnly, // 只允许输入数字
                                LengthLimitingTextInputFormatter(11), // 限制最大长度11位
                              ],
                              decoration: InputDecoration(
                                // 输入框装饰
                                labelText: '手机号码', // 标签文字
                                prefixIcon: const Icon(Icons.phone), // 前缀图标
                                border: OutlineInputBorder(
                                  // 边框样式
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  // 获得焦点时的边框样式
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              // 输入验证方法
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return '请输入手机号码'; // 空值检查
                                }
                                if (value.length != 11) {
                                  return '请输入11位手机号码'; // 长度检查
                                }
                                // 正则表达式验证手机号格式：1开头，第二位是3-9，后面9位数字
                                if (!RegExp(r'^1[3-9]\d{9}$').hasMatch(value)) {
                                  return '请输入正确的手机号码';
                                }
                                return null; // 验证通过返回null
                              },
                              // 用户按回车键时的回调
                              onFieldSubmitted: (_) {
                                // 如果验证码还没发送且不在倒计时中，自动发送验证码
                                if (!_isCodeSent && _countdown == 0) {
                                  _sendVerificationCode();
                                }
                              },
                            ),

                            const SizedBox(height: 16),

                            // ========== 🔢 验证码输入框和发送按钮 ==========
                            Row(
                              // Row：水平排列子Widget
                              children: [
                                Expanded(
                                  // Expanded：让子Widget占用剩余空间
                                  child: TextFormField(
                                    controller: _codeController,
                                    focusNode: _codeFocusNode,
                                    keyboardType: TextInputType.number, // 数字键盘
                                    inputFormatters: [
                                      FilteringTextInputFormatter.digitsOnly, // 只允许数字
                                      LengthLimitingTextInputFormatter(6), // 最大6位
                                    ],
                                    decoration: InputDecoration(
                                      labelText: '验证码',
                                      prefixIcon: const Icon(Icons.sms), // 短信图标
                                      border: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                      ),
                                      focusedBorder: OutlineInputBorder(
                                        borderRadius: BorderRadius.circular(12),
                                        borderSide:
                                            const BorderSide(color: Color(0xFF2196F3)), // 聚焦时的边框颜色
                                      ),
                                    ),
                                    validator: (value) {
                                      if (value == null || value.isEmpty) {
                                        return '请输入验证码';
                                      }
                                      if (value.length < 4) {
                                        return '验证码长度不正确';
                                      }
                                      return null;
                                    },
                                    // 用户按回车键时自动执行登录
                                    onFieldSubmitted: (_) => _login(),
                                  ),
                                ),
                                const SizedBox(width: 12), // 水平间距
                                // ========== 📤 发送验证码按钮 ==========
                                SizedBox(
                                  width: 120, // 固定宽度
                                  height: 56, // 固定高度
                                  child: ElevatedButton(
                                    // 凸起按钮
                                    // 按钮是否可点击：倒计时中或正在加载时禁用
                                    onPressed: (_countdown > 0 || authProvider.isLoading)
                                        ? null // null表示按钮禁用
                                        : _sendVerificationCode, // 点击时执行的方法
                                    child: authProvider.isLoading
                                        ? const SizedBox(
                                            // 加载中显示转圈动画
                                            width: 20,
                                            height: 20,
                                            child: CircularProgressIndicator(strokeWidth: 2),
                                          )
                                        : Text(
                                            // 根据倒计时状态显示不同文字
                                            _countdown > 0 ? '${_countdown}s' : '🔥 自动热重载测试1',
                                            style: const TextStyle(fontSize: 12),
                                          ),
                                  ),
                                ),
                              ],
                            ),

                            const SizedBox(height: 24),

                            // ========== 🔐 登录按钮 ==========
                            SizedBox(
                              width: double.infinity, // 占满宽度
                              height: 56,
                              child: ElevatedButton(
                                // 加载中时禁用按钮
                                onPressed: authProvider.isLoading ? null : _login,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: const Color(0xFF2196F3), // 背景色
                                  foregroundColor: Colors.white, // 文字颜色
                                  shape: RoundedRectangleBorder(
                                    // 按钮形状
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                ),
                                child: authProvider.isLoading
                                    ? const CircularProgressIndicator(
                                        // 加载动画
                                        color: Colors.white,
                                        strokeWidth: 2,
                                      )
                                    : const Text(
                                        '登录',
                                        style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(height: 40),

                      // ========== 📄 底部说明文字 ==========
                      Text(
                        '登录即表示您同意相关服务条款',
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.8), // 半透明白色
                        ),
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
