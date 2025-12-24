import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../game_colors.dart';
import '../components/crystal.dart';
import 'package:flutter/foundation.dart';

class GameHud extends StatelessWidget {
  final GeoJourneyGame game;

  const GameHud({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Health & Restart
        Positioned(
          top: 40,
          right: 20,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
               IconButton(
                 icon: const Icon(Icons.refresh, color: Colors.white),
                 onPressed: game.restartGame,
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
          child: ListenableBuilder(
            listenable: Listenable.merge([game.player.inventoryNotifier, game.player.specialInventoryNotifier]),
            builder: (context, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
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
              );
            },
          ),
        ),

        // Controls (D-Pad Left)
        Positioned(
          bottom: 50,
          left: 40,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              IconButton(
                onPressed: () => game.player.handleInput(Vector2(0, -1)),
                icon: const Icon(Icons.arrow_upward, color: Colors.white, size: 40),
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  IconButton(
                    onPressed: () => game.player.handleInput(Vector2(-1, 0)),
                    icon: const Icon(Icons.arrow_back, color: Colors.white, size: 40),
                  ),
                  const SizedBox(width: 40),
                  IconButton(
                    onPressed: () => game.player.handleInput(Vector2(1, 0)),
                    icon: const Icon(Icons.arrow_forward, color: Colors.white, size: 40),
                  ),
                ],
              ),
              IconButton(
                onPressed: () => game.player.handleInput(Vector2(0, 1)),
                icon: const Icon(Icons.arrow_downward, color: Colors.white, size: 40),
              ),
            ],
          ),
        ),

        // Attack Button (Right)
        Positioned(
           bottom: 80,
           right: 40,
           child: GestureDetector(
              onTap: () => game.player.attack(),
              child: Container(
                 width: 80,
                 height: 80,
                 decoration: BoxDecoration(
                    color: Colors.redAccent.withOpacity(0.8),
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 4),
                    boxShadow: [
                       BoxShadow(color: Colors.black.withOpacity(0.5), blurRadius: 10, offset: const Offset(0, 4))
                    ]
                 ),
                 child: const Icon(Icons.crisis_alert, color: Colors.white, size: 40),
              ),
           ),
        ),
      ],
    );
  }

  Widget _buildCrateItem(Color color, IconData icon, int count, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 5),
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.black54,
          border: Border.all(color: color, width: 2),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          children: [
            Icon(icon, color: color, size: 20),
            const SizedBox(width: 4),
            Text(
              '$count',
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
