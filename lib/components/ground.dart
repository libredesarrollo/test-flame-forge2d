import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:flame/collisions.dart';
import 'package:flame/components.dart';

class GroundBody extends BodyComponent {
  final Vector2 size;
  final Vector2 pos;

  GroundBody({required this.size, required this.pos}) : super() {
    // renderBody = false;
  }

  @override
  Body createBody() {
    final shape = PolygonShape();
    // paint = BasicPalette.transparent.paint();

    // Vector2 s = game.screenToWorld(size);

    shape.setAsBoxXY(size.x / 2, size.y / 2);
    final bodyDef =
        BodyDef(position: pos, type: BodyType.static, userData: this);
    // Vector2 s = game.screenToWorld(size);

    // shape.setAsBoxXY(s.x / 2, s.y / 2);
    // final bodyDef = BodyDef(
    //     position: game.screenToWorld(position),
    //     type: BodyType.static,
    //     userData: this);

    FixtureDef fixtureDef = FixtureDef(shape, density: 1, friction: 0);

    // final shape = EdgeShape()..set(Vector2(size.x / 2, size.y / 2), position);

    // BodyDef bodyDef = BodyDef(
    //     userData: this, position: Vector2.zero(), type: BodyType.static);

    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  // @override
  // Future<void> onLoad() {
  //   // add(GroundComponent(position: position, size: size));
  //   return super.onLoad();
  // }
}

// class GroundComponent extends PositionComponent {
//   GroundComponent({required size, required position})
//       : super(size: size, position: position) {
//     // debugMode = true;
//     // scale = Vector2.all(.5);
//     //add(RectangleHitbox()..collisionType = CollisionType.active);
//   }
// }
