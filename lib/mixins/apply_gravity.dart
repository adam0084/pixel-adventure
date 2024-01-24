import 'package:flame/components.dart';
import 'package:pixel_adventure/constants.dart';

Vector2 applyGravity(Vector2 velocity) {
  return  Vector2(velocity.x, velocity.y + gravity);
}
