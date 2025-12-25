import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../game_colors.dart';
import '../components/crystal.dart';
import 'package:flutter/foundation.dart';
import '../managers/localization_manager.dart';
import 'package:vibration/vibration.dart';

class GameHud extends StatelessWidget {
  final GeoJourneyGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationManager().currentLocale,
      builder: (context, locale, child) {
        return Stack(
          children: [
            // Health & Restart
            Positioned(
              top: 40,
              right: 20,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                    Row(
                       mainAxisSize: MainAxisSize.min,
                       children: [
                         IconButton(
                           icon: const Icon(Icons.home, color: Colors.cyanAccent, size: 28),
                           onPressed: game.returnToMainMenu,
                           tooltip: LocalizationManager().get('btn_main_menu'),
                           style: IconButton.styleFrom(
                             backgroundColor: Colors.black45,
                             padding: const EdgeInsets.all(8),
                           ),
                         ),
                         const SizedBox(width: 8),
                         IconButton(
                           icon: const Icon(Icons.refresh, color: Colors.white, size: 28),
                           onPressed: game.restartGame,
                           tooltip: LocalizationManager().get('btn_restart'),
                            style: IconButton.styleFrom(
                             backgroundColor: Colors.black45,
                             padding: const EdgeInsets.all(8),
                           ),
                         ),
                       ],
                    ),
                   const SizedBox(height: 10),
                   ValueListenableBuilder<int>(
                     valueListenable: game.player.healthNotifier,
                     builder: (context, value, child) {
                       return Row(
                         children: [
                           const Icon(Icons.favorite, color: Colors.red),
                           const SizedBox(width: 4),
                           Text(
                             '$value',
                             style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
                           ),
                         ],
                       );
                     },
                   ),
                   const SizedBox(height: 10),
                   // Score
                   ValueListenableBuilder<int>(
                     valueListenable: game.player.scoreNotifier,
                     builder: (context, value, child) {
                        return Row(
                             mainAxisSize: MainAxisSize.min,
                             children: [
                                 const Icon(Icons.stars, color: Colors.yellow, size: 28),
                                 const SizedBox(width: 4),
                                 Text(
                                   '$value',
                                   style: const TextStyle(
                                      color: Colors.yellow, 
                                      fontSize: 24, 
                                      fontWeight: FontWeight.bold,
                                      shadows: [Shadow(color: Colors.black, blurRadius: 4)]
                                   ),
                                 )
                             ]
                        );
                     }
                   ),
                ],
              ),
            ),
    
            // Inventory Bar
            Positioned(
              top: 40,
              left: 20,
              child: LayoutBuilder(
                builder: (context, constraints) {
                  final screenWidth = MediaQuery.of(context).size.width;
                  // Leave space for the right side panel (about 100px)
                  final maxWidth = screenWidth - 140;
                  
                  return ListenableBuilder(
                    listenable: Listenable.merge([game.player.inventoryNotifier, game.player.specialInventoryNotifier]),
                    builder: (context, child) {
                      final currentTotal = game.player.inventoryNotifier.value;
                      final maxTotal = game.player.maxInventoryTotal;
                      
                      return SizedBox(
                        width: maxWidth,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Capacity Text
                            Container(
                              margin: const EdgeInsets.only(bottom: 4),
                              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                              decoration: BoxDecoration(
                                color: Colors.black54,
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                "${LocalizationManager().get('bag_label')}: $currentTotal / $maxTotal",
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 14,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                            Wrap(
                              spacing: 4,
                              runSpacing: 4,
                              children: [
                                // Normal Crystals
                                ...GameColor.values.map((color) {
                                  final count = game.player.inventory[color] ?? 0;
                                  if (count == 0) return const SizedBox.shrink();
                                  return _buildCrateItem(color.color, Icons.diamond, count, () => game.player.useCrystal(color));
                                }),
                                // Special Crystals
                                ...[CrystalType.verticalDrill, CrystalType.aoeBlast].map((type) {
                                   final count = game.player.specialInventory[type] ?? 0;
                                   if (count == 0) return const SizedBox.shrink();
                                   return _buildCrateItem(
                                     type == CrystalType.verticalDrill ? Colors.white : Colors.amber, 
                                     type == CrystalType.verticalDrill ? Icons.south : Icons.star, 
                                     count, 
                                     () => game.player.useSpecialCrystal(type)
                                   );
                                }),
                              ],
                            ),
                          ],
                        ),
                      );
                    },
                  );
                },
              ),
            ),
    
            // Centered D-Pad Controls
            Positioned(
              bottom: 40,
              left: 0, 
              right: 0, 
              child: Center(
                child: SizedBox(
                   width: 200,
                   height: 200,
                   child: Stack(
                      children: [
                        // UP
                        Align(
                          alignment: Alignment.topCenter,
                          child: _buildDirBtn(Icons.arrow_upward, Vector2(0, -1), game),
                        ),
                        // LEFT
                        Align(
                          alignment: Alignment.centerLeft,
                          child: _buildDirBtn(Icons.arrow_back, Vector2(-1, 0), game),
                        ),
                        // RIGHT
                        Align(
                          alignment: Alignment.centerRight,
                          child: _buildDirBtn(Icons.arrow_forward, Vector2(1, 0), game),
                        ),
                        // DOWN
                        Align(
                          alignment: Alignment.bottomCenter,
                          child: _buildDirBtn(Icons.arrow_downward, Vector2(0, 1), game),
                        ),
                      ],
                   ),
                ),
              ),
            ),
            
            // Debug Button
            Positioned(
              top: 150,
              right: 20,
              child: Column(
                 children: [
                    IconButton(
                      onPressed: () => game.player.debugCheat(),
                      icon: const Icon(Icons.bug_report, color: Colors.greenAccent, size: 30),
                      style: IconButton.styleFrom(backgroundColor: Colors.black54),
                    ),
                    Text(LocalizationManager().get('cheat_label'), style: const TextStyle(color: Colors.white, fontSize: 10)),
                 ],
              ),
            ),
          ],
        );
      }
    );
  }

  Widget _buildCrateItem(Color color, IconData icon, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 44,
        height: 44,
        margin: const EdgeInsets.all(2),
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(6),
        ),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Center(child: Icon(icon, color: color, size: 24)),
            Positioned(
              right: -4,
              bottom: -4,
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                decoration: BoxDecoration(
                  color: Colors.black87,
                  borderRadius: BorderRadius.circular(6),
                ),
                child: Text(
                  '$count',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDirBtn(IconData icon, Vector2 direction, GeoJourneyGame game) {
    return GestureDetector(
      onTap: () {
        if (LocalizationManager().hapticEnabled.value) {
            Vibration.vibrate(duration: 15); // Light tap
        }
        game.player.handleInput(direction);
      },
      child: Container(
        width: 65,
        height: 65,
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.6), // Darker background for contrast
          borderRadius: BorderRadius.circular(15),
          border: Border.all(
            color: Colors.white.withOpacity(0.8), // Brighter border
            width: 3 // Thicker border
          ),
          boxShadow: [
             BoxShadow(
               color: Colors.black.withOpacity(0.5),
               blurRadius: 4,
               offset: const Offset(2, 2)
             )
          ]
        ),
        child: Icon(icon, color: Colors.white, size: 40),
      ),
    );
  }
}
