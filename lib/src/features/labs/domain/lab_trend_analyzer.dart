import 'lab_result.dart';

enum LabTrendDirection {
  insufficient,
  stable,
  rising,
  falling,
  mixed,
}

class LabTrend {
  const LabTrend({
    required this.direction,
    required this.title,
    required this.message,
  });

  final LabTrendDirection direction;
  final String title;
  final String message;
}

class LabTrendAnalyzer {
  const LabTrendAnalyzer();

  LabTrend analyze(List<LabResult> results) {
    final sorted = [...results]..sort((a, b) => a.date.compareTo(b.date));
    if (sorted.length < 3) {
      return const LabTrend(
        direction: LabTrendDirection.insufficient,
        title: 'Пока мало данных',
        message: 'Для тенденции нужно хотя бы три анализа с датами.',
      );
    }

    final tshValues = sorted
        .where((result) => result.tsh != null)
        .map((result) => result.tsh!)
        .toList();
    final freeT4Values = sorted
        .where((result) => result.freeT4 != null)
        .map((result) => result.freeT4!)
        .toList();

    final tshDirection = _directionFor(tshValues);
    final freeT4Direction = _directionFor(freeT4Values);

    if (tshDirection == LabTrendDirection.rising) {
      return const LabTrend(
        direction: LabTrendDirection.rising,
        title: 'ТТГ растет',
        message:
            'Если рост сохранится, лучше обсудить динамику с эндокринологом и не менять дозировку самостоятельно.',
      );
    }

    if (tshDirection == LabTrendDirection.falling) {
      return const LabTrend(
        direction: LabTrendDirection.falling,
        title: 'ТТГ снижается',
        message:
            'Это может быть ожидаемой динамикой на терапии, но при выраженном снижении стоит сверить результат с врачом.',
      );
    }

    if (freeT4Direction == LabTrendDirection.rising) {
      return const LabTrend(
        direction: LabTrendDirection.rising,
        title: 'Т4 растет',
        message:
            'Следите, не выходит ли свободный Т4 выше диапазона. При отклонении лучше обратиться к врачу.',
      );
    }

    if (freeT4Direction == LabTrendDirection.falling) {
      return const LabTrend(
        direction: LabTrendDirection.falling,
        title: 'Т4 снижается',
        message:
            'Если снижение продолжается или есть симптомы, стоит запланировать консультацию.',
      );
    }

    if (tshDirection == LabTrendDirection.stable &&
        freeT4Direction == LabTrendDirection.stable) {
      return const LabTrend(
        direction: LabTrendDirection.stable,
        title: 'Динамика спокойная',
        message:
            'Последние значения выглядят без выраженного тренда. Продолжайте плановый контроль.',
      );
    }

    return const LabTrend(
      direction: LabTrendDirection.mixed,
      title: 'Динамика неоднозначная',
      message:
          'Показатели меняются разнонаправленно. Лучше смотреть их вместе с самочувствием и рекомендациями врача.',
    );
  }

  LabTrendDirection _directionFor(List<double> values) {
    if (values.length < 3) {
      return LabTrendDirection.insufficient;
    }

    const alpha = 0.3;
    var previous = values.first;
    final smoothed = <double>[previous];
    for (var i = 1; i < values.length; i++) {
      final current = alpha * values[i] + (1 - alpha) * previous;
      smoothed.add(current);
      previous = current;
    }

    final delta = smoothed.last - smoothed[smoothed.length - 2];
    final threshold = (smoothed.last.abs() * 0.02).clamp(0.001, 0.05);
    if (delta.abs() < threshold) {
      return LabTrendDirection.stable;
    }
    if (delta > 0) {
      return LabTrendDirection.rising;
    }
    return LabTrendDirection.falling;
  }
}
