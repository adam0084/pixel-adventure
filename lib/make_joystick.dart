import 'dart:developer';

import 'package:flame/components.dart';
import 'package:flame/sprite.dart';
import 'package:flutter/painting.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

const double margin = 20;
const double scalingFactor = 0.6;

JoystickComponent makeJoystick({required PixelAdventure game}) {
// JoystickComponent makeJoystick(
//     {required PixelAdventure game,
//     required double size,
//     required Vector2 position}) {
  final image = game.images.fromCache('joystick.png');
  final sheet =
      SpriteSheet.fromColumnsAndRows(image: image, columns: 6, rows: 1);

  // const margin = EdgeInsets.only(left: 10, bottom: 100);
  final knob = SpriteComponent(
    sprite: sheet.getSpriteById(1),
    size: Vector2.all(100),
  );
  knob.setOpacity(0.7);
  final background = SpriteComponent(
    sprite: sheet.getSpriteById(0),
    size: Vector2.all(130),
  );
  background.setOpacity(0.5);
  // return JoystickComponent(
  //     knob: knob, background: background, size: size, position: position);
  final joystick = JoystickComponent(
      knob: knob, background: background, position: Vector2.zero());

  joystick.scale = Vector2.all(scalingFactor);
  joystick.anchor = Anchor.bottomLeft;

  // Vector2 viewportSize = game.camera.viewport.virtualSize.clone();
  // joystick.position = Vector2(margin, viewportSize.y - margin);

  // log('viewportSize: $viewportSize');

  // joystick.margin = EdgeInsets.only(left: margin, bottom: margin);

  return joystick;
}
