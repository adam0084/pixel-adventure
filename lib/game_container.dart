import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'pixel_adventure.dart';

class GameContainer extends StatefulWidget {
  const GameContainer({super.key});

  @override
  State<GameContainer> createState() => _GameContainerState();
}

class _GameContainerState extends State<GameContainer> {
  late PixelAdventure game;

  @override
  void initState() {
    game = PixelAdventure();
    super.initState();
  }

  @override
  void reassemble() {
    if (kDebugMode) {
      _resetGame();
    }
    super.reassemble();
  }

  void _resetGame() {
    setState(() {
      game = PixelAdventure();
    });
  }

  KeyEventResult _onKeyEvent(FocusNode node, RawKeyEvent event) {
    // log('Key event: ${event.logicalKey}');
    if (event.logicalKey == LogicalKeyboardKey.keyR) {
      _resetGame();
    }
    return KeyEventResult.handled;
  }

  @override
  Widget build(BuildContext context) {
    // ignore: sized_box_for_whitespace
    return Container(
        width: double.infinity,
        height: double.infinity,
        //https://github.com/flutter/flutter/issues/74287
        child: Focus(
          onKey: _onKeyEvent,
          child: GameWidget(game: game),
        ));
  }
}
