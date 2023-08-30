import 'dart:async';
import 'package:flame/flame.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:testforged2d/ball.dart';

import 'package:testforged2d/utils/boundaries.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame {
  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;

  static const String description = '''
    In this example we show how to use Flame's TapCallbacks mixin to react to
    taps on `BodyComponent`s.
    Tap the ball to give it a random impulse, or the text to add an effect to
    it.
  ''';
  MyGame() : super(zoom: 20, gravity: Vector2(0, 10.0));

  @override
  Future<void> onLoad() async {
    final boundaries = createBoundaries(this);
    boundaries.forEach(add);

    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);

    final center = screenToWorld(cameraComponent.viewport.size / 2);
    add(TappableBall(center));
  }
}

class TappableBall extends Ball with TapCallbacks {
  TappableBall(super.position) {
    // originalPaint = BasicPalette.white.paint();
    paint = originalPaint;
  }

  @override
  void onTapDown(_) {
    body.applyLinearImpulse(Vector2.random() * 1000);
    paint = randomPaint();
  }
}
