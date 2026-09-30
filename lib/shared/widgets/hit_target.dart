import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Gives a control drawn smaller than 48×48 a 48×48 touch target, centred on
/// it, without changing its size or anyone's layout.
///
/// The extended area is the control's as far as touch and accessibility are
/// concerned: a tap anywhere in it reaches the control (delivered at the
/// control's centre, the way Material's padded tap targets do), and the
/// control's semantics node reports that area as its bounds, so the platform
/// tap-target guidelines measure what a finger actually gets.
///
/// A render box only hit-tests positions inside its own size, so an area that
/// reaches outside the control's parent cannot be found by walking down the
/// tree. That routing is done by the nearest [HitTargetScope] above, which must
/// be big enough to contain the extended area — wrap the block the control
/// sits in, not the control.
///
/// Where extended areas overlap, a touch goes to the control nearest to it.
/// A touch on a control that is drawn — whether or not it is an extender — is
/// never taken by an extender that sits *under* it in paint order; one painted
/// above it may take it (a row's menu button over the row).
///
/// Merges the control's semantics into one node, as [MergeSemantics] does, so
/// the node that carries the tap action is the one with the extended bounds.
/// Pass `mergeSemantics: false` for a subtree with more than one action.
class HitTargetExtender extends SingleChildRenderObjectWidget {
  const HitTargetExtender({
    super.key,
    this.minSize = const Size.square(kMinInteractiveDimension),
    this.mergeSemantics = true,
    super.child,
  });

  /// Marks [child] as a drawn control whose own pixels an extended target
  /// under it must not take, without extending anything itself.
  const HitTargetExtender.obstacle({super.key, super.child})
    : minSize = Size.zero,
      mergeSemantics = false;

  /// The smallest area the control answers touches in. A dimension the
  /// control already exceeds is left as it is.
  final Size minSize;

  final bool mergeSemantics;

  @override
  RenderHitTargetExtender createRenderObject(BuildContext context) =>
      RenderHitTargetExtender(minSize: minSize, mergeSemantics: mergeSemantics);

  @override
  void updateRenderObject(
    BuildContext context,
    RenderHitTargetExtender renderObject,
  ) {
    renderObject
      ..minSize = minSize
      ..mergeSemantics = mergeSemantics;
  }
}

/// Routes touches in the extended areas of the [HitTargetExtender]s below it.
///
/// Has no size or paint of its own. Place it around the smallest block that
/// contains every extended area it serves, and inside any scrollable, so a
/// drag that starts on an extended area still scrolls.
class HitTargetScope extends SingleChildRenderObjectWidget {
  const HitTargetScope({super.key, super.child});

  @override
  RenderHitTargetScope createRenderObject(BuildContext context) =>
      RenderHitTargetScope();
}

class RenderHitTargetExtender extends RenderProxyBox {
  RenderHitTargetExtender({required Size minSize, required bool mergeSemantics})
    : _minSize = minSize,
      _mergeSemantics = mergeSemantics;

  Size get minSize => _minSize;
  Size _minSize;
  set minSize(Size value) {
    if (value == _minSize) return;
    _minSize = value;
    markNeedsSemanticsUpdate();
  }

  bool get mergeSemantics => _mergeSemantics;
  bool _mergeSemantics;
  set mergeSemantics(bool value) {
    if (value == _mergeSemantics) return;
    _mergeSemantics = value;
    markNeedsSemanticsUpdate();
  }

  RenderHitTargetScope? _scope;

  /// The area this control answers touches in, in its own coordinates.
  Rect get targetRect => Rect.fromCenter(
    center: size.center(Offset.zero),
    width: size.width > minSize.width ? size.width : minSize.width,
    height: size.height > minSize.height ? size.height : minSize.height,
  );

  bool get _extends => minSize.width > 0 || minSize.height > 0;

  @override
  void attach(PipelineOwner owner) {
    super.attach(owner);
    var node = parent;
    while (node != null && node is! RenderHitTargetScope) {
      node = node.parent;
    }
    _scope = node as RenderHitTargetScope?;
    _scope?._extenders.add(this);
    assert(
      _scope != null || !_extends,
      'A HitTargetExtender needs a HitTargetScope above it to route touches '
      'in its extended area.',
    );
  }

  @override
  void detach() {
    _scope?._extenders.remove(this);
    _scope = null;
    super.detach();
  }

  @override
  Rect get semanticBounds => mergeSemantics ? targetRect : super.semanticBounds;

  @override
  void describeSemanticsConfiguration(SemanticsConfiguration config) {
    super.describeSemanticsConfiguration(config);
    if (!mergeSemantics) return;
    config
      ..isSemanticBoundary = true
      ..isMergingSemanticsOfDescendants = true;
  }

  /// Hit-tests the child at its centre on behalf of a touch at [position],
  /// which is in the extended area but outside the child.
  bool _hitTestExtended(BoxHitTestResult result, Offset position) {
    final child = this.child;
    if (child == null) return false;
    final center = child.size.center(Offset.zero);
    final hit = result.addWithRawTransform(
      transform: MatrixUtils.forceToPoint(center),
      position: center,
      hitTest: (result, _) => child.hitTest(result, position: center),
    );
    if (hit) result.add(BoxHitTestEntry(this, position));
    return hit;
  }
}

class RenderHitTargetScope extends RenderProxyBox {
  final Set<RenderHitTargetExtender> _extenders = {};

  @override
  bool hitTest(BoxHitTestResult result, {required Offset position}) {
    if (!size.contains(position)) return false;
    final target = _extendedTargetAt(position);
    if (target != null) {
      final hit = result.addWithPaintTransform(
        transform: target.getTransformTo(this),
        position: position,
        hitTest: (result, local) => target._hitTestExtended(result, local),
      );
      if (hit) {
        result.add(BoxHitTestEntry(this, position));
        return true;
      }
    }
    return super.hitTest(result, position: position);
  }

  /// The extender whose extended area — not its own box — should take a touch
  /// at [position], or null to hit-test normally.
  RenderHitTargetExtender? _extendedTargetAt(Offset position) {
    if (_extenders.isEmpty) return null;
    // Paint order: a later extender is drawn over an earlier one.
    final ordered = <RenderHitTargetExtender>[];
    void visit(RenderObject child) {
      if (child is RenderHitTargetExtender && _extenders.contains(child)) {
        ordered.add(child);
      }
      child.visitChildren(visit);
    }

    visitChildren(visit);

    final local = <RenderHitTargetExtender, Offset>{};
    var topOwner = -1;
    for (var i = 0; i < ordered.length; i++) {
      final extender = ordered[i];
      if (!extender.hasSize) continue;
      final point = extender.globalToLocal(position, ancestor: this);
      local[extender] = point;
      if ((Offset.zero & extender.size).contains(point)) topOwner = i;
    }

    RenderHitTargetExtender? nearest;
    var nearestDistance = double.infinity;
    for (var i = topOwner + 1; i < ordered.length; i++) {
      final extender = ordered[i];
      final point = local[extender];
      if (point == null || !extender.targetRect.contains(point)) continue;
      final distance = _distance(Offset.zero & extender.size, point);
      if (distance < nearestDistance) {
        nearest = extender;
        nearestDistance = distance;
      }
    }
    return nearest;
  }

  static double _distance(Rect rect, Offset point) {
    final dx = point.dx < rect.left
        ? rect.left - point.dx
        : point.dx > rect.right
        ? point.dx - rect.right
        : 0.0;
    final dy = point.dy < rect.top
        ? rect.top - point.dy
        : point.dy > rect.bottom
        ? point.dy - rect.bottom
        : 0.0;
    return Offset(dx, dy).distance;
  }
}
