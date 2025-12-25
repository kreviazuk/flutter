import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../geo_journey_game.dart';

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
  // We check save data availability via parent or check inside?
  // Passed as param is better to avoid async layout flicker
  
  void _onContinue() {
     widget.game.loadAndContinueGame();
  }

  void _onNewGame() {
     // Confirm overwriting?
     if (widget.hasSaveData) {
       showDialog(
         context: context, 
         builder: (ctx) => AlertDialog(
            title: const Text("Start New Game?"),
            content: const Text("This will overwrite your current progress."),
            actions: [
               TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Cancel")),
               TextButton(
                 onPressed: () {
                    Navigator.pop(ctx);
                    widget.game.startNewGame();
                 }, 
                 child: const Text("Confirm", style: TextStyle(color: Colors.red))
               ),
            ],
         )
       );
     } else {
       widget.game.startNewGame();
     }
  }

  void _showHelp() {
     showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          title: const Text("How to Play", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          content: const SingleChildScrollView(
            child: Text(
              "1. Controls:\n"
              "   - D-Pad / Arrow Buttons: Move & Climb\n"
              "   - Red Button: Attack blocks & Tough carystals\n"
              "   - Inventory Tap: Use crystals/items\n\n"
              "2. Goal:\n"
              "   - Dig deep, collect crystals.\n"
              "   - Find the 'Bedrock Gate' to advance levels.\n\n"
              "3. Mechanics:\n"
              "   - Match 4 blocks to clear them.\n"
              "   - Don't get crushed by falling blocks!\n"
              "   - Bag upgrades automatically at score 50, 150, 300.",
              style: TextStyle(color: Colors.white70),
            ),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Got it!"))],
       )
     );
  }

  void _showAbout() {
      showDialog(
       context: context,
       builder: (ctx) => AlertDialog(
          title: const Text("About", style: TextStyle(color: Colors.white)),
          backgroundColor: Colors.grey[900],
          content: const Text(
            "Geo Journey: The Core Protocol\n"
            "Version 1.0.0\n\n"
            "Developed with Flutter & Flame.\n"
            "AI Assistant: Antigravity",
            style: TextStyle(color: Colors.white70),
          ),
          actions: [TextButton(onPressed: () => Navigator.pop(ctx), child: const Text("Close"))],
       )
     );
  }

  void _onExit() {
    SystemNavigator.pop(); // Works on Mobile/Android
    // For Web/Desktop, might not fully close but this is standard.
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
        child: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
               // Title
               const Text(
                 "GEO JOURNEY",
                 style: TextStyle(
                   fontFamily: 'Courier', 
                   fontSize: 50, 
                   fontWeight: FontWeight.w900,
                   color: Colors.amber,
                   shadows: [Shadow(blurRadius: 10, color: Colors.orange, offset: Offset(0,0))]
                 ),
               ),
               const Text(
                 "THE CORE PROTOCOL",
                 style: TextStyle(
                   fontSize: 20, 
                   letterSpacing: 4,
                   color: Colors.white70
                 ),
               ),
               
               const SizedBox(height: 60),

               // Buttons
               if (widget.hasSaveData)
                 _buildMenuButton("CONTINUE", Icons.history, _onContinue),
                 
               _buildMenuButton("NEW GAME", Icons.play_arrow, _onNewGame),
               _buildMenuButton("HELP", Icons.help_outline, _showHelp),
               _buildMenuButton("ABOUT", Icons.info_outline, _showAbout),
               _buildMenuButton("EXIT", Icons.exit_to_app, _onExit, isDestructive: true),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMenuButton(String label, IconData icon, VoidCallback onPressed, {bool isDestructive = false}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: SizedBox(
        width: 200,
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
