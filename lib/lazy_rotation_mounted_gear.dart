import 'dart:math';
import 'package:dummy_with_hat/mounted_gear.dart';
import 'package:flare_dart/actor_node.dart';
import 'package:flare_dart/math/vec2d.dart';

import 'mountable_actor.dart';
import 'package:flare_dart/math/mat2d.dart';

class LazyNode {
  final String nodeName;
  final double laziness;
  final double restitution;
  double originalRotation;

  ActorNode node;
  Vec2D lastWorldProjection;

  LazyNode(this.nodeName, {this.laziness=1.0, this.restitution=1.0});
}

class LazyRotationMountedGear extends MountedGear {
  final List<LazyNode> lazyNodes;

  LazyRotationMountedGear(String filename,
      {String alignmentNode,
      String targetShape,
      Mat2D mountOffset,
      this.lazyNodes})
      : super(filename,
            alignmentNode: alignmentNode,
            targetShape: targetShape,
            mountOffset: mountOffset);

  @override
  void onMounted() {
    for (final LazyNode lazy in lazyNodes) {
      lazy.node = gearArtboard.getNode(lazy.nodeName);
      lazy.originalRotation = lazy.node.rotation;
    }
  }

  void updateTransform(MountableActorShape shape) {
    super.updateTransform(shape);
  }

  // Vec2D lastGearWorldProjection;
  Mat2D inverseWorld = Mat2D();

  void advance(elapsedSeconds) {
    super.advance(elapsedSeconds);

    if (lazyNodes.isNotEmpty) {

      // First pass, roate towards old rotation.
      for (final LazyNode lazy in lazyNodes) {
        if (lazy.node != null) {
          if (lazy.lastWorldProjection != null) {
            if (Mat2D.invert(inverseWorld, lazy.node.worldTransform)) {
              Vec2D inLocal = Vec2D.transformMat2D(
                  Vec2D(), lazy.lastWorldProjection, inverseWorld);

              double radianRotation = atan2(inLocal[1], inLocal[0]);
              // Correct towards the local rotation such that the shape feels heavy and a little loose on the character's head.
              lazy.node.rotation += radianRotation * lazy.laziness;
              // Tend back towards origin.
              lazy.node.rotation += (lazy.originalRotation-lazy.node.rotation)*min(1.0, lazy.restitution*elapsedSeconds);
            }
          } else {
            lazy.lastWorldProjection = Vec2D();
          }
        }
      }

      // Compute all new world transforms.
      gearArtboard.advance(elapsedSeconds);

      // Final pass, extract new world projections.
      for (final LazyNode lazy in lazyNodes) {
          // Compute a position projected along the X axis so that we can invert it in the next frame
          // to determine how much the shape rotated locally
          Vec2D.transformMat2D(lazy.lastWorldProjection,
              Vec2D.fromValues(300.0, 0.0), lazy.node.worldTransform);
      }
    }
  }
}
