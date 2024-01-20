import 'dart:async';
import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

enum PlayerDirection { left, right, none }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure>, KeyboardHandler {
  final String characterName;

  PlayerDirection direction = PlayerDirection.none;
  double moveSpeed = 100;
  Vector2 velocity = Vector2.zero();

  Player(this.characterName);

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
      direction = PlayerDirection.none;
    } else if (isLeftKeyPressed) {
      direction = PlayerDirection.left;
    } else if (isRightKeyPressed) {
      direction = PlayerDirection.right;
    } else {
      direction = PlayerDirection.none;
    }

    // log('onKeyEvent: $event, $keysPressed');
    return super.onKeyEvent(event, keysPressed);
  }

  void _updatePlayerMovement(double dt) {
    double dx = 0.0;
    double dy = 0.0;

    switch (direction) {
      case PlayerDirection.left:
        dx -= moveSpeed * dt;
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
        dx += moveSpeed * dt;
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
