import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/geo_journey_game.dart';
import 'game/overlays/game_hud.dart';
import 'game/overlays/game_over_overlay.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: GameWidget(
          game: GeoJourneyGame(),
        overlayBuilderMap: {
          'GameHud': (context, GeoJourneyGame game) => GameHud(game: game),
          'GameOver': (context, GeoJourneyGame game) => GameOverOverlay(game: game),
          'BagFull': (context, GeoJourneyGame game) => const Center(
             child: Material(
               color: Colors.transparent,
               child: Text(
                 'Bag Full!',
                 style: TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
               ),
             ),
          ),
        },
        initialActiveOverlays: const ['GameHud'],
      ),
      ),
    ),
  );
}
