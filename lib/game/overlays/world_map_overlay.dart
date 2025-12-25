import 'package:flutter/material.dart';
import '../geo_journey_game.dart';
import '../managers/localization_manager.dart';
import '../data/challenges.dart';

class WorldMapOverlay extends StatelessWidget {
  final GeoJourneyGame game;

  const WorldMapOverlay({super.key, required this.game});

  void _onChallengeTap(BuildContext context, ChallengeData challenge) {
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
              game.startNewGame(); 
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
    return Scaffold(
      backgroundColor: const Color(0xFF1a1a1a), // Dark background matching game
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => game.returnToMainMenuFromMap(),
        ),
        title: Text(
          LocalizationManager().get('game_title'), // Or a new 'World Map' key if available
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 600),
          child: ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: gameChallenges.length,
            itemBuilder: (context, index) {
              final challenge = gameChallenges[index];
              return Card(
                color: Colors.white.withOpacity(0.05),
                margin: const EdgeInsets.symmetric(vertical: 8),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side: BorderSide(color: Colors.white.withOpacity(0.1)),
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                  leading: const Icon(Icons.public, color: Colors.blueAccent, size: 40),
                  title: Text(
                    LocalizationManager().get(challenge.translationKey),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  subtitle: Text(
                    "${LocalizationManager().get('challenge_target')}${challenge.targetScore}",
                    style: const TextStyle(color: Colors.grey),
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                       Column(
                         mainAxisAlignment: MainAxisAlignment.center,
                         crossAxisAlignment: CrossAxisAlignment.end,
                         children: [
                           const Icon(Icons.emoji_events, color: Colors.amber, size: 20),
                           Text(
                             "${challenge.bagReward}",
                             style: const TextStyle(color: Colors.amber, fontWeight: FontWeight.bold),
                           )
                         ],
                       ),
                       const SizedBox(width: 16),
                       const Icon(Icons.chevron_right, color: Colors.white54),
                    ],
                  ),
                  onTap: () => _onChallengeTap(context, challenge),
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}
