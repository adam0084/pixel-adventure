import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/levels/collision_block.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;
const double gravity = 50;

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

enum PlayerDirection { left, right, none }

enum PrimaryDirection { up, down, left, right, none }

PlayerDirection resolvePlayerDirection(
    PlayerDirection keyBoardDirection, PlayerDirection joystickDirection) {
  PlayerDirection direction = PlayerDirection.none;
  if (keyBoardDirection != PlayerDirection.none) {
    direction = keyBoardDirection;
  } else if (joystickDirection != PlayerDirection.none) {
    direction = joystickDirection;
  }
  return direction;
}

PrimaryDirection getXDirectionFromVelocity(Vector2 velocity) {
  PrimaryDirection direction = PrimaryDirection.none;
  if (velocity.x > 0) {
    direction = PrimaryDirection.right;
  } else if (velocity.x < 0) {
    direction = PrimaryDirection.left;
  }
  return direction;
}

PrimaryDirection getYDirectionFromVelocity(Vector2 velocity) {
  PrimaryDirection direction = PrimaryDirection.none;
  if (velocity.y > 0) {
    direction = PrimaryDirection.down;
  } else if (velocity.y < 0) {
    direction = PrimaryDirection.up;
  }
  return direction;
}

PrimaryDirection getPrimaryDirectionFromVelocity(Vector2 velocity) {
  PrimaryDirection direction = PrimaryDirection.none;
  if (velocity.x.abs() > velocity.y.abs()) {
    direction = getXDirectionFromVelocity(velocity);
  } else {
    direction = getYDirectionFromVelocity(velocity);
  }

  return direction;
}

bool isVerticalDirection(PrimaryDirection direction) {
  return direction == PrimaryDirection.up || direction == PrimaryDirection.down;
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  final String characterName;

  PlayerDirection direction = PlayerDirection.none;
  PlayerDirection keyDirection = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  JoystickComponent joystick;

  Player({required this.characterName, required this.joystick});

  bool isFacingRight = true;

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    add(RectangleHitbox());
    debugMode = true;
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    super.update(dt);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    final isLeftKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
            keysPressed.contains(LogicalKeyboardKey.keyA);

    final isRightKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
            keysPressed.contains(LogicalKeyboardKey.keyD);

    if (isLeftKeyPressed && isRightKeyPressed) {
      keyDirection = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      keyDirection = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      keyDirection = PlayerDirection.right;
    } else {
      keyDirection = PlayerDirection.none;
    }

    // log('onKeyEvent: $event, $keysPressed');
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    // log('onCollision: $intersectionPoints, $other');
    _updateVelocityAndPositionFromCollision(intersectionPoints, other);
    super.onCollision(intersectionPoints, other);
  }

  void _updateVelocityAndPositionFromCollision(
      Set<Vector2> intersectionPoints, PositionComponent other) {
    if (other is CollisionBlock) {
      final primaryDirection = getPrimaryDirectionFromVelocity(velocity);
      final primaryYDirection = getYDirectionFromVelocity(velocity);
      final primaryXDirection = getXDirectionFromVelocity(velocity);
      final isVertical = isVerticalDirection(primaryDirection);
      if (isVertical) {
        velocity.y = 0;
        if (primaryYDirection == PrimaryDirection.up) {
          position = position.clone()..y = other.bottom;
        } else if (primaryYDirection == PrimaryDirection.down) {
          position = position.clone()..y = other.top - size.y;
        }
      } else {
        velocity.x = 0;
        if (primaryXDirection == PrimaryDirection.left) {
          position = position.clone()..x = other.right;
        } else if (primaryXDirection == PrimaryDirection.right) {
          position = position.clone()..x = other.left - size.x;
        }
      }
    } else {
      log('other is not CollisionBlock');
      velocity = Vector2.zero();
    }
  }

  double _adjustMoveSpeedFromJoystick() {
    double adjustedMoveSpeed = moveSpeed;
    if (joystick.direction != JoystickDirection.idle) {
      adjustedMoveSpeed = moveSpeed * joystick.relativeDelta.x.abs();
    }
    return adjustedMoveSpeed;
  }

  PlayerDirection _getPlayerDirectionFromJoystick() {
    PlayerDirection joystickDirection = PlayerDirection.none;
    if (joystick.direction != JoystickDirection.idle) {
      joystickDirection = joystick.relativeDelta.x > 0
          ? PlayerDirection.right
          : PlayerDirection.left;
    }
    return joystickDirection;
  }

  void _updatePlayerMovement(double dt) {
    double dx = 0.0;
    // double dy = velocity.y + gravity * dt;
    double dy = gravity;
    double adjustedMoveSpeed = _adjustMoveSpeedFromJoystick();
    PlayerDirection joystickDirection = _getPlayerDirectionFromJoystick();
    direction = resolvePlayerDirection(keyDirection, joystickDirection);
    switch (direction) {
      case PlayerDirection.left:
        dx -= adjustedMoveSpeed;
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = false;
        }
        current = PlayerState.run;
        break;
      case PlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
          isFacingRight = true;
        }
        dx += adjustedMoveSpeed;
        current = PlayerState.run;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
    }
    velocity = Vector2(dx, dy);
    position += velocity * dt;
  }

  void _loadAllAnimations() {
    animations = {
      PlayerState.idle: _spriteAnimation('Idle', 11),
      PlayerState.run: _spriteAnimation("Run", 12),
      PlayerState.jump: _spriteAnimation("Jump", 1),
      PlayerState.fall: _spriteAnimation("Fall", 8),
      PlayerState.wallJump: _spriteAnimation("Wall Jump", 5),
      PlayerState.doubleJump: _spriteAnimation("Double Jump", 1),
      PlayerState.hit: _spriteAnimation("Hit", 7),
    };

    // current animation
    current = PlayerState.run;
  }

  SpriteAnimation _spriteAnimation(String animationName, int frameCount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Main Characters/$characterName/$animationName (32x32).png',
      ),
      SpriteAnimationData.sequenced(
        amount: frameCount,
        textureSize: Vector2.all(32),
        stepTime: stepTime,
      ),
    );
  }
}
