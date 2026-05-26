import '../../../core/domain/reference_range.dart';
import '../../../core/domain/reference_ranges.dart';
import '../../profile/domain/user_profile.dart';

enum LabStatus {
  missing,
  normal,
  low,
  high,
}

class LabEvaluation {
  const LabEvaluation({
    required this.status,
    required this.range,
  });

  final LabStatus status;
  final ReferenceRange range;

  bool get isNormal => status == LabStatus.normal;
}

class LabEvaluator {
  const LabEvaluator({
    this.tshRange = DefaultReferenceRanges.tsh,
    this.freeT4Range = DefaultReferenceRanges.freeT4,
    this.freeT3Range = DefaultReferenceRanges.freeT3,
  });

  final ReferenceRange tshRange;
  final ReferenceRange freeT4Range;
  final ReferenceRange freeT3Range;

  LabEvaluation evaluateTsh(double? value, UserProfile? profile) {
    return _evaluate(value, _tshRange(profile));
  }

  LabEvaluation evaluateFreeT4(double? value, UserProfile? profile) {
    return _evaluate(value, freeT4Range);
  }

  LabEvaluation evaluateFreeT3(double? value, UserProfile? profile) {
    return _evaluate(value, freeT3Range);
  }

  ReferenceRange _tshRange(UserProfile? profile) {
    final age = profile?.age;
    if (age != null && age >= 65) {
      return ReferenceRange(
        min: tshRange.min,
        max: tshRange.max < 5.0 ? 5.0 : tshRange.max,
        unit: tshRange.unit,
      );
    }
    return tshRange;
  }

  LabEvaluation _evaluate(double? value, ReferenceRange range) {
    if (value == null) {
      return LabEvaluation(status: LabStatus.missing, range: range);
    }
    if (value < range.min) {
      return LabEvaluation(status: LabStatus.low, range: range);
    }
    if (value > range.max) {
      return LabEvaluation(status: LabStatus.high, range: range);
    }
    return LabEvaluation(status: LabStatus.normal, range: range);
  }
}
