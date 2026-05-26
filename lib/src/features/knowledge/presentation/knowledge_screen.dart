import 'package:flutter/material.dart';

import '../../../app/design_tokens.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';

class KnowledgeScreen extends StatelessWidget {
  const KnowledgeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return ScreenFrame(
      title: 'Справка',
      subtitle:
          'Короткие заметки для обсуждения с врачом. Это не замена консультации.',
      children: const [
        _InfoCard(
          title: 'Контроль анализов',
          text:
              'ТТГ и свободный Т4 помогают отслеживать динамику терапии. Интервалы контроля зависят от назначения врача.',
        ),
        SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: 'После приема Эутирокса',
          text:
              'Еда, кофе, кальций, железо, соевые продукты и некоторые добавки могут мешать всасыванию. Конкретные интервалы лучше согласовать с врачом.',
        ),
        SizedBox(height: AppSpacing.lg),
        _InfoCard(
          title: 'Когда обратить внимание',
          text:
              'Если давно не было анализов или визита к эндокринологу, приложение предложит запланировать контроль.',
        ),
      ],
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard({
    required this.title,
    required this.text,
  });

  final String title;
  final String text;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.sm),
          Text(
            text,
            style: Theme.of(context)
                .textTheme
                .bodyMedium
                ?.copyWith(color: AppColors.muted),
          ),
        ],
      ),
    );
  }
}
