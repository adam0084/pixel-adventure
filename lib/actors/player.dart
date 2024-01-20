import 'dart:async';

import 'package:flame/components.dart';

import '../pixel_adventure.dart';

const double stepTime = 0.05;

enum PlayerState { idle, run, hit, jump, fall, wallJump, doubleJump }

class Player extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {

  final String characterName;

  Player(this.characterName);

  @override
  FutureOr<void> onLoad() {
    _loadAllAnimations();
    return super.onLoad();
  }

  void _loadAllAnimations() {

    animations = {
      PlayerState.idle: _spriteAnimation('Idle', 11),
      PlayerState.run: _spriteAnimation("Run", 12),
      PlayerState.jump: _spriteAnimation("Jump", 1),
      PlayerState.fall: _spriteAnimation("Fall", 8),
      PlayerState.wallJump: _spriteAnimation("Wall Jump", 1),
      PlayerState.doubleJump: _spriteAnimation("Double Jump", 1),
      PlayerState.hit: _spriteAnimation("Hit", 1),
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
