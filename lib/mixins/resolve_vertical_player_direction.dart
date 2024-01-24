import 'package:pixel_adventure/actors/player_direction.dart';

VerticalPlayerDirection resolveVerticalPlayerDirection(
    VerticalPlayerDirection keyBoardDirection,
    VerticalPlayerDirection joystickDirection) {
  VerticalPlayerDirection direction = VerticalPlayerDirection.none;
  if (keyBoardDirection != VerticalPlayerDirection.none) {
    direction = keyBoardDirection;
  } else if (joystickDirection != VerticalPlayerDirection.none) {
    direction = joystickDirection;
  }
  return direction;
}
