import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame_tiled/flame_tiled.dart';

class CollisionBlock extends PositionComponent {
  late final bool isPlatform;

  double get top => position.y;
  double get bottom => position.y + size.y;
  double get left => position.x;
  double get right => position.x + size.x;

  CollisionBlock({required TiledObject collisionObject}) {
    position = Vector2(collisionObject.x, collisionObject.y);
    size = Vector2(collisionObject.width, collisionObject.height);
    isPlatform = collisionObject.class_ == "Platform";
  }

  @override
  FutureOr<void> onLoad() {
    add(RectangleHitbox(
        isSolid: !isPlatform, collisionType: CollisionType.passive));
    // debugMode = true;
    return super.onLoad();
  }
}
