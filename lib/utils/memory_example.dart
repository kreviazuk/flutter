/// 内存管理示例 - 展示什么时候需要dispose
import 'dart:async';
import 'package:flutter/material.dart';

/// ✅ 正确的内存管理示例
class GoodMemoryManagement extends StatefulWidget {
  const GoodMemoryManagement({super.key});

  @override
  State<GoodMemoryManagement> createState() => _GoodMemoryManagementState();
}

class _GoodMemoryManagementState extends State<GoodMemoryManagement> {
  // ========== 🚨 这些需要手动dispose的资源 ==========

  /// 文本控制器 - 需要dispose
  /// 原因：控制器会监听文本变化，持有内存引用
  late TextEditingController _textController;

  /// 焦点节点 - 需要dispose
  /// 原因：焦点节点会监听焦点变化事件
  late FocusNode _focusNode;

  /// 计时器 - 需要dispose
  /// 原因：计时器会一直运行，即使页面关闭了
  Timer? _timer;

  /// 数据流订阅 - 需要dispose
  /// 原因：订阅会一直监听数据，造成内存泄漏
  StreamSubscription? _streamSubscription;

  @override
  void initState() {
    super.initState();

    // 初始化需要dispose的资源
    _textController = TextEditingController();
    _focusNode = FocusNode();

    // 启动计时器
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('计时器还在运行... ${DateTime.now()}');
    });

    // 监听数据流
    _streamSubscription =
        Stream.periodic(const Duration(seconds: 2)).listen((data) => print('数据流: $data'));
  }

  @override
  void dispose() {
    // ========== 🧹 清理资源，防止内存泄漏 ==========

    print('🧹 开始清理内存...');

    /// 1. 清理文本控制器
    _textController.dispose();
    print('✅ 文本控制器已清理');

    /// 2. 清理焦点节点
    _focusNode.dispose();
    print('✅ 焦点节点已清理');

    /// 3. 取消计时器
    _timer?.cancel();
    print('✅ 计时器已取消');

    /// 4. 取消数据流订阅
    _streamSubscription?.cancel();
    print('✅ 数据流订阅已取消');

    /// 5. 最后调用父类dispose
    super.dispose();
    print('🎉 内存清理完成！');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('好的内存管理')),
      body: Column(
        children: [
          TextField(
            controller: _textController,
            focusNode: _focusNode,
            decoration: const InputDecoration(
              labelText: '这个输入框会被正确清理',
            ),
          ),
          const SizedBox(height: 20),
          const Text('页面关闭时，所有资源都会被正确清理'),
        ],
      ),
    );
  }
}

/// ❌ 错误的内存管理示例（仅供对比，实际开发中避免这样写）
class BadMemoryManagement extends StatefulWidget {
  const BadMemoryManagement({super.key});

  @override
  State<BadMemoryManagement> createState() => _BadMemoryManagementState();
}

class _BadMemoryManagementState extends State<BadMemoryManagement> {
  late TextEditingController _textController;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    _textController = TextEditingController();

    // 启动计时器但不清理 - 这会导致内存泄漏！
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      print('💥 泄漏的计时器还在运行... ${DateTime.now()}');
    });
  }

  // ❌ 没有dispose方法 - 资源不会被清理！
  // @override
  // void dispose() {
  //   _textController.dispose();
  //   _timer?.cancel();
  //   super.dispose();
  // }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('坏的内存管理')),
      body: Column(
        children: [
          TextField(
            controller: _textController,
            decoration: const InputDecoration(
              labelText: '这个控制器不会被清理 💥',
            ),
          ),
          const Text('页面关闭后，资源仍然占用内存！'),
        ],
      ),
    );
  }
}

/// ========== 📋 内存管理检查清单 ==========
/// 
/// ✅ 需要dispose的资源：
/// - TextEditingController
/// - FocusNode  
/// - AnimationController
/// - Timer
/// - StreamSubscription
/// - ScrollController
/// - PageController
/// - TabController
/// 
/// ✅ 不需要dispose的资源：
/// - int, String, bool 等基本类型
/// - List, Map 等集合类型
/// - StatelessWidget
/// - BuildContext
/// - 普通的函数和变量
/// 
/// 🎯 判断标准：
/// 如果一个对象有dispose()方法，那它就需要被dispose！ 