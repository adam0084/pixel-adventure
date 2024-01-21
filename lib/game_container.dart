import 'dart:developer';

import 'package:flame/game.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

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
      setState(() {
        log("Reassembling game");
        game = PixelAdventure();
      });
    }
    super.reassemble();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      height: double.infinity,
      child: Focus(
          child: GameWidget(game: game),
          onKey: (FocusNode node, RawKeyEvent event) => KeyEventResult.handled),
    );
  }
}
