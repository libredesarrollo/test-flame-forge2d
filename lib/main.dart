import 'dart:async';
import 'package:flutter/material.dart';

import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:testforged2d/components/player.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame
    with TapDetector, HasKeyboardHandlerComponents {
  MyGame() : super(gravity: Vector2(0, 40));

  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;

  late PlayerBody playerBody;

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);

    Vector2 gameSize = screenToWorld(cameraComponent.viewport.size);
    cameraWorld.add(Ground(gameSize));

    playerBody = PlayerBody(mapSize: gameSize);
    cameraWorld.add(playerBody);
    // playerBody.loaded.then((value) {
    // print("loaded");
    // playerBody.body.position = Vector2(20, 10);
    // });
  }
}

class Ground extends BodyComponent {
  final Vector2 gameSize;
  Ground(this.gameSize);
  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(
          Vector2(0, gameSize.y * 0.8), Vector2(gameSize.x, gameSize.y * 0.8));
    BodyDef bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);
    FixtureDef fixtureDef = FixtureDef(shape, friction: 0.3, density: 1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}
