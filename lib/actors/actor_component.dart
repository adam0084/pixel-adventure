import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/player_move_behavior.dart';
import 'package:pixel_adventure/mixins/measurable_block.dart';

class ActorComponent extends PositionComponent
    with KeyboardHandler, CollisionCallbacks, MeasurableBlock {
  bool isGrounded = false;
  Vector2 velocity = Vector2.zero();
  PlayerMovebehavior previousMoveBehavior = PlayerMovebehavior();
}
