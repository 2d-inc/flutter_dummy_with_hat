import 'dart:ui';

import 'package:dummy_with_hat/mountable_actor.dart';
import 'package:flutter/services.dart';

abstract class MountedItem {
  Future<bool> initialize(AssetBundle assetBundle, MountableArtboard artboard);

  // A mount shape's transform has been updated, use this opportunity to update
  // relevant mounted artboard's transform too.
  void updateTransform(MountableActorShape shape);

  // Return false if you do not want the default paint operation to be completed.
  bool paint(MountableActorShape shape, Canvas canvas);

  void advance(elapsedSeconds);

  void dispose() {}
}
