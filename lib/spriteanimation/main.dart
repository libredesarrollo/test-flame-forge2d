import 'dart:async';
import 'package:flutter/widgets.dart' as f;
import 'package:flame/camera.dart' as camera;

import 'package:flame/components.dart';
import 'package:flame/game.dart';
import 'package:flame/input.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
// import 'package:testforged2d/player_component.dart';

import 'package:testforged2d/utils/boundaries.dart';

void main() {
  f.runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with TapDetector {
  MyGame() : super(gravity: Vector2.zero());
  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);

    final boundaries = createBoundaries(this);
    boundaries.forEach(add);
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);

    // // add(ChopperBody(info.eventPosition.game,
    // //     PlayerComponent(position: info.eventPosition.game)));
    // final spriteSize = Vector2.all(10);
    // final animationComponent = SpriteAnimationComponent(
    //   animation: animation,
    //   size: spriteSize,
    //   anchor: Anchor.center,
    // );
    // add(ChopperBody(position, animationComponent));
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
