import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flame/palette.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_state.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/levels/collision_block.dart';
import 'package:pixel_adventure/mixins/resolve_horizontal_player_direction.dart';
import 'package:pixel_adventure/mixins/resolve_vertical_player_direction.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;


enum RectangleSide { top, bottom, left, right }

double getSideForBlock(PositionComponent block, RectangleSide side) {
  double value = 0;
  switch (side) {
    case RectangleSide.top:
      value = block.position.y;
      break;
    case RectangleSide.bottom:
      value = block.position.y + block.size.y;
      break;
    case RectangleSide.left:
      value = block.position.x;
      break;
    case RectangleSide.right:
      value = block.position.x + block.size.x;
      break;
  }
  return value;
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

class SavedCollision {
  final Set<Vector2> intersectionPoints;
  final PositionComponent other;

  SavedCollision(this.intersectionPoints, this.other);
}

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler, CollisionCallbacks {
  final String characterName;

  HorizontalPlayerDirection horizontalDirection =
      HorizontalPlayerDirection.none;
  HorizontalPlayerDirection horizontalKeyDirection =
      HorizontalPlayerDirection.none;
  VerticalPlayerDirection verticalDirection = VerticalPlayerDirection.none;
  VerticalPlayerDirection verticalKeyDirection = VerticalPlayerDirection.none;

  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();
  bool isGrounded = false;
  // bool isJumping = false;
  JoystickComponent joystick;
  Vector2 previousPosition = Vector2.zero();
  Vector2 previousCenter = Vector2.zero();

  late final CircleComponent centerIndicator;

  List<SavedCollision> collisionComponents = [];

  Player({required this.characterName, required this.joystick});

  // bool isFacingRight = true;
  bool get isFacingRight => !isFlippedHorizontally;
  double get halfWidth => size.x / 2;
  double get halfHeight => size.y / 2;

  double get previousRight => previousCenter.x + halfWidth;
  double get previousBottom => previousPosition.y + size.y;
  double get previousLeft => previousCenter.x - halfWidth;
  double get previousTop => previousPosition.y;

  double get right => center.x + halfWidth;
  double get bottom => position.y + size.y;
  double get left => center.x - halfWidth;
  double get top => position.y;

  List<SavedCollision> get closestHorizontalCollisionComponents {
    final cx = center.x;
    return collisionComponents.toList()
      ..sort((a, b) {
        final ax = a.other.position.x;
        final bx = b.other.position.x;

        return (ax - cx).abs().compareTo((bx - cx).abs());
      });
  }

  List<SavedCollision> get closestVerticalCollisionComponents {
    final cy = center.y;
    return collisionComponents.toList()
      ..sort((a, b) {
        final ay = a.other.position.y;
        final by = b.other.position.y;

        return (ay - cy).abs().compareTo((by - cy).abs());
      });
  }

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    // Adjust collision detection to use hitbox instead of the whole sprite
    // add(RectangleHitbox(
    //   position: Vector2(10, 4),
    //   size: Vector2(14, 28),
    // ));
    add(RectangleHitbox());
    centerIndicator = CircleComponent(radius: 2)
      ..anchor = Anchor.center
      ..position = Vector2(center.x, center.y)
      ..paint = BasicPalette.red.paint()
      ..debugMode = true;
    // game.level.add(centerIndicator);
    game.collisionDetection.collisionsCompletedNotifier
        .addListener(_resolveCollisions);
    // debugMode = true;
    previousPosition = Vector2(position.x, position.y);
    previousCenter = Vector2(center.x, center.y);
    return super.onLoad();
  }

  @override
  void update(double dt) {
    _updatePlayerMovement(dt);
    centerIndicator.position = Vector2(center.x, center.y);
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

    final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
        keysPressed.contains(LogicalKeyboardKey.keyW);

    final isDownKeyPressed =
        keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
            keysPressed.contains(LogicalKeyboardKey.keyS);

    if (isLeftKeyPressed && isRightKeyPressed) {
      horizontalKeyDirection = HorizontalPlayerDirection.none;
    } else if (isLeftKeyPressed) {
      horizontalKeyDirection = HorizontalPlayerDirection.left;
    } else if (isRightKeyPressed) {
      horizontalKeyDirection = HorizontalPlayerDirection.right;
    } else {
      horizontalKeyDirection = HorizontalPlayerDirection.none;
    }

    if (isUpKeyPressed && isDownKeyPressed) {
      verticalKeyDirection = VerticalPlayerDirection.none;
    } else if (isUpKeyPressed) {
      verticalKeyDirection = VerticalPlayerDirection.up;
    } else if (isDownKeyPressed) {
      verticalKeyDirection = VerticalPlayerDirection.down;
    } else {
      verticalKeyDirection = VerticalPlayerDirection.none;
    }

    if (keysPressed.contains(LogicalKeyboardKey.keyT)) {
      log("position: $position, size: $size, velocity: $velocity, previousPosition: $previousPosition, center: $center, previousCenter: $previousCenter");
    }
    if (keysPressed.contains(LogicalKeyboardKey.keyF)) {
      if (horizontalDirection == HorizontalPlayerDirection.none) {
        flipHorizontallyAroundCenter();
      }
    }

    // log('onKeyEvent: $event, $keysPressed');
    return super.onKeyEvent(event, keysPressed);
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    // TODO: implement onCollision
    // log('onCollision: $intersectionPoints, $other');
    // _updateVelocityAndPositionFromCollision(intersectionPoints, other);
    collisionComponents.add(SavedCollision(intersectionPoints, other));
    super.onCollision(intersectionPoints, other);
  }

  void _resolveCollisions() {
    _handleHorizontalCollisions();
    _handleVerticalCollisions();
  }

  void _handleHorizontalCollisions() {
    for (final prevCollision in closestHorizontalCollisionComponents) {
      final block = prevCollision.other;

      if (block is CollisionBlock) {
        if (!block.isPlatform) {
          if (velocity.x > 0) {
            // moving right
            if (previousRight <= block.left && right > block.left) {
              velocity.x = 0;
              final dx = block.left - right;
              position.x += dx;
            }
          }
          if (velocity.x < 0) {
            // moving left
            if (previousLeft >= block.right && left < block.right) {
              velocity.x = 0;
              final dx = block.right - left;
              position.x += dx;
            }
          }
        }
      }
    }
  }

  bool _isCollided(CollisionBlock block) {
    final xCollision = (right - block.left) * (left - block.right) < 0;
    final yCollision = (bottom - block.top) * (top - block.bottom) < 0;

    return xCollision && yCollision;
  }

  void _handleVerticalCollisions() {
    for (final prevCollision in closestVerticalCollisionComponents) {
      final block = prevCollision.other;
      if (block is CollisionBlock) {
        if (!_isCollided(block)) {
          continue;
        }
        if (velocity.y > 0) {
          if (previousBottom <= block.top && bottom > block.top) {
            velocity.y = 0;
            final dy = block.top - bottom;
            position.y += dy;
            isGrounded = true;
          }
        }
        if (!block.isPlatform) {
          if (velocity.y < 0) {
            if (previousTop >= block.bottom && top < block.bottom) {
              velocity.y = 0;
              final dy = block.bottom - top;
              position.y += dy;
            }
          }
        }
      }
    }
  }

  double _adjustHorizontalMoveSpeedFromJoystick() {
    double adjustedMoveSpeed = moveSpeed;
    if (joystick.direction != JoystickDirection.idle) {
      adjustedMoveSpeed = moveSpeed * joystick.relativeDelta.x.abs();
    }
    return adjustedMoveSpeed;
  }

  double _adjustVerticalMoveSpeedFromJoystick() {
    double adjustedMoveSpeed = jumpSpeed;
    // if (joystick.direction != JoystickDirection.idle &&
    //     isGrounded &&
    //     joystick.relativeDelta.y < 0) {
    //   if (joystick.relativeDelta.y.abs() >
    //       joystickVerticalSensitivityThreshold) {
    //     adjustedMoveSpeed = jumpSpeed * joystick.relativeDelta.y.abs();
    //   }
    // }
    return adjustedMoveSpeed;
  }

  HorizontalPlayerDirection _getHorizontalPlayerDirectionFromJoystick() {
    HorizontalPlayerDirection joystickDirection =
        HorizontalPlayerDirection.none;
    if (joystick.direction != JoystickDirection.idle) {
      joystickDirection = joystick.relativeDelta.x > 0
          ? HorizontalPlayerDirection.right
          : HorizontalPlayerDirection.left;
    }
    return joystickDirection;
  }

  VerticalPlayerDirection _getVerticalPlayerDirectionFromJoystick() {
    VerticalPlayerDirection joystickDirection = VerticalPlayerDirection.none;
    if (joystick.direction != JoystickDirection.idle &&
        joystick.relativeDelta.y.abs() > joystickVerticalSensitivityThreshold) {
      joystickDirection = joystick.relativeDelta.y > 0
          ? VerticalPlayerDirection.down
          : VerticalPlayerDirection.up;
    }
    return joystickDirection;
  }

  void _updatePlayerMovement(double dt) {
    _updateHorizontalMovement(dt);
    _updateVerticalMovement(dt);
    previousPosition = Vector2(position.x, position.y);
    previousCenter = Vector2(center.x, center.y);
    position += velocity * dt;
    collisionComponents.clear();
  }

  void _updateHorizontalMovement(double dt) {
    double dx = 0.0;
    double adjustedMoveSpeed = _adjustHorizontalMoveSpeedFromJoystick();
    HorizontalPlayerDirection joystickDirection =
        _getHorizontalPlayerDirectionFromJoystick();
    horizontalDirection = resolveHorizontalPlayerDirection(
        horizontalKeyDirection, joystickDirection);
    switch (horizontalDirection) {
      case HorizontalPlayerDirection.left:
        dx -= adjustedMoveSpeed;
        if (isFacingRight) {
          flipHorizontallyAroundCenter();
        }
        current = PlayerState.run;
        break;
      case HorizontalPlayerDirection.right:
        if (!isFacingRight) {
          flipHorizontallyAroundCenter();
        }
        dx += adjustedMoveSpeed;
        current = PlayerState.run;
        break;
      case HorizontalPlayerDirection.none:
        current = PlayerState.idle;
        break;
    }
    velocity = Vector2(dx, velocity.y);
  }

  void _updateVerticalMovement(double dt) {
    double dy = 0;
    // double dy = 0;
    double adjustedMoveSpeed = _adjustVerticalMoveSpeedFromJoystick();
    VerticalPlayerDirection joystickDirection =
        _getVerticalPlayerDirectionFromJoystick();
    verticalDirection =
        resolveVerticalPlayerDirection(verticalKeyDirection, joystickDirection);

    if (verticalDirection == VerticalPlayerDirection.up && isGrounded) {
      dy -= adjustedMoveSpeed;
      isGrounded = false;
    } else {
      dy += gravity;
      if (position.y > previousPosition.y && velocity.y > 0) {
        isGrounded = false;
        current = PlayerState.fall;
      } else if (position.y < previousPosition.y && velocity.y < 0) {
        current = PlayerState.jump;
      }
    }

    // switch (verticalDirection) {
    //   case VerticalPlayerDirection.up:
    //     dy -= adjustedMoveSpeed;
    //     current = PlayerState.jump;
    //     break;
    //   case VerticalPlayerDirection.down:
    //     dy += adjustedMoveSpeed;
    //     current = PlayerState.fall;
    //     break;
    //   default:
    //     // do nothing becasue the horizontal movement will take care of it
    //     break;
    //   // case VerticalPlayerDirection.none:
    //   //   if(horizontalDirection == HorizontalPlayerDirection.none)
    //   //   current = PlayerState.idle;
    //   //   break;
    // }
    // final yVelocity = velocity.y + dy;
    // dy = dy.clamp(-terminalVelocity, terminalVelocity);
    velocity = Vector2(velocity.x, velocity.y + dy);
    velocity.y = velocity.y.clamp(-terminalVelocity, terminalVelocity);
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
