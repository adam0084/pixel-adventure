import 'package:flame/components.dart';
import 'package:flame/extensions.dart';
import 'package:pixel_adventure/constants.dart';
import 'package:pixel_adventure/pixel_adventure.dart';

class LevelBackground extends PositionComponent
    with HasGameRef<PixelAdventure> {
  final String backgroundName;
  final Vector2 levelSize;
  Image get image => game.images.fromCache("Background/$backgroundName.png");

  late Sprite _spriteTile;

  List<SpriteComponent> spriteTiles = [];

  LevelBackground({this.backgroundName = "Gray", required this.levelSize});

  @override
  Future<void> onLoad() async {
    size = levelSize;
    _spriteTile = Sprite(image, srcSize: Vector2.all(backgroundSize));
    _tileBackground();
    return super.onLoad();
  }

  void _tileBackground() {
    final columns = (levelSize.x / backgroundSize).ceil();
    final rows = (levelSize.y / backgroundSize).ceil();

    for (var i = 0; i < columns; i++) {
      for (var j = 0; j < rows; j++) {
        final spriteComp = SpriteComponent(
            sprite: _spriteTile,
            size: Vector2.all(backgroundSize * 1.02),
            position: Vector2(i * backgroundSize, j * backgroundSize));
        spriteTiles.add(spriteComp);
        add(spriteComp);
      }
    }
  }
}
