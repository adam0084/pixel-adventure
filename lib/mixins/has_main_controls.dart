import 'package:flame/components.dart';
import 'package:flutter/services.dart';
import 'package:pixel_adventure/actors/player_control_keys.dart';
import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_direction_vector.dart';
import 'package:pixel_adventure/mixins/flippable_position_component.dart';
import 'package:pixel_adventure/mixins/get_horizontal_direction_from_control_key.dart';
import 'package:pixel_adventure/mixins/get_vertical_direction_from_control_key.dart';
import 'package:pixel_adventure/mixins/joystick_component_extension.dart';
import 'package:pixel_adventure/mixins/resolve_horizontal_player_direction.dart';
import 'package:pixel_adventure/mixins/resolve_player_control_keys.dart';
import 'package:pixel_adventure/mixins/resolve_vertical_player_direction.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

mixin HasMainControls
    on HasGameRef<PixelAdventure>, KeyboardHandler, PositionComponent, FlippablePositionComponent {
  JoystickComponent get joystick => game.joystick;
  HorizontalPlayerDirection horizontalKeyDirection =
      HorizontalPlayerDirection.none;
  VerticalPlayerDirection verticalKeyDirection =
      VerticalPlayerDirection.none;

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    Set<PlayerControlKeys> playerControlKeys =
        resolvePlayerControlKeys(event, keysPressed);
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
      if (playerControlKeys.contains(PlayerControlKeys.flip) &&
          horizontalKeyDirection == HorizontalPlayerDirection.none) {
        flipHorizontally();
      }
      return true;
    }
  }

  PlayerDirectionVector getPlayerDirectionVector() {
    return PlayerDirectionVector(
      horizontalMagnitude: joystick.relativeDelta.x.abs(),
      horizontalDirection: resolveHorizontalPlayerDirection(horizontalKeyDirection, joystick.horizontalDirection),
      verticalDirection: resolveVerticalPlayerDirection(verticalKeyDirection, joystick.verticalDirection),
    );
  }
}
