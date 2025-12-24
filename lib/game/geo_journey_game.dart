import 'package:flame/game.dart';
import 'package:flame/components.dart';
import 'package:flutter/material.dart';
import 'components/player.dart';
import 'managers/grid_manager.dart';
import 'game_constants.dart';

class GeoJourneyGame extends FlameGame {
  final Player player = Player(
    position: Vector2(
      GameConstants.columns * GameConstants.blockSize / 2,
      0,
    ),
  );
  
  int currentLevel = 1;

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
    
    // Center camera X on the world/screen center
    // We manually update camera in the update loop to lock X axis
    camera.viewfinder.position = Vector2(size.x / 2, 0);
    camera.stop(); 
    
    // FPS Counter
    add(FpsTextComponent(position: Vector2(10, 50), scale: Vector2.all(1.2)));
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

  void onGameOver() {
    pauseEngine();
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
        
        final gridManager = findByKeyName('GridManager') as GridManager;
        gridManager.reset();
        
        player.moveToStart();
        resumeEngine();
    });
  }

  void restartGame() {
    currentLevel = 1;
    overlays.remove('GameOver');
    resumeEngine();
    
    // Reset Grid
    final gridManager = findByKeyName('GridManager') as GridManager;
    gridManager.reset();
    
    // Reset Player
    player.reset();
    
    // Reset Camera
    camera.stop();
    camera.viewfinder.position = Vector2(size.x / 2, player.position.y);
  }
}
