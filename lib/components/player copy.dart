import 'package:flutter/services.dart';

import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:testforged2d/components/character.dart';
import 'package:testforged2d/test/_main.dart';
import 'package:testforged2d/utils/create_animation_by_limit.dart';

class PlayerBody extends BodyComponent with ContactCallbacks, KeyboardHandler {
  Vector2 mapSize;

  // sprite
  late PlayerComponent _playerComponent;

  // player state
  MovementType _movementType = MovementType.idle;

  Vector2 _playerMove = Vector2.all(0);
  // mobility and jump
  final double _playerNormalVelocity = 15.0;
  final double _playerNormalJump = -25.0;

  bool _inGround = false;

  PlayerBody({required this.mapSize});

  @override
  Future<void> onLoad() async {
    await super.onLoad();
    _playerComponent = PlayerComponent(mapSize: mapSize);
    add(_playerComponent);
  }

  @override
  Body createBody() {
    final position = Vector2(15, 15);
    final shape = PolygonShape();
    // paint = BasicPalette.transparent.paint();
    shape.setAsBoxXY(5, 5);
    final bodyDef = BodyDef(
        position: Vector2(position.x, position.y),
        type: BodyType.dynamic,
        userData: this);
    FixtureDef fixtureDef =
        FixtureDef(shape, friction: 1, density: 15, restitution: 0);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    if (keysPressed.isEmpty) {
      _movementType = MovementType.idle;
      _playerMove = Vector2.all(0);
    }

    // if (true) {//_inGround
    // RIGHT
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN
        _movementType = MovementType.runright;
        _playerMove.x = _playerNormalVelocity * 3;
      } else {
        // WALKING
        _movementType = MovementType.walkingright;
        _playerMove.x = _playerNormalVelocity;
      }
    }
    // LEFT
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN
        _movementType = MovementType.runleft;
        _playerMove.x = -_playerNormalVelocity * 3;
      } else {
        // WALKING
        _movementType = MovementType.walkingleft;
        _playerMove.x = -_playerNormalVelocity;
      }
    }
    // JUMP
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      _movementType = MovementType.jump;
      // print("LogicalKeyboardKey.space");
      if (_inGround) {
        _playerMove.y = _playerNormalJump;
      } else {
        _playerMove = Vector2.all(0);
      }
    }
    // } else {
    //   if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
    //       keysPressed.contains(LogicalKeyboardKey.keyD)) {
    //     // RIGHT
    //     movementType = MovementType.jumpright;
    //   } else if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
    //       keysPressed.contains(LogicalKeyboardKey.keyA)) {
    //     // LEFT
    //     movementType = MovementType.jumpleft;
    //   }
    // }

    _playerComponent.setMode(_movementType);

    return true;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is Ground) {
      _inGround = true;
      body.linearVelocity = Vector2.all(0);
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is Ground) {
      _inGround = false;
      // body.linearVelocity = Vector2.all(0);
    }

    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    // final velocity = body.linearVelocity;
    // final position = body.position;

    // print(playerMove.x.toString());

    // if (playerMove.y != 0 && _inGround) {
    // print(playerMove.y.toString() +
    //     '*************************' +
    //     _inGround.toString());
    // print(body.position.x.toString() + "-----");
    // body.linearVelocity = Vector2(body.position.x, playerMove.y);
    //body.linearVelocity = playerMove; //Vector2(body.position.x, playerMove.y);
    // body.linearVelocity = playerMove;
    // body.linearVelocity.y = playerMove.y;
    // body.linearVelocity.x = body.position.x;

    // body.applyForce(playerMove * 2000);
    // body.applyLinearImpulse(playerMove * 50);

    // _inGround = false;
    // }

    // body.linearVelocity = velocity;

    body.setTransform(body.position, 0);
    if (_playerMove != Vector2.all(0)) {
      // print(playerMove.x.toString() + " " + body.position.x.toString());
      print(body.linearVelocity.toString());
      // body.position.x += dt * playerMove.x;
      // body.position.y += dt * playerMove.y;
      body.linearVelocity = _playerMove;
    }

    // if (playerMove.y != 0 && _inGround) {
    //   print(playerMove.y.toString() +
    //       "  " +
    //       _inGround.toString() +
    //       "   " +
    //       body.linearVelocity.toString() +
    //       "++++");

    // body.linearVelocity = playerMove;

    // body.applyForce(Vector2(body.position.x, playerMove.y * 20000));
    //body.applyLinearImpulse(Vector2(50, playerMove.y * 200));
    // body.position.x = 80;
    // }

    // bodyDef.position.x = dt * 500;
    super.update(dt);
  }
}

class PlayerComponent extends Character {
  Vector2 mapSize;
  late SpriteAnimationTicker deadAnimationTicker;

  PlayerComponent({required this.mapSize}) : super() {
    anchor = Anchor.center;
  }

  // set the animation
  setMode(MovementType movementType) {
    switch (movementType) {
      case MovementType.idle:
        animation = idleAnimation;
        break;
      case MovementType.walkingleft:
        if (right) flipHorizontally();
        right = false;
        animation = walkAnimation;
        break;
      case MovementType.walkingright:
        if (!right) flipHorizontally();
        right = true;
        animation = walkAnimation;
        break;
      case MovementType.runleft:
        if (right) flipHorizontally();
        right = false;
        animation = runAnimation;
        break;
      case MovementType.runright:
        if (!right) flipHorizontally();
        right = true;
        animation = runAnimation;
        break;
      case MovementType.jump:
      case MovementType.fall:
        // case MovementType.jumpleft:
        // case MovementType.jumpright:
        animation = jumpAnimation;
        break;
    }
  }

  @override
  Future<void>? onLoad() async {
    final spriteImage = await Flame.images.load('dinofull.png');
    final spriteSheet = SpriteSheet(
        image: spriteImage,
        srcSize: Vector2(spriteSheetWidth, spriteSheetHeight));

    // init animation
    deadAnimation = spriteSheet.createAnimationByLimit(
        xInit: 0, yInit: 0, step: 8, sizeX: 5, stepTime: .08, loop: false);
    idleAnimation = spriteSheet.createAnimationByLimit(
        xInit: 1, yInit: 2, step: 10, sizeX: 5, stepTime: .08);
    jumpAnimation = spriteSheet.createAnimationByLimit(
        xInit: 3, yInit: 0, step: 12, sizeX: 5, stepTime: .08, loop: false);
    runAnimation = spriteSheet.createAnimationByLimit(
        xInit: 5, yInit: 0, step: 8, sizeX: 5, stepTime: .08);
    walkAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: .08);
    walkSlowAnimation = spriteSheet.createAnimationByLimit(
        xInit: 6, yInit: 2, step: 10, sizeX: 5, stepTime: .32);

    animation = idleAnimation;
    size = Vector2(spriteSheetWidth / 40, spriteSheetHeight / 40);

    return super.onLoad();
  }

  // void reset({bool dead = false}) async {
  //   movementType = MovementType.idle;
  //   if (dead) {
  //     animation = deadAnimation;

  //     deadAnimationTicker = deadAnimation.createTicker();
  //     deadAnimationTicker.onFrame = (index) {
  //       // print("-----" + index.toString());
  //       if (deadAnimationTicker.isLastFrame) {
  //         animation = idleAnimation;
  //         // position =
  //         //     Vector2(spriteSheetWidth / 4, mapSize.y - spriteSheetHeight);
  //       }
  //     };

  //     deadAnimationTicker.onComplete = () {
  //       if (animation == deadAnimation) {
  //         animation = idleAnimation;
  //       }
  //     };
  //   } else {
  //     animation = idleAnimation;
  //     size = Vector2(spriteSheetWidth / 40, spriteSheetHeight / 40);
  //   }
  // }
}
