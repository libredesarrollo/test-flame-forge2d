import 'dart:async';
import 'package:flame/flame.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with TapDetector {
  MyGame() : super(gravity: Vector2(0, 30));
  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;

  final up = Vector2(0, -30);

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);
    Vector2 gameSize = screenToWorld(cameraComponent.viewport.size);
    cameraWorld.add(Ground(gameSize));
  }

  @override
  void onTap() {
    cameraWorld.add(Box());
    super.onTap();
  }
}

class BoxComponent extends SpriteComponent {
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('box.png');
    size = Vector2.all(10);
    anchor = Anchor.center;

    return super.onLoad();
  }
}

class Box extends BodyComponent {
  @override
  Future<void> onLoad() async {
    await super.onLoad();
    // paint = BasicPalette.red.paint();
    paint = BasicPalette.transparent.paint();
    add(BoxComponent());
    // final sprite = Sprite(gameRef.images.fromCache('box.png'));
    // add(
    //   SpriteComponent(
    //     sprite: sprite,
    //     size: Vector2(.5, .5),
    //     anchor: Anchor.center,
    //   ),
    // );
  }

  @override
  Body createBody() {
    // Shape shape = CircleShape()..radius = 3;
    final shape = PolygonShape();
    shape.setAsBoxXY(7, 5);
    BodyDef bodyDef =
        BodyDef(position: Vector2(40, 10), type: BodyType.dynamic);
    FixtureDef fixtureDef =
        FixtureDef(shape, friction: 1, density: 5, restitution: .1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ground extends BodyComponent {
  final Vector2 gameSize;
  Ground(this.gameSize);
  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(Vector2(0, gameSize.y * .9), Vector2(gameSize.x, gameSize.y * 0.9));

    BodyDef bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);

    FixtureDef fixtureDef = FixtureDef(shape, density: 1, friction: 1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
    // throw UnimplementedError();
  }
}
