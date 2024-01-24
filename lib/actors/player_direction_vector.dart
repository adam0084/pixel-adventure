import 'package:pixel_adventure/actors/player_direction.dart';
import 'package:pixel_adventure/actors/player_state.dart';

class PlayerDirectionVector {
  HorizontalPlayerDirection horizontalDirection;
  VerticalPlayerDirection verticalDirection;
  double horizontalMagnitude;

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
