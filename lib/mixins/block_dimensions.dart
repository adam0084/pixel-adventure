import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/player_move_behavior.dart';

class BlockDimensions {
  final double right;
  final double bottom;
  final double left;
  final double top;
  final Vector2 size;
  final Vector2 center;

  BlockDimensions({
    required this.center,
    required this.size,
  })  : right = center.x + size.x / 2,
        bottom = center.y + size.y / 2,
        left = center.x - size.x / 2,
        top = center.y - size.y / 2;

  BlockDimensions fromPreviousMoveBehavior(PlayerMovebehavior previousMove) {
    return BlockDimensions(
      center: previousMove.center,
      size: size,
    );
  }

  bool isCollided(BlockDimensions block) {
    final xCollision = (right - block.left) * (left - block.right) < 0;
    final yCollision = (bottom - block.top) * (top - block.bottom) < 0;
    return xCollision && yCollision;
  }
}
