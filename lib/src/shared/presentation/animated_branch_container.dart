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
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;

          return AnimatedBuilder(
            animation: _animation,
            builder: (context, _) {
              final previousIndex = _previousIndex;
              if (previousIndex == null) {
                return _BranchSlot(
                  isActive: true,
                  child: widget.children[widget.currentIndex],
                );
              }

              final previousOffset = -_direction * _animation.value * width;
              final currentOffset = _direction * (1 - _animation.value) * width;

              return Stack(
                fit: StackFit.expand,
                children: [
                  Transform.translate(
                    offset: Offset(previousOffset, 0),
                    child: _BranchSlot(
                      isActive: false,
                      child: widget.children[previousIndex],
                    ),
                  ),
                  Transform.translate(
                    offset: Offset(currentOffset, 0),
                    child: _BranchSlot(
                      isActive: true,
                      child: widget.children[widget.currentIndex],
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
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
    required this.child,
  });

  final bool isActive;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    return TickerMode(
      enabled: isActive,
      child: IgnorePointer(
        ignoring: !isActive,
        child: RepaintBoundary(child: child),
      ),
    );
  }
}
