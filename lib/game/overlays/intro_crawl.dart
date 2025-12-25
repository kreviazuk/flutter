import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../geo_journey_game.dart';

class IntroCrawlOverlay extends StatefulWidget {
  final GeoJourneyGame game;
  final VoidCallback onFinish;

  const IntroCrawlOverlay({super.key, required this.game, required this.onFinish});

  @override
  State<IntroCrawlOverlay> createState() => _IntroCrawlOverlayState();
}

class _IntroCrawlOverlayState extends State<IntroCrawlOverlay> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  bool _showStatic = false;

  static const String _introKey = 'geo_journey_intro_shown';
  
  final String _introText = 
      "在21XX年，地表因持续的太阳风暴而变得荒芜，人类被迫迁入地下避难所。\n\n"
      "作为“深层地质勘探局”的精英探险家，你驾驶着代号为“地鼠”的纳米挖掘装甲。\n\n"
      "你的任务是深入地壳，寻找维持地下城运转的唯一能源——源核水晶 (Core Crystals)。\n\n"
      "然而，你的装甲最初搭载的“量子压缩背包”还是民用原型机，能量稳定性很差，最初只能容纳 8 个单位的矿石水晶。一旦超载，空间折叠场就会失效，导致无法继续采集。\n\n"
      "随着你在挖掘过程中收集更多的高纯度样本（积分积累），总部会远程传输固件升级补丁，增强你背包的力场稳定性，从而逐步扩充容量，解锁更多携带空间，让你能向着更深的地心进发。";

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22), 
    );
    
    // Scroll until text is fully off screen or just finished?
    // User wants it to "show normally" after it comes out.
    // Let's scroll enough so the last line is visible, then switch.
    // If we scroll to -2.5 it is gone. Let's switch when it's done.
    _animation = Tween<double>(begin: 1.1, end: -1.5).animate(_controller);

    _controller.forward().whenComplete(() {
       // Animation done, switch to static view
       if (mounted) {
         setState(() {
           _showStatic = true;
         });
       }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _enterGame() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_introKey, true);
    widget.onFinish();
  }

  void _skipToStatic() {
     _controller.stop();
     setState(() {
       _showStatic = true;
     });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold( 
      backgroundColor: Colors.black,
      body: Stack(
         children: [
            // Background
            Positioned.fill(child: Container(color: Colors.black)),
            
            // Content
            if (_showStatic) _buildStaticView() else _buildAnimatedView(),
            
            // Skip Button (Only during animation)
            if (!_showStatic)
              Positioned(
                 bottom: 40,
                 right: 40,
                 child: TextButton(
                    onPressed: _skipToStatic, // Skip to static read instead of direct game
                    style: TextButton.styleFrom(
                      foregroundColor: Colors.white.withOpacity(0.5),
                    ),
                    child: const Text("SKIP ANIMATION >>", style: TextStyle(fontSize: 16)),
                 ),
              ),
         ],
      ),
    );
  }

  Widget _buildAnimatedView() {
      return AnimatedBuilder(
         animation: _animation,
         builder: (context, child) {
           final height = MediaQuery.of(context).size.height;
           final top = _animation.value * height;
           
           return Transform(
              transform: Matrix4.identity()
                ..setEntry(3, 2, 0.001)
                ..rotateX(0.5)
                ..translate(0.0, top), 
              alignment: Alignment.center,
              child: OverflowBox(
                 minHeight: 0,
                 maxHeight: double.infinity,
                 alignment: Alignment.topCenter,
                 child: Container(
                    alignment: Alignment.topCenter,
                    padding: const EdgeInsets.symmetric(horizontal: 40),
                    child: ConstrainedBox(
                      constraints: const BoxConstraints(maxWidth: 700),
                      child: Text(
                        _introText,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Color(0xFFFFCC00), 
                          fontSize: 32,
                          fontWeight: FontWeight.bold,
                          height: 1.5,
                          fontFamily: 'Courier',
                        ),
                      ),
                    ),
                 ),
              ),
           );
         },
      );
  }

  Widget _buildStaticView() {
      return Center(
        child: Container(
           constraints: const BoxConstraints(maxWidth: 800),
           padding: const EdgeInsets.all(40),
           child: Column(
             mainAxisSize: MainAxisSize.min,
             children: [
                const Text(
                  "MISSION BRIEFING",
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 24,
                    letterSpacing: 4,
                    fontWeight: FontWeight.bold
                  ),
                ),
                const SizedBox(height: 30),
                Expanded(
                  child: SingleChildScrollView(
                    child: Text(
                      _introText,
                      textAlign: TextAlign.left, // Normal reading
                      style: const TextStyle(
                        color: Color(0xFFFFCC00),
                        fontSize: 20, // Slightly smaller for reading
                        height: 1.6,
                        fontFamily: 'Courier',
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                   onPressed: _enterGame,
                   style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFFFCC00),
                      foregroundColor: Colors.black,
                      padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 15),
                   ),
                   child: const Text("INITIALIZE SYSTEM", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
             ],
           ),
        ),
      );
  }
}
