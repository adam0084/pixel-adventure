import 'dart:developer';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/actor_component.dart';
import 'package:pixel_adventure/levels/collision_block.dart';

mixin RectangularCollisionResolution on CollisionCallbacks, ActorComponent {
  List<PositionComponent> collidedComponents = [];

  List<PositionComponent> get closestHorizontalCollisionComponents {
    final cx = center.x;
    return collidedComponents.toList()
      ..sort((a, b) {
        final ax = a.position.x;
        final bx = b.position.x;

        return (ax - cx).abs().compareTo((bx - cx).abs());
      });
  }

  List<PositionComponent> get closestVerticalCollisionComponents {
    final cy = center.y;
    return collidedComponents.toList()
      ..sort((a, b) {
        final ay = a.position.y;
        final by = b.position.y;

        return (ay - cy).abs().compareTo((by - cy).abs());
      });
  }

  @override
  void onCollision(Set<Vector2> intersectionPoints, PositionComponent other) {
    collidedComponents.add(other);
    super.onCollision(intersectionPoints, other);
  }

  void resolveCollisions() {
    if (collidedComponents.isEmpty) {
      return;
    }

    _handleHorizontalCollisions();
    _handleVerticalCollisions();

    collidedComponents.clear();
  }

  void _handleHorizontalCollisions() {
    // final previousLeft = previousMoveBehavior.position.x;
    // final previousRight = previousMoveBehavior.position.x + size.x;
    // final left = position.x;
    // final right = position.x + size.x;

    // log("_handleHorizontalCollisions previousLeft: $previousLeft, previousRight: $previousRight, left: $left, right: $right");

    for (final block in closestHorizontalCollisionComponents) {
      if (block is CollisionBlock) {
        if (!block.isPlatform) {
          if (velocity.x > 0) {
            // moving right
            final previousRight = blockDimensions
                .fromPreviousMoveBehavior(previousMoveBehavior)
                .right;
            final right = blockDimensions.right;

            // final right = position.x + size.x;
            // log("previousMoveBehavior: $previousMoveBehavior");
            // log("right: $right, block.left: ${block.left}, previousRight: $previousRight, block.right: ${block.right}");
            if (previousRight <= block.left && right > block.left) {
              velocity.x = 0;
              final dx = block.left - right;
              position.x += dx;
            }
          }
          if (velocity.x < 0) {
            // moving left
            final previousLeft = blockDimensions
                .fromPreviousMoveBehavior(previousMoveBehavior)
                .left;
            final left = blockDimensions.left;

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

  void _handleVerticalCollisions() {
    // final previousTop = previousMoveBehavior.position.y;
    // final previousBottom = previousMoveBehavior.position.y + size.y;
    // final top = position.y;
    // final bottom = position.y + size.y;

    for (final block in closestVerticalCollisionComponents) {
      if (block is CollisionBlock) {
        if (!blockDimensions.isCollided(block.blockDimensions)) {
          // log("no longer collided");
          continue;
        }
        if (velocity.y > 0) {
          final previousBottom = previousMoveBehavior.position.y + size.y;
          final bottom = position.y + size.y;
          if (previousBottom <= block.top && bottom > block.top) {
            velocity.y = 0;
            final dy = block.top - bottom;
            position.y += dy;
            isGrounded = true;
          }
        }
        if (!block.isPlatform) {
          if (velocity.y < 0) {
            final previousTop = previousMoveBehavior.position.y;
            final top = position.y;
            // log("previousTop: $previousTop, top: $top, block.bottom: ${block.bottom}");
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
}
