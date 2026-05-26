import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../features/media/domain/medical_media.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';

class MediaScreen extends StatefulWidget {
  const MediaScreen({super.key});

  @override
  State<MediaScreen> createState() => _MediaScreenState();
}

class _MediaScreenState extends State<MediaScreen> {
  final Set<MedicalMediaCategory> _expanded = {
    MedicalMediaCategory.ultrasound,
    MedicalMediaCategory.ecg,
    MedicalMediaCategory.labs,
    MedicalMediaCategory.conclusion,
    MedicalMediaCategory.other,
  };

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);

    return ScreenFrame(
      title: 'Медиа',
      subtitle: 'Фото УЗИ, ЭКГ, заключений и анализов.',
      actions: [
        IconButton(
          tooltip: 'Добавить файл',
          onPressed: _pickMedia,
          icon: const Icon(Icons.add_photo_alternate_outlined),
        ),
      ],
      children: [
        _MediaSummary(count: appState.medicalMedia.length, onAdd: _pickMedia),
        const SizedBox(height: AppSpacing.lg),
        if (appState.medicalMedia.isEmpty)
          const _EmptyMediaCard()
        else
          for (final category in MedicalMediaCategory.values) ...[
            _MediaSection(
              category: category,
              files: appState.medicalMedia
                  .where((media) => media.category == category)
                  .toList(),
              isExpanded: _expanded.contains(category),
              onToggle: () => _toggle(category),
            ),
            const SizedBox(height: AppSpacing.md),
          ],
      ],
    );
  }

  void _toggle(MedicalMediaCategory category) {
    setState(() {
      if (_expanded.contains(category)) {
        _expanded.remove(category);
      } else {
        _expanded.add(category);
      }
    });
  }

  Future<void> _pickMedia() async {
    final category = await showModalBottomSheet<MedicalMediaCategory>(
      context: context,
      builder: (context) => const _CategorySheet(),
    );
    if (category == null || !mounted) {
      return;
    }

    final file = await ImagePicker().pickImage(
      source: ImageSource.gallery,
      imageQuality: 88,
    );
    if (file == null || !mounted) {
      return;
    }

    final bytes = await file.readAsBytes();
    final title = file.name.isEmpty ? category.label : file.name;
    await AppScope.read(context).addMedicalMedia(
      data: base64Encode(bytes),
      category: category,
      title: title,
      mimeType: file.mimeType,
    );
  }
}

class _CategorySheet extends StatelessWidget {
  const _CategorySheet();

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Padding(
        padding: const EdgeInsets.all(AppSpacing.lg),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            for (final category in MedicalMediaCategory.values)
              ListTile(
                leading: Icon(category.icon),
                title: Text(category.label),
                onTap: () => Navigator.of(context).pop(category),
              ),
          ],
        ),
      ),
    );
  }
}

class _MediaSummary extends StatelessWidget {
  const _MediaSummary({
    required this.count,
    required this.onAdd,
  });

  final int count;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Row(
        children: [
          const Icon(Icons.photo_library_outlined, color: AppColors.azure),
          const SizedBox(width: AppSpacing.md),
          Expanded(
            child: Text(
              count == 0 ? 'Файлов пока нет' : 'Файлов: $count',
              style: Theme.of(context).textTheme.titleMedium,
            ),
          ),
          FilledButton.icon(
            onPressed: onAdd,
            icon: const Icon(Icons.add),
            label: const Text('Добавить'),
          ),
        ],
      ),
    );
  }
}

class _MediaSection extends StatelessWidget {
  const _MediaSection({
    required this.category,
    required this.files,
    required this.isExpanded,
    required this.onToggle,
  });

  final MedicalMediaCategory category;
  final List<MedicalMedia> files;
  final bool isExpanded;
  final VoidCallback onToggle;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      padding: const EdgeInsets.all(AppSpacing.md),
      child: Column(
        children: [
          InkWell(
            borderRadius: BorderRadius.circular(AppRadii.control),
            onTap: onToggle,
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: AppSpacing.xs),
              child: Row(
                children: [
                  Icon(category.icon, color: AppColors.azure),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Text(
                      category.label,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                  ),
                  Text(
                    files.length.toString(),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                  const SizedBox(width: AppSpacing.sm),
                  Icon(
                    isExpanded ? Icons.expand_less : Icons.expand_more,
                    color: AppColors.muted,
                  ),
                ],
              ),
            ),
          ),
          if (isExpanded) ...[
            const SizedBox(height: AppSpacing.sm),
            if (files.isEmpty)
              Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'В этой секции пока пусто.',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: AppColors.muted,
                      ),
                ),
              )
            else
              for (final media in files) ...[
                _MediaTile(media: media),
                if (media != files.last) const Divider(height: AppSpacing.lg),
              ],
          ],
        ],
      ),
    );
  }
}

class _MediaTile extends StatelessWidget {
  const _MediaTile({required this.media});

  final MedicalMedia media;

  @override
  Widget build(BuildContext context) {
    final bytes = base64Decode(media.data);

    return InkWell(
      borderRadius: BorderRadius.circular(AppRadii.control),
      onTap: () => _openPreview(context),
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
        child: Row(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(AppRadii.control),
              child: Image.memory(
                bytes,
                width: 64,
                height: 64,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return const SizedBox(
                    width: 64,
                    height: 64,
                    child: ColoredBox(
                      color: AppColors.surfaceTint,
                      child: Icon(Icons.insert_drive_file_outlined),
                    ),
                  );
                },
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    media.title ?? media.category.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleSmall,
                  ),
                  const SizedBox(height: AppSpacing.xs),
                  Text(
                    DateFormat('dd.MM.yyyy HH:mm').format(media.createdAt),
                    style: Theme.of(context).textTheme.bodySmall?.copyWith(
                          color: AppColors.muted,
                        ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right, color: AppColors.muted),
          ],
        ),
      ),
    );
  }

  Future<void> _openPreview(BuildContext context) {
    final bytes = base64Decode(media.data);

    return showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog.fullscreen(
          child: Scaffold(
            appBar: AppBar(
              title: Text(media.title ?? media.category.label),
              actions: [
                IconButton(
                  tooltip: 'Удалить',
                  onPressed: () async {
                    final state = AppScope.read(context);
                    Navigator.of(context).pop();
                    await state.deleteMedicalMedia(media.id);
                  },
                  icon: const Icon(Icons.delete_outline),
                ),
              ],
            ),
            body: SafeArea(
              child: InteractiveViewer(
                minScale: 0.8,
                maxScale: 4,
                child: Center(
                  child: Image.memory(
                    bytes,
                    fit: BoxFit.contain,
                    errorBuilder: (context, error, stackTrace) {
                      return const Icon(Icons.insert_drive_file_outlined);
                    },
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}

class _EmptyMediaCard extends StatelessWidget {
  const _EmptyMediaCard();

  @override
  Widget build(BuildContext context) {
    return AppCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Icon(Icons.photo_library_outlined, color: AppColors.azure),
          const SizedBox(height: AppSpacing.md),
          Text('Файлов пока нет',
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: AppSpacing.xs),
          Text(
            'Добавьте фото УЗИ, ЭКГ, заключения или анализа.',
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

extension _MedicalMediaCategoryUi on MedicalMediaCategory {
  String get label {
    return switch (this) {
      MedicalMediaCategory.ultrasound => 'УЗИ',
      MedicalMediaCategory.ecg => 'ЭКГ',
      MedicalMediaCategory.labs => 'Анализы',
      MedicalMediaCategory.conclusion => 'Заключение',
      MedicalMediaCategory.other => 'Другое',
    };
  }

  IconData get icon {
    return switch (this) {
      MedicalMediaCategory.ultrasound => Icons.monitor_heart_outlined,
      MedicalMediaCategory.ecg => Icons.show_chart,
      MedicalMediaCategory.labs => Icons.science_outlined,
      MedicalMediaCategory.conclusion => Icons.description_outlined,
      MedicalMediaCategory.other => Icons.attach_file,
    };
  }
}
