import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../game_colors.dart';

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
            ],
          ),
        ),

        // Inventory Bar
        Positioned(
          top: 40,
          left: 20,
          // right: 0, // Remove right anchor to avoid conflict with health
          child: ValueListenableBuilder<int>(
            valueListenable: game.player.inventoryNotifier,
            builder: (context, value, child) {
              return Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: GameColor.values.map((color) {
                  final count = game.player.inventory[color] ?? 0;
                  return GestureDetector(
                    onTap: () => game.player.useCrystal(color),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 5),
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Colors.black54,
                        border: Border.all(color: color.color, width: 2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.diamond, color: color.color, size: 20),
                          const SizedBox(width: 4),
                          Text(
                            '$count',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                    ),
                  );
                }).toList(),
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
}
