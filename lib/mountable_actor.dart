import 'dart:ui' as ui;
import 'package:flare_dart/actor_component.dart';

import 'mounted_item.dart';
import 'package:flare_dart/actor_artboard.dart';
import 'package:flare_dart/actor_shape.dart';
import "package:flare_flutter/flare.dart";

// We create a custom Actor in order to override the shape nodes
// which we are using to add "injection" rendering/mounting functionality.
class MountableActor extends FlutterActor {
  @override
  ActorShape makeShapeNode() {
    return MountableActorShape();
  }

  @override
  ActorArtboard makeArtboard() {
    return MountableArtboard(this);
  }
}

class MountableArtboard extends FlutterActorArtboard {
  MountableArtboard(FlutterActor actor) : super(actor);

  Set<MountedItem> _mountedItems = Set<MountedItem>();

  /// Try to mount an item to a specific shape node, will return the
  /// [MountableActorShape] node if it succeeds.
  MountableActorShape mount(String shapeName, MountedItem item) {
    ActorNode node = getNode(shapeName);
    if (node is! MountableActorShape) {
      return null;
    }
    if ((node as MountableActorShape).mount(item)) {
      _mountedItems.add(item);
      return node;
    } else {
      return null;
    }
  }

  /// [MountableActorShape] notifies us when an item is unmounted
  /// this gives us the opportunity to clean up the list of mounts we store
  void onUnmount(MountedItem item) {
    bool unmount = true;
    for (ActorComponent component in components) {
      if (component is MountableActorShape && component.hasMount(item)) {
        unmount = false;
        break;
      }
    }
    if (unmount) {
      _mountedItems.remove(item);
    }
  }

  // Advance mounted items too.
  @override
  void advance(double seconds) {
    super.advance(seconds);
    for (final MountedItem item in _mountedItems) {
      item.advance(seconds);
    }
  }
}

// This is the custom actor shape we create with mount options
class MountableActorShape extends FlutterActorShape {
  List<MountedItem> _mounts;

  // Check if a specific item is mounted to this shape
  bool hasMount(MountedItem item) {
    return _mounts == null ? false : _mounts.contains(item);
  }

  // attempt to mount an item to this shape
  bool mount(MountedItem item) {
    if (_mounts == null) {
      _mounts = [];
    }
    if (_mounts.contains(item)) {
      return false;
    }
    _mounts.add(item);
    return true;
  }

  // attempt to unmount an item from this shape
  bool unmount(MountedItem item) {
    bool removed = _mounts.remove(item);
    (artboard as MountableArtboard).onUnmount(item);
    return removed;
  }

  // Whenever this shapes updates its transform, lets also
  // take that opportunity to update the mount, if we have one
  @override
  void updateWorldTransform() {
    super.updateWorldTransform();
    if (_mounts != null) {
      for (final MountedItem item in _mounts) {
        item.updateTransform(this);
      }
    }
  }

  void draw(ui.Canvas canvas) {
    if (!doesDraw) {
      return;
    }

    bool paintSelf = true;
    if (_mounts != null) {
      for (final MountedItem item in _mounts) {
        if (!item.paint(this, canvas)) {
          paintSelf = false;
        }
      }
    }
    if (!paintSelf) {
      return;
    }
    // draw original shape
    super.draw(canvas);
  }
}
