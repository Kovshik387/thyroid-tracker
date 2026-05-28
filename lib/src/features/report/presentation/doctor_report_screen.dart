import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

import '../../../app/app_scope.dart';
import '../../../app/design_tokens.dart';
import '../../../features/labs/domain/lab_result.dart';
import '../../../features/profile/domain/user_profile.dart';
import '../../../features/sleep/domain/sleep_log.dart';
import '../../../features/weight/domain/weight_log.dart';
import '../../../shared/platform/pdf_file_saver.dart';
import '../../../shared/presentation/app_card.dart';
import '../../../shared/presentation/screen_frame.dart';

class DoctorReportScreen extends StatefulWidget {
  const DoctorReportScreen({super.key});

  @override
  State<DoctorReportScreen> createState() => _DoctorReportScreenState();
}

class _DoctorReportScreenState extends State<DoctorReportScreen> {
  final _wellbeingController = TextEditingController();
  late DateTime _fromDate;
  late DateTime _toDate;
  var _isGenerating = false;

  @override
  void initState() {
    super.initState();
    final today = _dateOnly(DateTime.now());
    _toDate = today;
    _fromDate = today.subtract(const Duration(days: 90));
  }

  @override
  void dispose() {
    _wellbeingController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = AppScope.watch(context);

    return ScreenFrame(
      title: 'Отчет врачу',
      subtitle: 'Краткий PDF для визита к эндокринологу.',
      children: [
        AppCard(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('Самочувствие',
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: AppSpacing.md),
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: const Icon(Icons.date_range_outlined),
                title: const Text('Период для отчета'),
                subtitle: Text(
                  '${DateFormat('dd.MM.yyyy').format(_fromDate)} - ${DateFormat('dd.MM.yyyy').format(_toDate)}',
                ),
                trailing: const Icon(Icons.chevron_right),
                onTap: _pickReportRange,
              ),
              const SizedBox(height: AppSpacing.md),
              TextField(
                controller: _wellbeingController,
                minLines: 5,
                maxLines: 8,
                decoration: const InputDecoration(
                  hintText:
                      'Например: сон, усталость, пульс, вес, жалобы, переносимость препарата',
                ),
              ),
              const SizedBox(height: AppSpacing.lg),
              FilledButton.icon(
                onPressed: _isGenerating
                    ? null
                    : () => _generateReport(
                          profile: appState.userProfile,
                          labs: _filterLabs(appState.labs),
                          sleepLogs: _filterSleepLogs(appState.sleepLogs),
                          weightLogs: _filterWeightLogs(appState.weightLogs),
                          wellbeing: _wellbeingController.text.trim(),
                        ),
                icon: const Icon(Icons.picture_as_pdf_outlined),
                label: Text(_isGenerating ? 'Формирование...' : 'Создать PDF'),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Future<void> _pickReportRange() async {
    final now = _dateOnly(DateTime.now());
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 10),
      lastDate: now,
      initialDateRange: DateTimeRange(start: _fromDate, end: _toDate),
      locale: const Locale('ru'),
    );
    if (picked == null) {
      return;
    }
    setState(() {
      _fromDate = _dateOnly(picked.start);
      _toDate = _dateOnly(picked.end);
    });
  }

  List<LabResult> _filterLabs(List<LabResult> labs) {
    return labs.where((lab) {
      final date = _dateOnly(lab.date);
      return !date.isBefore(_fromDate) && !date.isAfter(_toDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<SleepLog> _filterSleepLogs(List<SleepLog> logs) {
    return logs.where((log) {
      final date = _dateOnly(log.date);
      return !date.isBefore(_fromDate) && !date.isAfter(_toDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  List<WeightLog> _filterWeightLogs(List<WeightLog> logs) {
    return logs.where((log) {
      final date = _dateOnly(log.date);
      return !date.isBefore(_fromDate) && !date.isAfter(_toDate);
    }).toList()
      ..sort((a, b) => a.date.compareTo(b.date));
  }

  Future<void> _generateReport({
    required UserProfile? profile,
    required List<LabResult> labs,
    required List<SleepLog> sleepLogs,
    required List<WeightLog> weightLogs,
    required String wellbeing,
  }) async {
    setState(() => _isGenerating = true);
    try {
      final fontData = await rootBundle.load('assets/fonts/arial.ttf');
      final font = pw.Font.ttf(fontData);
      final now = DateTime.now();
      final document = pw.Document();
      final sleepSummary = _analyzeSleep(sleepLogs);
      final weightSummary = _analyzeWeight(weightLogs);
      final patientName = profile?.name.trim().isNotEmpty == true
          ? profile!.name.trim()
          : 'Пациент';

      document.addPage(
        pw.MultiPage(
          pageFormat: PdfPageFormat.a4,
          margin: const pw.EdgeInsets.all(32),
          footer: (context) => pw.Align(
            alignment: pw.Alignment.centerRight,
            child: pw.Text(
              'ТироДневник · ${context.pageNumber}/${context.pagesCount}',
              style: pw.TextStyle(font: font, fontSize: 9),
            ),
          ),
          build: (context) {
            return [
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  _logo(font),
                  pw.Spacer(),
                  pw.Text(
                    DateFormat('dd.MM.yyyy').format(now),
                    style: pw.TextStyle(font: font, fontSize: 12),
                  ),
                ],
              ),
              pw.SizedBox(height: 18),
              pw.Row(
                crossAxisAlignment: pw.CrossAxisAlignment.start,
                children: [
                  pw.Expanded(
                    child: pw.Column(
                      crossAxisAlignment: pw.CrossAxisAlignment.start,
                      children: [
                        pw.Text(
                          patientName,
                          style: pw.TextStyle(
                            font: font,
                            fontSize: 20,
                            fontWeight: pw.FontWeight.bold,
                          ),
                        ),
                        pw.SizedBox(height: 4),
                        pw.Text(
                          'Дата рождения: ${_formatDate(profile?.birthDate)}'
                          '${profile?.age == null ? '' : ' (${profile!.age} ${_yearsWord(profile.age!)})'}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                        pw.Text(
                          'Диагноз: ${_emptyDash(profile?.diagnosis)}',
                          style: pw.TextStyle(font: font, fontSize: 11),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              pw.SizedBox(height: 20),
              pw.Text(
                'Отчет для врача-эндокринолога',
                style: pw.TextStyle(
                  font: font,
                  fontSize: 18,
                  fontWeight: pw.FontWeight.bold,
                ),
              ),
              pw.SizedBox(height: 6),
              pw.Text(
                'Период: ${DateFormat('dd.MM.yyyy').format(_fromDate)} - ${DateFormat('dd.MM.yyyy').format(_toDate)}',
                style: pw.TextStyle(font: font, fontSize: 11),
              ),
              pw.SizedBox(height: 18),
              _sectionTitle(font, 'Показатели крови за период'),
              pw.SizedBox(height: 8),
              _labTable(font, labs),
              pw.SizedBox(height: 18),
              _sectionTitle(font, 'Сон'),
              pw.SizedBox(height: 8),
              _summaryBox(font, sleepSummary.title, sleepSummary.details),
              pw.SizedBox(height: 18),
              _sectionTitle(font, 'Вес'),
              pw.SizedBox(height: 8),
              _summaryBox(font, weightSummary.title, weightSummary.details),
              pw.SizedBox(height: 18),
              _sectionTitle(font, 'Короткая справка о самочувствии'),
              pw.SizedBox(height: 8),
              pw.Container(
                width: double.infinity,
                padding: const pw.EdgeInsets.all(12),
                decoration: pw.BoxDecoration(
                  border: pw.Border.all(color: PdfColors.grey400),
                  borderRadius: pw.BorderRadius.circular(6),
                ),
                child: pw.Text(
                  wellbeing.isEmpty ? 'Не указано.' : wellbeing,
                  style: pw.TextStyle(font: font, fontSize: 12, height: 1.35),
                ),
              ),
            ];
          },
        ),
      );

      final bytes = await document.save();
      await savePdfFile(
        bytes: bytes,
        fileName: 'tirodnevnik-endocrinologist-report.pdf',
      );
    } catch (error) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Не удалось сформировать PDF: $error')),
        );
      }
    } finally {
      if (mounted) {
        setState(() => _isGenerating = false);
      }
    }
  }
}

pw.Widget _summaryBox(pw.Font font, String title, String details) {
  return pw.Container(
    width: double.infinity,
    padding: const pw.EdgeInsets.all(12),
    decoration: pw.BoxDecoration(
      border: pw.Border.all(color: PdfColors.grey400),
      borderRadius: pw.BorderRadius.circular(6),
    ),
    child: pw.Column(
      crossAxisAlignment: pw.CrossAxisAlignment.start,
      children: [
        pw.Text(
          title,
          style: pw.TextStyle(
            font: font,
            fontSize: 12,
            fontWeight: pw.FontWeight.bold,
          ),
        ),
        pw.SizedBox(height: 4),
        pw.Text(
          details,
          style: pw.TextStyle(font: font, fontSize: 11, height: 1.35),
        ),
      ],
    ),
  );
}

pw.Widget _logo(pw.Font font) {
  return pw.Row(
    children: [
      pw.Container(
        width: 34,
        height: 34,
        decoration: const pw.BoxDecoration(
          color: PdfColor.fromInt(0xFF007AFF),
          shape: pw.BoxShape.circle,
        ),
        child: pw.Center(
          child: pw.Text(
            'T',
            style: pw.TextStyle(
              font: font,
              color: PdfColors.white,
              fontSize: 18,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
        ),
      ),
      pw.SizedBox(width: 8),
      pw.Column(
        crossAxisAlignment: pw.CrossAxisAlignment.start,
        children: [
          pw.Text(
            'ТироДневник',
            style: pw.TextStyle(
              font: font,
              fontSize: 16,
              fontWeight: pw.FontWeight.bold,
            ),
          ),
          pw.Text(
            'Дневник щитовидной железы',
            style: pw.TextStyle(font: font, fontSize: 9),
          ),
        ],
      ),
    ],
  );
}

pw.Widget _sectionTitle(pw.Font font, String text) {
  return pw.Text(
    text,
    style: pw.TextStyle(
      font: font,
      fontSize: 14,
      fontWeight: pw.FontWeight.bold,
    ),
  );
}

pw.Widget _labTable(pw.Font font, List<LabResult> labs) {
  if (labs.isEmpty) {
    return pw.Text(
      'За выбранный период анализы не найдены.',
      style: pw.TextStyle(font: font, fontSize: 11),
    );
  }

  return pw.Table(
    border: pw.TableBorder.all(color: PdfColors.grey400),
    columnWidths: const {
      0: pw.FlexColumnWidth(1.1),
      1: pw.FlexColumnWidth(1),
      2: pw.FlexColumnWidth(1),
      3: pw.FlexColumnWidth(1),
    },
    children: [
      pw.TableRow(
        decoration: const pw.BoxDecoration(color: PdfColor.fromInt(0xFFE5F1FF)),
        children: [
          _tableCell(font, 'Дата', bold: true),
          _tableCell(font, 'ТТГ', bold: true),
          _tableCell(font, 'Т4 св.', bold: true),
          _tableCell(font, 'Т3 св.', bold: true),
        ],
      ),
      for (final lab in labs)
        pw.TableRow(
          children: [
            _tableCell(font, DateFormat('dd.MM.yyyy').format(lab.date)),
            _tableCell(font, _formatMetric(lab.tsh, '')),
            _tableCell(font, _formatMetric(lab.freeT4, '')),
            _tableCell(font, _formatMetric(lab.freeT3, '')),
          ],
        ),
    ],
  );
}

pw.Widget _tableCell(pw.Font font, String text, {bool bold = false}) {
  return pw.Padding(
    padding: const pw.EdgeInsets.all(8),
    child: pw.Text(
      text,
      style: pw.TextStyle(
        font: font,
        fontSize: 12,
        fontWeight: bold ? pw.FontWeight.bold : pw.FontWeight.normal,
      ),
    ),
  );
}

String _formatMetric(double? value, String unit) {
  if (value == null) {
    return '-';
  }
  final formatted =
      value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
  if (unit.isEmpty) {
    return formatted;
  }
  return '$formatted $unit';
}

_SleepSummary _analyzeSleep(List<SleepLog> logs) {
  final validLogs = logs
      .where((log) => log.sleepStart != null && log.sleepEnd != null)
      .toList();
  if (validLogs.isEmpty) {
    return const _SleepSummary(
      title: 'Недостаточно данных о сне',
      details: 'За выбранный период недостаточно данных для оценки режима сна.',
    );
  }

  final startMinutes = validLogs.map((log) {
    final start = log.sleepStart!;
    final minutes = start.hour * 60 + start.minute;
    return minutes < 12 * 60 ? minutes + 24 * 60 : minutes;
  }).toList();
  final averageStart =
      startMinutes.reduce((a, b) => a + b) / startMinutes.length;

  var normalDurationCount = 0;
  var stableStartCount = 0;
  for (final log in validLogs) {
    final duration = log.duration;
    if (duration != null &&
        duration.inMinutes >= 7 * 60 &&
        duration.inMinutes <= 8 * 60) {
      normalDurationCount++;
    }

    final start = log.sleepStart!;
    final minutes = start.hour * 60 + start.minute;
    final normalized = minutes < 12 * 60 ? minutes + 24 * 60 : minutes;
    if ((normalized - averageStart).abs() <= 120) {
      stableStartCount++;
    }
  }

  final normalDurationShare = normalDurationCount / validLogs.length;
  final stableStartShare = stableStartCount / validLogs.length;
  final isRegular = normalDurationShare >= 0.7 && stableStartShare >= 0.7;
  final averageDurationMinutes = validLogs
          .map((log) => log.duration?.inMinutes ?? 0)
          .reduce((a, b) => a + b) /
      validLogs.length;

  return _SleepSummary(
    title: isRegular ? 'Сон выглядит регулярным' : 'Сон нерегулярный',
    details:
        'Обычная длительность сна: ${_formatDuration(averageDurationMinutes.round())}. '
        'Время засыпания в основном держится около ${_formatSleepStart(averageStart.round())}. '
        '${isRegular ? 'Режим соответствует ориентиру 7-8 часов сна и стабильному времени засыпания.' : 'Есть заметные отклонения по длительности сна или времени засыпания.'}',
  );
}

_WeightSummary _analyzeWeight(List<WeightLog> logs) {
  if (logs.length < 2) {
    return const _WeightSummary(
      title: 'Недостаточно данных о весе',
      details: 'Для оценки динамики веса нужно минимум две записи за период.',
    );
  }

  final first = logs.first;
  final last = logs.last;
  final delta = last.weightKg - first.weightKg;
  final percent = first.weightKg == 0 ? 0.0 : delta / first.weightKg * 100;
  final absDelta = delta.abs();
  final changedSignificantly = absDelta >= 3 || percent.abs() >= 5;
  final direction = delta > 0
      ? 'увеличился'
      : delta < 0
          ? 'снизился'
          : 'не изменился';

  return _WeightSummary(
    title: changedSignificantly
        ? 'Вес заметно изменился'
        : 'Вес без выраженных изменений',
    details:
        'За выбранный период вес $direction: ${_formatWeight(first.weightKg)} кг -> ${_formatWeight(last.weightKg)} кг. '
        'Изменение: ${delta >= 0 ? '+' : ''}${_formatWeight(delta)} кг (${percent >= 0 ? '+' : ''}${percent.toStringAsFixed(1)}%).',
  );
}

String _formatDate(DateTime? date) {
  return date == null ? '-' : DateFormat('dd.MM.yyyy').format(date);
}

String _emptyDash(String? value) {
  final trimmed = value?.trim();
  return trimmed == null || trimmed.isEmpty ? '-' : trimmed;
}

String _formatDuration(int minutes) {
  final hours = minutes ~/ 60;
  final rest = minutes % 60;
  return '$hours ч ${rest.toString().padLeft(2, '0')} мин';
}

String _formatSleepStart(int normalizedMinutes) {
  final minutes = normalizedMinutes % (24 * 60);
  final hour = (minutes ~/ 60).toString().padLeft(2, '0');
  final minute = (minutes % 60).toString().padLeft(2, '0');
  return '$hour:$minute';
}

String _formatWeight(double value) {
  return value.toStringAsFixed(value.truncateToDouble() == value ? 0 : 1);
}

String _yearsWord(int value) {
  final mod10 = value % 10;
  final mod100 = value % 100;
  if (mod10 == 1 && mod100 != 11) {
    return 'год';
  }
  if (mod10 >= 2 && mod10 <= 4 && (mod100 < 12 || mod100 > 14)) {
    return 'года';
  }
  return 'лет';
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);

class _SleepSummary {
  const _SleepSummary({
    required this.title,
    required this.details,
  });

  final String title;
  final String details;
}

class _WeightSummary {
  const _WeightSummary({
    required this.title,
    required this.details,
  });

  final String title;
  final String details;
}
