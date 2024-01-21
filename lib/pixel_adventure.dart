import 'dart:async';
import 'dart:math';
import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/layout.dart';
import 'package:flutter/widgets.dart';
import 'package:pixel_adventure/actors/player.dart';
import 'package:pixel_adventure/levels/level.dart';
import 'package:pixel_adventure/make_joystick.dart';

final worldSize = Vector2(640, 360);
final joystickMargin = 20.0;

class PixelAdventure extends FlameGame with HasKeyboardHandlerComponents {
  PixelAdventure()
      // : super(
      //       camera:
      //           CameraComponent.withFixedResolution(width: 640, height: 360)) {
      : super(camera: CameraComponent()) {
    // camera.viewfinder.anchor = Anchor.topLeft;
  }

  @override
  Color backgroundColor() => const Color(0xFF211F30);

  late final JoystickComponent joystick;
  late final Level level;
  late final Player player;

  @override
  FutureOr<void> onLoad() async {
    await images.loadAllImages();
    joystick = makeJoystick(game: this);
    player = Player(characterName: "Mask Dude", joystick: joystick);
    // makeJoystick(game: this, size: 160.0, position: Vector2(10, 300));
    level = Level(player: player);
    world = level;
    // cam = CameraComponent.withFixedResolution(
    //     width: 640, height: 360, world: level);
    // cam.viewfinder.anchor = Anchor.topLeft;
    // cam.viewport.add(joystick);
    // addAll([cam, level]);
    camera.viewport.add(joystick);

    camera.viewfinder.anchor = Anchor.center;
    // camera.viewport.add(AlignComponent(
    //   alignment: Anchor.bottomLeft,
    //   child: joystick,
    // ));
    _layoutCameraAndWorld();
    // add(AlignComponent(
    //   alignment: Anchor.bottomLeft,
    //   child: joystick,
    // ));

    return super.onLoad();
  }

  @override
  void onGameResize(Vector2 size) {
    // TODO: implement onGameResize
    if (isLoaded) {
      _layoutCameraAndWorld();
    }
    super.onGameResize(size);
  }

  void _layoutCameraAndWorld() {
    final viewportSize = camera.viewport.virtualSize;
    final zoomX = viewportSize.x / worldSize.x;
    final zoomY = viewportSize.y / worldSize.y;
    camera.viewfinder.zoom = min(zoomX, zoomY);
    camera.viewfinder.position = worldSize / 2;
    joystick.position =
        Vector2(joystickMargin, viewportSize.y - joystickMargin);
  }
}
