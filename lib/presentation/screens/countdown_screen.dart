import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'dart:async';
import 'dart:math' as math;
import '../theme/app_colors.dart';
import 'location_display_screen_pure.dart';

/// 🏁 马里奥赛车风格倒计时页面
class CountdownScreen extends StatefulWidget {
  final VoidCallback? onCountdownComplete;

  const CountdownScreen({
    super.key,
    this.onCountdownComplete,
  });

  @override
  State<CountdownScreen> createState() => _CountdownScreenState();
}

class _CountdownScreenState extends State<CountdownScreen> with TickerProviderStateMixin {
  late AnimationController _mainController;
  late AnimationController _scaleController;
  late AnimationController _rotateController;
  late AnimationController _backgroundController;

  late Animation<double> _scaleAnimation;
  late Animation<double> _rotateAnimation;
  late Animation<double> _fadeAnimation;
  late Animation<Color?> _colorAnimation;
  late Animation<double> _backgroundAnimation;

  int _currentCount = 3;
  Timer? _countdownTimer;
  bool _isFinished = false;

  // 倒计时文本和颜色
  final List<String> _countdownTexts = ['3', '2', '1', 'GO!'];
  final List<Color> _countdownColors = [
    Colors.red,
    Colors.orange,
    Colors.yellow,
    AppColors.success,
  ];

  @override
  void initState() {
    super.initState();
    _initAnimations();
    _startCountdown();
  }

  void _initAnimations() {
    // 主控制器 - 控制整个动画周期
    _mainController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 缩放动画控制器
    _scaleController = AnimationController(
      duration: const Duration(milliseconds: 800),
      vsync: this,
    );

    // 旋转动画控制器
    _rotateController = AnimationController(
      duration: const Duration(milliseconds: 1000),
      vsync: this,
    );

    // 背景动画控制器
    _backgroundController = AnimationController(
      duration: const Duration(milliseconds: 4000),
      vsync: this,
    );

    // 缩放动画 - 从0.5到1.2再到1.0
    _scaleAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.5, end: 1.2).chain(CurveTween(curve: Curves.easeOutBack)),
        weight: 60,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.2, end: 1.0).chain(CurveTween(curve: Curves.elasticOut)),
        weight: 40,
      ),
    ]).animate(_scaleController);

    // 旋转动画
    _rotateAnimation = Tween<double>(
      begin: 0,
      end: 2 * math.pi,
    ).animate(CurvedAnimation(
      parent: _rotateController,
      curve: Curves.elasticOut,
    ));

    // 淡入淡出动画
    _fadeAnimation = TweenSequence<double>([
      TweenSequenceItem(
        tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeIn)),
        weight: 30,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 1.0),
        weight: 40,
      ),
      TweenSequenceItem(
        tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeOut)),
        weight: 30,
      ),
    ]).animate(_mainController);

    // 颜色变化动画
    _colorAnimation = ColorTween(
      begin: _countdownColors[0],
      end: _countdownColors[0],
    ).animate(_mainController);

    // 背景脉动动画
    _backgroundAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _backgroundController,
      curve: Curves.easeInOut,
    ));

    // 启动背景动画循环
    _backgroundController.repeat(reverse: true);
  }

  void _startCountdown() {
    _playCountdownAnimation();

    _countdownTimer = Timer.periodic(
      const Duration(seconds: 1),
      (timer) {
        if (_currentCount > 0) {
          setState(() {
            _currentCount--;
          });

          if (_currentCount >= 0) {
            _playCountdownAnimation();
          }
        } else {
          timer.cancel();
          _finishCountdown();
        }
      },
    );
  }

  void _playCountdownAnimation() {
    // 震动反馈
    HapticFeedback.heavyImpact();

    // 重置所有动画
    _mainController.reset();
    _scaleController.reset();
    _rotateController.reset();

    // 更新颜色动画
    final colorIndex = math.max(0, 3 - _currentCount);
    if (colorIndex < _countdownColors.length) {
      _colorAnimation = ColorTween(
        begin: _countdownColors[colorIndex],
        end: _countdownColors[colorIndex],
      ).animate(_mainController);
    }

    // 播放动画
    _mainController.forward();
    _scaleController.forward();

    // 只有在数字时才旋转，GO时不旋转
    if (_currentCount > 0) {
      _rotateController.forward();
    }
  }

  void _finishCountdown() {
    setState(() {
      _isFinished = true;
    });

    // 最终的GO动画
    HapticFeedback.heavyImpact();

    // 等待动画完成后跳转到位置显示页面
    Timer(const Duration(milliseconds: 1500), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (context) => const LocationDisplayScreenPure(),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _countdownTimer?.cancel();
    _mainController.dispose();
    _scaleController.dispose();
    _rotateController.dispose();
    _backgroundController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primary.withOpacity(0.8),
              AppColors.secondary.withOpacity(0.6),
              Colors.black87,
            ],
          ),
        ),
        child: Stack(
          children: [
            // 背景动画圆圈
            ...List.generate(5, (index) => _buildBackgroundCircle(index)),

            // 主要内容
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // 标题
                  AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Transform.scale(
                        scale: 1.0 + _backgroundAnimation.value * 0.1,
                        child: Text(
                          '🏃‍♂️ 准备开始跑步！',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.white.withOpacity(0.9),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 2),
                                blurRadius: 8,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // 倒计时数字
                  AnimatedBuilder(
                    animation: Listenable.merge([
                      _scaleAnimation,
                      _rotateAnimation,
                      _fadeAnimation,
                      _colorAnimation,
                    ]),
                    builder: (context, child) {
                      final currentText = _isFinished
                          ? 'GO!'
                          : _currentCount > 0
                              ? '$_currentCount'
                              : 'GO!';

                      return Transform.scale(
                        scale: _scaleAnimation.value,
                        child: Transform.rotate(
                          angle: _currentCount > 0 ? _rotateAnimation.value : 0,
                          child: Opacity(
                            opacity: _fadeAnimation.value,
                            child: Container(
                              width: 200,
                              height: 200,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                gradient: RadialGradient(
                                  colors: [
                                    (_colorAnimation.value ?? AppColors.primary).withOpacity(0.3),
                                    (_colorAnimation.value ?? AppColors.primary).withOpacity(0.1),
                                    Colors.transparent,
                                  ],
                                ),
                                boxShadow: [
                                  BoxShadow(
                                    color: (_colorAnimation.value ?? AppColors.primary)
                                        .withOpacity(0.5),
                                    blurRadius: 30,
                                    spreadRadius: 10,
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  currentText,
                                  style: TextStyle(
                                    fontSize: _isFinished ? 60 : 80,
                                    fontWeight: FontWeight.w900,
                                    color: _colorAnimation.value ?? AppColors.primary,
                                    shadows: [
                                      Shadow(
                                        offset: const Offset(0, 4),
                                        blurRadius: 15,
                                        color: Colors.black.withOpacity(0.7),
                                      ),
                                      Shadow(
                                        offset: const Offset(0, 0),
                                        blurRadius: 20,
                                        color: (_colorAnimation.value ?? AppColors.primary)
                                            .withOpacity(0.8),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),

                  const SizedBox(height: 60),

                  // 底部提示
                  AnimatedBuilder(
                    animation: _backgroundAnimation,
                    builder: (context, child) {
                      return Opacity(
                        opacity: 0.7 + _backgroundAnimation.value * 0.3,
                        child: Text(
                          _isFinished ? '🎉 开始你的跑步之旅！' : '⚡ 马上就要开始了...',
                          style: TextStyle(
                            fontSize: 18,
                            color: Colors.white.withOpacity(0.8),
                            shadows: [
                              Shadow(
                                offset: const Offset(0, 1),
                                blurRadius: 4,
                                color: Colors.black.withOpacity(0.5),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),

            // 返回按钮
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              child: IconButton(
                onPressed: () => Navigator.of(context).pop(),
                icon: const Icon(
                  Icons.arrow_back,
                  color: Colors.white,
                  size: 28,
                ),
                style: IconButton.styleFrom(
                  backgroundColor: Colors.black26,
                  padding: const EdgeInsets.all(12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBackgroundCircle(int index) {
    return AnimatedBuilder(
      animation: _backgroundAnimation,
      builder: (context, child) {
        final progress = (_backgroundAnimation.value + index * 0.2) % 1.0;
        final size = 100.0 + index * 50.0;
        final opacity = 0.1 - progress * 0.1;

        return Positioned(
          left: (MediaQuery.of(context).size.width - size) / 2,
          top: (MediaQuery.of(context).size.height - size) / 2,
          child: Container(
            width: size * (1 + progress),
            height: size * (1 + progress),
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              border: Border.all(
                color: Colors.white.withOpacity(opacity),
                width: 2,
              ),
            ),
          ),
        );
      },
    );
  }
}
