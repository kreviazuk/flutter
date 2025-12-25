import 'package:flame/game.dart';
import 'package:flutter/material.dart';
import 'game/geo_journey_game.dart';
import 'game/overlays/game_hud.dart';
import 'game/overlays/game_over_overlay.dart';
import 'game/overlays/main_menu.dart';
import 'game/overlays/intro_crawl.dart';
import 'game/overlays/world_map_overlay.dart';
import 'game/managers/localization_manager.dart';

import 'package:google_mobile_ads/google_mobile_ads.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await MobileAds.instance.initialize();
  
  runApp(
    MaterialApp(
      home: GameWidget<GeoJourneyGame>(
        game: GeoJourneyGame(),
        overlayBuilderMap: {
          'MainMenu': (context, GeoJourneyGame game) => MainMenuOverlay(game: game, hasSaveData: game.hasSaveData),
          'IntroCrawl': (context, GeoJourneyGame game) => IntroCrawlOverlay(game: game, onFinish: game.onIntroFinish),
          'WorldMap': (context, GeoJourneyGame game) => WorldMapOverlay(game: game),
          'GameHud': (context, GeoJourneyGame game) => GameHud(game: game),
          'GameOver': (context, GeoJourneyGame game) => GameOverOverlay(game: game),
          'BagFull': (context, GeoJourneyGame game) => Center(
             child: Material(
               color: Colors.transparent,
               child: Text(
                 LocalizationManager().get('bag_full'),
                 style: const TextStyle(color: Colors.red, fontSize: 32, fontWeight: FontWeight.bold),
               ),
             ),
          ),
          'LevelComplete': (context, GeoJourneyGame game) => Center(
             child: Material(
               color: Colors.black87,
               child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      LocalizationManager().get('level_complete'),
                      style: const TextStyle(color: Colors.greenAccent, fontSize: 40, fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 20),
                    const CircularProgressIndicator(color: Colors.white),
                    const SizedBox(height: 20),
                    Text(
                      '${LocalizationManager().get('next_level_loading')}${game.currentLevel + 1}...', 
                      style: const TextStyle(color: Colors.white, fontSize: 20),
                    ),
                  ],
               ),
             ),
          ),
        },
        initialActiveOverlays: const [],
      ),
    ),
  );
}
