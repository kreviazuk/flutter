/// 平台内存管理对比 - H5 vs Flutter
///
/// 这个文件解释为什么H5开发不需要手动dispose，而Flutter需要

/// ========== 🌐 H5/JavaScript 示例 ==========
///
/// 在JavaScript中，你可以这样写：
///
/// ```javascript
/// // H5开发 - 不需要手动清理
/// function createLoginPage() {
///   // 1. 创建定时器
///   let timer = setInterval(() => {
///     console.log('定时器运行中...');
///   }, 1000);
///
///   // 2. 添加事件监听
///   let button = document.getElementById('loginBtn');
///   button.addEventListener('click', handleLogin);
///
///   // 3. 创建变量
///   let userInput = '';
///   let formData = {};
///
///   // 🤖 页面关闭时，浏览器自动清理所有这些！
///   // 不需要写 clearInterval(timer)
///   // 不需要写 button.removeEventListener()
///   // 浏览器的垃圾回收器会自动处理
/// }
///
/// // ✅ H5开发者只需要专注业务逻辑，不用担心内存
/// ```

/// ========== 📱 Flutter/Dart 示例 ==========
///
/// 在Flutter中，必须手动管理：
///
/// ```dart
/// class LoginPage extends StatefulWidget {
///   @override
///   _LoginPageState createState() => _LoginPageState();
/// }
///
/// class _LoginPageState extends State<LoginPage> {
///   Timer? _timer;
///   TextEditingController _controller;
///   StreamSubscription? _subscription;
///
///   @override
///   void initState() {
///     super.initState();
///
///     // 创建资源
///     _timer = Timer.periodic(Duration(seconds: 1), (timer) {
///       print('定时器运行中...');
///     });
///
///     _controller = TextEditingController();
///     _subscription = someStream.listen((data) => print(data));
///   }
///
///   @override
///   void dispose() {
///     // 🛠️ 必须手动清理，否则内存泄漏！
///     _timer?.cancel();
///     _controller.dispose();
///     _subscription?.cancel();
///     super.dispose();
///   }
/// }
/// ```

/// ========== 🔍 为什么有这种差异？ ==========

/// 💡 原因1：运行环境不同
///
/// H5应用运行在浏览器中：
/// - 浏览器 = 一个强大的虚拟机
/// - V8引擎（Chrome）有完善的垃圾回收
/// - 页面关闭 = 整个JavaScript环境销毁
/// - 浏览器会强制清理所有资源
///
/// Flutter应用运行在设备上：
/// - 直接运行在操作系统上
/// - 更接近底层，性能更好
/// - 需要精确控制资源使用
/// - 系统不会强制清理应用内部资源

/// 💡 原因2：生命周期管理不同
///
/// H5页面生命周期：
/// 页面加载 → 运行JavaScript → 页面关闭 → 浏览器清理一切
///
/// Flutter页面生命周期：
/// 创建Widget → initState → build → ... → dispose（需要手动清理）

/// 💡 原因3：性能要求不同
///
/// H5应用：
/// - 运行在浏览器沙箱中
/// - 浏览器限制了能做的事情
/// - 牺牲一些性能换取便利性
///
/// Flutter应用：
/// - 需要60fps流畅体验
/// - 直接控制GPU渲染
/// - 手动管理换取最佳性能

/// ========== 🎯 实际例子对比 ==========

class PlatformComparisonExample {
  /// 🌐 H5定时器示例（JavaScript伪代码）
  ///
  /// ```javascript
  /// // H5中这样写就够了
  /// let countdown = 60;
  /// let timer = setInterval(() => {
  ///   countdown--;
  ///   document.getElementById('countdown').textContent = countdown;
  ///   if (countdown <= 0) {
  ///     clearInterval(timer); // 可选：手动清理
  ///   }
  /// }, 1000);
  ///
  /// // 用户关闭页面 → 浏览器自动清理timer
  /// // 开发者无需担心内存泄漏
  /// ```

  /// 📱 Flutter中对应的代码
  void flutterTimerExample() {
    // 必须这样写，否则内存泄漏
    /*
    Timer? _timer;
    int _countdown = 60;
    
    void startTimer() {
      _timer = Timer.periodic(Duration(seconds: 1), (timer) {
        setState(() {
          _countdown--;
        });
        if (_countdown <= 0) {
          timer.cancel(); // 必须手动清理
        }
      });
    }
    
    @override
    void dispose() {
      _timer?.cancel(); // 必须在dispose中清理
      super.dispose();
    }
    */
  }
}

/// ========== 📋 总结：为什么H5不需要dispose ==========
/// 
/// 🌐 H5/JavaScript的优势：
/// ✅ 浏览器自动垃圾回收
/// ✅ 页面关闭时强制清理一切
/// ✅ 开发者心智负担小
/// ✅ 不容易出现内存泄漏
/// ✅ 专注业务逻辑开发
/// 
/// 📱 Flutter/Native的特点：
/// ✅ 性能更好，更流畅
/// ✅ 功能更强大，可以做更多事
/// ✅ 更接近底层，可以精确控制
/// ❌ 需要手动管理资源
/// ❌ 容易出现内存泄漏
/// ❌ 学习曲线稍陡峭
/// 
/// 🎯 选择建议：
/// - 简单的内容展示 → H5更方便
/// - 复杂的交互应用 → Flutter更合适
/// - 需要高性能 → Flutter更好
/// - 快速开发原型 → H5更快 