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
    for (final block in closestHorizontalCollisionComponents) {
      if (block is CollisionBlock) {
        if (!block.isPlatform) {
          if (velocity.x > 0) {
            // moving right
            final previousRight = blockDimensions
                .fromPreviousMoveBehavior(previousMoveBehavior)
                .right;
            final right = blockDimensions.right;

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
    for (final block in closestVerticalCollisionComponents) {
      if (block is CollisionBlock) {
        if (!blockDimensions.isCollided(block.blockDimensions)) {
          continue;
        }
        if (velocity.y > 0) {
          final previousBottom = blockDimensions
              .fromPreviousMoveBehavior(previousMoveBehavior)
              .bottom;
          final bottom = blockDimensions.bottom;
          if (previousBottom <= block.top && bottom > block.top) {
            velocity.y = 0;
            final dy = block.top - bottom;
            position.y += dy;
            isGrounded = true;
          }
        }
        if (!block.isPlatform) {
          if (velocity.y < 0) {
            final previousTop = blockDimensions
                .fromPreviousMoveBehavior(previousMoveBehavior)
                .top;
            final top = blockDimensions.top;
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
