import 'package:flame/components.dart';
import 'package:pixel_adventure/mixins/block_dimensions.dart';

mixin MeasurableBlock on PositionComponent {
  BlockDimensions get blockDimensions => BlockDimensions(
        center: center,
        size: size,
      );
}