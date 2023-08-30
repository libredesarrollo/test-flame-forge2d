import 'dart:async';

import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with TapDetector {
  MyGame() : super(gravity: Vector2(0, 15));
  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;
  Player player = Player();

  final up = Vector2(0, -30);

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);
    Vector2 gameSize = screenToWorld(cameraComponent.viewport.size);
    cameraWorld.add(Ground(gameSize));
    cameraWorld.add(player);
  }

  @override
  void onTap() {
    // player.body.applyForce(up * 2000);
    player.body.applyLinearImpulse(up *
        30); // Los impulsos producen cambios inmediatos en la velocidad del cuerpo
    // player.body.linearVelocity = up; // velocidad lineal
    super.onTap();
  }
}

class Player extends BodyComponent {
  @override
  Body createBody() {
    // Shape shape = CircleShape()..radius = 3;
    final shape = PolygonShape();
    shape.setAsBoxXY(5, 3);
    BodyDef bodyDef =
        BodyDef(position: Vector2(15, 10), type: BodyType.dynamic);
    FixtureDef fixtureDef =
        FixtureDef(shape, friction: 1, density: 1, restitution: .1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ground extends BodyComponent {
  final Vector2 gameSize;
  Ground(this.gameSize);
  @override
  Body createBody() {
    final shape = EdgeShape()
      ..set(Vector2(0, gameSize.y * .4), Vector2(gameSize.x, gameSize.y * 0.9));

    BodyDef bodyDef = BodyDef(
        userData: this, position: Vector2.zero(), type: BodyType.static);

    FixtureDef fixtureDef = FixtureDef(shape, density: 1, friction: 1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
    // throw UnimplementedError();
  }
}
