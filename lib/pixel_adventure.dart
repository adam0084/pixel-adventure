import 'dart:async';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:pixel_adventure/levels/level.dart';
import 'package:pixel_adventure/make_joystick.dart';

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents {
  PixelAdventure()
      : super(
            camera:
                CameraComponent.withFixedResolution(width: 640, height: 360)) {
    camera.viewfinder.anchor = Anchor.topLeft;
  }

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final JoystickComponent joystick;
  late final Level level;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    joystick = makeJoystick(game: this);
    // makeJoystick(game: this, size: 160.0, position: Vector2(10, 300));
    level = Level();
    world = level;

    // cam = CameraComponent.withFixedResolution(
    //     width: 640, height: 360, world: level);
    // cam.viewfinder.anchor = Anchor.topLeft;
    // cam.viewport.add(joystick);
    // addAll([cam, level]);
    camera.viewport.add(joystick);
    
    return super.onLoad();
  }
}
