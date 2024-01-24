
import 'package:flutter/services.dart';
import 'package:pixel_adventure/actors/player_control_keys.dart';

Set<PlayerControlKeys> resolvePlayerControlKeys(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
  Set<PlayerControlKeys> playerControlKeys = {};

  final isLeftKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
      keysPressed.contains(LogicalKeyboardKey.keyA);

  final isRightKeyPressed =
      keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
          keysPressed.contains(LogicalKeyboardKey.keyD);

  final isUpKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowUp) ||
      keysPressed.contains(LogicalKeyboardKey.keyW);

  final isDownKeyPressed = keysPressed.contains(LogicalKeyboardKey.arrowDown) ||
      keysPressed.contains(LogicalKeyboardKey.keyS);

  if (isLeftKeyPressed && isRightKeyPressed) {
    // do nothing
  } else if (isLeftKeyPressed) {
    playerControlKeys.add(PlayerControlKeys.left);
  } else if (isRightKeyPressed) {
    playerControlKeys.add(PlayerControlKeys.right);
  } 

  if (isUpKeyPressed && isDownKeyPressed) {
    //do nothing
  } else if (isUpKeyPressed) {
    playerControlKeys.add(PlayerControlKeys.up);
  } else if (isDownKeyPressed) {
    playerControlKeys.add(PlayerControlKeys.down);
  } 

  if (keysPressed.contains(LogicalKeyboardKey.keyT)) {
    playerControlKeys.add(PlayerControlKeys.log);
  }
  if (keysPressed.contains(LogicalKeyboardKey.keyF)) {
    playerControlKeys.add(PlayerControlKeys.flip);
  }

  return playerControlKeys;
}