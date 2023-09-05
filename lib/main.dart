import 'dart:async';
import 'dart:math';
import 'package:flame/flame.dart';
import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame/palette.dart';
import 'package:flame/sprite.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:flutter/material.dart';
import 'package:testforged2d/utils/create_animation_by_limit.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

// class Explotion extends SpriteAnimationComponent{
//   @override
//   FutureOr<void> onLoad() async{
//     final spriteImage = await Flame.images.load('explotions.png');
//     final spriteSheet = SpriteSheet(
//         image: spriteImage,
//         srcSize: Vector2(192, 192));
//         animation = spriteSheet.createAnimationByLimit(
//         xInit: 0, yInit: 0, step: 8, sizeX: 5, stepTime: .08, loop: false);
//     return super.onLoad();
//   }
// }

class MyGame extends Forge2DGame with TapDetector {
  MyGame() : super(gravity: Vector2(0, 30));
  final cameraWorld = camera.World();
  late final CameraComponent cameraComponent;

  @override
  Future<void> onLoad() async {
    cameraComponent = CameraComponent(world: cameraWorld);
    cameraComponent.viewfinder.anchor = Anchor.topLeft;

    addAll([cameraComponent, cameraWorld]);
    Vector2 gameSize = screenToWorld(cameraComponent.viewport.size);
    cameraWorld.add(Ground(gameSize));
  }

  @override
  void onTapDown(TapDownInfo info) {
    super.onTapDown(info);
    // cameraWorld.add(Box(info.eventPosition.game));

    if (Random.secure().nextBool()) {
      cameraWorld.add(Box(info.eventPosition.game));
    } else {
      cameraWorld.add(Ball(info.eventPosition.game));
    }
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

class BallComponent extends SpriteComponent {
  @override
  FutureOr<void> onLoad() async {
    sprite = await Sprite.load('ball.png');
    size = Vector2.all(10);
    anchor = Anchor.center;

    return super.onLoad();
  }
}

class _Base extends BodyComponent with ContactCallbacks {
  final Vector2 position;
  late final SpriteAnimation explotionAnimation;

  _Base(this.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    final spriteImage = await Flame.images.load('explotions.png');
    final spriteSheet =
        SpriteSheet(image: spriteImage, srcSize: Vector2(192, 192));
    explotionAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 20, sizeX: 5, stepTime: .03, loop: false);
  }

  @override
  void beginContact(Object other, Contact contact) {
    print("beginContact" + other.toString());

    if (other is Ball || other is Box) {
      gameRef.add(SpriteAnimationComponent(
        position: body.position,
        animation: explotionAnimation.clone(),
        anchor: Anchor.center,
        size: Vector2.all(50),
        removeOnFinish: true,
      ));

      removeFromParent();
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    print("endContact" + other.toString());
    super.endContact(other, contact);
  }

  @override
  Body createBody() {
    // TODO: implement createBody
    throw UnimplementedError();
  }
}

class Box extends _Base {
  Box(super.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(BoxComponent());
  }

  @override
  Body createBody() {
    // Shape shape = CircleShape()..radius = 3;
    final shape = PolygonShape();
    shape.setAsBoxXY(5, 5);
    BodyDef bodyDef = BodyDef(
        position: Vector2(position.x, position.y),
        type: BodyType.dynamic,
        userData: this);
    FixtureDef fixtureDef =
        FixtureDef(shape, friction: 1, density: 5, restitution: .1);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }
}

class Ball extends _Base {
  Ball(super.position);

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    add(BallComponent());
  }

  @override
  Body createBody() {
    final shape = CircleShape()..radius = 5;
    BodyDef bodyDef = BodyDef(
        position: Vector2(position.x, position.y),
        type: BodyType.dynamic,
        userData: this);
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
  }
}
