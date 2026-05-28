import 'package:flutter/material.dart';

class AnimatedBranchContainer extends StatefulWidget {
  const AnimatedBranchContainer({
    required this.currentIndex,
    required this.children,
    super.key,
  });

  final int currentIndex;
  final List<Widget> children;

  @override
  State<AnimatedBranchContainer> createState() =>
      _AnimatedBranchContainerState();
}

class _AnimatedBranchContainerState extends State<AnimatedBranchContainer>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 320),
  );
  late final Animation<double> _animation = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOutCubic,
    reverseCurve: Curves.easeOutCubic,
  );

  int? _previousIndex;
  var _direction = 1;

  @override
  void didUpdateWidget(covariant AnimatedBranchContainer oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.currentIndex == widget.currentIndex) {
      return;
    }

    _previousIndex = oldWidget.currentIndex;
    _direction = widget.currentIndex > oldWidget.currentIndex ? 1 : -1;
    _controller.forward(from: 0).whenComplete(() {
      if (mounted) {
        setState(() => _previousIndex = null);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRect(
      child: AnimatedBuilder(
        animation: _animation,
        builder: (context, _) {
          return Stack(
            fit: StackFit.expand,
            children: [
              for (var index = 0; index < widget.children.length; index++)
                _BranchSlot(
                  isActive: index == widget.currentIndex,
                  isOutgoing: index == _previousIndex,
                  offset: _offsetFor(index),
                  child: widget.children[index],
                ),
            ],
          );
        },
      ),
    );
  }

  Offset _offsetFor(int index) {
    if (index == widget.currentIndex) {
      return Offset(_direction * (1 - _animation.value), 0);
    }
    if (index == _previousIndex) {
      return Offset(-_direction * _animation.value * 0.28, 0);
    }
    return Offset.zero;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}

class _BranchSlot extends StatelessWidget {
  const _BranchSlot({
    required this.isActive,
    required this.isOutgoing,
    required this.offset,
    required this.child,
  });

  final bool isActive;
  final bool isOutgoing;
  final Offset offset;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isVisible = isActive || isOutgoing;

    return Offstage(
      offstage: !isVisible,
      child: TickerMode(
        enabled: isActive,
        child: IgnorePointer(
          ignoring: !isActive,
          child: FractionalTranslation(
            translation: offset,
            child: RepaintBoundary(child: child),
          ),
        ),
      ),
    );
  }
}
