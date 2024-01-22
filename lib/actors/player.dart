import 'dart:async';
import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/levels/collision_block.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;
const double gravity = 50;
const double joystickVerticalSensitivityThreshold = 0.35;

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

enum HorizontalPlayerDirection { left, right, none }

enum VerticalPlayerDirection { up, down, none }

enum PrimaryDirection { up, down, left, right, none }

HorizontalPlayerDirection resolveHorizontalPlayerDirection(
    HorizontalPlayerDirection keyBoardDirection,
    HorizontalPlayerDirection joystickDirection) {
  HorizontalPlayerDirection direction = HorizontalPlayerDirection.none;
  if (keyBoardDirection != HorizontalPlayerDirection.none) {
    direction = keyBoardDirection;
  } else if (joystickDirection != HorizontalPlayerDirection.none) {
    direction = joystickDirection;
  }
  return direction;
}

VerticalPlayerDirection resolveVerticalPlayerDirection(
    VerticalPlayerDirection keyBoardDirection,
    VerticalPlayerDirection joystickDirection) {
  VerticalPlayerDirection direction = VerticalPlayerDirection.none;
  if (keyBoardDirection != VerticalPlayerDirection.none) {
    direction = keyBoardDirection;
  } else if (joystickDirection != VerticalPlayerDirection.none) {
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
  JoystickComponent joystick;

  List<SavedCollision> collisionComponents = [];

  Player({required this.characterName, required this.joystick});

  // bool isFacingRight = true;

  bool get isFacingRight => !isFlippedHorizontally;
  double get centerX => position.x + size.x / 2;
  double get centerY => position.y + size.y / 2;

  List<SavedCollision> get closestHorizontalCollisionComponents {
    final cx = centerX;
    return collisionComponents.toList()
      ..sort((a, b) {
        final ax = a.other.position.x;
        final bx = b.other.position.x;

        return (ax - cx).abs().compareTo((bx - cx).abs());
      });
  }

  List<SavedCollision> get closestVerticalCollisionComponents {
    final cy = centerY;
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
    add(RectangleHitbox());
    game.collisionDetection.collisionsCompletedNotifier
        .addListener(_resolveCollisions);
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
      log('prevCollision: ${prevCollision.intersectionPoints} $block');
      if (prevCollision.intersectionPoints.length == 2) {
        final p1 = prevCollision.intersectionPoints.elementAt(0);
        final p2 = prevCollision.intersectionPoints.elementAt(1);
        final dy = p1.y - p2.y;
        if ((dy * 10000).round() == 0) {
          // if the y values are the same, then we can assume that the player is colliding with a wall
          continue;
        }
      }
      if (block is CollisionBlock) {
        if (!block.isPlatform) {
          if (velocity.x > 0) {
            position.x = block.left - size.x;
          }
          if (velocity.x < 0) {
            if (isFacingRight) {
              position.x = block.right;
            } else {
              position.x = block.right + size.x;
            }
          }
          velocity.x = 0;
        }
      }
    }
  }

  bool _isCollided(PositionComponent block) {
    bool isCollided = false;
    isCollided = block.containsPoint(position) ||
        block.containsPoint(position + size) ||
        block.containsPoint(position + Vector2(size.x, 0)) ||
        block.containsPoint(position + Vector2(0, size.y));
    return isCollided;
  }

  void _handleVerticalCollisions() {
    for (final prevCollision in closestVerticalCollisionComponents) {
      final block = prevCollision.other;
      if (prevCollision.intersectionPoints.length == 2) {
        final p1 = prevCollision.intersectionPoints.elementAt(0);
        final p2 = prevCollision.intersectionPoints.elementAt(1);
        final dx = p1.x - p2.x;
        if ((dx * 10000).round() == 0) {
          // if the x values are the same, then we can assume that the player is colliding with a wall
          continue;
        }
      }
      if (block is CollisionBlock) {
        if (!block.isPlatform) {
          if (velocity.y > 0) {
            position.y = block.top - size.y;
          }
          if (velocity.y < 0) {
            position.y = block.bottom;
          }
          velocity.y = 0;
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
    double adjustedMoveSpeed = moveSpeed;
    if (joystick.direction != JoystickDirection.idle) {
      adjustedMoveSpeed = moveSpeed * joystick.relativeDelta.y.abs();
    }
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
    // double dy = velocity.y + gravity * dt;
    double dy = 0;
    double adjustedMoveSpeed = _adjustVerticalMoveSpeedFromJoystick();
    VerticalPlayerDirection joystickDirection =
        _getVerticalPlayerDirectionFromJoystick();
    verticalDirection =
        resolveVerticalPlayerDirection(verticalKeyDirection, joystickDirection);
    switch (verticalDirection) {
      case VerticalPlayerDirection.up:
        dy -= adjustedMoveSpeed;
        current = PlayerState.jump;
        break;
      case VerticalPlayerDirection.down:
        dy += adjustedMoveSpeed;
        current = PlayerState.fall;
        break;
      default:
        // do nothing becasue the horizontal movement will take care of it
        break;
      // case VerticalPlayerDirection.none:
      //   if(horizontalDirection == HorizontalPlayerDirection.none)
      //   current = PlayerState.idle;
      //   break;
    }
    velocity = Vector2(velocity.x, dy);
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
