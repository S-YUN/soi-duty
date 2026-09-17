import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

/// 바깥에도 가로 스크롤(탭 셸의 PageView)이 있을 때 쓰는 가로 PageView.
///
/// 중첩된 같은 축의 스크롤에서는 항상 안쪽이 제스처를 가져가므로, 그대로 두면 끝 페이지에서
/// 더 밀어도 아무 일이 없다. 여기서는 끝에서 생기는 overscroll을 바깥 position에 [Drag]로
/// 흘려보내 탭 전환으로 이어지게 한다. 손을 떼면 바깥 PageView가 자기 물리로 스냅한다.
class HandoffPageView extends StatefulWidget {
  const HandoffPageView({
    super.key,
    required this.controller,
    required this.itemCount,
    required this.itemBuilder,
    this.onPageChanged,
  });

  final PageController controller;
  final int itemCount;
  final IndexedWidgetBuilder itemBuilder;
  final ValueChanged<int>? onPageChanged;

  @override
  State<HandoffPageView> createState() => _HandoffPageViewState();
}

class _HandoffPageViewState extends State<HandoffPageView> {
  Drag? _outerDrag;

  /// 바깥에 넘긴 누적 overscroll(px). 부호가 방향. 안쪽이 끝에서 되돌아오면 같이 되감는다.
  var _handedOff = 0.0;

  bool _onNotification(ScrollNotification n) {
    // depth 0 = 이 PageView 자신. 페이지 안의 세로 스크롤은 걸러낸다.
    if (n.depth != 0 || n.metrics.axis != Axis.horizontal) return false;

    if (n is OverscrollNotification) {
      final details = n.dragDetails;
      if (details == null) return false; // 손가락이 아닌 관성 overscroll은 넘기지 않는다.
      final outer = Scrollable.maybeOf(context, axis: Axis.horizontal)?.position;
      if (outer == null) return false;
      _outerDrag ??= outer.drag(DragStartDetails(globalPosition: details.globalPosition), _reset);
      _forward(n.overscroll, details.globalPosition);
    } else if (n is ScrollUpdateNotification && _outerDrag != null) {
      // 끝에서 되돌아오는 중 — 바깥도 같은 만큼 되감고, 원점에 닿으면 바깥 드래그를 끝낸다.
      final delta = n.scrollDelta ?? 0;
      if (delta == 0) return false;
      final position = n.dragDetails?.globalPosition ?? Offset.zero;
      final next = _handedOff + delta;
      if (next.sign == _handedOff.sign) {
        _forward(delta, position);
      } else {
        _forward(-_handedOff, position);
        _end(null);
      }
    } else if (n is ScrollEndNotification && _outerDrag != null) {
      _end(n.dragDetails);
    }
    return false;
  }

  void _forward(double overscroll, Offset globalPosition) {
    _handedOff += overscroll;
    // 스크롤 오프셋과 손가락 이동은 부호가 반대.
    _outerDrag?.update(
      DragUpdateDetails(globalPosition: globalPosition, delta: Offset(-overscroll, 0), primaryDelta: -overscroll),
    );
  }

  void _end(DragEndDetails? details) {
    final drag = _outerDrag;
    _reset();
    drag?.end(details ?? DragEndDetails(primaryVelocity: 0));
  }

  void _reset() {
    _outerDrag = null;
    _handedOff = 0;
  }

  @override
  Widget build(BuildContext context) {
    return NotificationListener<ScrollNotification>(
      onNotification: _onNotification,
      child: PageView.builder(
        controller: widget.controller,
        // Clamping: 끝에서 튕기지 않고 overscroll을 그대로 보고해야 바깥으로 넘길 수 있다.
        physics: const PageScrollPhysics(parent: ClampingScrollPhysics()),
        itemCount: widget.itemCount,
        itemBuilder: widget.itemBuilder,
        onPageChanged: widget.onPageChanged,
      ),
    );
  }
}
