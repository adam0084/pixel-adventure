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

  @override
  String toString() {
    // TODO: implement toString
    return 'PlayerMoveBehavior: position: $position, center: $center, velocity: $velocity';
  }
}
