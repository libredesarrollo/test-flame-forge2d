import 'package:flutter/services.dart';

import 'package:flame/sprite.dart';
import 'package:flame/flame.dart';
import 'package:flame/components.dart';
import 'package:flame_forge2d/flame_forge2d.dart';

import 'package:testforged2d/components/character.dart';
import 'package:testforged2d/components/ground.dart';

import 'package:testforged2d/utils/create_animation_by_limit.dart';

class PlayerBody extends BodyComponent with ContactCallbacks, KeyboardHandler {
  Vector2 mapSize;

  // sprite
  late PlayerComponent playerComponent;

  // player state
  MovementType movementType = MovementType.idle;

  Vector2 _playerMove = Vector2.all(0);

  // mobility and jump
  final double _playerNormalVelocity = 15.0;
  final double _playerNormalJump = -25.0;
  final double _playerNormalImpulse = 2000.0;

  bool _inGround = false;

  // double jump
  bool _doubleJump = false;
  final double _timeToDoubleJump = .5;
  double _elapseTimeToDoubleJump = 0;

  PlayerBody({required this.mapSize}) : super() {
    renderBody = true;
  }

  @override
  Future<void> onLoad() async {
    await super.onLoad();

    playerComponent = PlayerComponent(mapSize: mapSize);
    add(playerComponent);
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
        FixtureDef(shape, friction: 1, density: 0, restitution: 0);
    return world.createBody(bodyDef)..createFixture(fixtureDef);
  }

  @override
  bool onKeyEvent(RawKeyEvent event, Set<LogicalKeyboardKey> keysPressed) {
    // print(keysPressed.toString() + "   " + movementType.toString());
    if (keysPressed.isEmpty) {
      if (_inGround) movementType = MovementType.idle;
      _playerMove = Vector2.all(0);
      body.linearVelocity = Vector2.all(0);
    }

    // RIGHT
    if (keysPressed.contains(LogicalKeyboardKey.arrowRight) ||
        keysPressed.contains(LogicalKeyboardKey.keyD)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.runright;
        }

        _playerMove.x = _playerNormalVelocity * 3;
      } else {
        // WALKING
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.walkingright;
        }

        _playerMove.x = _playerNormalVelocity;
      }
    }
    // LEFT
    if (keysPressed.contains(LogicalKeyboardKey.arrowLeft) ||
        keysPressed.contains(LogicalKeyboardKey.keyA)) {
      if (keysPressed.contains(LogicalKeyboardKey.shiftLeft)) {
        // RUN

        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.runleft;
        }
        _playerMove.x = -_playerNormalVelocity * 3;
      } else {
        // WALKING
        if (movementType != MovementType.jump &&
            movementType != MovementType.fall) {
          movementType = MovementType.walkingleft;
        }

        _playerMove.x = -_playerNormalVelocity;
      }
    }
    // JUMP
    if (keysPressed.contains(LogicalKeyboardKey.space)) {
      movementType = MovementType.jump;
      if (_inGround) {
        _playerMove.y = _playerNormalJump;
      } else {
        // in the air
        if (_elapseTimeToDoubleJump >= _timeToDoubleJump && !_doubleJump) {
          // el usuario preciono la tecla para un doble salto
          // paso el tiempo en el cual se puede usar el doble salto
          // double jump active
          _doubleJump = true;
          _playerMove.y = _playerNormalJump;
        } else {
          // reset the jump
          _playerMove.y = 0;
        }
      }
    }

    // IMPULSE
    if (keysPressed.contains(LogicalKeyboardKey.keyC)) {
      _playerMove.x *= _playerNormalImpulse;
    }

    playerComponent.setMode(movementType);

    return true;
  }

  @override
  void beginContact(Object other, Contact contact) {
    if (other is GroundBody) {
      _inGround = true;
      body.linearVelocity = Vector2.all(0);
    }

    super.beginContact(other, contact);
  }

  @override
  void endContact(Object other, Contact contact) {
    if (other is GroundBody) {
      _inGround = false;
    }

    super.endContact(other, contact);
  }

  @override
  void update(double dt) {
    // print("$movementType -- ${body.linearVelocity}");

    // *** double jump
    if (movementType == MovementType.jump ||
        movementType == MovementType.fall) {
      // if the user is in the air
      _elapseTimeToDoubleJump += dt;
    } else {
      // reset the properties to double jump
      _elapseTimeToDoubleJump = 0;
      _doubleJump = false;
    }
    // *** double jump

    // keeps the player upright
    body.setTransform(body.position, 0);

    // only if there is movement
    if (_playerMove != Vector2.all(0)) {
      if (body.linearVelocity.y.abs() > 0.1 && _playerMove.y == 0) {
        // si el player tiene una velocidad aplicada en el eje Y, no se varia
        // esto evita que cuando el player esta en el aire y se mueve en el eje X
        // se aplique el _playerMove.y==0 en la velocidad del player
        // if the player has a speed applied to the Y axis, it does not vary
        // this prevents when the player is in the air and moves in the X axis
        // _playerMove.y==0 is applied to the player speed
        body.linearVelocity.x = _playerMove.x;
      } else {
        body.linearVelocity = _playerMove;
      }
    }

    if (body.linearVelocity.y > 0.1 && movementType == MovementType.jump) {
      // el player tiene una velocidad aplicada positiva, por lo tanto, esta cayendo
      // The player has a positive applied velocity, therefore, he is falling
      movementType = MovementType.fall;
      playerComponent.setMode(MovementType.fall);
    } else if (/*body.linearVelocity.y == 0*/ _inGround &&
        movementType == MovementType.fall) {
      // si el player esta en el aire, cayendo al entrar en contacto
      // con el piso, tiene velocidad cero, se coloca en reposo
      // si no queda con la animacion de saltando
      // if the player is in the air, falling upon contact
      // with the floor, it has zero speed, it is placed at rest
      // if it doesn't stay with the jumping animation
      movementType = MovementType.idle;
      playerComponent.setMode(movementType);
    }
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
}
