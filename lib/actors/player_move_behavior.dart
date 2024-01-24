import 'package:flame/components.dart';

class PlayerMovebehavior {
  final Vector2 position;
  final Vector2 center;
  final Vector2 velocity;

  PlayerMovebehavior({
    position,
    center,
    velocity,
  })  : position = position ?? Vector2.zero(),
        center = center ?? Vector2.zero(),
        velocity = velocity ?? Vector2.zero();
}
