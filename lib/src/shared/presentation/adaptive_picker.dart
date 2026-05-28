import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import '../../app/design_tokens.dart';

bool get _usesCupertinoPickers {
  if (kIsWeb) {
    return false;
  }
  return defaultTargetPlatform == TargetPlatform.iOS ||
      defaultTargetPlatform == TargetPlatform.macOS;
}

Future<DateTime?> pickAdaptiveDate({
  required BuildContext context,
  required DateTime initialDate,
  required DateTime firstDate,
  required DateTime lastDate,
}) {
  if (!_usesCupertinoPickers) {
    return showDatePicker(
      context: context,
      initialDate: initialDate,
      firstDate: firstDate,
      lastDate: lastDate,
      locale: const Locale('ru'),
    );
  }

  final safeInitial = _clampDate(initialDate, firstDate, lastDate);
  return _showCupertinoPicker<DateTime>(
    context: context,
    initialValue: safeInitial,
    builder: (context, onChanged) {
      return CupertinoDatePicker(
        mode: CupertinoDatePickerMode.date,
        initialDateTime: safeInitial,
        minimumDate: firstDate,
        maximumDate: lastDate,
        onDateTimeChanged: (value) => onChanged(_dateOnly(value)),
      );
    },
  );
}

Future<TimeOfDay?> pickAdaptiveTime({
  required BuildContext context,
  required TimeOfDay initialTime,
}) {
  if (!_usesCupertinoPickers) {
    return showTimePicker(context: context, initialTime: initialTime);
  }

  final now = DateTime.now();
  final initialDateTime = DateTime(
    now.year,
    now.month,
    now.day,
    initialTime.hour,
    initialTime.minute,
  );

  return _showCupertinoPicker<TimeOfDay>(
    context: context,
    initialValue: initialTime,
    builder: (context, onChanged) {
      return CupertinoDatePicker(
        mode: CupertinoDatePickerMode.time,
        use24hFormat: true,
        initialDateTime: initialDateTime,
        onDateTimeChanged: (value) {
          onChanged(TimeOfDay(hour: value.hour, minute: value.minute));
        },
      );
    },
  );
}

Future<DateTimeRange?> pickAdaptiveDateRange({
  required BuildContext context,
  required DateTime firstDate,
  required DateTime lastDate,
  DateTimeRange? initialDateRange,
}) async {
  if (!_usesCupertinoPickers) {
    return showDateRangePicker(
      context: context,
      firstDate: firstDate,
      lastDate: lastDate,
      initialDateRange: initialDateRange,
      locale: const Locale('ru'),
    );
  }

  final initialStart = _clampDate(
    initialDateRange?.start ??
        DateTime(lastDate.year, lastDate.month - 1, lastDate.day),
    firstDate,
    lastDate,
  );
  final start = await pickAdaptiveDate(
    context: context,
    initialDate: initialStart,
    firstDate: firstDate,
    lastDate: lastDate,
  );
  if (start == null || !context.mounted) {
    return null;
  }

  final initialEnd = _clampDate(
    initialDateRange?.end ?? lastDate,
    start,
    lastDate,
  );
  final end = await pickAdaptiveDate(
    context: context,
    initialDate: initialEnd,
    firstDate: start,
    lastDate: lastDate,
  );
  if (end == null) {
    return null;
  }

  return DateTimeRange(start: _dateOnly(start), end: _dateOnly(end));
}

Future<T?> _showCupertinoPicker<T>({
  required BuildContext context,
  required T initialValue,
  required Widget Function(BuildContext, ValueChanged<T>) builder,
}) {
  var selectedValue = initialValue;

  return showCupertinoModalPopup<T>(
    context: context,
    builder: (context) {
      return Container(
        height: 320,
        color: CupertinoColors.systemBackground.resolveFrom(context),
        child: SafeArea(
          top: false,
          child: Column(
            children: [
              SizedBox(
                height: 52,
                child: Row(
                  children: [
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      onPressed: () => Navigator.of(context).pop(),
                      child: const Text('Отмена'),
                    ),
                    const Spacer(),
                    CupertinoButton(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                      ),
                      onPressed: () => Navigator.of(context).pop(selectedValue),
                      child: const Text('Готово'),
                    ),
                  ],
                ),
              ),
              Expanded(
                child: builder(
                  context,
                  (value) => selectedValue = value,
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
}

DateTime _clampDate(DateTime value, DateTime firstDate, DateTime lastDate) {
  if (value.isBefore(firstDate)) {
    return firstDate;
  }
  if (value.isAfter(lastDate)) {
    return lastDate;
  }
  return value;
}

DateTime _dateOnly(DateTime date) => DateTime(date.year, date.month, date.day);
