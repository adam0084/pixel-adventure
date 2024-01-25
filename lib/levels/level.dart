import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/levels/collision_block.dart';
import 'package:pixel_adventure/levels/level_background.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class Level extends World with HasGameRef<PixelAdventure> {
  // late final Player player;

  // Level({required this.player});

  PositionComponent get player => gameRef.player;

  late TiledComponent tiledLevel;
  late LevelBackground levelBackground;

  

  // Add your custom code here
  @override
  FutureOr<void> onLoad() async {
    tiledLevel = await TiledComponent.load("Level02.tmx", Vector2.all(16));
    levelBackground =
        LevelBackground(backgroundName: "Green", levelSize: tiledLevel.size);
    
    add(levelBackground);
    add(tiledLevel);
    _layoutCollisionBlocks();
    _spawnPlayer();

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    // size = size;
    // TODO: implement onGameResize
    super.onGameResize(size);
  }

  void _spawnPlayer() {
    final spawnPointsLayer =
        tiledLevel.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        if (spawnPoint.class_ == "Player") {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.anchor = Anchor.topLeft;
          add(player);
        }
      }
    }
  }

  void _layoutCollisionBlocks() {
    final collisionsLayer =
        tiledLevel.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        add(CollisionBlock(collisionObject: collision));
      }
    }
  }
}
