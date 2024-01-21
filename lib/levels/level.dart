import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/collision_block.dart';

class Level extends World {
  late final Player player;

  Level({required this.player});

  late TiledComponent level;
  // Add your custom code here
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("Level02.tmx", Vector2.all(16));
    add(level);
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    if (spawnPointsLayer != null) {
      for (final spawnPoint in spawnPointsLayer.objects) {
        if (spawnPoint.class_ == "Player") {
          player.position = Vector2(spawnPoint.x, spawnPoint.y);
          player.anchor = Anchor.topLeft;
          add(player);
        }
      }
    }

    final collisionsLayer = level.tileMap.getLayer<ObjectGroup>("Collisions");
    if (collisionsLayer != null) {
      for (final collision in collisionsLayer.objects) {
        add(CollisionBlock(collisionObject: collision));
      }
    }
    // add(Player("Mask Dude"));
    return super.onLoad();
  }
}
