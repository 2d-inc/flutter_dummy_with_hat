import 'mounted_item.dart';
import 'flare_render_box.dart';
import 'mountable_actor.dart';
import 'package:flare_flutter/flare.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter/rendering.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_dart/math/aabb.dart';

class Dummy extends LeafRenderObjectWidget {
  final BoxFit fit;
  final Alignment alignment;
  final bool isPlaying;

  // Dummy specific.
  final bool isRunning;
  final double speed;
  final MountedItem mountedItem;

  Dummy(
      {this.fit = BoxFit.contain,
      this.alignment = Alignment.center,
      this.isPlaying = true,
      this.isRunning = false,
      this.speed = 1.0,
      this.mountedItem});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return DummyRenderObject()
      ..assetBundle = DefaultAssetBundle.of(context)
      ..fit = fit
      ..alignment = alignment
      ..isPlaying = isPlaying
      ..isRunning = isRunning
      ..speed = speed
      ..mountedItem = mountedItem;
  }

  @override
  void updateRenderObject(
      BuildContext context, covariant DummyRenderObject renderObject) {
    renderObject
      ..assetBundle = DefaultAssetBundle.of(context)
      ..fit = fit
      ..alignment = alignment
      ..isPlaying = isPlaying
      ..isRunning = isRunning
      ..speed = speed
      ..mountedItem = mountedItem;
  }

  didUnmountRenderObject(covariant DummyRenderObject renderObject) {
    renderObject.dispose();
  }
}

class DummyRenderObject extends FlareRenderBox {
  MountableActor _character;

  ActorAnimation _running;
  ActorAnimation _idle;
  double _runMix = 0.0;
  double _animationTime = 0.0;

  bool isRunning = false;
  double speed = 1.0;
  static const double transitionSpeed = 3.0;
  MountedItem _mountedItem;
  MountedItem get mountedItem => _mountedItem;
  set mountedItem(MountedItem value) {
    if (_mountedItem == value) {
      return;
    }

    updateMountedItem(value);
  }

  void updateMountedItem(MountedItem value) {
    _mountedItem?.dispose();
    _mountedItem = value;
    if (value == null || _character == null) {
      return;
    }

    _mountedItem.initialize(assetBundle, _character.artboard).then((bool success) {
      if (!success || _mountedItem != value) {
        // return if we failed to load or the gear is no longer the original request
        value?.dispose();
        return;
      }
    });
  }

  @override
  void advance(double elapsedSeconds) {
    _animationTime += elapsedSeconds * speed;
    _runMix +=
        elapsedSeconds * (isRunning ? transitionSpeed : -transitionSpeed);
    _runMix = _runMix.clamp(0.0, 1.0);
    if (_runMix < 1.0) {
      _idle.apply(_animationTime % _idle.duration, _character.artboard, 1.0);
    }
    if (_runMix > 0.0) {
      _running.apply(
          _animationTime % _running.duration, _character.artboard, _runMix);
    }

    _character.artboard.advance(elapsedSeconds);
  }

  @override
  AABB get aabb => _character?.artboard?.artboardAABB();

  @override
  void paintFlare(Canvas canvas, Mat2D viewTransform) {
    // Make sure loading is complete.
    if (_character == null) {
      return;
    }
    (_character.artboard as FlutterActorArtboard).draw(canvas);
  }

  @override
  void load(AssetBundle assetBundle) async {
    MountableActor character = MountableActor();
    if (!await character.loadFromBundle(assetBundle, "assets/Dummy_hat.flr")) {
      throw Exception("Missing Dummy_hat.flr.");
    }

    character.artboard.initializeGraphics();
    _idle = character.artboard.getAnimation("idle_1");
    _running = character.artboard.getAnimation("run_1");
    _character = character;
    updateMountedItem(_mountedItem);

    advance(0.0);
  }
}
