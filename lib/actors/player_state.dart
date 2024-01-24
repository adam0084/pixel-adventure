import 'package:flame/components.dart';

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

PlayerState playerStateFromVelocity(Vector2 velocity) {
  if (velocity.y < 0) {
    return PlayerState.jump;
  } else if (velocity.y > 0) {
    return PlayerState.fall;
  } else if (velocity.x != 0) {
    return PlayerState.run;
  } else {
    return PlayerState.idle;
  }
}
