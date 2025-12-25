class ChallengeData {
  final String id;
  final String translationKey;
  final int targetScore;
  final int bagReward;
  final double mapX; // 0.0 to 1.0 relative to map width
  final double mapY; // 0.0 to 1.0 relative to map height

  const ChallengeData({
    required this.id,
    required this.translationKey,
    required this.targetScore,
    required this.bagReward,
    required this.mapX,
    required this.mapY,
  });
}

const List<ChallengeData> gameChallenges = [
  ChallengeData(
    id: 'africa',
    translationKey: 'challenge_africa',
    targetScore: 1500,
    bagReward: 10,
    mapX: 0.52, 
    mapY: 0.55,
  ),
  ChallengeData(
    id: 'europe',
    translationKey: 'challenge_europe',
    targetScore: 3000,
    bagReward: 12,
    mapX: 0.50,
    mapY: 0.30,
  ),
  ChallengeData(
    id: 'asia',
    translationKey: 'challenge_asia',
    targetScore: 5000,
    bagReward: 14,
    mapX: 0.70,
    mapY: 0.35,
  ),
  ChallengeData(
    id: 'australia',
    translationKey: 'challenge_australia',
    targetScore: 7500,
    bagReward: 16,
    mapX: 0.82,
    mapY: 0.70,
  ),
  ChallengeData(
    id: 'americas',
    translationKey: 'challenge_americas',
    targetScore: 10000,
    bagReward: 18,
    mapX: 0.25,
    mapY: 0.45,
  ),
  ChallengeData(
    id: 'antarctica',
    translationKey: 'challenge_antarctica',
    targetScore: 12000,
    bagReward: 20,
    mapX: 0.55,
    mapY: 0.88,
  ),
];
