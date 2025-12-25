import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../managers/localization_manager.dart';
import '../data/challenges.dart';

class WorldMapOverlay extends StatelessWidget {
  final GeoJourneyGame game;

  const WorldMapOverlay({super.key, required this.game});

  void _onTrophyTap(BuildContext context, ChallengeData challenge) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Colors.grey[900],
        title: Text(
          LocalizationManager().get(challenge.translationKey),
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "${LocalizationManager().get('challenge_target')}${challenge.targetScore}",
              style: const TextStyle(color: Colors.amber, fontSize: 18),
            ),
            const SizedBox(height: 10),
            Text(
              "${LocalizationManager().get('challenge_reward')}${challenge.bagReward}${LocalizationManager().get('challenge_bag')}",
              style: const TextStyle(color: Colors.cyanAccent, fontSize: 16),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(LocalizationManager().get('no'), style: TextStyle(color: Colors.white70)),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              game.startNewGame(); // Start game normally
              // In future we can pass challenge specific params
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber,
              foregroundColor: Colors.black,
            ),
            child: Text(LocalizationManager().get('btn_challenge')),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    // Simulated large map width
    const double mapWidth = 1200.0;
    const double mapHeight = 600.0;

    return Scaffold(
      backgroundColor: Colors.blue[800], // Ocean color
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            border: Border.all(color: Colors.white, width: 4),
            borderRadius: BorderRadius.circular(10),
            color: const Color(0xFF4FA4F4), // Lighter ocean blue
          ),
          width: MediaQuery.of(context).size.width * 0.9,
          height: MediaQuery.of(context).size.height * 0.8,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: SizedBox(
              width: mapWidth,
              height: mapHeight,
              child: Stack(
                children: [
                   // Map Background (Placeholder Continents)
                   // Asia / Europe
                   Positioned(
                     left: 600, top: 100,
                     child: _buildContinentShape(300, 250, Colors.green),
                   ),
                   // Africa
                   Positioned(
                     left: 550, top: 350,
                     child: _buildContinentShape(200, 200, Colors.green[600]!),
                   ),
                   // Americas
                   Positioned(
                     left: 150, top: 100,
                     child: _buildContinentShape(250, 400, Colors.green[700]!),
                   ),
                   // Australia
                   Positioned(
                     left: 950, top: 400,
                     child: _buildContinentShape(150, 120, Colors.green[400]!),
                   ),
                   // Antarctica
                   Positioned(
                     left: 400, top: 550,
                     child: _buildContinentShape(500, 50, Colors.white),
                   ),

                   // Trophies
                   ...gameChallenges.map((challenge) {
                      return Positioned(
                         left: challenge.mapX * mapWidth,
                         top: challenge.mapY * mapHeight,
                         child: GestureDetector(
                           onTap: () => _onTrophyTap(context, challenge),
                           child: Column(
                             children: [
                               const Icon(Icons.emoji_events, color: Colors.amber, size: 40, 
                                 shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                               ),
                               Container(
                                 padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 2),
                                 decoration: BoxDecoration(color: Colors.black54, borderRadius: BorderRadius.circular(4)),
                                 child: Text(
                                   "${challenge.targetScore}", 
                                   style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)
                                 ),
                               ),
                             ],
                           ),
                         ),
                      );
                   }),
                   
                   // Back Button
                   Positioned(
                     top: 20, left: 20,
                     child: FloatingActionButton(
                       backgroundColor: Colors.black54,
                       onPressed: () {
                          // Close map, go back to main menu
                          // Since overlay management is rigid, we might need a method in Game
                          game.returnToMainMenuFromMap();
                       },
                       child: const Icon(Icons.arrow_back, color: Colors.white),
                     ),
                   ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContinentShape(double width, double height, Color color) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(30), // Rounded organic shape
        boxShadow: const [BoxShadow(color: Colors.black26, blurRadius: 4)]
      ),
    );
  }
}
