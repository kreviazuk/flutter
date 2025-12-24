import 'dart:math';
import 'package:flame/components.dart';
import '../geo_journey_game.dart';
import '../components/block.dart';
import '../components/crystal.dart';
import '../game_colors.dart';
import '../game_constants.dart';

class GridManager extends Component with HasGameRef<GeoJourneyGame> {
  GridManager({super.key});

  final Random _random = Random();
  int _maxGeneratedY = 0;
  final Map<String, GameBlock> _blocks = {};
  final Map<String, Crystal> _crystals = {};

  @override
  Future<void> onLoad() async {
    // Generate initial world
    _generateRows(1, 30);
  }

  void _generateRows(int startY, int endY) {
    if (startY > rowsPerLevel) return;

    for (int y = startY; y < endY; y++) {
      if (y == rowsPerLevel) {
         // This is the "End of Level" floor.
         // Generate a solid row of special "Bedrock/Gate" blocks.
         for (int x = 0; x < GameConstants.columns; x++) {
             spawnBlock(x, y, isLevelExit: true);
         }
         _maxGeneratedY = y + 1;
         return; 
      }
      
      for (int x = 0; x < GameConstants.columns; x++) {
        spawnGameElement(x, y);
      }
    }
    _maxGeneratedY = endY;
  }

  static const int rowsPerLevel = 50;

  @override
  void update(double dt) {
    // Generate new rows if needed (but handle limit)
    if (gameRef.player.gridY > _maxGeneratedY - 20) {
      if (_maxGeneratedY <= rowsPerLevel) {
         int nextEnd = _maxGeneratedY + 20;
         if (nextEnd > rowsPerLevel + 1) nextEnd = rowsPerLevel + 1; 
         _generateRows(_maxGeneratedY, nextEnd);
      }
    }
    
    // Physics Logic
    _handleGravity(dt);
  }

  // Time accumulator for gravity steps
  double _gravityTimer = 0;
  final double _gravityStep = 0.1; // blocks fall every 0.1s

  void reset() {
    _blocks.clear(); 
    _crystals.clear();
    gameRef.world.children.whereType<GameBlock>().forEach((b) => b.removeFromParent());
    gameRef.world.children.whereType<Crystal>().forEach((c) => c.removeFromParent());
    
    _maxGeneratedY = 0;
    _generateRows(1, 30);
  }

  Set<String> _pendingMatchChecks = {};

  void _handleGravity(double dt) {
    _gravityTimer += dt;
    if (_gravityTimer < _gravityStep) return;
    _gravityTimer = 0;

    bool moved = false;
    _pendingMatchChecks.clear();
    
    // Track processed blocks to avoid handling same group multiple times
    final Set<String> processedInfo = {};

    // 1. Process Blocks (Grouped Physics)
    final List<String> blockKeys = _blocks.keys.toList();
    
    for (final key in blockKeys) {
      if (processedInfo.contains(key)) continue;
      if (!_blocks.containsKey(key)) continue; // might have moved?
      
      final parts = key.split(',');
      final x = int.parse(parts[0]);
      final y = int.parse(parts[1]);
      final block = _blocks[key]!;
      
      // Find entire connected group
      final groupPoints = _findGroup(x, y, block.gameColor, {}); // Local visited for search
      
      // Mark global processed
      for (final p in groupPoints) {
        processedInfo.add('${p.x},${p.y}');
      }
      
      // Check stability of the GROUP
      bool isSupported = false;
      bool hitsPlayer = false;
      
      for (final p in groupPoints) {
        // Check below each block in group
        final targetY = p.y + 1;
        
        // 1. Floor support
        if (targetY >= _maxGeneratedY) {
          isSupported = true;
          break;
        }
        
        // 2. Player interaction (NOT support)
        if (gameRef.player.gridX == p.x && gameRef.player.gridY == targetY) {
          hitsPlayer = true;
          // Player does not support, so continue checking other supports
          continue; 
        }
        
        // 3. Block support (Must be NOT in same group)
        final blockBelow = getBlockAt(p.x, targetY);
        if (blockBelow != null) {
          // Check if it's in the group
          bool inGroup = groupPoints.any((g) => g.x == p.x && g.y == targetY);
          if (!inGroup) {
            isSupported = true;
            break;
          }
        }
        
        // 4. Crystal support
        if (getCrystalAt(p.x, targetY) != null) {
          isSupported = true;
          break;
        }
      }
      
      if (!isSupported) {
        // TELEGRAPHING LOGIC:
        
        bool canFall = false;
        
        // 1. Tick timers for all blocks in group
        for (final p in groupPoints) {
           final b = _blocks['${p.x},${p.y}'];
           if (b != null) {
              b.startShake(dt); // Decrements timer and shakes
              if (b.fallDelay <= 0) canFall = true;
           }
        }
        
        // 2. Decide action
        if (!canFall) {
           // Still shaking, do not move/crush yet.
           continue; 
        }

        if (hitsPlayer) {
           // Group falls onto player -> Damage & Disappear
           gameRef.player.takeDamage(20);
           
           // Clear ALL blocks in the column above the collision point
           // This prevents the "piledriver" effect where remaining blocks fall one by one
           // We take the X from the first block in the falling group
           if (groupPoints.isNotEmpty) {
             final int x = groupPoints.first.x;
             // Remove everything from player's head upwards in this column
             for (int y = gameRef.player.gridY - 1; y >= 0; y--) {
                 if (getBlockAt(x, y) != null) {
                    removeBlockAt(x, y, awardScore: false);
                 } else if (getCrystalAt(x, y) != null) {
                    removeCrystalAt(x, y);
                 } else {
                    // Stop at first gap to avoid clearing floating islands way up?
                    // Or justify clearing everything falling? 
                    // Let's clear contiguous stack only.
                    break;
                 }
             }
           }
        } else {
           // Fall
           // FIX: Capture ALL moved keys (including dragged ones) for match checking
           final movedOldKeys = _moveGroup(groupPoints, 0, 1);
           moved = true;
           
           // Add all new positions to pending match checks
           for (final oldKey in movedOldKeys) {
              final parts = oldKey.split(',');
              final ox = int.parse(parts[0]);
              final oy = int.parse(parts[1]);
              _pendingMatchChecks.add('$ox,${oy+1}'); 
           }
        }
      } else {
         // Supported! Reset timers
         for (final p in groupPoints) {
           final b = _blocks['${p.x},${p.y}'];
           if (b != null) b.resetShake();
         }
      }
    }

    // 2. Process Crystals (Enhanced Physics with delay)
    for (int y = _maxGeneratedY - 1; y >= 0; y--) {
       for (int x = 0; x < GameConstants.columns; x++) {
          final crystal = getCrystalAt(x, y);
          if (crystal == null) continue;

          bool isSupported = false;
          bool hitsPlayer = false;

          final targetY = y + 1;
          if (targetY >= _maxGeneratedY) {
            isSupported = true;
          } else {
            if (gameRef.player.gridX == x && gameRef.player.gridY == targetY) {
              hitsPlayer = true;
            } else if (getBlockAt(x, targetY) != null || getCrystalAt(x, targetY) != null) {
              isSupported = true;
            }
          }

          if (!isSupported) {
            crystal.startShake(dt);
            if (crystal.fallDelay <= 0) {
              if (hitsPlayer) {
                // Hits player: Collect normally NO damage
                if (gameRef.player.collectCrystal(crystal)) {
                  removeCrystalAt(x, y);
                }
              } else {
                // Normal fall
                _moveCrystal(crystal, x, y, x, targetY);
                moved = true;
              }
            }
          } else {
            crystal.resetShake();
          }
       }
    }

    if (moved && _pendingMatchChecks.isNotEmpty) {
       _checkMatches();
    }
  }

  // Returns set of all keys that were moved (original positions)
  Set<String> _moveGroup(List<({int x, int y})> group, int dx, int dy) {
    // We must move in an order that doesn't overwrite ourselves. 
    // For falling (dy=1), move bottom-most first.
    group.sort((a, b) => b.y.compareTo(a.y)); // Descending Y
    
    // We need to track what we move to avoid duplicates/loops if recursion happens (though falling is directional)
    final Set<String> movedKeys = {};
    
    // Primary move
    for (final p in group) {
      final key = '${p.x},${p.y}';
      if (!movedKeys.contains(key)) {
         _moveBlockRecursive(p.x, p.y, dx, dy, movedKeys);
      }
    }
    
    return movedKeys;
  }
  
  void _moveBlockRecursive(int x, int y, int dx, int dy, Set<String> movedKeys) {
     final key = '$x,$y';
     if (movedKeys.contains(key)) return;
     
     // DISTINCTION: Is it a Block or Crystal?
     if (_blocks.containsKey(key)) {
        final block = _blocks[key]!;
        _moveBlock(block, x, y, x + dx, y + dy);
        movedKeys.add(key);
     } else if (_crystals.containsKey(key)) {
        final crystal = _crystals[key]!;
        _moveCrystal(crystal, x, y, x + dx, y + dy);
        movedKeys.add(key);
     } else {
        return; // Nothing here
     }
     
     // Recursive Drag: Check PREVIOUS position's neighbor ABOVE (before move).
     // Who was sitting on me? (x, y - 1)
     final aboveX = x;
     final aboveY = y - 1;
     final aboveKey = '$aboveX,$aboveY';
     
     if (_crystals.containsKey(aboveKey)) {
        // Crystals just fall with us (simple item physics)
        _moveBlockRecursive(aboveX, aboveY, dx, dy, movedKeys);
     } else if (_blocks.containsKey(aboveKey)) {
        final aboveBlock = _blocks[aboveKey]!;
        
        // BRIDGE CHECK:
        // Does this block have any horizontal neighbors of the SAME color?
        // If yes, it might be part of a bridge/structure that should hold it up.
        bool hasBridgeSupport = false;
        
        // Check Left
        final leftKey = '${aboveX - 1},$aboveY';
        if (_blocks.containsKey(leftKey)) {
           if (_blocks[leftKey]!.gameColor == aboveBlock.gameColor) {
              hasBridgeSupport = true;
           }
        }
        
        // Check Right
        final rightKey = '${aboveX + 1},$aboveY';
        if (!hasBridgeSupport && _blocks.containsKey(rightKey)) {
           if (_blocks[rightKey]!.gameColor == aboveBlock.gameColor) {
              hasBridgeSupport = true;
           }
        }
        
        if (!hasBridgeSupport) {
           // It's isolated (vertically stacked maybe, but no horizontal bridge).
           // Drag it down!
           _moveBlockRecursive(aboveX, aboveY, dx, dy, movedKeys);
        }
     }
  }
  
  bool _canFallTo(int x, int y) {
    // Treat ungenerated area as solid ground
    if (y >= _maxGeneratedY) return false;

    // Cannot fall into player
    if (gameRef.player.gridX == x && gameRef.player.gridY == y) return false;
    
    // Cannot fall existing block
    if (getBlockAt(x, y) != null) return false;
    
    // Cannot fall into existing crystal
    if (getCrystalAt(x, y) != null) return false;

    return true;
  }

  void _moveBlock(GameBlock block, int oldX, int oldY, int newX, int newY) {
    _blocks.remove('$oldX,$oldY');
    _blocks['$newX,$newY'] = block;
    
    // Update visual position
    block.position = Vector2(
      newX * GameConstants.blockSize,
      newY * GameConstants.blockSize,
    );
  }
  
  void _moveCrystal(Crystal crystal, int oldX, int oldY, int newX, int newY) {
    _crystals.remove('$oldX,$oldY');
    _crystals['$newX,$newY'] = crystal;
    
    crystal.position = Vector2(
      newX * GameConstants.blockSize,
      newY * GameConstants.blockSize,
    );
  }


  void _checkMatches() {
    // Only check blocks that moved
    final Set<String> visited = {};
    
    // Copy the set to avoid modification during iteration if any
    final toCheck = Set<String>.from(_pendingMatchChecks);
    
    for (final key in toCheck) {
         if (visited.contains(key)) continue;
         
         final parts = key.split(',');
         final x = int.parse(parts[0]);
         final y = int.parse(parts[1]);
         
         final block = getBlockAt(x, y);
         if (block == null) continue;
         
         final group = _findGroup(x, y, block.gameColor, visited);
         
         if (group.length >= 4) {
           // Remove all blocks in group
           // print("Match found! Removing ${group.length} blocks.");
           for (final pos in group) {
             removeBlockAt(pos.x, pos.y);
           }
         }
    }
  }

  List<({int x, int y})> _findGroup(int startX, int startY, GameColor color, Set<String> visited) {
    final List<({int x, int y})> group = [];
    final List<({int x, int y})> queue = [(x: startX, y: startY)];
    
    visited.add('$startX,$startY');
    
    while (queue.isNotEmpty) {
      final current = queue.removeLast();
      group.add(current);
      
      // Check neighbors (Up, Down, Left, Right)
      final neighbors = [
        (x: current.x, y: current.y - 1),
        (x: current.x, y: current.y + 1),
        (x: current.x - 1, y: current.y),
        (x: current.x + 1, y: current.y),
      ];
      
      for (final n in neighbors) {
        final key = '${n.x},${n.y}';
        if (visited.contains(key)) continue;
        
        final neighborBlock = getBlockAt(n.x, n.y);
        if (neighborBlock != null && neighborBlock.gameColor == color) {
          visited.add(key);
          queue.add(n);
        }
      }
    }
    
    return group;
  }

  void spawnGameElement(int x, int y) {
    if (_blocks.containsKey('$x,$y') || _crystals.containsKey('$x,$y')) return;
    
    // Skip player start position
    if (x == GameConstants.columns ~/ 2 && y == 0) return;
    
    // Force solid blocks for the first 5 rows to give a safe start
    if (y < 5) {
       spawnBlock(x, y);
       return;
    }

    // 4% chance for Brown Tough Element (Block or Crystal)
    double toughRoll = _random.nextDouble();
    bool isTough = toughRoll < 0.04;
    GameColor? forcedColor = isTough ? GameColor.brown : null;

    // 10% chance for Crystal, 90% for Block
    if (_random.nextDouble() < 0.1) {
      spawnCrystal(x, y, colorOverride: forcedColor);
    } else {
      spawnBlock(x, y, colorOverride: forcedColor);
    }
  }

  void spawnCrystal(int x, int y, {GameColor? colorOverride}) {
    // Randomly decide crystal type
    double roll = _random.nextDouble();
    CrystalType type = CrystalType.normal;
    
    if (roll < 0.05) {
      type = CrystalType.heart;
    } else if (roll < 0.08) {
      type = CrystalType.verticalDrill;
    } else if (roll < 0.11) {
      type = CrystalType.aoeBlast;
    }

    final color = colorOverride ?? (type == CrystalType.heart 
       ? GameColor.red 
       : GameColor.values[_random.nextInt(GameColor.values.length - 1)]);
       
    final crystal = Crystal(
      gameColor: color,
      type: type,
      position: Vector2(
        x * GameConstants.blockSize,
        y * GameConstants.blockSize,
      ),
      size: Vector2.all(GameConstants.blockSize),
    );
    gameRef.world.add(crystal);
    _crystals['$x,$y'] = crystal;
  }

  void spawnBlock(int x, int y, {bool isLevelExit = false, GameColor? colorOverride}) {
    if (_blocks.containsKey('$x,$y')) return;

    final color = colorOverride ?? (isLevelExit 
       ? GameColor.values[0] // Placeolder color for bedrock
       : GameColor.values[_random.nextInt(GameColor.values.length - 1)]);
       
    final block = GameBlock(
      gameColor: color,
      isLevelExit: isLevelExit,
      position: Vector2(
        x * GameConstants.blockSize,
        y * GameConstants.blockSize,
      ),
      size: Vector2.all(GameConstants.blockSize),
    );
    gameRef.world.add(block);
    _blocks['$x,$y'] = block;
  }

  GameBlock? getBlockAt(int x, int y) {
    return _blocks['$x,$y'];
  }
  
  Crystal? getCrystalAt(int x, int y) {
    return _crystals['$x,$y'];
  }

  void removeBlockAt(int x, int y, {bool awardScore = true}) {
    final block = _blocks['$x,$y'];
    if (block != null) {
      gameRef.world.remove(block);
      _blocks.remove('$x,$y');
      if (awardScore) {
         gameRef.player.scoreNotifier.value++;
      }
    }
  }

  void removeCrystalAt(int x, int y) {
    final crystal = _crystals['$x,$y'];
    if (crystal != null) {
      gameRef.world.remove(crystal);
      _crystals.remove('$x,$y');
    }
  }
  
  void removeAllBlocksOfColor(GameColor color) {
    // Check intersection with viewport
    final viewport = gameRef.camera.visibleWorldRect;
    final keysToRemove = <String>[];
    
    _blocks.forEach((key, block) {
      if (block.gameColor == color) {
        // Simple check: is center of block inside rect?
        if (viewport.contains(block.position.toOffset())) {
           gameRef.world.remove(block);
           keysToRemove.add(key);
           gameRef.player.scoreNotifier.value++;
        }
      }
    });
    
    for (var key in keysToRemove) {
      _blocks.remove(key);
    }
    
    // Trigger physics check immediately to handle floating blocks
    _gravityTimer = _gravityStep; // Force check next frame
  }

  void clearVerticalColumn(int x, int startY, int count) {
    for (int i = 0; i < count; i++) {
      int targetY = startY + i;
      if (targetY >= _maxGeneratedY) break;
      removeBlockAt(x, targetY);
      removeCrystalAt(x, targetY);
    }
  }

  void clearArea(int centerX, int centerY, int radius) {
    for (int y = centerY - radius; y <= centerY + radius; y++) {
      for (int x = centerX - radius; x <= centerX + radius; x++) {
        if (x < 0 || x >= GameConstants.columns) continue;
        if (y < 0 || y >= _maxGeneratedY) continue;
        
        removeBlockAt(x, y);
        removeCrystalAt(x, y);
      }
    }
  }

  void damageElementAt(int x, int y) {
    final block = getBlockAt(x, y);
    if (block != null) {
      if (block.hit()) {
        removeBlockAt(x, y);
        if (block.isLevelExit) {
          gameRef.nextLevel();
        }
      }
      return;
    }

    final crystal = getCrystalAt(x, y);
    if (crystal != null) {
      if (crystal.health > 1) {
         if (crystal.hit()) {
            if (gameRef.player.collectCrystal(crystal)) {
               removeCrystalAt(x, y);
            }
         }
      }
    }
  }
}
