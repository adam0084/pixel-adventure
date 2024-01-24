import 'package:pixel_adventure/actors/player_direction.dart';

HorizontalPlayerDirection resolveHorizontalPlayerDirection(
    HorizontalPlayerDirection keyBoardDirection,
    HorizontalPlayerDirection joystickDirection) {
  HorizontalPlayerDirection direction = HorizontalPlayerDirection.none;
  if (keyBoardDirection != HorizontalPlayerDirection.none) {
    direction = keyBoardDirection;
  } else if (joystickDirection != HorizontalPlayerDirection.none) {
    direction = joystickDirection;
  }
  return direction;
}
