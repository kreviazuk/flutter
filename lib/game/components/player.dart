import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game_constants.dart';
import '../geo_journey_game.dart';
import '../managers/grid_manager.dart';
import '../game_colors.dart';

enum PlayerState { idle, moving, falling, digging }

class Player extends PositionComponent with HasGameRef<GeoJourneyGame> {
  PlayerState playerState = PlayerState.idle;
  int gridX = 0;
  int gridY = 0;
  
  // Inventory
  static const int maxInventoryTotal = 20;
  final Map<GameColor, int> inventory = {
    for (var color in GameColor.values) color: 0
  };
  final ValueNotifier<int> inventoryNotifier = ValueNotifier(0);
  
  // Health
  final ValueNotifier<int> healthNotifier = ValueNotifier(100);

  // Movement smoothing
  final double moveSpeed = 5.0; // grid cells per second
  bool _isMoving = false;
  double _currentLerpTime = 0.0;
  Vector2 _startPosition = Vector2.zero();
  Vector2 _targetPosition = Vector2.zero();
  final List<Vector2> _moveQueue = [];
  bool _lastMoveDug = false;

  GridManager? _gridManager;

  Player({required Vector2 position}) : super(position: position, size: Vector2.all(GameConstants.blockSize * 0.8));

  @override
  void onLoad() {
    super.onLoad();
    
    // Force player to be exactly in the center column
    gridX = GameConstants.columns ~/ 2;
    gridY = 0; // Start at top
    
    // Re-calculate position based on grid coordinates
    position = _getPixelPosition(gridX, gridY);
    
    size = Vector2.all(GameConstants.blockSize * 0.8);
    anchor = Anchor.center;
    
    // Initial position
    _targetPosition = position.clone();
    
    _gridManager = gameRef.findByKeyName('GridManager') as GridManager?;

    // Visuals
    add(CircleComponent(
      radius: size.x / 2,
      paint: Paint()..color = Colors.orangeAccent,
    ));
    add(CircleComponent(
      radius: size.x * 0.1,
      position: Vector2(size.x * 0.3, size.y * 0.3),
      paint: Paint()..color = Colors.black,
      anchor: Anchor.center,
    ));
    add(CircleComponent(
      radius: size.x * 0.1,
      position: Vector2(size.x * 0.7, size.y * 0.3),
      paint: Paint()..color = Colors.black,
      anchor: Anchor.center,
    ));
  }

  @override
  void update(double dt) {
    super.update(dt);
    if (_gridManager == null) {
      final managers = gameRef.world.children.whereType<GridManager>();
      if (managers.isNotEmpty) _gridManager = managers.first;
    }
    
    // Check for death
    if (healthNotifier.value <= 0) {
      return;
    }

    // Process Move Queue
    if (!_isMoving && _moveQueue.isNotEmpty) {
      final direction = _moveQueue.removeAt(0);
      bool moved = _performLogicalMove(direction);
      if (moved) {
         _startVisualMovement();
      }
    }
    
    if (_isMoving) {
      _currentLerpTime += dt * moveSpeed;
      if (_currentLerpTime >= 1.0) {
        _isMoving = false;
        _currentLerpTime = 1.0;
        position = _targetPosition;
        
        // Deduct health on step completion
        if (healthNotifier.value > 0 && _lastMoveDug) {
           takeDamage(1); 
        }
      } else {
        position = _startPosition + (_targetPosition - _startPosition) * _currentLerpTime;
      }
    } else {
      // Gravity check (only if not moving)
       _checkGravity();
    }
  }
  
  void _checkGravity() {
    if (_gridManager == null) return;
    
    final int nextY = gridY + 1;
    
    // Check block below
    final blockBelow = _gridManager!.getBlockAt(gridX, nextY);
    if (blockBelow != null) return; // Supported by block

    // Check crystal below
    final crystalBelow = _gridManager!.getCrystalAt(gridX, nextY);
    if (crystalBelow != null) {
       // Try to collect
       bool collected = collectCrystal(crystalBelow.gameColor, isHeart: crystalBelow.isHeart);
       if (collected) {
          _gridManager!.removeCrystalAt(gridX, nextY);
       } else {
          // Cannot collect (full bag), so treating as solid support
          return;
       }
    }

    if (gridY < 1000) { 
        // Fall down
        gridY++;
        _lastMoveDug = false; // Falling is not digging
        _startVisualMovement();
    }
  }

  // Public API to request a move
  void move(Vector2 delta) {
    if (healthNotifier.value <= 0) return;
    
    // Prevent moving UP
    if (delta.y < 0) return;

    if (_gridManager == null) return;
    
    // Just add to queue. Logic happens in update().
    _moveQueue.add(delta);
  }
  
  // Returns true if logic resulted in a position change that needs animation
  bool _performLogicalMove(Vector2 delta) {
     _lastMoveDug = false;
     int newX = gridX + delta.x.toInt();
     int newY = gridY + delta.y.toInt();

     if (newX < 0 || newX >= GameConstants.columns) return false;
     if (newY < 0) return false;

     // Check Block
     final block = _gridManager!.getBlockAt(newX, newY);
     if (block != null) {
       bool climbed = false;
       
       // Attempt CLIMB if moving horizontally
       if (delta.y == 0 && delta.x != 0) {
          // Check cell ABOVE the target block
          final int aboveY = newY - 1;
          if (aboveY >= 0) {
              final blockAbove = _gridManager!.getBlockAt(newX, aboveY);
              final crystalAbove = _gridManager!.getCrystalAt(newX, aboveY);
              
              if (blockAbove == null) {
                  // Space is free of blocks. Check for crystal.
                  if (crystalAbove != null) {
                      // Attempt to collect crystal to clear the path
                      bool collected = collectCrystal(crystalAbove.gameColor, isHeart: crystalAbove.isHeart);
                      if (!collected) {
                          // Bag full, cannot climb
                          climbed = false;
                      } else {
                          // Collected! Remove crystal and climb.
                          _gridManager!.removeCrystalAt(newX, aboveY);
                          gridX = newX;
                          gridY = aboveY;
                          climbed = true;
                      }
                  } else {
                      // Space is completely free
                      gridX = newX;
                      gridY = aboveY;
                      climbed = true;
                  }
              }
          }
       }

       if (!climbed) {
           // If we couldn't climb, we Dig/Destroy (Standard behavior)
           
           if (block.isLevelExit) {
              // DIGGING BEDROCK TRIGGERS NEXT LEVEL
              gameRef.nextLevel();
              return true; // Move completes (level resets anyway)
           }
       
           _gridManager!.removeBlockAt(newX, newY);
           _lastMoveDug = true;
           gridX = newX;
           gridY = newY;
       }
       
       return true;
     } else {
       // Check Crystal
       final crystal = _gridManager!.getCrystalAt(newX, newY);
       if (crystal != null) {
         bool collected = collectCrystal(crystal.gameColor, isHeart: crystal.isHeart);
         if (collected) {
            _gridManager!.removeCrystalAt(newX, newY);
         } else {
           // Bag full - block movement
           return false; 
         }
       }
       gridX = newX;
       gridY = newY;
       return true;
     }
  }
  
  void _startVisualMovement() {
      _startPosition = position.clone();
      _targetPosition = _getPixelPosition(gridX, gridY);
      _isMoving = true;
      _currentLerpTime = 0;
  }

  bool collectCrystal(GameColor color, {bool isHeart = false}) {
    if (isHeart) {
       // Heal Player
       healthNotifier.value = (healthNotifier.value + 20).clamp(0, 100);
       print("Healed +20! Health: ${healthNotifier.value}");
       
       // Add visual effect for healing to the body
       final body = children.whereType<CircleComponent>().firstOrNull;
       if (body != null) {
           body.add(
              ColorEffect(
                Colors.green,
                EffectController(duration: 0.5, alternate: true, repeatCount: 1),
              )
           );
       }
       return true; // Always collected
    }
  
    if (inventory[color]! >= 5) {
      gameRef.showBagFullMessage();
      return false; // Bag full
    }
    
    inventory[color] = inventory[color]! + 1;
    inventoryNotifier.value++; // Trigger update
    print("Collected ${color.name}! Total: ${inventory[color]}");
    return true;
  }
  
  void takeDamage(int amount) {
    if (amount <= 0) return;
    
    healthNotifier.value = (healthNotifier.value - amount).clamp(0, 100);
    
    // Play "Get Hit" Animation (Squash & Flash)
    _playHitAnimation();

    if (healthNotifier.value <= 0) {
      die();
    }
  }

  void _playHitAnimation() {
    // 1. Squash Effect (Flatten vertically, expand horizontally)
    // Scale to (x: 1.5, y: 0.5) quickly, then bounce back
    add(
      ScaleEffect.to(
        Vector2(1.5, 0.5), 
        EffectController(
          duration: 0.1, 
          reverseDuration: 0.1,
          curve: Curves.easeOut,
        ),
      ),
    );
    
    // 2. Color Flash (Tint Red)
    // We apply this to the main circle body (first child)
    final body = children.whereType<CircleComponent>().firstOrNull;
    if (body != null) {
      body.add(
        ColorEffect(
          Colors.red,
          EffectController(
            duration: 0.2,
            reverseDuration: 0.2,
          ),
          opacityTo: 0.8,
        ),
      );
    }
    
    // 3. Shake Position (Jitter)
    add(
      MoveEffect.by(
        Vector2(5, 0),
        EffectController(
          duration: 0.05,
          reverseDuration: 0.05,
          repeatCount: 3,
          alternate: true,
        ),
      ),
    );
  }

  void die() {
     print("Player Died!");
     // Death animation could be spinning and shrinking
     add(
       ScaleEffect.to(
         Vector2.zero(),
         EffectController(duration: 0.5, curve: Curves.easeInBack),
         onComplete: () => gameRef.onGameOver(),
       )
     );
     add(
       RotateEffect.by(
         6.28, // 360 degrees
         EffectController(duration: 0.5),
       )
     );
  }
  
  void moveToStart() {
    gridX = GameConstants.columns ~/ 2;
    gridY = 0;
    position = _getPixelPosition(gridX, gridY);
    _isMoving = false;
    _moveQueue.clear();
    _targetPosition = position.clone();
  }

  void reset() {
    healthNotifier.value = 100;
    inventory.updateAll((key, value) => 0);
    inventoryNotifier.value++;
    
    // Reset Physics State
    gridX = GameConstants.columns ~/ 2;
    gridY = 0;
    position = _getPixelPosition(gridX, gridY);
    _isMoving = false;
    _moveQueue.clear();
    _targetPosition = position.clone();
    
    // Reset Visuals (from Death Animation)
    scale = Vector2.all(1.0);
    angle = 0;
    
    // Remove all temporary effects
    removeAll(children.whereType<Effect>());
    
    // Also reset children color effects if any
    for (final child in children) {
       child.removeAll(child.children.whereType<Effect>());
    }
  }
  
  void useCrystal(GameColor color) {
    if ((inventory[color] ?? 0) > 0) {
      inventory[color] = inventory[color]! - 1;
      inventoryNotifier.value++;
      _gridManager?.removeAllBlocksOfColor(color);
    }
  }

  Vector2 _getPixelPosition(int x, int y) {
    return Vector2(
      x * GameConstants.blockSize + GameConstants.blockSize / 2, // Center of tile
      y * GameConstants.blockSize + GameConstants.blockSize / 2, // Center of tile
    );
  }
}
