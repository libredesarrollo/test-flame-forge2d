import 'dart:async';
import 'package:flame_tiled/flame_tiled.dart';
import 'package:flutter/material.dart';

// import 'package:flame/camera.dart' as camera;
import 'package:flame/components.dart';
import 'package:flame/events.dart';
import 'package:flame/game.dart';
import 'package:flame_forge2d/flame_forge2d.dart';
import 'package:testforged2d/background/tile_map_component.dart';
import 'package:testforged2d/components/character.dart';
import 'package:testforged2d/components/ground.dart';

import 'package:testforged2d/components/player.dart';

void main() {
  runApp(GameWidget(game: MyGame()));
}

class MyGame extends Forge2DGame
    with TapDetector, HasKeyboardHandlerComponents {
  MyGame() : super(gravity: Vector2(0, 40), zoom: 10);

  // late TileMapComponent background;

  //final cameraWorld = camera.World();
  // late final CameraComponent cameraComponent;

  late PlayerBody playerBody;

  @override
  Future<void> onLoad() async {
    // cameraComponent = CameraComponent(world: cameraWorld);

    camera.viewfinder.anchor = Anchor.topLeft;

    Vector2 gameSize = screenToWorld(camera.viewport.size);

    // background = TileMapComponent(game: this);
    playerBody = PlayerBody(mapSize: gameSize);

    playerBody.loaded.then((value) {
      playerBody.playerComponent.loaded.then((value) {
        camera.follow(playerBody);
        camera.viewfinder.anchor = Anchor.center;
      });
    });

    // world.add(background);
    world.add(playerBody);

    tile();

    world.physicsWorld
        .setContactFilter(CustomContactFilter(playerBody: playerBody));

    // background.loaded.then(
    //   (value) {
    //   },
    // );

    // playerBody.loaded.then((value) {
    // print("loaded");
    // playerBody.body.position = Vector2(20, 10);
    // });
  }

  tile() async {
    final tiledMap = await TiledComponent.load('map3.tmx', Vector2.all(32));
    final objGroup = tiledMap.tileMap.getLayer<ObjectGroup>('ground');

    for (var obj in objGroup!.objects) {
      world.add(GroundBody(
          size: screenToWorld(Vector2(obj.width, obj.height)),
          pos: screenToWorld(
              Vector2(obj.x + (obj.width / 2), obj.y + (obj.height / 2)))));
    }
    tiledMap.scale = Vector2.all(.1);
    world.add(tiledMap);
  }

  // @override
  // Future<void> onLoad() async {
  // cameraComponent = CameraComponent(world: cameraWorld);
  // cameraComponent.viewfinder.anchor = Anchor.topLeft;

  //camera.viewfinder.anchor = Anchor.topLeft;

  // addAll([cameraComponent, cameraWorld]);

  // Vector2 gameSize = screenToWorld(cameraComponent.viewport.size);
  // cameraWorld.add(Ground(gameSize));

  // playerBody = PlayerBody(mapSize: gameSize);
  // cameraWorld.add(playerBody);
  // playerBody.loaded.then((value) {
  // print("loaded");
  // playerBody.body.position = Vector2(20, 10);
  // });
  // }
}

// class Ground extends BodyComponent {
//   final Vector2 gameSize;
//   Ground(this.gameSize);
//   @override
//   Body createBody() {
//     final shape = EdgeShape()
//       ..set(
//           Vector2(0, gameSize.y * 0.8), Vector2(gameSize.x, gameSize.y * 0.8));
//     BodyDef bodyDef = BodyDef(
//         userData: this, position: Vector2.zero(), type: BodyType.static);
//     FixtureDef fixtureDef = FixtureDef(shape, friction: 0.3, density: 1);
//     return world.createBody(bodyDef)..createFixture(fixtureDef);
//   }
// }

class CustomContactFilter implements ContactFilter {
  final PlayerBody playerBody;

  CustomContactFilter({required this.playerBody});

  @override
  bool shouldCollide(Fixture fixtureA, Fixture fixtureB) {
    // si el player esta en el aire, puede transpasar los tiles
    // verificamos que los cuerpos en contacto son el player y el piso
    if (playerBody.movementType == MovementType.jump &&
        (fixtureA.body.userData is PlayerBody &&
            fixtureB.body.userData is GroundBody)) {
      return false;
    }
    return true;
  }
}
