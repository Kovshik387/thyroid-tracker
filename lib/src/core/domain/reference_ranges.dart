import 'reference_range.dart';

class DefaultReferenceRanges {
  const DefaultReferenceRanges._();

  static const tsh = ReferenceRange(
    min: 0.4,
    max: 4.0,
    unit: 'мМЕ/л',
  );

  static const freeT4 = ReferenceRange(
    min: 9,
    max: 22,
    unit: 'пмоль/л',
  );

  static const freeT3 = ReferenceRange(
    min: 3.1,
    max: 6.8,
    unit: 'пмоль/л',
  );
}
