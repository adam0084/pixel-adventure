import 'dart:async';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/player_state.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

const double stepTime = 0.05;

class PlayerSprite extends SpriteAnimationGroupComponent
    with HasGameRef<PixelAdventure> {
  final String characterName;

  PlayerSprite({required this.characterName});

  @override
  FutureOr<void> onLoad() {
    // TODO: implement onLoad
    _loadAllAnimations();
    return super.onLoad();
  }

  RectangleHitbox get hitbox => RectangleHitbox(
        size: Vector2.all(playerSize),
      );

  void _loadAllAnimations() {
    animations = {
      PlayerState.idle: _spriteAnimation('Idle', 11),
      PlayerState.run: _spriteAnimation("Run", 12),
      PlayerState.jump: _spriteAnimation("Jump", 1),
      PlayerState.fall: _spriteAnimation("Fall", 1),
      PlayerState.wallJump: _spriteAnimation("Wall Jump", 5),
      PlayerState.doubleJump: _spriteAnimation("Double Jump", 1),
      PlayerState.hit: _spriteAnimation("Hit", 7),
    };

    // current animation
    current = PlayerState.idle;
  }

  SpriteAnimation _spriteAnimation(String animationName, int frameCount) {
    return SpriteAnimation.fromFrameData(
      game.images.fromCache(
        'Main Characters/$characterName/$animationName (32x32).png',
      ),
      SpriteAnimationData.sequenced(
        amount: frameCount,
        textureSize: Vector2.all(playerSize),
        stepTime: stepTime,
      ),
    );
  }
}
