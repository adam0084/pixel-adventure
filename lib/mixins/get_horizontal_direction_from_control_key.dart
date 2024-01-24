import 'package:pixel_adventure/actors/player_control_keys.dart';
import 'package:pixel_adventure/actors/player_direction.dart';

HorizontalPlayerDirection getHorizontalPlayerDirectionFromControlKey(
    Set<PlayerControlKeys> playerControlKeys) {
  if (playerControlKeys.isEmpty) {
    return HorizontalPlayerDirection.none;
  } else if (playerControlKeys.contains((PlayerControlKeys.left))) {
    return HorizontalPlayerDirection.left;
  } else if (playerControlKeys.contains((PlayerControlKeys.right))) {
    return HorizontalPlayerDirection.right;
  } else {
    return HorizontalPlayerDirection.none;
  }
}
