import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_state.dart';
import 'package:pixel_adventure/constants.dart';

class PlayerDirectionVector {
  HorizontalPlayerDirection horizontalDirection;
  VerticalPlayerDirection verticalDirection;
  double horizontalMagnitude;

  double get dx {
    if(horizontalDirection == HorizontalPlayerDirection.left) {
      return -horizontalMagnitude * moveSpeed;
    } else if(horizontalDirection == HorizontalPlayerDirection.right) {
      return horizontalMagnitude * moveSpeed;
    } else {
      return 0.0;
    }
  }

  double get dy {
    if(verticalDirection == VerticalPlayerDirection.up) {
      return -moveSpeed;
    } else if(verticalDirection == VerticalPlayerDirection.down) {
      return moveSpeed;
    } else {
      return 0.0;
    }
  }

  PlayerDirectionVector(
      {required this.horizontalDirection,
      required this.verticalDirection,
      this.horizontalMagnitude = 1.0});

  PlayerState get playerState {
    if(verticalDirection != VerticalPlayerDirection.none) {
      if(verticalDirection == VerticalPlayerDirection.up) {
        return PlayerState.jump;
      } else {
        return PlayerState.fall;
      }
    } else if(horizontalDirection != HorizontalPlayerDirection.none) {
      return PlayerState.run;
    }

    return PlayerState.idle;
  }
}
