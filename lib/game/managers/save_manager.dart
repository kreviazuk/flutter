import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../game_colors.dart';
import '../components/crystal.dart';

class BlockSaveData {
  final int x;
  final int y;
  final String colorName;
  final bool isLevelExit;

  BlockSaveData(this.x, this.y, this.colorName, this.isLevelExit);

  Map<String, dynamic> toJson() => {
    'x': x, 'y': y, 'color': colorName, 'isLevelExit': isLevelExit
  };

  factory BlockSaveData.fromJson(Map<String, dynamic> json) {
    return BlockSaveData(
      json['x'], json['y'], json['color'], json['isLevelExit'] ?? false
    );
  }
}

class CrystalSaveData {
  final int x;
  final int y;
  final String colorName;
  final String typeName;
  final int health;

  CrystalSaveData(this.x, this.y, this.colorName, this.typeName, this.health);

  Map<String, dynamic> toJson() => {
    'x': x, 'y': y, 'color': colorName, 'type': typeName, 'health': health
  };

  factory CrystalSaveData.fromJson(Map<String, dynamic> json) {
    return CrystalSaveData(
      json['x'], json['y'], json['color'], json['type'], json['health'] ?? 1
    );
  }
}

class GameSaveData {
  final int level;
  final int score;
  final int health;
  final int maxInventory;
  final Map<GameColor, int> inventory;
  final Map<CrystalType, int> specialInventory;
  
  // New Fields for Restoration
  final int playerX;
  final int playerY;
  final double playerFacingX;
  final double playerFacingY;
  final int maxGeneratedY;
  final List<BlockSaveData> blocks;
  final List<CrystalSaveData> crystals;

  GameSaveData({
    required this.level,
    required this.score,
    required this.health,
    required this.maxInventory,
    required this.inventory,
    required this.specialInventory,
    required this.playerX,
    required this.playerY,
    required this.playerFacingX,
    required this.playerFacingY,
    required this.maxGeneratedY,
    required this.blocks,
    required this.crystals,
  });

  Map<String, dynamic> toJson() {
    return {
      'level': level,
      'score': score,
      'health': health,
      'maxInventory': maxInventory,
      'inventory': inventory.map((k, v) => MapEntry(k.name, v)),
      'specialInventory': specialInventory.map((k, v) => MapEntry(k.name, v)),
      'playerX': playerX,
      'playerY': playerY,
      'playerFacingX': playerFacingX,
      'playerFacingY': playerFacingY,
      'maxGeneratedY': maxGeneratedY,
      'blocks': blocks.map((b) => b.toJson()).toList(),
      'crystals': crystals.map((c) => c.toJson()).toList(),
    };
  }

  factory GameSaveData.fromJson(Map<String, dynamic> json) {
    // Restore Inventory
    final invMap = <GameColor, int>{};
    if (json['inventory'] != null) {
      final Map<String, dynamic> invJson = json['inventory'];
      invJson.forEach((key, value) {
         final color = GameColor.values.firstWhere((e) => e.name == key, orElse: () => GameColor.red);
         invMap[color] = value as int;
      });
    }

    // Restore Special Inventory
    final specialMap = <CrystalType, int>{};
    if (json['specialInventory'] != null) {
      final Map<String, dynamic> specialJson = json['specialInventory'];
      specialJson.forEach((key, value) {
         final type = CrystalType.values.firstWhere((e) => e.name == key, orElse: () => CrystalType.normal);
         specialMap[type] = value as int;
      });
    }
    
    // Restore Blocks
    final loadedBlocks = <BlockSaveData>[];
    if (json['blocks'] != null) {
      (json['blocks'] as List).forEach((v) {
        loadedBlocks.add(BlockSaveData.fromJson(v));
      });
    }

    // Restore Crystals
    final loadedCrystals = <CrystalSaveData>[];
    if (json['crystals'] != null) {
      (json['crystals'] as List).forEach((v) {
        loadedCrystals.add(CrystalSaveData.fromJson(v));
      });
    }

    return GameSaveData(
      level: json['level'] ?? 1,
      score: json['score'] ?? 0,
      health: json['health'] ?? 100,
      maxInventory: json['maxInventory'] ?? 8,
      inventory: invMap,
      specialInventory: specialMap,
      playerX: json['playerX'] ?? 3,
      playerY: json['playerY'] ?? 0,
      playerFacingX: json['playerFacingX'] ?? 0.0,
      playerFacingY: json['playerFacingY'] ?? 1.0,
      maxGeneratedY: json['maxGeneratedY'] ?? 30,
      blocks: loadedBlocks,
      crystals: loadedCrystals,
    );
  }
}

class SaveManager {
  static const String _saveKey = 'geo_journey_save_v1';

  Future<void> saveGame(GameSaveData data) async {
    final prefs = await SharedPreferences.getInstance();
    final jsonString = jsonEncode(data.toJson());
    await prefs.setString(_saveKey, jsonString);
    print("Game Saved: Level ${data.level}, Score ${data.score}");
  }

  Future<GameSaveData?> loadGame() async {
    final prefs = await SharedPreferences.getInstance();
    if (!prefs.containsKey(_saveKey)) return null;

    final jsonString = prefs.getString(_saveKey);
    if (jsonString == null) return null;

    try {
      final jsonMap = jsonDecode(jsonString);
      return GameSaveData.fromJson(jsonMap);
    } catch (e) {
      print("Failed to load save: $e");
      return null;
    }
  }

  Future<void> clearSave() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(_saveKey);
  }
  
  Future<bool> hasSaveData() async {
     final prefs = await SharedPreferences.getInstance();
     return prefs.containsKey(_saveKey); 
  }
}
