import 'dart:ui';

import 'package:flare_dart/math/transform_components.dart';
import 'package:flutter/services.dart';

import 'mounted_item.dart';

import 'mountable_actor.dart';
import 'package:flare_dart/math/mat2d.dart';
import 'package:flare_flutter/flare.dart';

class MountedGear extends MountedItem {
  final String filename;
  final String alignmentNode;
  final String targetShape;
  final Mat2D mountOffset;
  MountedGear(this.filename,
      {this.alignmentNode, this.targetShape, this.mountOffset});

  FlutterActor _gear;
  FlutterActorArtboard _gearArtboard;
  ActorNode _gearAlignmentNode;
  MountableActorShape _mountedToShape;
  ActorNode get gearAlignmentNode => _gearAlignmentNode;
  FlutterActorArtboard get gearArtboard => _gearArtboard;
  MountableActorShape get mountedToShape => _mountedToShape;

  Future<bool> initialize(
      AssetBundle assetBundle, MountableArtboard artboard) async {
    FlutterActor gear = FlutterActor();
    if (!await gear.loadFromBundle(assetBundle, filename)) {
      return false;
    }

    gear.artboard.initializeGraphics();
    MountableActorShape shape = artboard.mount(targetShape, this);
    if (shape == null) {
      gear.dispose();
      return false;
    }
    _gear = gear;
    _gearArtboard = gear.artboard;
    _mountedToShape = shape;
    _gearAlignmentNode =
        alignmentNode == null ? null : _gearArtboard.getNode(alignmentNode);
    _gearArtboard.advance(0.0);
    onMounted();
    return true;
  }

  void onMounted() {}

  Mat2D computeToGearTransform() {
    Mat2D toGearTransform = Mat2D();
    if (gearAlignmentNode != null) {
      // Reset the mounted artboard to world origin so that we can
      // correctly compute relative transform to other artboard's world
      // If we don't do this we'll create a feedback loop.
      // This is only necessary if you expect to animate the mount point
      // within your "hat" artboard.
      gearArtboard.root.x = 0.0;
      gearArtboard.root.y = 0.0;
      gearArtboard.root.scaleX = 1.0;
      gearArtboard.root.scaleY = 1.0;
      gearArtboard.root.rotation = 0.0;
      gearArtboard.advance(0.0);
      if (!Mat2D.invert(toGearTransform, gearAlignmentNode.worldTransform)) {
        return toGearTransform;
      }
    }
    if (mountOffset != null) {
      Mat2D.multiply(toGearTransform, mountOffset, toGearTransform);
    }
    return toGearTransform;
  }

  // A mount shape's transform has been updated, use this opportunity to update
  // relevant mounted artboard's transform too.
  void updateTransform(MountableActorShape shape) {
    if (shape == _mountedToShape) {
      Mat2D toGearTransform = computeToGearTransform();
      Mat2D.multiply(toGearTransform, shape.worldTransform, toGearTransform);

      TransformComponents transformComponents = TransformComponents();
      Mat2D.decompose(toGearTransform, transformComponents);

      _gearArtboard.root.translation = transformComponents.translation;
      _gearArtboard.root.scaleX = transformComponents.scaleX;
      _gearArtboard.root.scaleY = transformComponents.scaleY;
      _gearArtboard.root.rotation = transformComponents.rotation;
    }
  }

  // Return false if you do not want the default paint operation to be completed.
  bool paint(MountableActorShape shape, Canvas canvas) {
    if (shape == _mountedToShape) {
      _gearArtboard.draw(canvas);
    }
    return false;
  }

  void advance(elapsedSeconds) {
    _gear?.artboard?.advance(elapsedSeconds);
  }

  void dispose() {
    _mountedToShape?.unmount(this);
    _mountedToShape = null;
    _gear?.dispose();
    _gear = null;
  }
}
