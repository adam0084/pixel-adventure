import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

enum PlayerDirection { left, right, none }

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

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
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

  double _adjustMoveSpeedFromJoystick() {
    double adjustedMoveSpeed = moveSpeed;
    if (joystick.direction != JoystickDirection.idle) {
      adjustedMoveSpeed = moveSpeed * joystick.relativeDelta.x.abs();
    }
    return adjustedMoveSpeed;
  }

  PlayerDirection _getPlayerDirectionFromJoystick() {
    PlayerDirection direction = PlayerDirection.none;
    if (joystick.direction != JoystickDirection.idle) {
      direction = joystick.relativeDelta.x > 0
          ? PlayerDirection.right
          : PlayerDirection.left;
    }
    return direction;
  }

  void _updatePlayerMovement(double dt) {
    double dx = 0.0;
    double dy = 0.0;
    double adjustedMoveSpeed = _adjustMoveSpeedFromJoystick();
    PlayerDirection joystickDirection = _getPlayerDirectionFromJoystick();
    direction = resolvePlayerDirection(keyDirection, joystickDirection);
    switch (direction) {
      case PlayerDirection.left:
        dx -= adjustedMoveSpeed * dt;
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
        dx += adjustedMoveSpeed * dt;
        current = PlayerState.run;
        break;
      case PlayerDirection.none:
        current = PlayerState.idle;
        break;
    }
    velocity = Vector2(dx, dy);
    position += velocity;
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
