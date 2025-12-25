import 'package:flame/components.dart';
import 'package:flame/effects.dart';
import 'package:flutter/material.dart';
import '../game_constants.dart';
import '../geo_journey_game.dart';
import '../managers/grid_manager.dart';
import '../game_colors.dart';
import 'crystal.dart';

enum PlayerState { idle, moving, falling, digging }

class Player extends PositionComponent with HasGameRef<GeoJourneyGame> {
  PlayerState playerState = PlayerState.idle;
  int gridX = 0;
  int gridY = 0;
  
  // Inventory
  int maxInventoryTotal = 8; // Initial capacity
  final Map<GameColor, int> inventory = {
    for (var color in GameColor.values) color: 0
  };
  final Map<CrystalType, int> specialInventory = {
    CrystalType.verticalDrill: 0,
    CrystalType.aoeBlast: 0,
  };
  final ValueNotifier<int> inventoryNotifier = ValueNotifier(0);
  final ValueNotifier<int> specialInventoryNotifier = ValueNotifier(0);
  
  // Health
  final ValueNotifier<int> healthNotifier = ValueNotifier(100);
  
  // Score
  final ValueNotifier<int> scoreNotifier = ValueNotifier(0);

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

  // State
  Vector2 facing = Vector2(0, 1); // Default facing DOWN
  
  // Visual Components Reference
  late PositionComponent _visualContainer;
  late PositionComponent _sword; // Changed to PositionComponent for compound graphics

  @override
  void onLoad() {
    super.onLoad();
    
    // Listen for score updates to upgrade bag
    scoreNotifier.addListener(_checkBagUpgrade);
    
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

    // --- VISUALS ---
    _visualContainer = PositionComponent(size: size, anchor: Anchor.center, position: size / 2);
    add(_visualContainer);
    
    // 1. Shadow (Oval at feet)
    _visualContainer.add(CircleComponent(
        radius: size.x * 0.35,
        position: Vector2(size.x * 0.5, size.y * 0.85),
        anchor: Anchor.center,
        paint: Paint()..color = Colors.black.withOpacity(0.3),
        scale: Vector2(1.2, 0.4), // Flattened
    ));


    // 2. SWORD Container (Pivot at center of player to rotate around)
    // We want the sword to rotate around the player's center, but be drawn slightly offset.
    _sword = PositionComponent(
      size: Vector2.zero(),
      position: size / 2, 
      anchor: Anchor.center,
    );
    _visualContainer.add(_sword);
    
    // Draw Sword Graphics inside the container (Offset from center)
    // Blade
    _sword.add(RectangleComponent(
       size: Vector2(size.x * 0.1, size.y * 0.6),
       position: Vector2(0, size.y * 0.3), // Stick out
       anchor: Anchor.topCenter,
       paint: Paint()..color = Colors.grey.shade300,
    ));
    // Hilt/Guard
    _sword.add(RectangleComponent(
       size: Vector2(size.x * 0.25, size.y * 0.08),
       position: Vector2(0, size.y * 0.3),
       anchor: Anchor.bottomCenter,
       paint: Paint()..color = Colors.amber.shade700,
    ));
    // Grip
    _sword.add(RectangleComponent(
       size: Vector2(size.x * 0.08, size.y * 0.15),
       position: Vector2(0, size.y * 0.22), // Further back/in hand
       anchor: Anchor.bottomCenter,
       paint: Paint()..color = Colors.brown.shade800,
    ));


    // 3. Body (Cyan Tunic)
    _visualContainer.add(RectangleComponent(
        size: Vector2(size.x * 0.5, size.y * 0.35),
        position: Vector2(size.x * 0.5, size.y * 0.75),
        anchor: Anchor.bottomCenter,
        paint: Paint()..color = Colors.cyan.shade600,
    ));
    
    // 4. Head (Skin Color)
    _visualContainer.add(CircleComponent(
        radius: size.x * 0.3,
        position: Vector2(size.x * 0.5, size.y * 0.35),
        anchor: Anchor.center,
        paint: Paint()..color = const Color(0xFFFCD5B5), // Peach/Skin
    ));
    
    // 5. Hat (Blue Cone + Brim)
    final hatColor = Colors.blue.shade900;
    // Brim
    _visualContainer.add(CircleComponent(
        radius: size.x * 0.42,
        position: Vector2(size.x * 0.5, size.y * 0.32),
        anchor: Anchor.center,
        paint: Paint()..color = hatColor,
        scale: Vector2(1, 0.3), // Flattened brim
    ));
    // Cone
    _visualContainer.add(
       PolygonComponent(
         [
            Vector2(size.x * 0.5, -size.y * 0.2), // Top Tip
            Vector2(size.x * 0.75, size.y * 0.35), 
            Vector2(size.x * 0.25, size.y * 0.35),
         ],
         paint: Paint()..color = hatColor,
       )
    );
    
    // 6. Eyes
     _visualContainer.add(CircleComponent(
        radius: size.x * 0.04,
        position: Vector2(size.x * 0.4, size.y * 0.38),
        paint: Paint()..color = Colors.black,
     ));
      _visualContainer.add(CircleComponent(
        radius: size.x * 0.04,
        position: Vector2(size.x * 0.6, size.y * 0.38),
        paint: Paint()..color = Colors.black,
     ));
     
    _updateSwordVisual();
  }
  
  void _updateSwordVisual() {
      // Directions: Up (0, -1), Down (0, 1), Left (-1, 0), Right (1, 0)
      
      double angle = 0;
      if (facing.y == 1) angle = 0; // Down (Normal)
      else if (facing.y == -1) angle = 3.14159; // Up (180 deg)
      else if (facing.x == 1) angle = -1.5708; // Right (-90 deg)
      else if (facing.x == -1) angle = 1.5708; // Left (90 deg)
      
      // Since sword pivots at center (0,0 of container)
      // Visuals are offset by y * 0.3 to stick out.
      // Rotation:
      // 0 (Down) -> Sticks out Down.
      // 180 (Up) -> Sticks out Up.
      // -90 (Right) -> Sticks out Right.
      // 90 (Left) -> Sticks out Left.
      
      _sword.angle = angle;
      
      // We don't need manual positioning anymore because the container rotates!
      // But we might want to offset the container slightly so it looks like it's in a hand.
      // The hand is approx at center/slightly side.
      // Let's keep it simple: Rotating around center is robust.
      _sword.position = size / 2; 
  }

  // New Input Handler
  void handleInput(Vector2 direction) {
     if (healthNotifier.value <= 0) return;
     if (_isMoving) return; // Wait for move to finish
     
     // Always update facing immediately for responsiveness
     facing = direction;
     _updateSwordVisual();
     
     if (_gridManager == null) return;

     // 1. Vertical Logic
     if (direction.y != 0) {
        // UP: Cannot move up, but can dig/attack up
        if (direction.y < 0) {
           final blockAbove = _gridManager!.getBlockAt(gridX, gridY - 1);
           final crystalAbove = _gridManager!.getCrystalAt(gridX, gridY - 1);
           
           if (blockAbove != null || (crystalAbove != null && crystalAbove.health > 1)) {
              attack(); // Breaks block above
           }
           return; // Cannot move up
        }
        
        // DOWN: Check if blocked. If blocked, Attack. If not, Move.
        if (direction.y > 0) {
           int tx = gridX;
           int ty = gridY + 1;
           final targetBlock = _gridManager!.getBlockAt(tx, ty);
           final targetCrystal = _gridManager!.getCrystalAt(tx, ty);
           
           if (targetBlock != null || (targetCrystal != null && targetCrystal.health > 1)) {
              attack();
              return;
           }
        }
     }
     
     // 2. Horizontal Logic (Left / Right)
     if (direction.y == 0) {
        int tx = gridX + direction.x.toInt();
        int ty = gridY + direction.y.toInt();
        final targetBlock = _gridManager!.getBlockAt(tx, ty);
        final targetCrystal = _gridManager!.getCrystalAt(tx, ty);

        // Check Block in front
        if (targetBlock != null || (targetCrystal != null && targetCrystal.health > 1)) {
           // We are blocked horizontally.
           // Optional: Check auto-climb if it was a block?
           // Original logic had auto-climb. Let's preserve it for blocks ONLY.
           
           if (targetBlock != null) {
              final blockAboveTarget = _gridManager!.getBlockAt(tx, ty - 1);
              final blockAbovePlayer = _gridManager!.getBlockAt(gridX, gridY - 1);
              final crystalAboveTarget = _gridManager!.getCrystalAt(tx, ty - 1);
              
              if (blockAboveTarget == null && blockAbovePlayer == null && crystalAboveTarget == null) {
                 // Path clear -> Auto Climb (unless it's a queued move?)
                 // Actually auto-climb logic is handled in `_moveQueue`.
                 // We just queue the direction, and `_performLogicalMove` handles climb?
                 // Wait, original logic checked here.
                 _moveQueue.add(direction); 
                 return;
              }
           }
           
           // If no climb, Attack!
           attack();
           return; 
        }
     }
     
     // Queue the move (if not blocked)
     _moveQueue.add(direction);
  }
  
  void attack() {
     if (healthNotifier.value <= 0) return;
     if (_isMoving) return;
     
     // Target coordinates
     int tx = gridX + facing.x.toInt();
     int ty = gridY + facing.y.toInt();
     
     // Attack Animation (Sword Poke)
     _sword.add(
       MoveEffect.by(
         facing * 10, 
         EffectController(duration: 0.1, reverseDuration: 0.1)
       )
     );
     
     // Logic
     _gridManager?.damageElementAt(tx, ty);
     takeDamage(1); 
  }
  
  // Public API to request a move (Legacy/Code compat, but handleInput is main entry)
  void move(Vector2 delta) {
      handleInput(delta);
  }
  
  @override
  void update(double dt) {
    super.update(dt); // Keep existing update logic forLERP
    // ... rest of update logic from original file ...
    // Need to preserve checks for death etc.
    // Since I'm replacing a chunk, I must ensure I copy relevant parts back or targeting is precise.
    
    // NOTE: The user instruction was big, so I am replacing `onLoad` through `_startVisualMovement`.
    // I need to paste back the `update` implementation carefully.
    
    if (_gridManager == null) {
      final managers = gameRef.world.children.whereType<GridManager>();
      if (managers.isNotEmpty) _gridManager = managers.first;
    }
    
    // Check for death
    if (healthNotifier.value <= 0) return;

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
        
        // Deduct health on step completion? No, health only on eating blocks?
        // Wait, did we change health logic? 
        // "Health is only consumed when 'eating' (destroying) blocks, not when walking or climbing."
        // With manual attack, moving NEVER destroys blocks. So moving NEVER consumes health.
        // I will remove the health deduction here regardless.
      } else {
        position = _startPosition + (_targetPosition - _startPosition) * _currentLerpTime;
      }
    } else {
      // Gravity check (only if not moving)
       _checkGravity();
    }
  }

  bool collectCrystal(Crystal crystal) {
    if (crystal.type == CrystalType.heart) {
       // Heal Player
       healthNotifier.value = (healthNotifier.value + 20).clamp(0, 100);
       print("Healed +20! Health: ${healthNotifier.value}");
       
       // Add visual effect for healing to visible parts
       for (final child in _visualContainer.children) {
           if (child is ShapeComponent) {
               child.add(
                  ColorEffect(
                    Colors.green,
                    EffectController(duration: 0.5, alternate: true, repeatCount: 1),
                    opacityTo: 0.5,
                  )
               );
           }
       }
       return true; 
    }

    if (crystal.type == CrystalType.verticalDrill || crystal.type == CrystalType.aoeBlast) {
       if (inventoryNotifier.value >= maxInventoryTotal) {
          gameRef.showBagFullMessage();
          return true; // Destroy item
       }
       specialInventory[crystal.type] = (specialInventory[crystal.type] ?? 0) + 1;
       inventoryNotifier.value++; 
       specialInventoryNotifier.value++;
       print("Collected Special Item: ${crystal.type.name}!");
       return true;
    }
  
    if (inventoryNotifier.value >= maxInventoryTotal) {
      gameRef.showBagFullMessage();
      // Logic: Destroy crystal even if bag full
      return true; // Return true to signal "collected/destroyed"
    }
    
    inventory[crystal.gameColor] = inventory[crystal.gameColor]! + 1;
    inventoryNotifier.value++; // Trigger update
    print("Collected ${crystal.gameColor.name}! Total: ${inventory[crystal.gameColor]}");
    return true;
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
       // We only reach here if handleInput decided we can CLIMB
       // (If we were supposed to Attack, handleInput wouldn't have called this)
       
       bool climbed = false;
       
       // Attempt CLIMB if moving horizontally
        if (delta.y == 0 && delta.x != 0) {
           // Check headspace before climbing
           final blockAbovePlayer = _gridManager!.getBlockAt(gridX, gridY - 1);
           if (blockAbovePlayer != null) return false;

           // Check cell ABOVE the target block
           final int aboveY = newY - 1;
           if (aboveY >= 0) {
              final blockAbove = _gridManager!.getBlockAt(newX, aboveY);
              final crystalAbove = _gridManager!.getCrystalAt(newX, aboveY);
              
              if (blockAbove == null) {
                  // Space is free of blocks. Check for crystal.
                  if (crystalAbove != null) {
                      if (crystalAbove.health > 1) {
                         // Tough crystal blocks climbing
                         return false; 
                      }
                      // Attempt to collect crystal to clear the path
                      bool collected = collectCrystal(crystalAbove);
                      if (collected) {
                           _gridManager!.removeCrystalAt(newX, aboveY);
                           gridX = newX;
                           gridY = aboveY;
                           climbed = true;
                      } 
                      // If bag full, climb fails -> returns false at end
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
           // Blocked (Climb failed or vertical move into block)
           return false;
       }
       
       return true;
     } else {
       // Check Crystal
        final crystal = _gridManager!.getCrystalAt(newX, newY);
        if (crystal != null) {
          if (crystal.health > 1) return false;
          bool collected = collectCrystal(crystal);
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
    specialInventory.updateAll((key, value) => 0);
    inventoryNotifier.value = 0;
    specialInventoryNotifier.value = 0;
    maxInventoryTotal = 8; // Reset capacity
    
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
      inventoryNotifier.value--;
      _gridManager?.removeAllBlocksOfColor(color);
    }
  }

  void useSpecialCrystal(CrystalType type) {
    if ((specialInventory[type] ?? 0) > 0) {
      specialInventory[type] = specialInventory[type]! - 1;
      inventoryNotifier.value--;
      specialInventoryNotifier.value--;

      if (type == CrystalType.verticalDrill) {
        _gridManager?.clearVerticalColumn(gridX, gridY + 1, 20);
      } else if (type == CrystalType.aoeBlast) {
        _gridManager?.clearArea(gridX, gridY, 2);
      }
    }
  }

  void debugCheat() {
    // Add 1 of every color
    for (var color in GameColor.values) {
       inventory[color] = (inventory[color] ?? 0) + 1;
    }
    // Add specials
    specialInventory[CrystalType.verticalDrill] = (specialInventory[CrystalType.verticalDrill] ?? 0) + 1;
    specialInventory[CrystalType.aoeBlast] = (specialInventory[CrystalType.aoeBlast] ?? 0) + 1;
    
    // Recalculate totals for consistency
    int specialCount = specialInventory.values.fold(0, (sum, c) => sum + c);
    int normalCount = inventory.values.fold(0, (sum, c) => sum + c);
    
    specialInventoryNotifier.value = specialCount;
    inventoryNotifier.value = specialCount + normalCount;
    
    print("Debug Cheat Activated: Inventory Filled!");
  }

  void _checkBagUpgrade() {
      final score = scoreNotifier.value;
      int newMax = 8;
      
      // Upgrade Milestones
      // Upgrade Milestones (New Logic)
      if (score >= 12000) newMax = 20;
      else if (score >= 10000) newMax = 18;
      else if (score >= 7500) newMax = 16;
      else if (score >= 5000) newMax = 14;
      else if (score >= 3000) newMax = 12;
      else if (score >= 1500) newMax = 10;
      
      if (newMax > maxInventoryTotal) {
          maxInventoryTotal = newMax;
          print("Bag Upgraded! New Capacity: $maxInventoryTotal");
          
          // Show Upgrade Visual (Text)
          final text = TextComponent(
            text: 'BAG UPGRADED!\nCapacity: $maxInventoryTotal',
            textRenderer: TextPaint(
              style: const TextStyle(
                color: Color(0xFFFFD700), // Gold
                fontSize: 32,
                fontWeight: FontWeight.bold,
                shadows: [Shadow(blurRadius: 4, color: Colors.black, offset: Offset(2,2))],
              ),
            ),
            anchor: Anchor.center,
            position: gameRef.size / 2, 
            priority: 100,
          );
          
          gameRef.camera.viewport.add(text); // Add to viewport so it stays on screen
          
          // Effect on Player
          _playUpgradeEffect();
          
          Future.delayed(const Duration(seconds: 3), () {
             text.removeFromParent();
          });
      }
  }

  void _playUpgradeEffect() {
     // Flash Gold
      final body = children.whereType<CircleComponent>().firstOrNull;
      if (body != null) {
        body.add(
          ColorEffect(
            Colors.yellow,
            EffectController(
              duration: 0.5,
              reverseDuration: 0.5,
              repeatCount: 2,
            ),
            opacityTo: 0.8,
          )
        );
      }
  }
  
  void restorePosition(int x, int y, Vector2 face) {
      gridX = x;
      gridY = y;
      facing = face;
      position = _getPixelPosition(gridX, gridY);
      _targetPosition = position.clone();
      _isMoving = false;
      _moveQueue.clear();
      _updateSwordVisual();
  }

  Vector2 _getPixelPosition(int x, int y) {
    return Vector2(
      x * GameConstants.blockSize + GameConstants.blockSize / 2, // Center of tile
      y * GameConstants.blockSize + GameConstants.blockSize / 2, // Center of tile
    );
  }
  
  void _startVisualMovement() {
      _startPosition = position.clone();
      _targetPosition = _getPixelPosition(gridX, gridY);
      _isMoving = true;
      _currentLerpTime = 0;
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
       if (crystalBelow.health > 1) return; // Supported by tough crystal
       // Try to collect
       bool collected = collectCrystal(crystalBelow);
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
}
