import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../managers/localization_manager.dart';

class GameOverOverlay extends StatelessWidget {
  final GeoJourneyGame game;

  const GameOverOverlay({super.key, required this.game});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<String>(
      valueListenable: LocalizationManager().currentLocale,
      builder: (context, locale, child) {
        return Center(
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: Colors.black87,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(color: Colors.red, width: 2),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  LocalizationManager().get('game_over'),
                  style: const TextStyle(
                    color: Colors.red,
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  "${LocalizationManager().get('final_score')}${game.player.scoreNotifier.value}",
                  style: const TextStyle(color: Colors.white, fontSize: 18),
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () {
                    game.adManager.showRewardedAd(
                      onUserEarnedReward: () {
                        game.revivePlayer();
                      }
                    );
                  },
                  icon: const Icon(Icons.video_library, color: Colors.yellow),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
                  ),
                  label: Text(LocalizationManager().get('btn_revive')),
                ),
                const SizedBox(height: 10),
                ElevatedButton(
                  onPressed: game.restartGame,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                  ),
                  child: Text(LocalizationManager().get('btn_restart')),
                ),
              ],
            ),
          ),
        );
      }
    );
  }
}
