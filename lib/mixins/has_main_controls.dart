import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/actors/player_control_keys.dart';
import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_direction_vector.dart';
import 'package:pixel_adventure/mixins/get_horizontal_direction_from_control_key.dart';
import 'package:pixel_adventure/mixins/get_vertical_direction_from_control_key.dart';
import 'package:pixel_adventure/mixins/joystick_component_extension.dart';
import 'package:pixel_adventure/mixins/resolve_horizontal_player_direction.dart';
import 'package:pixel_adventure/mixins/resolve_player_control_keys.dart';
import 'package:pixel_adventure/mixins/resolve_vertical_player_direction.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

mixin HasMainControls
    on HasGameRef<PixelAdventure>, KeyboardHandler, PositionComponent {
  JoystickComponent get joystick => game.joystick;
  HorizontalPlayerDirection horizontalKeyDirection =
      HorizontalPlayerDirection.none;
  VerticalPlayerDirection verticalKeyDirection = VerticalPlayerDirection.none;
  HorizontalPlayerDirection idleHorizontalDirection =
      HorizontalPlayerDirection.right;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    horizontalKeyDirection = HorizontalPlayerDirection.none;
    verticalKeyDirection = VerticalPlayerDirection.none;

    Set<PlayerControlKeys> playerControlKeys =
        resolvePlayerControlKeys(event, keysPressed);

    // log("playerControlKeys: $playerControlKeys");
    if (playerControlKeys.isEmpty) {
      return super.onKeyEvent(event, keysPressed);
    } else {
      horizontalKeyDirection =
          getHorizontalPlayerDirectionFromControlKey(playerControlKeys);
      verticalKeyDirection =
          getVerticalPlayerDirectionFromControlKey(playerControlKeys);
      // if (keysPressed.contains(LogicalKeyboardKey.keyT)) {
      //   log("position: $position, size: $size, velocity: $velocity, previousPosition: $previousPosition, center: $center, previousCenter: $previousCenter");
      // }

      // we always assume the keyboard takes precedence over the joystick
      if (horizontalKeyDirection != HorizontalPlayerDirection.none) {
        idleHorizontalDirection = horizontalKeyDirection;
      } else if (playerControlKeys.contains(PlayerControlKeys.flip)) {
        if (idleHorizontalDirection == HorizontalPlayerDirection.right) {
          idleHorizontalDirection = HorizontalPlayerDirection.left;
        } else {
          idleHorizontalDirection = HorizontalPlayerDirection.right;
        }
      }
      // log("horizontalKeyDirection: $horizontalKeyDirection, verticalKeyDirection: $verticalKeyDirection, idleHorizontalDirection: $idleHorizontalDirection");
      return true;
    }
  }

  PlayerDirectionVector getPlayerDirectionVector() {
    final resolvedHorizontalDireciton = resolveHorizontalPlayerDirection(
        horizontalKeyDirection, joystick.horizontalDirection);

    // we may need to update the idle direction based on the joystick
    if (resolvedHorizontalDireciton != HorizontalPlayerDirection.none) {
      idleHorizontalDirection = resolvedHorizontalDireciton;
    }

    return PlayerDirectionVector(
      horizontalMagnitude: joystick.horizontalMagnitude,
      horizontalDirection: resolvedHorizontalDireciton,
      verticalDirection: resolveVerticalPlayerDirection(
          verticalKeyDirection, joystick.verticalDirection),
    );
  }
}
