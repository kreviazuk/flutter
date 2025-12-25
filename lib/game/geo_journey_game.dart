import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'managers/grid_manager.dart';
import 'managers/save_manager.dart';
import 'overlays/main_menu.dart';
import 'game_constants.dart';
import 'dart:async' as async; // For debouncer

class GeoJourneyGame extends FlameGame {
  final Player player = Player(
    position: Vector2(
      GameConstants.columns * GameConstants.blockSize / 2,
      0,
    ),
  );
  
  int currentLevel = 1;
  final SaveManager saveManager = SaveManager();
  bool hasSaveData = false;
  async.Timer? _saveDebouncer;

  @override
  Color backgroundColor() => const Color(0xFF1a1a1a); // Dark background

  @override
  Future<void> onLoad() async {
    super.onLoad();
    
    // Dynamic block size to fit screen width
    GameConstants.blockSize = size.x / GameConstants.columns;
    
    // Background
    add(RectangleComponent(
      size: size,
      paint: Paint()..color = const Color(0xFF222222),
    ));

    camera.viewfinder.anchor = Anchor.center;
    
    world.add(GridManager(key: ComponentKey.named('GridManager')));
    world.add(player);
    
    // Center camera
    camera.viewfinder.position = Vector2(size.x / 2, 0);
    camera.stop(); 
    
    // Pause initially to show Menu
    pauseEngine();
    
    // Check Save Data
    hasSaveData = await saveManager.hasSaveData();
    
    // Show Menu
    overlays.add('MainMenu');
  }

  void startNewGame() async {
     await saveManager.clearSave();
     restartGame(); // Resets specific components
     
     // Remove Menu, Add HUD
     overlays.remove('MainMenu');
     overlays.add('GameHud');
     
     resumeEngine();
     _setupAutoSave();
     saveGame(); // Initial save
  }

  Future<void> loadAndContinueGame() async {
     final data = await saveManager.loadGame();
     if (data != null) {
        // Find GridManager safely
        final gridManager = world.children.whereType<GridManager>().firstOrNull;
        if (gridManager == null) {
          print("Error: GridManager not found during load.");
          return;
        }

        // Restore State
        currentLevel = data.level;
        player.scoreNotifier.value = data.score;
        player.healthNotifier.value = data.health;
        player.maxInventoryTotal = data.maxInventory;
        
        // Restore Inventory manually
        player.inventory.clear();
        player.inventory.addAll(data.inventory);
        
        player.specialInventory.clear();
        player.specialInventory.addAll(data.specialInventory);
        
        // Notify Listeners to update UI
        player.inventoryNotifier.value = data.inventory.values.fold(0, (sum, v) => sum + v) + 
                                         data.specialInventory.values.fold(0, (sum, v) => sum + v);
        player.specialInventoryNotifier.value = data.specialInventory.values.fold(0, (sum, v) => sum + v);
        
        // Restore Grid
        gridManager.restoreState(data.maxGeneratedY, data.blocks, data.crystals);
        
        // Restore Player Position
        player.restorePosition(
           data.playerX, 
           data.playerY, 
           Vector2(data.playerFacingX, data.playerFacingY)
        );
        
        // Camera will auto-update in update() loop
        
        print("Game Loaded: Level $currentLevel, Score ${data.score}");
     }
     
     overlays.remove('MainMenu');
     overlays.add('GameHud');
     resumeEngine();
     _setupAutoSave();
  }
  
  void _setupAutoSave() {
     // Listen to critical changes
     player.scoreNotifier.addListener(_scheduleSave);
     player.healthNotifier.addListener(_scheduleSave);
     player.inventoryNotifier.addListener(_scheduleSave);
  }
  
  void _scheduleSave() {
     // Debounce save to avoid disk spam every frame if multiple things change
     if (_saveDebouncer?.isActive ?? false) _saveDebouncer!.cancel();
     _saveDebouncer = async.Timer(const Duration(seconds: 1), () {
        saveGame();
     });
  }

  Future<void> saveGame() async {
     // We do not save if health is 0 (Dead) to prevent death-loop
     if (player.healthNotifier.value <= 0) {
        await saveManager.clearSave(); 
        return; 
     }
     
     final gridManager = world.children.whereType<GridManager>().firstOrNull;
     if (gridManager == null) return;
  
     final data = GameSaveData(
       level: currentLevel, 
       score: player.scoreNotifier.value, 
       health: player.healthNotifier.value, 
       maxInventory: player.maxInventoryTotal, 
       inventory: player.inventory, 
       specialInventory: player.specialInventory,
       // New Fields
       playerX: player.gridX,
       playerY: player.gridY,
       playerFacingX: player.facing.x,
       playerFacingY: player.facing.y,
       maxGeneratedY: gridManager.maxGeneratedY,
       blocks: gridManager.getBlocksData(),
       crystals: gridManager.getCrystalsData(),
     );
     await saveManager.saveGame(data);
  }

  @override
  void update(double dt) {
    super.update(dt);
    // Lock X to center, Follow Player Y
    // Use linear interpolation or direct assignment for Y
    // For now direct assignment to mimic strict follow
    camera.viewfinder.position = Vector2(size.x / 2, player.position.y);
  }

  void showBagFullMessage() {
     overlays.add('BagFull');
     Future.delayed(const Duration(seconds: 1), () {
       overlays.remove('BagFull');
     });
  }

  void onGameOver() async {
    await saveManager.clearSave(); // Death deletes save
    pauseEngine();
    overlays.remove('GameHud');
    overlays.add('GameOver');
  }
  
  void nextLevel() {
    print("Level Complete! Starting Level ${currentLevel + 1}");
    
    // 1. Show Level Transition Overlay (You can customize this)
    overlays.add('LevelComplete'); // Make sure to add this builder
    pauseEngine();
    
    Future.delayed(const Duration(seconds: 2), () {
        currentLevel++;
        overlays.remove('LevelComplete');
        
        final gridManager = world.children.whereType<GridManager>().first;
        gridManager.reset();
        
        player.moveToStart();
        resumeEngine();
        saveGame(); // Save on level start (with fresh grid)
    });
  }

  void restartGame() {
    currentLevel = 1;
    overlays.remove('GameOver');
    overlays.add('GameHud'); // Ensure HUD is back if it was removed
    resumeEngine();
    
    // Reset Grid
    final gridManager = world.children.whereType<GridManager>().firstOrNull;
    if (gridManager != null) {
       gridManager.reset();
    } else {
       print("Warning: GridManager not found in restartGame");
    }
    
    // Reset Player
    player.reset();
    
    // Reset Camera
    camera.stop();
    camera.viewfinder.position = Vector2(size.x / 2, player.position.y);
  }
  void returnToMainMenu() async {
    await saveGame();
    pauseEngine();
    overlays.remove('GameHud');
    // Ensure "Continue" button will be active
    hasSaveData = await saveManager.hasSaveData(); 
    overlays.add('MainMenu');
  }

}
