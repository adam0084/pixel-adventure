import 'dart:async';

import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:pixel_adventure/actors/player.dart';

class Level extends World {
  late TiledComponent level;
  // Add your custom code here
  @override
  FutureOr<void> onLoad() async {
    level = await TiledComponent.load("Level01.tmx", Vector2.all(16));
    add(level);
    final spawnPointsLayer = level.tileMap.getLayer<ObjectGroup>("Spawnpoints");
    for (final spawnPoint in spawnPointsLayer!.objects) {
      switch (spawnPoint.class_) {
        case "Player":
          final player = Player("Mask Dude")
            ..position = Vector2(spawnPoint.x, spawnPoint.y)
            ..anchor = Anchor.topLeft;
          add(player);
          break;
      }
    }
    // add(Player("Mask Dude"));
    return super.onLoad();
  }
}
