import 'package:flame/components.dart';
import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/constants.dart';

extension PlayerDirection on JoystickComponent {
  HorizontalPlayerDirection get horizontalDirection {
    if (relativeDelta.x > 0) {
      return HorizontalPlayerDirection.right;
    } else if (relativeDelta.y < 0) {
      return HorizontalPlayerDirection.left;
    } else {
      return HorizontalPlayerDirection.none;
    }
  }

  VerticalPlayerDirection get verticalDirection {
    if (relativeDelta.y > joystickVerticalSensitivityThreshold) {
      return VerticalPlayerDirection.down;
    } else if (relativeDelta.y < -joystickVerticalSensitivityThreshold) {
      return VerticalPlayerDirection.up;
    } else {
      return VerticalPlayerDirection.none;
    }
  }
}