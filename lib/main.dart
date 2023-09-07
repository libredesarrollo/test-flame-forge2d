import 'dart:async';
import 'dart:math';
import 'package:flame/flame.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:testforged2d/components/player.dart';
import 'package:testforged2d/test/_main.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame with TapDetector {
  MyGame() : super(gravity: Vector2(0, 30));

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
    playerBody.loaded.then((value) {
      print("loaded");
      playerBody.bodyDef.position = Vector2(20, 10);
    });
  }
}
