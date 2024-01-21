// import 'dart:developer';

import 'package:flame/flame.dart';
// import 'package:flame/game.dart';
// import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:pixel_adventure/game_container.dart';
// import 'package:pixel_adventure/pixel_adventure.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Flame.device.fullScreen();
  await Flame.device.setLandscape();
  // PixelAdventure game = PixelAdventure();
  // runApp(GameWidget(game: kDebugMode ? PixelAdventure() : game));
  // if (kDebugMode) {
  //   log('Debug mode');
  //   runApp(GameWidget(game: PixelAdventure()));
  // } else {
  // PixelAdventure game = PixelAdventure();
  // runApp(GameWidget(game: game));

  // }

  runApp(const GameContainer());
}
