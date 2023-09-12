import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

enum MovementType {
  walkingright,
  walkingleft,
  runright,
  runleft,
  idle,
  jump,
  jumpright,
  jumpleft,
}

class Character extends SpriteAnimationComponent {
  int animationIndex = 0;

  MovementType movementType = MovementType.idle;

  // size sprite
  final double spriteSheetWidth = 680;
  final double spriteSheetHeight = 472;

  bool inGround = false; // player on the floor
  bool right = true; // player looking to the right

  late SpriteAnimation deadAnimation,
      idleAnimation,
      jumpAnimation,
      runAnimation,
      walkAnimation,
      walkSlowAnimation;
}
