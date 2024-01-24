import 'package:pixel_adventure/actors/player_control_keys.dart';
import 'package:pixel_adventure/actors/player_direction.dart';

VerticalPlayerDirection getVerticalPlayerDirectionFromControlKey(
    Set<PlayerControlKeys> playerControlKeys) {
  if (playerControlKeys.isEmpty) {
    return VerticalPlayerDirection.none;
  } else if (playerControlKeys.contains((PlayerControlKeys.up))) {
    return VerticalPlayerDirection.up;
  } else if (playerControlKeys.contains((PlayerControlKeys.down))) {
    return VerticalPlayerDirection.down;
  } else {
    return VerticalPlayerDirection.none;
  }
}

