import 'dart:async';
import 'dart:collection';

import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

enum AppMessageType {
  info,
  success,
  warning,
  error,
}

void showAdaptiveMessage(
  BuildContext context,
  String message, {
  AppMessageType type = AppMessageType.info,
}) {
  _TopMessageQueue.instance.show(context, message, type);
}

class _QueuedMessage {
  const _QueuedMessage(this.message, this.type);

  final String message;
  final AppMessageType type;
}

class _TopMessageQueue {
  _TopMessageQueue._();

  static final instance = _TopMessageQueue._();
  static const _maxQueuedMessages = 3;

  final _queue = Queue<_QueuedMessage>();
  OverlayEntry? _entry;
  var _isShowing = false;

  void show(BuildContext context, String message, AppMessageType type) {
    final overlay = Overlay.maybeOf(context, rootOverlay: true);
    if (overlay == null) {
      ScaffoldMessenger.maybeOf(context)
        ?..hideCurrentSnackBar()
        ..showSnackBar(SnackBar(content: Text(message)));
      return;
    }

    if (_queue.length >= _maxQueuedMessages) {
      _queue.removeFirst();
    }
    _queue.addLast(_QueuedMessage(message, type));

    if (!_isShowing) {
      _showNext(overlay);
    }
  }

  void _showNext(OverlayState overlay) {
    final next = _queue.isEmpty ? null : _queue.removeFirst();
    if (next == null) {
      _isShowing = false;
      return;
    }

    _isShowing = true;
    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (context) => _TopMessageBanner(
        message: next.message,
        type: next.type,
        onDismissed: () {
          entry.remove();
          if (_entry == entry) {
            _entry = null;
          }
          scheduleMicrotask(() => _showNext(overlay));
        },
      ),
    );
    _entry = entry;
    overlay.insert(entry);
  }
}

class _TopMessageBanner extends StatefulWidget {
  const _TopMessageBanner({
    required this.message,
    required this.type,
    required this.onDismissed,
  });

  final String message;
  final AppMessageType type;
  final VoidCallback onDismissed;

  @override
  State<_TopMessageBanner> createState() => _TopMessageBannerState();
}

class _TopMessageBannerState extends State<_TopMessageBanner>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller = AnimationController(
    vsync: this,
    duration: const Duration(milliseconds: 260),
    reverseDuration: const Duration(milliseconds: 190),
  );
  late final Animation<Offset> _offset = Tween(
    begin: const Offset(0, -0.65),
    end: Offset.zero,
  ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));
  late final Animation<double> _opacity = CurvedAnimation(
    parent: _controller,
    curve: Curves.easeOut,
  );

  Timer? _timer;
  var _dismissed = false;

  @override
  void initState() {
    super.initState();
    _controller.forward();
    _timer = Timer(const Duration(milliseconds: 2400), _dismiss);
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  Future<void> _dismiss() async {
    if (_dismissed || !mounted) {
      return;
    }
    _dismissed = true;
    await _controller.reverse();
    if (mounted) {
      widget.onDismissed();
    }
  }

  @override
  Widget build(BuildContext context) {
    final top = MediaQuery.paddingOf(context).top;
    final spec = _MessageVisualSpec.fromType(widget.type);

    return Positioned(
      left: AppSpacing.lg,
      right: AppSpacing.lg,
      top: top + AppSpacing.sm,
      child: SlideTransition(
        position: _offset,
        child: FadeTransition(
          opacity: _opacity,
          child: GestureDetector(
            onTap: _dismiss,
            child: Material(
              color: Colors.transparent,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  color: spec.background,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: spec.border),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.12),
                      blurRadius: 24,
                      offset: const Offset(0, 10),
                    ),
                  ],
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppSpacing.md,
                    vertical: AppSpacing.md,
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      DecoratedBox(
                        decoration: BoxDecoration(
                          color: spec.accent.withValues(alpha: 0.12),
                          shape: BoxShape.circle,
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(6),
                          child: Icon(spec.icon, color: spec.accent, size: 18),
                        ),
                      ),
                      const SizedBox(width: AppSpacing.sm),
                      Expanded(
                        child: Text(
                          widget.message,
                          maxLines: 3,
                          overflow: TextOverflow.ellipsis,
                          style:
                              Theme.of(context).textTheme.bodyMedium?.copyWith(
                                    color: AppColors.ink,
                                    fontWeight: FontWeight.w600,
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MessageVisualSpec {
  const _MessageVisualSpec({
    required this.background,
    required this.border,
    required this.accent,
    required this.icon,
  });

  final Color background;
  final Color border;
  final Color accent;
  final IconData icon;

  factory _MessageVisualSpec.fromType(AppMessageType type) {
    return switch (type) {
      AppMessageType.success => const _MessageVisualSpec(
          background: Color(0xFFF2FBF5),
          border: Color(0xFFD6F1DE),
          accent: AppColors.mint,
          icon: Icons.check_rounded,
        ),
      AppMessageType.warning => const _MessageVisualSpec(
          background: Color(0xFFFFF8EA),
          border: Color(0xFFFFE5B8),
          accent: AppColors.amber,
          icon: Icons.priority_high_rounded,
        ),
      AppMessageType.error => const _MessageVisualSpec(
          background: Color(0xFFFFF1F0),
          border: Color(0xFFFFD5D2),
          accent: AppColors.coral,
          icon: Icons.close_rounded,
        ),
      AppMessageType.info => const _MessageVisualSpec(
          background: AppColors.surface,
          border: AppColors.border,
          accent: AppColors.azure,
          icon: Icons.info_outline_rounded,
        ),
    };
  }
}
