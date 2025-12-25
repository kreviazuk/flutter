import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../geo_journey_game.dart';
import '../managers/localization_manager.dart';

class MainMenuOverlay extends StatefulWidget {
  final GeoJourneyGame game;
  final bool hasSaveData;

  const MainMenuOverlay({
    super.key, 
    required this.game, 
    required this.hasSaveData
  });

  @override
  State<MainMenuOverlay> createState() => _MainMenuOverlayState();
}

class _MainMenuOverlayState extends State<MainMenuOverlay> {
  final _loc = LocalizationManager();

  void _onContinue() {
     widget.game.loadAndContinueGame();
  }

  void _onNewGame() {
     // Confirm overwriting?
     if (widget.hasSaveData) {
       showDialog(
         context: context, 
         builder: (ctx) => AlertDialog(
            title: Text(_loc.get('dialog_confirm_title')),
            content: Text(_loc.get('dialog_confirm_content')),
            actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: Text(_loc.get('no'))),
               TextButton(
                 onPressed: () {
                    Navigator.pop(ctx);
                    widget.game.startNewGame();
                 }, 
                 child: Text(_loc.get('yes'), style: const TextStyle(color: Colors.red))
               ),
            ],
         )
       );
     } else {
       widget.game.startNewGame();
     }
  }

  void _showSettings() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(_loc.get('settings_title'), style: const TextStyle(color: Colors.white)),
        backgroundColor: Colors.grey[900],
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
             Text(_loc.get('settings_language'), style: const TextStyle(color: Colors.white70)),
             const SizedBox(height: 10),
             Row(
               mainAxisAlignment: MainAxisAlignment.spaceEvenly,
               children: [
                 ElevatedButton(
                   onPressed: () { LocalizationManager().setLocale('zh'); Navigator.pop(ctx); },
                   child: const Text('中文'),
                 ),
                 ElevatedButton(
                   onPressed: () { LocalizationManager().setLocale('en'); Navigator.pop(ctx); },
                   child: const Text('English'),
                 ),
               ],
             )
          ],
        ),
        actions: [
           TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))
        ],
      )
    );
  }

  void _showHelp() {
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          title: Text(_loc.get('btn_help'), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          content: SingleChildScrollView(
            child: Text(
              _loc.get('dialog_help_content'),
              style: const TextStyle(color: Colors.white70),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("OK"))],
       )
     );
  }

  void _showAbout() {
      showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          title: Text(_loc.get('btn_about'), style: const TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          content: Text(
            _loc.get('dialog_about_content'),
            style: const TextStyle(color: Colors.white70),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
       )
     );
  }

  void _onExit() {
    SystemNavigator.pop(); 
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        image: DecorationImage(
          image: AssetImage('assets/images/bg.png'),
          fit: BoxFit.cover,
        ),
      ),
      child: Container(
        // Dark overlay for readability
        color: Colors.black.withOpacity(0.5),
        child: ValueListenableBuilder<String>(
          valueListenable: _loc.currentLocale,
          builder: (context, locale, child) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                   // Title
                   Text(
                     _loc.get('game_title'),
                     style: const TextStyle(
                       fontFamily: 'Courier', 
                       fontSize: 50, 
                       fontWeight: FontWeight.w900,
                       color: Colors.amber,
                       shadows: [Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(0,0))]
                     ),
                   ),
                   Text(
                     _loc.get('game_subtitle'),
                     style: const TextStyle(
                       fontSize: 20, 
                       letterSpacing: 4,
                       color: Colors.white70
                     ),
                   ),
                   
                   const SizedBox(height: 60),

                   // Buttons
                   if (widget.hasSaveData)
                     _buildMenuButton(_loc.get('btn_continue'), Icons.history, _onContinue),
                     
                   _buildMenuButton(_loc.get('btn_new_game'), Icons.play_arrow, _onNewGame),
                   _buildMenuButton(_loc.get('btn_settings'), Icons.settings, _showSettings),
                   _buildMenuButton(_loc.get('btn_help'), Icons.help_outline, _showHelp),
                   _buildMenuButton(_loc.get('btn_about'), Icons.info_outline, _showAbout),
                   _buildMenuButton(_loc.get('btn_exit'), Icons.exit_to_app, _onExit, isDestructive: true),
                ],
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onPressed, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 240, // Slightly wider for translations
        height: 50,
        child: ElevatedButton.icon(
          onPressed: onPressed,
          icon: Icon(icon, size: 20),
          label: Text(label, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          style: ElevatedButton.styleFrom(
            backgroundColor: isDestructive ? Colors.red.withOpacity(0.8) : Colors.blueGrey.shade800,
            foregroundColor: Colors.white,
            elevation: 5,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            side: BorderSide(color: Colors.white.withOpacity(0.2), width: 1),
          ),
        ),
      ),
    );
  }
}
