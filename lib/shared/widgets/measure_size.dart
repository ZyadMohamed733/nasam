import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';

/// Reports its child's laid-out size after each layout that changes it.
class MeasureSize extends SingleChildRenderObjectWidget {
  const MeasureSize({super.key, required this.onChange, super.child});

  final ValueChanged<Size> onChange;

  @override
  RenderObject createRenderObject(BuildContext context) =>
      _RenderMeasureSize(onChange);

  @override
  void updateRenderObject(BuildContext context, RenderObject renderObject) =>
      (renderObject as _RenderMeasureSize).onChange = onChange;
}

class _RenderMeasureSize extends RenderProxyBox {
  _RenderMeasureSize(this.onChange);

  ValueChanged<Size> onChange;
  Size? _reported;

  @override
  void performLayout() {
    super.performLayout();
    final size = this.size;
    if (size == _reported) return;
    _reported = size;
    // Reported after the frame: the listener rebuilds, which cannot happen
    // during layout.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (attached) onChange(size);
    });
  }
}
