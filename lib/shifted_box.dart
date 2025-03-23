import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';

class ShiftedBox extends SingleChildRenderObjectWidget {
  final Offset offset;

  const ShiftedBox({super.key, required Widget super.child, this.offset = Offset.zero});

  @override
  RenderObject createRenderObject(BuildContext context) {
    return RenderShiftedBox(offset);
  }

  @override
  void updateRenderObject(BuildContext context, RenderShiftedBox renderObject) {
    renderObject.offset = offset;
  }
}

class RenderShiftedBox extends RenderProxyBox {
  Offset _offset;

  RenderShiftedBox(this._offset);

  Offset get offset => _offset;
  set offset(Offset value) {
    if (_offset != value) {
      _offset = value;
      markNeedsPaint();
    }
  }

  @override
  void paint(PaintingContext context, Offset position) {
    context.paintChild(child!, position + offset);
  }
}
