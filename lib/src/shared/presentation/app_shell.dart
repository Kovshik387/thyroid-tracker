import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:go_router/go_router.dart';

import '../../app/design_tokens.dart';
import 'adaptive_icon.dart';

class AppShell extends StatefulWidget {
  const AppShell({
    required this.navigationShell,
    super.key,
  });

  final StatefulNavigationShell navigationShell;

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.paddingOf(context).bottom;
    final navigationShell = widget.navigationShell;

    return Scaffold(
      body: GestureDetector(
        behavior: HitTestBehavior.translucent,
        onHorizontalDragEnd: _supportsSwipeNavigation
            ? (details) => _handleHorizontalDrag(details)
            : null,
        child: navigationShell,
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: AppColors.surface,
          border: Border(top: BorderSide(color: AppColors.border)),
        ),
        padding: EdgeInsets.only(
          left: AppSpacing.sm,
          right: AppSpacing.sm,
          top: AppSpacing.xs,
          bottom: bottomInset + AppSpacing.xs,
        ),
        child: Row(
          children: [
            _TabItem(
              icon: AppIcons.home.value,
              activeIcon: AppIcons.homeFilled.value,
              label: 'Главная',
              isSelected: navigationShell.currentIndex == 0,
              onTap: () => _goBranch(0),
            ),
            _TabItem(
              icon: AppIcons.labs.value,
              activeIcon: AppIcons.labsFilled.value,
              label: 'Анализы',
              isSelected: navigationShell.currentIndex == 1,
              onTap: () => _goBranch(1),
            ),
            _TabItem(
              icon: AppIcons.medication.value,
              activeIcon: AppIcons.medicationFilled.value,
              label: 'Лечение',
              isSelected: navigationShell.currentIndex == 2,
              onTap: () => _goBranch(2),
            ),
            _TabItem(
              icon: AppIcons.more.value,
              activeIcon: AppIcons.moreFilled.value,
              label: 'Разделы',
              isSelected: navigationShell.currentIndex == 3,
              onTap: () => _goBranch(3),
            ),
          ],
        ),
      ),
    );
  }

  void _goBranch(int index) {
    final currentIndex = widget.navigationShell.currentIndex;
    widget.navigationShell.goBranch(
      index,
      initialLocation: index == currentIndex,
    );
  }

  bool get _supportsSwipeNavigation {
    if (kIsWeb) {
      return false;
    }
    return defaultTargetPlatform == TargetPlatform.iOS ||
        defaultTargetPlatform == TargetPlatform.macOS;
  }

  void _handleHorizontalDrag(DragEndDetails details) {
    final velocity = details.primaryVelocity ?? 0;
    if (velocity.abs() < 260) {
      return;
    }

    final currentIndex = widget.navigationShell.currentIndex;
    final nextIndex = velocity < 0 ? currentIndex + 1 : currentIndex - 1;
    if (nextIndex < 0 || nextIndex > 3) {
      return;
    }
    _goBranch(nextIndex);
  }
}

class _TabItem extends StatelessWidget {
  const _TabItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final color = isSelected ? AppColors.azure : AppColors.muted;

    return Expanded(
      child: InkResponse(
        onTap: onTap,
        radius: 30,
        containedInkWell: false,
        highlightShape: BoxShape.circle,
        child: SizedBox(
          height: 48,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(isSelected ? activeIcon : icon, color: color, size: 23),
              const SizedBox(height: 2),
              Text(
                label,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                textAlign: TextAlign.center,
                style: TextStyle(
                  color: color,
                  fontSize: 10,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
