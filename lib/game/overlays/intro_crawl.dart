import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../geo_journey_game.dart';
import '../managers/localization_manager.dart';

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
  final _loc = LocalizationManager();

  static const String _introKey = 'geo_journey_intro_shown';
  
  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 22), 
    );
    
    _animation = Tween<double>(begin: 1.1, end: -1.5).animate(_controller);

    _controller.forward().whenComplete(() {
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
    return ValueListenableBuilder<String>(
      valueListenable: _loc.currentLocale,
      builder: (context, locale, child) { 
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
                        onPressed: _skipToStatic, 
                        style: TextButton.styleFrom(
                          foregroundColor: Colors.white.withOpacity(0.5),
                        ),
                        child: Text(_loc.get('intro_skip'), style: const TextStyle(fontSize: 16)),
                     ),
                  ),
             ],
          ),
        );
      }
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
                        _loc.get('intro_text'),
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
                Text(
                  _loc.get('intro_briefing'),
                  style: const TextStyle(
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
                      _loc.get('intro_text'),
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
                   child: Text(_loc.get('intro_init'), style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                ),
             ],
           ),
        ),
      );
  }
}
