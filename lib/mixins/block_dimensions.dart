import 'dart:developer';

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
    // log('top: $top, bottom: $bottom, block.top: ${block.top}, block.bottom: ${block.bottom}');

    final xCollision = (right - block.left) * (left - block.right) < 0;
    // final yCollision = (block.top - bottom) * (block.bottom - top) < 0;
    final yCollision = (bottom - block.top) * (top - block.bottom) < 0;
    // log('xCollision: $xCollision, yCollision: $yCollision');
    return xCollision && yCollision;
    // return right > other.left &&
    //     left < other.right &&
    //     bottom > other.top &&
    //     top < other.bottom;
  }
}
