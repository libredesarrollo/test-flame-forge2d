import 'dart:ui';

import 'package:flame/components.dart';
import 'package:flame/flame.dart';

import 'package:flame_forge2d/flame_forge2d.dart';

class PlayerComponent extends SpriteAnimationComponent /**with TapDetector */ {
  PlayerComponent({required position});
  late Image chopper;

  @override
  Future<void> onLoad() async {
    chopper = await Flame.images.load('animations/chopper.png');

    animation = SpriteAnimation.fromFrameData(
      chopper,
      SpriteAnimationData.sequenced(
        amount: 4,
        textureSize: Vector2.all(48),
        stepTime: 0.15,
      ),
    );

    final spriteSize = Vector2.all(10);
    size = spriteSize;
    anchor = Anchor.center;
  }
}

class ChopperBody extends BodyComponent {
  final Vector2 position;
  final Vector2 size;

  ChopperBody(
    this.position,
    PositionComponent component,
  ) : size = component.size {
    renderBody = false;
    add(component);
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = size.x / 4;
    final fixtureDef = FixtureDef(
      shape,
      userData: this, // To be able to determine object in collision
      restitution: 0.8,
      density: 1.0,
      friction: 0.2,
    );

    final velocity = (Vector2.random() - Vector2.random()) * 200;
    final bodyDef = BodyDef(
      position: position,
      angle: velocity.angleTo(Vector2(1, 0)),
      linearVelocity: velocity,
      type: BodyType.dynamic,
    );
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
