import 'dart:ui';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/actor_component.dart';
import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_move_behavior.dart';
import 'package:pixel_adventure/actors/player_sprite.dart';
import 'package:pixel_adventure/actors/player_state.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/mixins/has_main_controls.dart';
import 'package:pixel_adventure/mixins/rectangular_collision_resolution.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class PlayerActor extends ActorComponent
    with
        HasGameRef<PixelAdventure>,
        HasMainControls,
        RectangularCollisionResolution {
  final PlayerSprite playerSprite;
  final Vector2 spriteCenter = Vector2.all(playerSize / 2);
  late final RectangleComponent outlineIndicator;

  PlayerActor({characterName = "Mask Dude"})
      : playerSprite = PlayerSprite(characterName: characterName) {
    size = Vector2.all(playerSize);
  }

  @override
  Future<void> onLoad() async {
    debugMode = true;

    outlineIndicator = RectangleComponent(
      size: Vector2.all(32),
      paint: Paint()..color = const Color.fromARGB(135, 233, 15, 15),
    );

    add(outlineIndicator);
    add(playerSprite);
    add(RectangleHitbox(size: Vector2.all(playerSize)));
    game.collisionDetection.collisionsCompletedNotifier
        .addListener(resolveCollisions);
    await super.onLoad();
  }

  @override
  void update(double dt) {
    final nextMove = _getNextMoveBehavior(dt);
    _applyPlayerMoveBehavior(nextMove);
    _updateSprite();
    super.update(dt);
  }

  void _applyPlayerMoveBehavior(PlayerMovebehavior moveBehavior) {
    previousMoveBehavior = PlayerMovebehavior(
      position: Vector2(x, y),
      center: Vector2(center.x, center.y),
      velocity: Vector2(velocity.x, velocity.y),
    );

    velocity = moveBehavior.velocity;
    x = moveBehavior.position.x;
    y = moveBehavior.position.y;
  }

  void _updateSprite() {
    playerSprite.current = playerStateFromVelocity(velocity);
    if (playerSprite.isFlippedHorizontally &&
        idleHorizontalDirection == HorizontalPlayerDirection.right) {
      playerSprite.flipHorizontally();
    } else if (!playerSprite.isFlippedHorizontally &&
        idleHorizontalDirection == HorizontalPlayerDirection.left) {
      playerSprite.flipHorizontally();
    }
    playerSprite.anchor = Anchor.center;
    playerSprite.center = spriteCenter;
  }

  PlayerMovebehavior _getNextMoveBehavior(double dt) {
    final directionVector = getPlayerDirectionVector();

    final velocity = Vector2(
      directionVector.dx,
      directionVector.dy,
    );
    final nextPosition = Vector2(x, y);
    nextPosition.add(velocity * dt);
    final nextCenter = Vector2(center.x, center.y);
    nextCenter.add(velocity * dt);
    return PlayerMovebehavior(
      position: nextPosition,
      center: nextCenter,
      velocity: velocity,
    );
  }
}
