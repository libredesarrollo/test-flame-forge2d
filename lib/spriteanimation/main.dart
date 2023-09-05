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
