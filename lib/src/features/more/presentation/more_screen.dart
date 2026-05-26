import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../../app/app_router.dart';
import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';

class MoreScreen extends StatelessWidget {
  const MoreScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Дополнительно',
      subtitle: 'Дополнительные разделы приложения.',
      children: [
        _MoreSection(
          title: 'Здоровье',
          children: [
            _MoreTile(
              icon: Icons.event_note_outlined,
              iconColor: AppColors.azure,
              title: 'Врач',
              subtitle: 'Визиты и рекомендации',
              onTap: () => context.push(AppRoute.doctor.path),
            ),
            _MoreTile(
              icon: Icons.photo_library_outlined,
              iconColor: AppColors.aqua,
              title: 'Медиа',
              subtitle: 'Фото УЗИ, ЭКГ и заключений',
              onTap: () => context.push(AppRoute.media.path),
            ),
            _MoreTile(
              icon: Icons.menu_book_outlined,
              iconColor: AppColors.amber,
              title: 'Справочник',
              subtitle: 'Питание, контроль, вопросы врачу',
              onTap: () => context.push(AppRoute.knowledge.path),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _MoreSection(
          title: 'Дневники',
          children: [
            _MoreTile(
              icon: Icons.bedtime_outlined,
              iconColor: AppColors.azureDeep,
              title: 'Сон',
              subtitle: 'Дневник сна и качества восстановления',
              onTap: () => context.push(AppRoute.sleep.path),
            ),
            _MoreTile(
              icon: Icons.monitor_weight_outlined,
              iconColor: AppColors.mint,
              title: 'Вес',
              subtitle: 'История веса и динамика',
              onTap: () => context.push(AppRoute.weight.path),
            ),
          ],
        ),
        const SizedBox(height: AppSpacing.lg),
        _MoreSection(
          title: 'Приложение',
          children: [
            _MoreTile(
              icon: Icons.settings_outlined,
              iconColor: AppColors.muted,
              title: 'Настройки',
              subtitle: 'Диапазоны, напоминания, резервные копии',
              onTap: () => context.push(AppRoute.settings.path),
            ),
            _MoreTile(
              icon: Icons.restart_alt_outlined,
              iconColor: AppColors.coral,
              title: 'Сбросить приложение',
              subtitle: 'Очистить локальные данные и открыть первый запуск',
              isDestructive: true,
              onTap: () => _confirmReset(context),
            ),
          ],
        ),
      ],
    );
  }

  Future<void> _confirmReset(BuildContext context) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Сбросить данные?'),
          content: const Text(
            'Все анализы, отметки приема, визиты врача и настройки будут удалены с этого устройства.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(false),
              child: const Text('Отмена'),
            ),
            FilledButton(
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Сбросить'),
            ),
          ],
        );
      },
    );

    if (confirmed == true && context.mounted) {
      await AppScope.read(context).resetToDefaults();
    }
  }
}

class _MoreSection extends StatelessWidget {
  const _MoreSection({
    required this.title,
    required this.children,
  });

  final String title;
  final List<_MoreTile> children;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.only(
            left: AppSpacing.md,
            bottom: AppSpacing.sm,
          ),
          child: Text(
            title.toUpperCase(),
            style: Theme.of(context).textTheme.labelSmall?.copyWith(
                  color: AppColors.muted,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ),
        AppCard(
          padding: EdgeInsets.zero,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(AppRadii.card),
            child: Column(
              children: [
                for (var index = 0; index < children.length; index++) ...[
                  children[index],
                  if (index != children.length - 1)
                    const Padding(
                      padding: EdgeInsets.only(left: 64),
                      child: Divider(height: 1),
                    ),
                ],
              ],
            ),
          ),
        ),
      ],
    );
  }
}

class _MoreTile extends StatelessWidget {
  const _MoreTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.isDestructive = false,
  });

  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final bool isDestructive;

  @override
  Widget build(BuildContext context) {
    final foreground = isDestructive ? AppColors.coral : AppColors.ink;

    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.md,
          vertical: AppSpacing.sm,
        ),
        child: Row(
          children: [
            DecoratedBox(
              decoration: BoxDecoration(
                color: iconColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(9),
              ),
              child: SizedBox(
                width: 36,
                height: 36,
                child: Icon(icon, color: iconColor, size: 21),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                          color: foreground,
                          fontWeight: FontWeight.w600,
                        ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    subtitle,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: AppSpacing.sm),
            const Icon(
              Icons.chevron_right,
              color: AppColors.borderStrong,
              size: 22,
            ),
          ],
        ),
      ),
    );
  }
}
