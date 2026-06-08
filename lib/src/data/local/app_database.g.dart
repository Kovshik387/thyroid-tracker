// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $LabResultEntriesTable extends LabResultEntries
    with TableInfo<$LabResultEntriesTable, LabResultEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LabResultEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _tshMeta = const VerificationMeta('tsh');
  @override
  late final GeneratedColumn<double> tsh = GeneratedColumn<double>(
      'tsh', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _freeT4Meta = const VerificationMeta('freeT4');
  @override
  late final GeneratedColumn<double> freeT4 = GeneratedColumn<double>(
      'free_t4', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _freeT3Meta = const VerificationMeta('freeT3');
  @override
  late final GeneratedColumn<double> freeT3 = GeneratedColumn<double>(
      'free_t3', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, tsh, freeT4, freeT3, comment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'lab_result_entries';
  @override
  VerificationContext validateIntegrity(Insertable<LabResultEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('tsh')) {
      context.handle(
          _tshMeta, tsh.isAcceptableOrUnknown(data['tsh']!, _tshMeta));
    }
    if (data.containsKey('free_t4')) {
      context.handle(_freeT4Meta,
          freeT4.isAcceptableOrUnknown(data['free_t4']!, _freeT4Meta));
    }
    if (data.containsKey('free_t3')) {
      context.handle(_freeT3Meta,
          freeT3.isAcceptableOrUnknown(data['free_t3']!, _freeT3Meta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LabResultEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LabResultEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      tsh: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}tsh']),
      freeT4: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}free_t4']),
      freeT3: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}free_t3']),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
    );
  }

  @override
  $LabResultEntriesTable createAlias(String alias) {
    return $LabResultEntriesTable(attachedDatabase, alias);
  }
}

class LabResultEntry extends DataClass implements Insertable<LabResultEntry> {
  final String id;
  final DateTime date;
  final double? tsh;
  final double? freeT4;
  final double? freeT3;
  final String? comment;
  const LabResultEntry(
      {required this.id,
      required this.date,
      this.tsh,
      this.freeT4,
      this.freeT3,
      this.comment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || tsh != null) {
      map['tsh'] = Variable<double>(tsh);
    }
    if (!nullToAbsent || freeT4 != null) {
      map['free_t4'] = Variable<double>(freeT4);
    }
    if (!nullToAbsent || freeT3 != null) {
      map['free_t3'] = Variable<double>(freeT3);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  LabResultEntriesCompanion toCompanion(bool nullToAbsent) {
    return LabResultEntriesCompanion(
      id: Value(id),
      date: Value(date),
      tsh: tsh == null && nullToAbsent ? const Value.absent() : Value(tsh),
      freeT4:
          freeT4 == null && nullToAbsent ? const Value.absent() : Value(freeT4),
      freeT3:
          freeT3 == null && nullToAbsent ? const Value.absent() : Value(freeT3),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory LabResultEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LabResultEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      tsh: serializer.fromJson<double?>(json['tsh']),
      freeT4: serializer.fromJson<double?>(json['freeT4']),
      freeT3: serializer.fromJson<double?>(json['freeT3']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'tsh': serializer.toJson<double?>(tsh),
      'freeT4': serializer.toJson<double?>(freeT4),
      'freeT3': serializer.toJson<double?>(freeT3),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  LabResultEntry copyWith(
          {String? id,
          DateTime? date,
          Value<double?> tsh = const Value.absent(),
          Value<double?> freeT4 = const Value.absent(),
          Value<double?> freeT3 = const Value.absent(),
          Value<String?> comment = const Value.absent()}) =>
      LabResultEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        tsh: tsh.present ? tsh.value : this.tsh,
        freeT4: freeT4.present ? freeT4.value : this.freeT4,
        freeT3: freeT3.present ? freeT3.value : this.freeT3,
        comment: comment.present ? comment.value : this.comment,
      );
  LabResultEntry copyWithCompanion(LabResultEntriesCompanion data) {
    return LabResultEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      tsh: data.tsh.present ? data.tsh.value : this.tsh,
      freeT4: data.freeT4.present ? data.freeT4.value : this.freeT4,
      freeT3: data.freeT3.present ? data.freeT3.value : this.freeT3,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LabResultEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('tsh: $tsh, ')
          ..write('freeT4: $freeT4, ')
          ..write('freeT3: $freeT3, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, tsh, freeT4, freeT3, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LabResultEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.tsh == this.tsh &&
          other.freeT4 == this.freeT4 &&
          other.freeT3 == this.freeT3 &&
          other.comment == this.comment);
}

class LabResultEntriesCompanion extends UpdateCompanion<LabResultEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double?> tsh;
  final Value<double?> freeT4;
  final Value<double?> freeT3;
  final Value<String?> comment;
  final Value<int> rowid;
  const LabResultEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.tsh = const Value.absent(),
    this.freeT4 = const Value.absent(),
    this.freeT3 = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LabResultEntriesCompanion.insert({
    required String id,
    required DateTime date,
    this.tsh = const Value.absent(),
    this.freeT4 = const Value.absent(),
    this.freeT3 = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<LabResultEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? tsh,
    Expression<double>? freeT4,
    Expression<double>? freeT3,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (tsh != null) 'tsh': tsh,
      if (freeT4 != null) 'free_t4': freeT4,
      if (freeT3 != null) 'free_t3': freeT3,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LabResultEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<double?>? tsh,
      Value<double?>? freeT4,
      Value<double?>? freeT3,
      Value<String?>? comment,
      Value<int>? rowid}) {
    return LabResultEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      tsh: tsh ?? this.tsh,
      freeT4: freeT4 ?? this.freeT4,
      freeT3: freeT3 ?? this.freeT3,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (tsh.present) {
      map['tsh'] = Variable<double>(tsh.value);
    }
    if (freeT4.present) {
      map['free_t4'] = Variable<double>(freeT4.value);
    }
    if (freeT3.present) {
      map['free_t3'] = Variable<double>(freeT3.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LabResultEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('tsh: $tsh, ')
          ..write('freeT4: $freeT4, ')
          ..write('freeT3: $freeT3, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $DoctorVisitEntriesTable extends DoctorVisitEntries
    with TableInfo<$DoctorVisitEntriesTable, DoctorVisitEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $DoctorVisitEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _doctorNameMeta =
      const VerificationMeta('doctorName');
  @override
  late final GeneratedColumn<String> doctorName = GeneratedColumn<String>(
      'doctor_name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _specializationMeta =
      const VerificationMeta('specialization');
  @override
  late final GeneratedColumn<String> specialization = GeneratedColumn<String>(
      'specialization', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _recommendationsMeta =
      const VerificationMeta('recommendations');
  @override
  late final GeneratedColumn<String> recommendations = GeneratedColumn<String>(
      'recommendations', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _nextControlDateMeta =
      const VerificationMeta('nextControlDate');
  @override
  late final GeneratedColumn<DateTime> nextControlDate =
      GeneratedColumn<DateTime>('next_control_date', aliasedName, true,
          type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, doctorName, specialization, recommendations, nextControlDate];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'doctor_visit_entries';
  @override
  VerificationContext validateIntegrity(Insertable<DoctorVisitEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('doctor_name')) {
      context.handle(
          _doctorNameMeta,
          doctorName.isAcceptableOrUnknown(
              data['doctor_name']!, _doctorNameMeta));
    }
    if (data.containsKey('specialization')) {
      context.handle(
          _specializationMeta,
          specialization.isAcceptableOrUnknown(
              data['specialization']!, _specializationMeta));
    }
    if (data.containsKey('recommendations')) {
      context.handle(
          _recommendationsMeta,
          recommendations.isAcceptableOrUnknown(
              data['recommendations']!, _recommendationsMeta));
    }
    if (data.containsKey('next_control_date')) {
      context.handle(
          _nextControlDateMeta,
          nextControlDate.isAcceptableOrUnknown(
              data['next_control_date']!, _nextControlDateMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  DoctorVisitEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return DoctorVisitEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      doctorName: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}doctor_name']),
      specialization: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}specialization']),
      recommendations: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}recommendations']),
      nextControlDate: attachedDatabase.typeMapping.read(
          DriftSqlType.dateTime, data['${effectivePrefix}next_control_date']),
    );
  }

  @override
  $DoctorVisitEntriesTable createAlias(String alias) {
    return $DoctorVisitEntriesTable(attachedDatabase, alias);
  }
}

class DoctorVisitEntry extends DataClass
    implements Insertable<DoctorVisitEntry> {
  final String id;
  final DateTime date;
  final String? doctorName;
  final String? specialization;
  final String? recommendations;
  final DateTime? nextControlDate;
  const DoctorVisitEntry(
      {required this.id,
      required this.date,
      this.doctorName,
      this.specialization,
      this.recommendations,
      this.nextControlDate});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || doctorName != null) {
      map['doctor_name'] = Variable<String>(doctorName);
    }
    if (!nullToAbsent || specialization != null) {
      map['specialization'] = Variable<String>(specialization);
    }
    if (!nullToAbsent || recommendations != null) {
      map['recommendations'] = Variable<String>(recommendations);
    }
    if (!nullToAbsent || nextControlDate != null) {
      map['next_control_date'] = Variable<DateTime>(nextControlDate);
    }
    return map;
  }

  DoctorVisitEntriesCompanion toCompanion(bool nullToAbsent) {
    return DoctorVisitEntriesCompanion(
      id: Value(id),
      date: Value(date),
      doctorName: doctorName == null && nullToAbsent
          ? const Value.absent()
          : Value(doctorName),
      specialization: specialization == null && nullToAbsent
          ? const Value.absent()
          : Value(specialization),
      recommendations: recommendations == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendations),
      nextControlDate: nextControlDate == null && nullToAbsent
          ? const Value.absent()
          : Value(nextControlDate),
    );
  }

  factory DoctorVisitEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return DoctorVisitEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      doctorName: serializer.fromJson<String?>(json['doctorName']),
      specialization: serializer.fromJson<String?>(json['specialization']),
      recommendations: serializer.fromJson<String?>(json['recommendations']),
      nextControlDate: serializer.fromJson<DateTime?>(json['nextControlDate']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'doctorName': serializer.toJson<String?>(doctorName),
      'specialization': serializer.toJson<String?>(specialization),
      'recommendations': serializer.toJson<String?>(recommendations),
      'nextControlDate': serializer.toJson<DateTime?>(nextControlDate),
    };
  }

  DoctorVisitEntry copyWith(
          {String? id,
          DateTime? date,
          Value<String?> doctorName = const Value.absent(),
          Value<String?> specialization = const Value.absent(),
          Value<String?> recommendations = const Value.absent(),
          Value<DateTime?> nextControlDate = const Value.absent()}) =>
      DoctorVisitEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        doctorName: doctorName.present ? doctorName.value : this.doctorName,
        specialization:
            specialization.present ? specialization.value : this.specialization,
        recommendations: recommendations.present
            ? recommendations.value
            : this.recommendations,
        nextControlDate: nextControlDate.present
            ? nextControlDate.value
            : this.nextControlDate,
      );
  DoctorVisitEntry copyWithCompanion(DoctorVisitEntriesCompanion data) {
    return DoctorVisitEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      doctorName:
          data.doctorName.present ? data.doctorName.value : this.doctorName,
      specialization: data.specialization.present
          ? data.specialization.value
          : this.specialization,
      recommendations: data.recommendations.present
          ? data.recommendations.value
          : this.recommendations,
      nextControlDate: data.nextControlDate.present
          ? data.nextControlDate.value
          : this.nextControlDate,
    );
  }

  @override
  String toString() {
    return (StringBuffer('DoctorVisitEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('doctorName: $doctorName, ')
          ..write('specialization: $specialization, ')
          ..write('recommendations: $recommendations, ')
          ..write('nextControlDate: $nextControlDate')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, date, doctorName, specialization, recommendations, nextControlDate);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is DoctorVisitEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.doctorName == this.doctorName &&
          other.specialization == this.specialization &&
          other.recommendations == this.recommendations &&
          other.nextControlDate == this.nextControlDate);
}

class DoctorVisitEntriesCompanion extends UpdateCompanion<DoctorVisitEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<String?> doctorName;
  final Value<String?> specialization;
  final Value<String?> recommendations;
  final Value<DateTime?> nextControlDate;
  final Value<int> rowid;
  const DoctorVisitEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.doctorName = const Value.absent(),
    this.specialization = const Value.absent(),
    this.recommendations = const Value.absent(),
    this.nextControlDate = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  DoctorVisitEntriesCompanion.insert({
    required String id,
    required DateTime date,
    this.doctorName = const Value.absent(),
    this.specialization = const Value.absent(),
    this.recommendations = const Value.absent(),
    this.nextControlDate = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<DoctorVisitEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<String>? doctorName,
    Expression<String>? specialization,
    Expression<String>? recommendations,
    Expression<DateTime>? nextControlDate,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (doctorName != null) 'doctor_name': doctorName,
      if (specialization != null) 'specialization': specialization,
      if (recommendations != null) 'recommendations': recommendations,
      if (nextControlDate != null) 'next_control_date': nextControlDate,
      if (rowid != null) 'rowid': rowid,
    });
  }

  DoctorVisitEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<String?>? doctorName,
      Value<String?>? specialization,
      Value<String?>? recommendations,
      Value<DateTime?>? nextControlDate,
      Value<int>? rowid}) {
    return DoctorVisitEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      doctorName: doctorName ?? this.doctorName,
      specialization: specialization ?? this.specialization,
      recommendations: recommendations ?? this.recommendations,
      nextControlDate: nextControlDate ?? this.nextControlDate,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (doctorName.present) {
      map['doctor_name'] = Variable<String>(doctorName.value);
    }
    if (specialization.present) {
      map['specialization'] = Variable<String>(specialization.value);
    }
    if (recommendations.present) {
      map['recommendations'] = Variable<String>(recommendations.value);
    }
    if (nextControlDate.present) {
      map['next_control_date'] = Variable<DateTime>(nextControlDate.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('DoctorVisitEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('doctorName: $doctorName, ')
          ..write('specialization: $specialization, ')
          ..write('recommendations: $recommendations, ')
          ..write('nextControlDate: $nextControlDate, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationPlanEntriesTable extends MedicationPlanEntries
    with TableInfo<$MedicationPlanEntriesTable, MedicationPlanEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationPlanEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dosageMeta = const VerificationMeta('dosage');
  @override
  late final GeneratedColumn<String> dosage = GeneratedColumn<String>(
      'dosage', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _intakeTimeMeta =
      const VerificationMeta('intakeTime');
  @override
  late final GeneratedColumn<DateTime> intakeTime = GeneratedColumn<DateTime>(
      'intake_time', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _doseMcgMeta =
      const VerificationMeta('doseMcg');
  @override
  late final GeneratedColumn<double> doseMcg = GeneratedColumn<double>(
      'dose_mcg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _startedAtMeta =
      const VerificationMeta('startedAt');
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
      'started_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _endedAtMeta =
      const VerificationMeta('endedAt');
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
      'ended_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _noteMeta = const VerificationMeta('note');
  @override
  late final GeneratedColumn<String> note = GeneratedColumn<String>(
      'note', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, dosage, intakeTime, doseMcg, startedAt, endedAt, note];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_plan_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<MedicationPlanEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('dosage')) {
      context.handle(_dosageMeta,
          dosage.isAcceptableOrUnknown(data['dosage']!, _dosageMeta));
    } else if (isInserting) {
      context.missing(_dosageMeta);
    }
    if (data.containsKey('intake_time')) {
      context.handle(
          _intakeTimeMeta,
          intakeTime.isAcceptableOrUnknown(
              data['intake_time']!, _intakeTimeMeta));
    } else if (isInserting) {
      context.missing(_intakeTimeMeta);
    }
    if (data.containsKey('dose_mcg')) {
      context.handle(_doseMcgMeta,
          doseMcg.isAcceptableOrUnknown(data['dose_mcg']!, _doseMcgMeta));
    }
    if (data.containsKey('started_at')) {
      context.handle(_startedAtMeta,
          startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta));
    }
    if (data.containsKey('ended_at')) {
      context.handle(_endedAtMeta,
          endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta));
    }
    if (data.containsKey('note')) {
      context.handle(
          _noteMeta, note.isAcceptableOrUnknown(data['note']!, _noteMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationPlanEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationPlanEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      dosage: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}dosage'])!,
      intakeTime: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}intake_time'])!,
      doseMcg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}dose_mcg']),
      startedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}started_at']),
      endedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}ended_at']),
      note: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}note']),
    );
  }

  @override
  $MedicationPlanEntriesTable createAlias(String alias) {
    return $MedicationPlanEntriesTable(attachedDatabase, alias);
  }
}

class MedicationPlanEntry extends DataClass
    implements Insertable<MedicationPlanEntry> {
  final String id;
  final String name;
  final String dosage;
  final DateTime intakeTime;
  final double? doseMcg;
  final DateTime? startedAt;
  final DateTime? endedAt;
  final String? note;
  const MedicationPlanEntry(
      {required this.id,
      required this.name,
      required this.dosage,
      required this.intakeTime,
      this.doseMcg,
      this.startedAt,
      this.endedAt,
      this.note});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    map['dosage'] = Variable<String>(dosage);
    map['intake_time'] = Variable<DateTime>(intakeTime);
    if (!nullToAbsent || doseMcg != null) {
      map['dose_mcg'] = Variable<double>(doseMcg);
    }
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    if (!nullToAbsent || note != null) {
      map['note'] = Variable<String>(note);
    }
    return map;
  }

  MedicationPlanEntriesCompanion toCompanion(bool nullToAbsent) {
    return MedicationPlanEntriesCompanion(
      id: Value(id),
      name: Value(name),
      dosage: Value(dosage),
      intakeTime: Value(intakeTime),
      doseMcg: doseMcg == null && nullToAbsent
          ? const Value.absent()
          : Value(doseMcg),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
      note: note == null && nullToAbsent ? const Value.absent() : Value(note),
    );
  }

  factory MedicationPlanEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationPlanEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      dosage: serializer.fromJson<String>(json['dosage']),
      intakeTime: serializer.fromJson<DateTime>(json['intakeTime']),
      doseMcg: serializer.fromJson<double?>(json['doseMcg']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
      note: serializer.fromJson<String?>(json['note']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'dosage': serializer.toJson<String>(dosage),
      'intakeTime': serializer.toJson<DateTime>(intakeTime),
      'doseMcg': serializer.toJson<double?>(doseMcg),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
      'note': serializer.toJson<String?>(note),
    };
  }

  MedicationPlanEntry copyWith(
          {String? id,
          String? name,
          String? dosage,
          DateTime? intakeTime,
          Value<double?> doseMcg = const Value.absent(),
          Value<DateTime?> startedAt = const Value.absent(),
          Value<DateTime?> endedAt = const Value.absent(),
          Value<String?> note = const Value.absent()}) =>
      MedicationPlanEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        dosage: dosage ?? this.dosage,
        intakeTime: intakeTime ?? this.intakeTime,
        doseMcg: doseMcg.present ? doseMcg.value : this.doseMcg,
        startedAt: startedAt.present ? startedAt.value : this.startedAt,
        endedAt: endedAt.present ? endedAt.value : this.endedAt,
        note: note.present ? note.value : this.note,
      );
  MedicationPlanEntry copyWithCompanion(MedicationPlanEntriesCompanion data) {
    return MedicationPlanEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      dosage: data.dosage.present ? data.dosage.value : this.dosage,
      intakeTime:
          data.intakeTime.present ? data.intakeTime.value : this.intakeTime,
      doseMcg: data.doseMcg.present ? data.doseMcg.value : this.doseMcg,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
      note: data.note.present ? data.note.value : this.note,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPlanEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('intakeTime: $intakeTime, ')
          ..write('doseMcg: $doseMcg, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('note: $note')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id, name, dosage, intakeTime, doseMcg, startedAt, endedAt, note);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationPlanEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.dosage == this.dosage &&
          other.intakeTime == this.intakeTime &&
          other.doseMcg == this.doseMcg &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt &&
          other.note == this.note);
}

class MedicationPlanEntriesCompanion
    extends UpdateCompanion<MedicationPlanEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<String> dosage;
  final Value<DateTime> intakeTime;
  final Value<double?> doseMcg;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> endedAt;
  final Value<String?> note;
  final Value<int> rowid;
  const MedicationPlanEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.dosage = const Value.absent(),
    this.intakeTime = const Value.absent(),
    this.doseMcg = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationPlanEntriesCompanion.insert({
    required String id,
    required String name,
    required String dosage,
    required DateTime intakeTime,
    this.doseMcg = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
    this.note = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        dosage = Value(dosage),
        intakeTime = Value(intakeTime);
  static Insertable<MedicationPlanEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<String>? dosage,
    Expression<DateTime>? intakeTime,
    Expression<double>? doseMcg,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
    Expression<String>? note,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (dosage != null) 'dosage': dosage,
      if (intakeTime != null) 'intake_time': intakeTime,
      if (doseMcg != null) 'dose_mcg': doseMcg,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
      if (note != null) 'note': note,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationPlanEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<String>? dosage,
      Value<DateTime>? intakeTime,
      Value<double?>? doseMcg,
      Value<DateTime?>? startedAt,
      Value<DateTime?>? endedAt,
      Value<String?>? note,
      Value<int>? rowid}) {
    return MedicationPlanEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      dosage: dosage ?? this.dosage,
      intakeTime: intakeTime ?? this.intakeTime,
      doseMcg: doseMcg ?? this.doseMcg,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
      note: note ?? this.note,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (dosage.present) {
      map['dosage'] = Variable<String>(dosage.value);
    }
    if (intakeTime.present) {
      map['intake_time'] = Variable<DateTime>(intakeTime.value);
    }
    if (doseMcg.present) {
      map['dose_mcg'] = Variable<double>(doseMcg.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    if (note.present) {
      map['note'] = Variable<String>(note.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationPlanEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('dosage: $dosage, ')
          ..write('intakeTime: $intakeTime, ')
          ..write('doseMcg: $doseMcg, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt, ')
          ..write('note: $note, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicationIntakeEntriesTable extends MedicationIntakeEntries
    with TableInfo<$MedicationIntakeEntriesTable, MedicationIntakeEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicationIntakeEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<String> planId = GeneratedColumn<String>(
      'plan_id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _takenAtMeta =
      const VerificationMeta('takenAt');
  @override
  late final GeneratedColumn<DateTime> takenAt = GeneratedColumn<DateTime>(
      'taken_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _takenMeta = const VerificationMeta('taken');
  @override
  late final GeneratedColumn<bool> taken = GeneratedColumn<bool>(
      'taken', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: true,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("taken" IN (0, 1))'));
  static const VerificationMeta _countsForStreakMeta =
      const VerificationMeta('countsForStreak');
  @override
  late final GeneratedColumn<bool> countsForStreak = GeneratedColumn<bool>(
      'counts_for_streak', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("counts_for_streak" IN (0, 1))'),
      defaultValue: const Constant(true));
  @override
  List<GeneratedColumn> get $columns =>
      [id, planId, date, takenAt, taken, countsForStreak];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medication_intake_entries';
  @override
  VerificationContext validateIntegrity(
      Insertable<MedicationIntakeEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('plan_id')) {
      context.handle(_planIdMeta,
          planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta));
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('taken_at')) {
      context.handle(_takenAtMeta,
          takenAt.isAcceptableOrUnknown(data['taken_at']!, _takenAtMeta));
    }
    if (data.containsKey('taken')) {
      context.handle(
          _takenMeta, taken.isAcceptableOrUnknown(data['taken']!, _takenMeta));
    } else if (isInserting) {
      context.missing(_takenMeta);
    }
    if (data.containsKey('counts_for_streak')) {
      context.handle(
          _countsForStreakMeta,
          countsForStreak.isAcceptableOrUnknown(
              data['counts_for_streak']!, _countsForStreakMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicationIntakeEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicationIntakeEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      planId: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}plan_id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      takenAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}taken_at']),
      taken: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}taken'])!,
      countsForStreak: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}counts_for_streak'])!,
    );
  }

  @override
  $MedicationIntakeEntriesTable createAlias(String alias) {
    return $MedicationIntakeEntriesTable(attachedDatabase, alias);
  }
}

class MedicationIntakeEntry extends DataClass
    implements Insertable<MedicationIntakeEntry> {
  final String id;
  final String planId;
  final DateTime date;
  final DateTime? takenAt;
  final bool taken;
  final bool countsForStreak;
  const MedicationIntakeEntry(
      {required this.id,
      required this.planId,
      required this.date,
      this.takenAt,
      required this.taken,
      required this.countsForStreak});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['plan_id'] = Variable<String>(planId);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || takenAt != null) {
      map['taken_at'] = Variable<DateTime>(takenAt);
    }
    map['taken'] = Variable<bool>(taken);
    map['counts_for_streak'] = Variable<bool>(countsForStreak);
    return map;
  }

  MedicationIntakeEntriesCompanion toCompanion(bool nullToAbsent) {
    return MedicationIntakeEntriesCompanion(
      id: Value(id),
      planId: Value(planId),
      date: Value(date),
      takenAt: takenAt == null && nullToAbsent
          ? const Value.absent()
          : Value(takenAt),
      taken: Value(taken),
      countsForStreak: Value(countsForStreak),
    );
  }

  factory MedicationIntakeEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicationIntakeEntry(
      id: serializer.fromJson<String>(json['id']),
      planId: serializer.fromJson<String>(json['planId']),
      date: serializer.fromJson<DateTime>(json['date']),
      takenAt: serializer.fromJson<DateTime?>(json['takenAt']),
      taken: serializer.fromJson<bool>(json['taken']),
      countsForStreak: serializer.fromJson<bool>(json['countsForStreak']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'planId': serializer.toJson<String>(planId),
      'date': serializer.toJson<DateTime>(date),
      'takenAt': serializer.toJson<DateTime?>(takenAt),
      'taken': serializer.toJson<bool>(taken),
      'countsForStreak': serializer.toJson<bool>(countsForStreak),
    };
  }

  MedicationIntakeEntry copyWith(
          {String? id,
          String? planId,
          DateTime? date,
          Value<DateTime?> takenAt = const Value.absent(),
          bool? taken,
          bool? countsForStreak}) =>
      MedicationIntakeEntry(
        id: id ?? this.id,
        planId: planId ?? this.planId,
        date: date ?? this.date,
        takenAt: takenAt.present ? takenAt.value : this.takenAt,
        taken: taken ?? this.taken,
        countsForStreak: countsForStreak ?? this.countsForStreak,
      );
  MedicationIntakeEntry copyWithCompanion(
      MedicationIntakeEntriesCompanion data) {
    return MedicationIntakeEntry(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      date: data.date.present ? data.date.value : this.date,
      takenAt: data.takenAt.present ? data.takenAt.value : this.takenAt,
      taken: data.taken.present ? data.taken.value : this.taken,
      countsForStreak: data.countsForStreak.present
          ? data.countsForStreak.value
          : this.countsForStreak,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicationIntakeEntry(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('takenAt: $takenAt, ')
          ..write('taken: $taken, ')
          ..write('countsForStreak: $countsForStreak')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, planId, date, takenAt, taken, countsForStreak);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicationIntakeEntry &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.date == this.date &&
          other.takenAt == this.takenAt &&
          other.taken == this.taken &&
          other.countsForStreak == this.countsForStreak);
}

class MedicationIntakeEntriesCompanion
    extends UpdateCompanion<MedicationIntakeEntry> {
  final Value<String> id;
  final Value<String> planId;
  final Value<DateTime> date;
  final Value<DateTime?> takenAt;
  final Value<bool> taken;
  final Value<bool> countsForStreak;
  final Value<int> rowid;
  const MedicationIntakeEntriesCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.date = const Value.absent(),
    this.takenAt = const Value.absent(),
    this.taken = const Value.absent(),
    this.countsForStreak = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicationIntakeEntriesCompanion.insert({
    required String id,
    required String planId,
    required DateTime date,
    this.takenAt = const Value.absent(),
    required bool taken,
    this.countsForStreak = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        planId = Value(planId),
        date = Value(date),
        taken = Value(taken);
  static Insertable<MedicationIntakeEntry> custom({
    Expression<String>? id,
    Expression<String>? planId,
    Expression<DateTime>? date,
    Expression<DateTime>? takenAt,
    Expression<bool>? taken,
    Expression<bool>? countsForStreak,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (date != null) 'date': date,
      if (takenAt != null) 'taken_at': takenAt,
      if (taken != null) 'taken': taken,
      if (countsForStreak != null) 'counts_for_streak': countsForStreak,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicationIntakeEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? planId,
      Value<DateTime>? date,
      Value<DateTime?>? takenAt,
      Value<bool>? taken,
      Value<bool>? countsForStreak,
      Value<int>? rowid}) {
    return MedicationIntakeEntriesCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      date: date ?? this.date,
      takenAt: takenAt ?? this.takenAt,
      taken: taken ?? this.taken,
      countsForStreak: countsForStreak ?? this.countsForStreak,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<String>(planId.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (takenAt.present) {
      map['taken_at'] = Variable<DateTime>(takenAt.value);
    }
    if (taken.present) {
      map['taken'] = Variable<bool>(taken.value);
    }
    if (countsForStreak.present) {
      map['counts_for_streak'] = Variable<bool>(countsForStreak.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicationIntakeEntriesCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('date: $date, ')
          ..write('takenAt: $takenAt, ')
          ..write('taken: $taken, ')
          ..write('countsForStreak: $countsForStreak, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AppSettingEntriesTable extends AppSettingEntries
    with TableInfo<$AppSettingEntriesTable, AppSettingEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
      'key', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
      'value', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_setting_entries';
  @override
  VerificationContext validateIntegrity(Insertable<AppSettingEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
          _keyMeta, key.isAcceptableOrUnknown(data['key']!, _keyMeta));
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
          _valueMeta, value.isAcceptableOrUnknown(data['value']!, _valueMeta));
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSettingEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSettingEntry(
      key: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}key'])!,
      value: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}value'])!,
    );
  }

  @override
  $AppSettingEntriesTable createAlias(String alias) {
    return $AppSettingEntriesTable(attachedDatabase, alias);
  }
}

class AppSettingEntry extends DataClass implements Insertable<AppSettingEntry> {
  final String key;
  final String value;
  const AppSettingEntry({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingEntriesCompanion toCompanion(bool nullToAbsent) {
    return AppSettingEntriesCompanion(
      key: Value(key),
      value: Value(value),
    );
  }

  factory AppSettingEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSettingEntry(
      key: serializer.fromJson<String>(json['key']),
      value: serializer.fromJson<String>(json['value']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'key': serializer.toJson<String>(key),
      'value': serializer.toJson<String>(value),
    };
  }

  AppSettingEntry copyWith({String? key, String? value}) => AppSettingEntry(
        key: key ?? this.key,
        value: value ?? this.value,
      );
  AppSettingEntry copyWithCompanion(AppSettingEntriesCompanion data) {
    return AppSettingEntry(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingEntry(')
          ..write('key: $key, ')
          ..write('value: $value')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(key, value);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AppSettingEntry &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingEntriesCompanion extends UpdateCompanion<AppSettingEntry> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingEntriesCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingEntriesCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  })  : key = Value(key),
        value = Value(value);
  static Insertable<AppSettingEntry> custom({
    Expression<String>? key,
    Expression<String>? value,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (key != null) 'key': key,
      if (value != null) 'value': value,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AppSettingEntriesCompanion copyWith(
      {Value<String>? key, Value<String>? value, Value<int>? rowid}) {
    return AppSettingEntriesCompanion(
      key: key ?? this.key,
      value: value ?? this.value,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (key.present) {
      map['key'] = Variable<String>(key.value);
    }
    if (value.present) {
      map['value'] = Variable<String>(value.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AppSettingEntriesCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $UserProfileEntriesTable extends UserProfileEntries
    with TableInfo<$UserProfileEntriesTable, UserProfileEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $UserProfileEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _ageMeta = const VerificationMeta('age');
  @override
  late final GeneratedColumn<int> age = GeneratedColumn<int>(
      'age', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _birthDateMeta =
      const VerificationMeta('birthDate');
  @override
  late final GeneratedColumn<DateTime> birthDate = GeneratedColumn<DateTime>(
      'birth_date', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _heightCmMeta =
      const VerificationMeta('heightCm');
  @override
  late final GeneratedColumn<double> heightCm = GeneratedColumn<double>(
      'height_cm', aliasedName, true,
      type: DriftSqlType.double, requiredDuringInsert: false);
  static const VerificationMeta _sexMeta = const VerificationMeta('sex');
  @override
  late final GeneratedColumn<String> sex = GeneratedColumn<String>(
      'sex', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _diagnosisMeta =
      const VerificationMeta('diagnosis');
  @override
  late final GeneratedColumn<String> diagnosis = GeneratedColumn<String>(
      'diagnosis', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _avatarDataMeta =
      const VerificationMeta('avatarData');
  @override
  late final GeneratedColumn<String> avatarData = GeneratedColumn<String>(
      'avatar_data', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        age,
        birthDate,
        weightKg,
        heightCm,
        sex,
        diagnosis,
        avatarData,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'user_profile_entries';
  @override
  VerificationContext validateIntegrity(Insertable<UserProfileEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('age')) {
      context.handle(
          _ageMeta, age.isAcceptableOrUnknown(data['age']!, _ageMeta));
    }
    if (data.containsKey('birth_date')) {
      context.handle(_birthDateMeta,
          birthDate.isAcceptableOrUnknown(data['birth_date']!, _birthDateMeta));
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    }
    if (data.containsKey('height_cm')) {
      context.handle(_heightCmMeta,
          heightCm.isAcceptableOrUnknown(data['height_cm']!, _heightCmMeta));
    }
    if (data.containsKey('sex')) {
      context.handle(
          _sexMeta, sex.isAcceptableOrUnknown(data['sex']!, _sexMeta));
    }
    if (data.containsKey('diagnosis')) {
      context.handle(_diagnosisMeta,
          diagnosis.isAcceptableOrUnknown(data['diagnosis']!, _diagnosisMeta));
    }
    if (data.containsKey('avatar_data')) {
      context.handle(
          _avatarDataMeta,
          avatarData.isAcceptableOrUnknown(
              data['avatar_data']!, _avatarDataMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  UserProfileEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return UserProfileEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      age: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}age']),
      birthDate: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}birth_date']),
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg']),
      heightCm: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}height_cm']),
      sex: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}sex']),
      diagnosis: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}diagnosis']),
      avatarData: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}avatar_data']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $UserProfileEntriesTable createAlias(String alias) {
    return $UserProfileEntriesTable(attachedDatabase, alias);
  }
}

class UserProfileEntry extends DataClass
    implements Insertable<UserProfileEntry> {
  final String id;
  final String name;
  final int? age;
  final DateTime? birthDate;
  final double? weightKg;
  final double? heightCm;
  final String? sex;
  final String? diagnosis;
  final String? avatarData;
  final DateTime createdAt;
  const UserProfileEntry(
      {required this.id,
      required this.name,
      this.age,
      this.birthDate,
      this.weightKg,
      this.heightCm,
      this.sex,
      this.diagnosis,
      this.avatarData,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['name'] = Variable<String>(name);
    if (!nullToAbsent || age != null) {
      map['age'] = Variable<int>(age);
    }
    if (!nullToAbsent || birthDate != null) {
      map['birth_date'] = Variable<DateTime>(birthDate);
    }
    if (!nullToAbsent || weightKg != null) {
      map['weight_kg'] = Variable<double>(weightKg);
    }
    if (!nullToAbsent || heightCm != null) {
      map['height_cm'] = Variable<double>(heightCm);
    }
    if (!nullToAbsent || sex != null) {
      map['sex'] = Variable<String>(sex);
    }
    if (!nullToAbsent || diagnosis != null) {
      map['diagnosis'] = Variable<String>(diagnosis);
    }
    if (!nullToAbsent || avatarData != null) {
      map['avatar_data'] = Variable<String>(avatarData);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  UserProfileEntriesCompanion toCompanion(bool nullToAbsent) {
    return UserProfileEntriesCompanion(
      id: Value(id),
      name: Value(name),
      age: age == null && nullToAbsent ? const Value.absent() : Value(age),
      birthDate: birthDate == null && nullToAbsent
          ? const Value.absent()
          : Value(birthDate),
      weightKg: weightKg == null && nullToAbsent
          ? const Value.absent()
          : Value(weightKg),
      heightCm: heightCm == null && nullToAbsent
          ? const Value.absent()
          : Value(heightCm),
      sex: sex == null && nullToAbsent ? const Value.absent() : Value(sex),
      diagnosis: diagnosis == null && nullToAbsent
          ? const Value.absent()
          : Value(diagnosis),
      avatarData: avatarData == null && nullToAbsent
          ? const Value.absent()
          : Value(avatarData),
      createdAt: Value(createdAt),
    );
  }

  factory UserProfileEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return UserProfileEntry(
      id: serializer.fromJson<String>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      age: serializer.fromJson<int?>(json['age']),
      birthDate: serializer.fromJson<DateTime?>(json['birthDate']),
      weightKg: serializer.fromJson<double?>(json['weightKg']),
      heightCm: serializer.fromJson<double?>(json['heightCm']),
      sex: serializer.fromJson<String?>(json['sex']),
      diagnosis: serializer.fromJson<String?>(json['diagnosis']),
      avatarData: serializer.fromJson<String?>(json['avatarData']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'name': serializer.toJson<String>(name),
      'age': serializer.toJson<int?>(age),
      'birthDate': serializer.toJson<DateTime?>(birthDate),
      'weightKg': serializer.toJson<double?>(weightKg),
      'heightCm': serializer.toJson<double?>(heightCm),
      'sex': serializer.toJson<String?>(sex),
      'diagnosis': serializer.toJson<String?>(diagnosis),
      'avatarData': serializer.toJson<String?>(avatarData),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  UserProfileEntry copyWith(
          {String? id,
          String? name,
          Value<int?> age = const Value.absent(),
          Value<DateTime?> birthDate = const Value.absent(),
          Value<double?> weightKg = const Value.absent(),
          Value<double?> heightCm = const Value.absent(),
          Value<String?> sex = const Value.absent(),
          Value<String?> diagnosis = const Value.absent(),
          Value<String?> avatarData = const Value.absent(),
          DateTime? createdAt}) =>
      UserProfileEntry(
        id: id ?? this.id,
        name: name ?? this.name,
        age: age.present ? age.value : this.age,
        birthDate: birthDate.present ? birthDate.value : this.birthDate,
        weightKg: weightKg.present ? weightKg.value : this.weightKg,
        heightCm: heightCm.present ? heightCm.value : this.heightCm,
        sex: sex.present ? sex.value : this.sex,
        diagnosis: diagnosis.present ? diagnosis.value : this.diagnosis,
        avatarData: avatarData.present ? avatarData.value : this.avatarData,
        createdAt: createdAt ?? this.createdAt,
      );
  UserProfileEntry copyWithCompanion(UserProfileEntriesCompanion data) {
    return UserProfileEntry(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      age: data.age.present ? data.age.value : this.age,
      birthDate: data.birthDate.present ? data.birthDate.value : this.birthDate,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      heightCm: data.heightCm.present ? data.heightCm.value : this.heightCm,
      sex: data.sex.present ? data.sex.value : this.sex,
      diagnosis: data.diagnosis.present ? data.diagnosis.value : this.diagnosis,
      avatarData:
          data.avatarData.present ? data.avatarData.value : this.avatarData,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileEntry(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('birthDate: $birthDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('sex: $sex, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('avatarData: $avatarData, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, name, age, birthDate, weightKg, heightCm,
      sex, diagnosis, avatarData, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is UserProfileEntry &&
          other.id == this.id &&
          other.name == this.name &&
          other.age == this.age &&
          other.birthDate == this.birthDate &&
          other.weightKg == this.weightKg &&
          other.heightCm == this.heightCm &&
          other.sex == this.sex &&
          other.diagnosis == this.diagnosis &&
          other.avatarData == this.avatarData &&
          other.createdAt == this.createdAt);
}

class UserProfileEntriesCompanion extends UpdateCompanion<UserProfileEntry> {
  final Value<String> id;
  final Value<String> name;
  final Value<int?> age;
  final Value<DateTime?> birthDate;
  final Value<double?> weightKg;
  final Value<double?> heightCm;
  final Value<String?> sex;
  final Value<String?> diagnosis;
  final Value<String?> avatarData;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const UserProfileEntriesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.age = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.sex = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.avatarData = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  UserProfileEntriesCompanion.insert({
    required String id,
    required String name,
    this.age = const Value.absent(),
    this.birthDate = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.heightCm = const Value.absent(),
    this.sex = const Value.absent(),
    this.diagnosis = const Value.absent(),
    this.avatarData = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        name = Value(name),
        createdAt = Value(createdAt);
  static Insertable<UserProfileEntry> custom({
    Expression<String>? id,
    Expression<String>? name,
    Expression<int>? age,
    Expression<DateTime>? birthDate,
    Expression<double>? weightKg,
    Expression<double>? heightCm,
    Expression<String>? sex,
    Expression<String>? diagnosis,
    Expression<String>? avatarData,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (age != null) 'age': age,
      if (birthDate != null) 'birth_date': birthDate,
      if (weightKg != null) 'weight_kg': weightKg,
      if (heightCm != null) 'height_cm': heightCm,
      if (sex != null) 'sex': sex,
      if (diagnosis != null) 'diagnosis': diagnosis,
      if (avatarData != null) 'avatar_data': avatarData,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  UserProfileEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String>? name,
      Value<int?>? age,
      Value<DateTime?>? birthDate,
      Value<double?>? weightKg,
      Value<double?>? heightCm,
      Value<String?>? sex,
      Value<String?>? diagnosis,
      Value<String?>? avatarData,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return UserProfileEntriesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      age: age ?? this.age,
      birthDate: birthDate ?? this.birthDate,
      weightKg: weightKg ?? this.weightKg,
      heightCm: heightCm ?? this.heightCm,
      sex: sex ?? this.sex,
      diagnosis: diagnosis ?? this.diagnosis,
      avatarData: avatarData ?? this.avatarData,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (age.present) {
      map['age'] = Variable<int>(age.value);
    }
    if (birthDate.present) {
      map['birth_date'] = Variable<DateTime>(birthDate.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (heightCm.present) {
      map['height_cm'] = Variable<double>(heightCm.value);
    }
    if (sex.present) {
      map['sex'] = Variable<String>(sex.value);
    }
    if (diagnosis.present) {
      map['diagnosis'] = Variable<String>(diagnosis.value);
    }
    if (avatarData.present) {
      map['avatar_data'] = Variable<String>(avatarData.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('UserProfileEntriesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('age: $age, ')
          ..write('birthDate: $birthDate, ')
          ..write('weightKg: $weightKg, ')
          ..write('heightCm: $heightCm, ')
          ..write('sex: $sex, ')
          ..write('diagnosis: $diagnosis, ')
          ..write('avatarData: $avatarData, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MedicalMediaEntriesTable extends MedicalMediaEntries
    with TableInfo<$MedicalMediaEntriesTable, MedicalMediaEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MedicalMediaEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
      'title', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _categoryMeta =
      const VerificationMeta('category');
  @override
  late final GeneratedColumn<String> category = GeneratedColumn<String>(
      'category', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dataMeta = const VerificationMeta('data');
  @override
  late final GeneratedColumn<String> data = GeneratedColumn<String>(
      'data', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _mimeTypeMeta =
      const VerificationMeta('mimeType');
  @override
  late final GeneratedColumn<String> mimeType = GeneratedColumn<String>(
      'mime_type', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  @override
  List<GeneratedColumn> get $columns =>
      [id, title, category, data, mimeType, comment, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'medical_media_entries';
  @override
  VerificationContext validateIntegrity(Insertable<MedicalMediaEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
          _titleMeta, title.isAcceptableOrUnknown(data['title']!, _titleMeta));
    }
    if (data.containsKey('category')) {
      context.handle(_categoryMeta,
          category.isAcceptableOrUnknown(data['category']!, _categoryMeta));
    } else if (isInserting) {
      context.missing(_categoryMeta);
    }
    if (data.containsKey('data')) {
      context.handle(
          _dataMeta, this.data.isAcceptableOrUnknown(data['data']!, _dataMeta));
    } else if (isInserting) {
      context.missing(_dataMeta);
    }
    if (data.containsKey('mime_type')) {
      context.handle(_mimeTypeMeta,
          mimeType.isAcceptableOrUnknown(data['mime_type']!, _mimeTypeMeta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MedicalMediaEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MedicalMediaEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      title: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}title']),
      category: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}category'])!,
      data: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}data'])!,
      mimeType: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}mime_type']),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at'])!,
    );
  }

  @override
  $MedicalMediaEntriesTable createAlias(String alias) {
    return $MedicalMediaEntriesTable(attachedDatabase, alias);
  }
}

class MedicalMediaEntry extends DataClass
    implements Insertable<MedicalMediaEntry> {
  final String id;
  final String? title;
  final String category;
  final String data;
  final String? mimeType;
  final String? comment;
  final DateTime createdAt;
  const MedicalMediaEntry(
      {required this.id,
      this.title,
      required this.category,
      required this.data,
      this.mimeType,
      this.comment,
      required this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    if (!nullToAbsent || title != null) {
      map['title'] = Variable<String>(title);
    }
    map['category'] = Variable<String>(category);
    map['data'] = Variable<String>(data);
    if (!nullToAbsent || mimeType != null) {
      map['mime_type'] = Variable<String>(mimeType);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  MedicalMediaEntriesCompanion toCompanion(bool nullToAbsent) {
    return MedicalMediaEntriesCompanion(
      id: Value(id),
      title:
          title == null && nullToAbsent ? const Value.absent() : Value(title),
      category: Value(category),
      data: Value(data),
      mimeType: mimeType == null && nullToAbsent
          ? const Value.absent()
          : Value(mimeType),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
      createdAt: Value(createdAt),
    );
  }

  factory MedicalMediaEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MedicalMediaEntry(
      id: serializer.fromJson<String>(json['id']),
      title: serializer.fromJson<String?>(json['title']),
      category: serializer.fromJson<String>(json['category']),
      data: serializer.fromJson<String>(json['data']),
      mimeType: serializer.fromJson<String?>(json['mimeType']),
      comment: serializer.fromJson<String?>(json['comment']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'title': serializer.toJson<String?>(title),
      'category': serializer.toJson<String>(category),
      'data': serializer.toJson<String>(data),
      'mimeType': serializer.toJson<String?>(mimeType),
      'comment': serializer.toJson<String?>(comment),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  MedicalMediaEntry copyWith(
          {String? id,
          Value<String?> title = const Value.absent(),
          String? category,
          String? data,
          Value<String?> mimeType = const Value.absent(),
          Value<String?> comment = const Value.absent(),
          DateTime? createdAt}) =>
      MedicalMediaEntry(
        id: id ?? this.id,
        title: title.present ? title.value : this.title,
        category: category ?? this.category,
        data: data ?? this.data,
        mimeType: mimeType.present ? mimeType.value : this.mimeType,
        comment: comment.present ? comment.value : this.comment,
        createdAt: createdAt ?? this.createdAt,
      );
  MedicalMediaEntry copyWithCompanion(MedicalMediaEntriesCompanion data) {
    return MedicalMediaEntry(
      id: data.id.present ? data.id.value : this.id,
      title: data.title.present ? data.title.value : this.title,
      category: data.category.present ? data.category.value : this.category,
      data: data.data.present ? data.data.value : this.data,
      mimeType: data.mimeType.present ? data.mimeType.value : this.mimeType,
      comment: data.comment.present ? data.comment.value : this.comment,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MedicalMediaEntry(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('data: $data, ')
          ..write('mimeType: $mimeType, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, title, category, data, mimeType, comment, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MedicalMediaEntry &&
          other.id == this.id &&
          other.title == this.title &&
          other.category == this.category &&
          other.data == this.data &&
          other.mimeType == this.mimeType &&
          other.comment == this.comment &&
          other.createdAt == this.createdAt);
}

class MedicalMediaEntriesCompanion extends UpdateCompanion<MedicalMediaEntry> {
  final Value<String> id;
  final Value<String?> title;
  final Value<String> category;
  final Value<String> data;
  final Value<String?> mimeType;
  final Value<String?> comment;
  final Value<DateTime> createdAt;
  final Value<int> rowid;
  const MedicalMediaEntriesCompanion({
    this.id = const Value.absent(),
    this.title = const Value.absent(),
    this.category = const Value.absent(),
    this.data = const Value.absent(),
    this.mimeType = const Value.absent(),
    this.comment = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MedicalMediaEntriesCompanion.insert({
    required String id,
    this.title = const Value.absent(),
    required String category,
    required String data,
    this.mimeType = const Value.absent(),
    this.comment = const Value.absent(),
    required DateTime createdAt,
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        category = Value(category),
        data = Value(data),
        createdAt = Value(createdAt);
  static Insertable<MedicalMediaEntry> custom({
    Expression<String>? id,
    Expression<String>? title,
    Expression<String>? category,
    Expression<String>? data,
    Expression<String>? mimeType,
    Expression<String>? comment,
    Expression<DateTime>? createdAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (title != null) 'title': title,
      if (category != null) 'category': category,
      if (data != null) 'data': data,
      if (mimeType != null) 'mime_type': mimeType,
      if (comment != null) 'comment': comment,
      if (createdAt != null) 'created_at': createdAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MedicalMediaEntriesCompanion copyWith(
      {Value<String>? id,
      Value<String?>? title,
      Value<String>? category,
      Value<String>? data,
      Value<String?>? mimeType,
      Value<String?>? comment,
      Value<DateTime>? createdAt,
      Value<int>? rowid}) {
    return MedicalMediaEntriesCompanion(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      data: data ?? this.data,
      mimeType: mimeType ?? this.mimeType,
      comment: comment ?? this.comment,
      createdAt: createdAt ?? this.createdAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (category.present) {
      map['category'] = Variable<String>(category.value);
    }
    if (data.present) {
      map['data'] = Variable<String>(data.value);
    }
    if (mimeType.present) {
      map['mime_type'] = Variable<String>(mimeType.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MedicalMediaEntriesCompanion(')
          ..write('id: $id, ')
          ..write('title: $title, ')
          ..write('category: $category, ')
          ..write('data: $data, ')
          ..write('mimeType: $mimeType, ')
          ..write('comment: $comment, ')
          ..write('createdAt: $createdAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SleepLogEntriesTable extends SleepLogEntries
    with TableInfo<$SleepLogEntriesTable, SleepLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SleepLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _sleepStartMeta =
      const VerificationMeta('sleepStart');
  @override
  late final GeneratedColumn<DateTime> sleepStart = GeneratedColumn<DateTime>(
      'sleep_start', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _sleepEndMeta =
      const VerificationMeta('sleepEnd');
  @override
  late final GeneratedColumn<DateTime> sleepEnd = GeneratedColumn<DateTime>(
      'sleep_end', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _qualityMeta =
      const VerificationMeta('quality');
  @override
  late final GeneratedColumn<int> quality = GeneratedColumn<int>(
      'quality', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, date, sleepStart, sleepEnd, quality, comment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sleep_log_entries';
  @override
  VerificationContext validateIntegrity(Insertable<SleepLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('sleep_start')) {
      context.handle(
          _sleepStartMeta,
          sleepStart.isAcceptableOrUnknown(
              data['sleep_start']!, _sleepStartMeta));
    }
    if (data.containsKey('sleep_end')) {
      context.handle(_sleepEndMeta,
          sleepEnd.isAcceptableOrUnknown(data['sleep_end']!, _sleepEndMeta));
    }
    if (data.containsKey('quality')) {
      context.handle(_qualityMeta,
          quality.isAcceptableOrUnknown(data['quality']!, _qualityMeta));
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SleepLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SleepLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      sleepStart: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sleep_start']),
      sleepEnd: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}sleep_end']),
      quality: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}quality']),
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
    );
  }

  @override
  $SleepLogEntriesTable createAlias(String alias) {
    return $SleepLogEntriesTable(attachedDatabase, alias);
  }
}

class SleepLogEntry extends DataClass implements Insertable<SleepLogEntry> {
  final String id;
  final DateTime date;
  final DateTime? sleepStart;
  final DateTime? sleepEnd;
  final int? quality;
  final String? comment;
  const SleepLogEntry(
      {required this.id,
      required this.date,
      this.sleepStart,
      this.sleepEnd,
      this.quality,
      this.comment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    if (!nullToAbsent || sleepStart != null) {
      map['sleep_start'] = Variable<DateTime>(sleepStart);
    }
    if (!nullToAbsent || sleepEnd != null) {
      map['sleep_end'] = Variable<DateTime>(sleepEnd);
    }
    if (!nullToAbsent || quality != null) {
      map['quality'] = Variable<int>(quality);
    }
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  SleepLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return SleepLogEntriesCompanion(
      id: Value(id),
      date: Value(date),
      sleepStart: sleepStart == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepStart),
      sleepEnd: sleepEnd == null && nullToAbsent
          ? const Value.absent()
          : Value(sleepEnd),
      quality: quality == null && nullToAbsent
          ? const Value.absent()
          : Value(quality),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory SleepLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SleepLogEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      sleepStart: serializer.fromJson<DateTime?>(json['sleepStart']),
      sleepEnd: serializer.fromJson<DateTime?>(json['sleepEnd']),
      quality: serializer.fromJson<int?>(json['quality']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'sleepStart': serializer.toJson<DateTime?>(sleepStart),
      'sleepEnd': serializer.toJson<DateTime?>(sleepEnd),
      'quality': serializer.toJson<int?>(quality),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  SleepLogEntry copyWith(
          {String? id,
          DateTime? date,
          Value<DateTime?> sleepStart = const Value.absent(),
          Value<DateTime?> sleepEnd = const Value.absent(),
          Value<int?> quality = const Value.absent(),
          Value<String?> comment = const Value.absent()}) =>
      SleepLogEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        sleepStart: sleepStart.present ? sleepStart.value : this.sleepStart,
        sleepEnd: sleepEnd.present ? sleepEnd.value : this.sleepEnd,
        quality: quality.present ? quality.value : this.quality,
        comment: comment.present ? comment.value : this.comment,
      );
  SleepLogEntry copyWithCompanion(SleepLogEntriesCompanion data) {
    return SleepLogEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      sleepStart:
          data.sleepStart.present ? data.sleepStart.value : this.sleepStart,
      sleepEnd: data.sleepEnd.present ? data.sleepEnd.value : this.sleepEnd,
      quality: data.quality.present ? data.quality.value : this.quality,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepStart: $sleepStart, ')
          ..write('sleepEnd: $sleepEnd, ')
          ..write('quality: $quality, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, date, sleepStart, sleepEnd, quality, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SleepLogEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.sleepStart == this.sleepStart &&
          other.sleepEnd == this.sleepEnd &&
          other.quality == this.quality &&
          other.comment == this.comment);
}

class SleepLogEntriesCompanion extends UpdateCompanion<SleepLogEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<DateTime?> sleepStart;
  final Value<DateTime?> sleepEnd;
  final Value<int?> quality;
  final Value<String?> comment;
  final Value<int> rowid;
  const SleepLogEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.sleepStart = const Value.absent(),
    this.sleepEnd = const Value.absent(),
    this.quality = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SleepLogEntriesCompanion.insert({
    required String id,
    required DateTime date,
    this.sleepStart = const Value.absent(),
    this.sleepEnd = const Value.absent(),
    this.quality = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date);
  static Insertable<SleepLogEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<DateTime>? sleepStart,
    Expression<DateTime>? sleepEnd,
    Expression<int>? quality,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (sleepStart != null) 'sleep_start': sleepStart,
      if (sleepEnd != null) 'sleep_end': sleepEnd,
      if (quality != null) 'quality': quality,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SleepLogEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<DateTime?>? sleepStart,
      Value<DateTime?>? sleepEnd,
      Value<int?>? quality,
      Value<String?>? comment,
      Value<int>? rowid}) {
    return SleepLogEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      sleepStart: sleepStart ?? this.sleepStart,
      sleepEnd: sleepEnd ?? this.sleepEnd,
      quality: quality ?? this.quality,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (sleepStart.present) {
      map['sleep_start'] = Variable<DateTime>(sleepStart.value);
    }
    if (sleepEnd.present) {
      map['sleep_end'] = Variable<DateTime>(sleepEnd.value);
    }
    if (quality.present) {
      map['quality'] = Variable<int>(quality.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SleepLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('sleepStart: $sleepStart, ')
          ..write('sleepEnd: $sleepEnd, ')
          ..write('quality: $quality, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeightLogEntriesTable extends WeightLogEntries
    with TableInfo<$WeightLogEntriesTable, WeightLogEntry> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeightLogEntriesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
      'id', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _dateMeta = const VerificationMeta('date');
  @override
  late final GeneratedColumn<DateTime> date = GeneratedColumn<DateTime>(
      'date', aliasedName, false,
      type: DriftSqlType.dateTime, requiredDuringInsert: true);
  static const VerificationMeta _weightKgMeta =
      const VerificationMeta('weightKg');
  @override
  late final GeneratedColumn<double> weightKg = GeneratedColumn<double>(
      'weight_kg', aliasedName, false,
      type: DriftSqlType.double, requiredDuringInsert: true);
  static const VerificationMeta _commentMeta =
      const VerificationMeta('comment');
  @override
  late final GeneratedColumn<String> comment = GeneratedColumn<String>(
      'comment', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [id, date, weightKg, comment];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weight_log_entries';
  @override
  VerificationContext validateIntegrity(Insertable<WeightLogEntry> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('date')) {
      context.handle(
          _dateMeta, date.isAcceptableOrUnknown(data['date']!, _dateMeta));
    } else if (isInserting) {
      context.missing(_dateMeta);
    }
    if (data.containsKey('weight_kg')) {
      context.handle(_weightKgMeta,
          weightKg.isAcceptableOrUnknown(data['weight_kg']!, _weightKgMeta));
    } else if (isInserting) {
      context.missing(_weightKgMeta);
    }
    if (data.containsKey('comment')) {
      context.handle(_commentMeta,
          comment.isAcceptableOrUnknown(data['comment']!, _commentMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeightLogEntry map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeightLogEntry(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}id'])!,
      date: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}date'])!,
      weightKg: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}weight_kg'])!,
      comment: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}comment']),
    );
  }

  @override
  $WeightLogEntriesTable createAlias(String alias) {
    return $WeightLogEntriesTable(attachedDatabase, alias);
  }
}

class WeightLogEntry extends DataClass implements Insertable<WeightLogEntry> {
  final String id;
  final DateTime date;
  final double weightKg;
  final String? comment;
  const WeightLogEntry(
      {required this.id,
      required this.date,
      required this.weightKg,
      this.comment});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['date'] = Variable<DateTime>(date);
    map['weight_kg'] = Variable<double>(weightKg);
    if (!nullToAbsent || comment != null) {
      map['comment'] = Variable<String>(comment);
    }
    return map;
  }

  WeightLogEntriesCompanion toCompanion(bool nullToAbsent) {
    return WeightLogEntriesCompanion(
      id: Value(id),
      date: Value(date),
      weightKg: Value(weightKg),
      comment: comment == null && nullToAbsent
          ? const Value.absent()
          : Value(comment),
    );
  }

  factory WeightLogEntry.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeightLogEntry(
      id: serializer.fromJson<String>(json['id']),
      date: serializer.fromJson<DateTime>(json['date']),
      weightKg: serializer.fromJson<double>(json['weightKg']),
      comment: serializer.fromJson<String?>(json['comment']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'date': serializer.toJson<DateTime>(date),
      'weightKg': serializer.toJson<double>(weightKg),
      'comment': serializer.toJson<String?>(comment),
    };
  }

  WeightLogEntry copyWith(
          {String? id,
          DateTime? date,
          double? weightKg,
          Value<String?> comment = const Value.absent()}) =>
      WeightLogEntry(
        id: id ?? this.id,
        date: date ?? this.date,
        weightKg: weightKg ?? this.weightKg,
        comment: comment.present ? comment.value : this.comment,
      );
  WeightLogEntry copyWithCompanion(WeightLogEntriesCompanion data) {
    return WeightLogEntry(
      id: data.id.present ? data.id.value : this.id,
      date: data.date.present ? data.date.value : this.date,
      weightKg: data.weightKg.present ? data.weightKg.value : this.weightKg,
      comment: data.comment.present ? data.comment.value : this.comment,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogEntry(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('comment: $comment')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, date, weightKg, comment);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeightLogEntry &&
          other.id == this.id &&
          other.date == this.date &&
          other.weightKg == this.weightKg &&
          other.comment == this.comment);
}

class WeightLogEntriesCompanion extends UpdateCompanion<WeightLogEntry> {
  final Value<String> id;
  final Value<DateTime> date;
  final Value<double> weightKg;
  final Value<String?> comment;
  final Value<int> rowid;
  const WeightLogEntriesCompanion({
    this.id = const Value.absent(),
    this.date = const Value.absent(),
    this.weightKg = const Value.absent(),
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeightLogEntriesCompanion.insert({
    required String id,
    required DateTime date,
    required double weightKg,
    this.comment = const Value.absent(),
    this.rowid = const Value.absent(),
  })  : id = Value(id),
        date = Value(date),
        weightKg = Value(weightKg);
  static Insertable<WeightLogEntry> custom({
    Expression<String>? id,
    Expression<DateTime>? date,
    Expression<double>? weightKg,
    Expression<String>? comment,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (date != null) 'date': date,
      if (weightKg != null) 'weight_kg': weightKg,
      if (comment != null) 'comment': comment,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeightLogEntriesCompanion copyWith(
      {Value<String>? id,
      Value<DateTime>? date,
      Value<double>? weightKg,
      Value<String?>? comment,
      Value<int>? rowid}) {
    return WeightLogEntriesCompanion(
      id: id ?? this.id,
      date: date ?? this.date,
      weightKg: weightKg ?? this.weightKg,
      comment: comment ?? this.comment,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (date.present) {
      map['date'] = Variable<DateTime>(date.value);
    }
    if (weightKg.present) {
      map['weight_kg'] = Variable<double>(weightKg.value);
    }
    if (comment.present) {
      map['comment'] = Variable<String>(comment.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeightLogEntriesCompanion(')
          ..write('id: $id, ')
          ..write('date: $date, ')
          ..write('weightKg: $weightKg, ')
          ..write('comment: $comment, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $LabResultEntriesTable labResultEntries =
      $LabResultEntriesTable(this);
  late final $DoctorVisitEntriesTable doctorVisitEntries =
      $DoctorVisitEntriesTable(this);
  late final $MedicationPlanEntriesTable medicationPlanEntries =
      $MedicationPlanEntriesTable(this);
  late final $MedicationIntakeEntriesTable medicationIntakeEntries =
      $MedicationIntakeEntriesTable(this);
  late final $AppSettingEntriesTable appSettingEntries =
      $AppSettingEntriesTable(this);
  late final $UserProfileEntriesTable userProfileEntries =
      $UserProfileEntriesTable(this);
  late final $MedicalMediaEntriesTable medicalMediaEntries =
      $MedicalMediaEntriesTable(this);
  late final $SleepLogEntriesTable sleepLogEntries =
      $SleepLogEntriesTable(this);
  late final $WeightLogEntriesTable weightLogEntries =
      $WeightLogEntriesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
        labResultEntries,
        doctorVisitEntries,
        medicationPlanEntries,
        medicationIntakeEntries,
        appSettingEntries,
        userProfileEntries,
        medicalMediaEntries,
        sleepLogEntries,
        weightLogEntries
      ];
}

typedef $$LabResultEntriesTableCreateCompanionBuilder
    = LabResultEntriesCompanion Function({
  required String id,
  required DateTime date,
  Value<double?> tsh,
  Value<double?> freeT4,
  Value<double?> freeT3,
  Value<String?> comment,
  Value<int> rowid,
});
typedef $$LabResultEntriesTableUpdateCompanionBuilder
    = LabResultEntriesCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<double?> tsh,
  Value<double?> freeT4,
  Value<double?> freeT3,
  Value<String?> comment,
  Value<int> rowid,
});

class $$LabResultEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $LabResultEntriesTable> {
  $$LabResultEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get tsh => $composableBuilder(
      column: $table.tsh, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get freeT4 => $composableBuilder(
      column: $table.freeT4, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get freeT3 => $composableBuilder(
      column: $table.freeT3, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));
}

class $$LabResultEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $LabResultEntriesTable> {
  $$LabResultEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get tsh => $composableBuilder(
      column: $table.tsh, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get freeT4 => $composableBuilder(
      column: $table.freeT4, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get freeT3 => $composableBuilder(
      column: $table.freeT3, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));
}

class $$LabResultEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $LabResultEntriesTable> {
  $$LabResultEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get tsh =>
      $composableBuilder(column: $table.tsh, builder: (column) => column);

  GeneratedColumn<double> get freeT4 =>
      $composableBuilder(column: $table.freeT4, builder: (column) => column);

  GeneratedColumn<double> get freeT3 =>
      $composableBuilder(column: $table.freeT3, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$LabResultEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $LabResultEntriesTable,
    LabResultEntry,
    $$LabResultEntriesTableFilterComposer,
    $$LabResultEntriesTableOrderingComposer,
    $$LabResultEntriesTableAnnotationComposer,
    $$LabResultEntriesTableCreateCompanionBuilder,
    $$LabResultEntriesTableUpdateCompanionBuilder,
    (
      LabResultEntry,
      BaseReferences<_$AppDatabase, $LabResultEntriesTable, LabResultEntry>
    ),
    LabResultEntry,
    PrefetchHooks Function()> {
  $$LabResultEntriesTableTableManager(
      _$AppDatabase db, $LabResultEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LabResultEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LabResultEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LabResultEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double?> tsh = const Value.absent(),
            Value<double?> freeT4 = const Value.absent(),
            Value<double?> freeT3 = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LabResultEntriesCompanion(
            id: id,
            date: date,
            tsh: tsh,
            freeT4: freeT4,
            freeT3: freeT3,
            comment: comment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<double?> tsh = const Value.absent(),
            Value<double?> freeT4 = const Value.absent(),
            Value<double?> freeT3 = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              LabResultEntriesCompanion.insert(
            id: id,
            date: date,
            tsh: tsh,
            freeT4: freeT4,
            freeT3: freeT3,
            comment: comment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$LabResultEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $LabResultEntriesTable,
    LabResultEntry,
    $$LabResultEntriesTableFilterComposer,
    $$LabResultEntriesTableOrderingComposer,
    $$LabResultEntriesTableAnnotationComposer,
    $$LabResultEntriesTableCreateCompanionBuilder,
    $$LabResultEntriesTableUpdateCompanionBuilder,
    (
      LabResultEntry,
      BaseReferences<_$AppDatabase, $LabResultEntriesTable, LabResultEntry>
    ),
    LabResultEntry,
    PrefetchHooks Function()>;
typedef $$DoctorVisitEntriesTableCreateCompanionBuilder
    = DoctorVisitEntriesCompanion Function({
  required String id,
  required DateTime date,
  Value<String?> doctorName,
  Value<String?> specialization,
  Value<String?> recommendations,
  Value<DateTime?> nextControlDate,
  Value<int> rowid,
});
typedef $$DoctorVisitEntriesTableUpdateCompanionBuilder
    = DoctorVisitEntriesCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<String?> doctorName,
  Value<String?> specialization,
  Value<String?> recommendations,
  Value<DateTime?> nextControlDate,
  Value<int> rowid,
});

class $$DoctorVisitEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $DoctorVisitEntriesTable> {
  $$DoctorVisitEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get doctorName => $composableBuilder(
      column: $table.doctorName, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get recommendations => $composableBuilder(
      column: $table.recommendations,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get nextControlDate => $composableBuilder(
      column: $table.nextControlDate,
      builder: (column) => ColumnFilters(column));
}

class $$DoctorVisitEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $DoctorVisitEntriesTable> {
  $$DoctorVisitEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get doctorName => $composableBuilder(
      column: $table.doctorName, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get specialization => $composableBuilder(
      column: $table.specialization,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get recommendations => $composableBuilder(
      column: $table.recommendations,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get nextControlDate => $composableBuilder(
      column: $table.nextControlDate,
      builder: (column) => ColumnOrderings(column));
}

class $$DoctorVisitEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $DoctorVisitEntriesTable> {
  $$DoctorVisitEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<String> get doctorName => $composableBuilder(
      column: $table.doctorName, builder: (column) => column);

  GeneratedColumn<String> get specialization => $composableBuilder(
      column: $table.specialization, builder: (column) => column);

  GeneratedColumn<String> get recommendations => $composableBuilder(
      column: $table.recommendations, builder: (column) => column);

  GeneratedColumn<DateTime> get nextControlDate => $composableBuilder(
      column: $table.nextControlDate, builder: (column) => column);
}

class $$DoctorVisitEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $DoctorVisitEntriesTable,
    DoctorVisitEntry,
    $$DoctorVisitEntriesTableFilterComposer,
    $$DoctorVisitEntriesTableOrderingComposer,
    $$DoctorVisitEntriesTableAnnotationComposer,
    $$DoctorVisitEntriesTableCreateCompanionBuilder,
    $$DoctorVisitEntriesTableUpdateCompanionBuilder,
    (
      DoctorVisitEntry,
      BaseReferences<_$AppDatabase, $DoctorVisitEntriesTable, DoctorVisitEntry>
    ),
    DoctorVisitEntry,
    PrefetchHooks Function()> {
  $$DoctorVisitEntriesTableTableManager(
      _$AppDatabase db, $DoctorVisitEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$DoctorVisitEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$DoctorVisitEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$DoctorVisitEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<String?> doctorName = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
            Value<String?> recommendations = const Value.absent(),
            Value<DateTime?> nextControlDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DoctorVisitEntriesCompanion(
            id: id,
            date: date,
            doctorName: doctorName,
            specialization: specialization,
            recommendations: recommendations,
            nextControlDate: nextControlDate,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<String?> doctorName = const Value.absent(),
            Value<String?> specialization = const Value.absent(),
            Value<String?> recommendations = const Value.absent(),
            Value<DateTime?> nextControlDate = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              DoctorVisitEntriesCompanion.insert(
            id: id,
            date: date,
            doctorName: doctorName,
            specialization: specialization,
            recommendations: recommendations,
            nextControlDate: nextControlDate,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$DoctorVisitEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $DoctorVisitEntriesTable,
    DoctorVisitEntry,
    $$DoctorVisitEntriesTableFilterComposer,
    $$DoctorVisitEntriesTableOrderingComposer,
    $$DoctorVisitEntriesTableAnnotationComposer,
    $$DoctorVisitEntriesTableCreateCompanionBuilder,
    $$DoctorVisitEntriesTableUpdateCompanionBuilder,
    (
      DoctorVisitEntry,
      BaseReferences<_$AppDatabase, $DoctorVisitEntriesTable, DoctorVisitEntry>
    ),
    DoctorVisitEntry,
    PrefetchHooks Function()>;
typedef $$MedicationPlanEntriesTableCreateCompanionBuilder
    = MedicationPlanEntriesCompanion Function({
  required String id,
  required String name,
  required String dosage,
  required DateTime intakeTime,
  Value<double?> doseMcg,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> note,
  Value<int> rowid,
});
typedef $$MedicationPlanEntriesTableUpdateCompanionBuilder
    = MedicationPlanEntriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<String> dosage,
  Value<DateTime> intakeTime,
  Value<double?> doseMcg,
  Value<DateTime?> startedAt,
  Value<DateTime?> endedAt,
  Value<String?> note,
  Value<int> rowid,
});

class $$MedicationPlanEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationPlanEntriesTable> {
  $$MedicationPlanEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get intakeTime => $composableBuilder(
      column: $table.intakeTime, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get doseMcg => $composableBuilder(
      column: $table.doseMcg, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnFilters(column));
}

class $$MedicationPlanEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationPlanEntriesTable> {
  $$MedicationPlanEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get dosage => $composableBuilder(
      column: $table.dosage, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get intakeTime => $composableBuilder(
      column: $table.intakeTime, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get doseMcg => $composableBuilder(
      column: $table.doseMcg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
      column: $table.startedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
      column: $table.endedAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get note => $composableBuilder(
      column: $table.note, builder: (column) => ColumnOrderings(column));
}

class $$MedicationPlanEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationPlanEntriesTable> {
  $$MedicationPlanEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get dosage =>
      $composableBuilder(column: $table.dosage, builder: (column) => column);

  GeneratedColumn<DateTime> get intakeTime => $composableBuilder(
      column: $table.intakeTime, builder: (column) => column);

  GeneratedColumn<double> get doseMcg =>
      $composableBuilder(column: $table.doseMcg, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  GeneratedColumn<String> get note =>
      $composableBuilder(column: $table.note, builder: (column) => column);
}

class $$MedicationPlanEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationPlanEntriesTable,
    MedicationPlanEntry,
    $$MedicationPlanEntriesTableFilterComposer,
    $$MedicationPlanEntriesTableOrderingComposer,
    $$MedicationPlanEntriesTableAnnotationComposer,
    $$MedicationPlanEntriesTableCreateCompanionBuilder,
    $$MedicationPlanEntriesTableUpdateCompanionBuilder,
    (
      MedicationPlanEntry,
      BaseReferences<_$AppDatabase, $MedicationPlanEntriesTable,
          MedicationPlanEntry>
    ),
    MedicationPlanEntry,
    PrefetchHooks Function()> {
  $$MedicationPlanEntriesTableTableManager(
      _$AppDatabase db, $MedicationPlanEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationPlanEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationPlanEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationPlanEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<String> dosage = const Value.absent(),
            Value<DateTime> intakeTime = const Value.absent(),
            Value<double?> doseMcg = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationPlanEntriesCompanion(
            id: id,
            name: name,
            dosage: dosage,
            intakeTime: intakeTime,
            doseMcg: doseMcg,
            startedAt: startedAt,
            endedAt: endedAt,
            note: note,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            required String dosage,
            required DateTime intakeTime,
            Value<double?> doseMcg = const Value.absent(),
            Value<DateTime?> startedAt = const Value.absent(),
            Value<DateTime?> endedAt = const Value.absent(),
            Value<String?> note = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationPlanEntriesCompanion.insert(
            id: id,
            name: name,
            dosage: dosage,
            intakeTime: intakeTime,
            doseMcg: doseMcg,
            startedAt: startedAt,
            endedAt: endedAt,
            note: note,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationPlanEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MedicationPlanEntriesTable,
        MedicationPlanEntry,
        $$MedicationPlanEntriesTableFilterComposer,
        $$MedicationPlanEntriesTableOrderingComposer,
        $$MedicationPlanEntriesTableAnnotationComposer,
        $$MedicationPlanEntriesTableCreateCompanionBuilder,
        $$MedicationPlanEntriesTableUpdateCompanionBuilder,
        (
          MedicationPlanEntry,
          BaseReferences<_$AppDatabase, $MedicationPlanEntriesTable,
              MedicationPlanEntry>
        ),
        MedicationPlanEntry,
        PrefetchHooks Function()>;
typedef $$MedicationIntakeEntriesTableCreateCompanionBuilder
    = MedicationIntakeEntriesCompanion Function({
  required String id,
  required String planId,
  required DateTime date,
  Value<DateTime?> takenAt,
  required bool taken,
  Value<bool> countsForStreak,
  Value<int> rowid,
});
typedef $$MedicationIntakeEntriesTableUpdateCompanionBuilder
    = MedicationIntakeEntriesCompanion Function({
  Value<String> id,
  Value<String> planId,
  Value<DateTime> date,
  Value<DateTime?> takenAt,
  Value<bool> taken,
  Value<bool> countsForStreak,
  Value<int> rowid,
});

class $$MedicationIntakeEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicationIntakeEntriesTable> {
  $$MedicationIntakeEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get countsForStreak => $composableBuilder(
      column: $table.countsForStreak,
      builder: (column) => ColumnFilters(column));
}

class $$MedicationIntakeEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicationIntakeEntriesTable> {
  $$MedicationIntakeEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get planId => $composableBuilder(
      column: $table.planId, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get takenAt => $composableBuilder(
      column: $table.takenAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get taken => $composableBuilder(
      column: $table.taken, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get countsForStreak => $composableBuilder(
      column: $table.countsForStreak,
      builder: (column) => ColumnOrderings(column));
}

class $$MedicationIntakeEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicationIntakeEntriesTable> {
  $$MedicationIntakeEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get planId =>
      $composableBuilder(column: $table.planId, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get takenAt =>
      $composableBuilder(column: $table.takenAt, builder: (column) => column);

  GeneratedColumn<bool> get taken =>
      $composableBuilder(column: $table.taken, builder: (column) => column);

  GeneratedColumn<bool> get countsForStreak => $composableBuilder(
      column: $table.countsForStreak, builder: (column) => column);
}

class $$MedicationIntakeEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicationIntakeEntriesTable,
    MedicationIntakeEntry,
    $$MedicationIntakeEntriesTableFilterComposer,
    $$MedicationIntakeEntriesTableOrderingComposer,
    $$MedicationIntakeEntriesTableAnnotationComposer,
    $$MedicationIntakeEntriesTableCreateCompanionBuilder,
    $$MedicationIntakeEntriesTableUpdateCompanionBuilder,
    (
      MedicationIntakeEntry,
      BaseReferences<_$AppDatabase, $MedicationIntakeEntriesTable,
          MedicationIntakeEntry>
    ),
    MedicationIntakeEntry,
    PrefetchHooks Function()> {
  $$MedicationIntakeEntriesTableTableManager(
      _$AppDatabase db, $MedicationIntakeEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicationIntakeEntriesTableFilterComposer(
                  $db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicationIntakeEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicationIntakeEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> planId = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> takenAt = const Value.absent(),
            Value<bool> taken = const Value.absent(),
            Value<bool> countsForStreak = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationIntakeEntriesCompanion(
            id: id,
            planId: planId,
            date: date,
            takenAt: takenAt,
            taken: taken,
            countsForStreak: countsForStreak,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String planId,
            required DateTime date,
            Value<DateTime?> takenAt = const Value.absent(),
            required bool taken,
            Value<bool> countsForStreak = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicationIntakeEntriesCompanion.insert(
            id: id,
            planId: planId,
            date: date,
            takenAt: takenAt,
            taken: taken,
            countsForStreak: countsForStreak,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicationIntakeEntriesTableProcessedTableManager
    = ProcessedTableManager<
        _$AppDatabase,
        $MedicationIntakeEntriesTable,
        MedicationIntakeEntry,
        $$MedicationIntakeEntriesTableFilterComposer,
        $$MedicationIntakeEntriesTableOrderingComposer,
        $$MedicationIntakeEntriesTableAnnotationComposer,
        $$MedicationIntakeEntriesTableCreateCompanionBuilder,
        $$MedicationIntakeEntriesTableUpdateCompanionBuilder,
        (
          MedicationIntakeEntry,
          BaseReferences<_$AppDatabase, $MedicationIntakeEntriesTable,
              MedicationIntakeEntry>
        ),
        MedicationIntakeEntry,
        PrefetchHooks Function()>;
typedef $$AppSettingEntriesTableCreateCompanionBuilder
    = AppSettingEntriesCompanion Function({
  required String key,
  required String value,
  Value<int> rowid,
});
typedef $$AppSettingEntriesTableUpdateCompanionBuilder
    = AppSettingEntriesCompanion Function({
  Value<String> key,
  Value<String> value,
  Value<int> rowid,
});

class $$AppSettingEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingEntriesTable> {
  $$AppSettingEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnFilters(column));
}

class $$AppSettingEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingEntriesTable> {
  $$AppSettingEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
      column: $table.key, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get value => $composableBuilder(
      column: $table.value, builder: (column) => ColumnOrderings(column));
}

class $$AppSettingEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingEntriesTable> {
  $$AppSettingEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get key =>
      $composableBuilder(column: $table.key, builder: (column) => column);

  GeneratedColumn<String> get value =>
      $composableBuilder(column: $table.value, builder: (column) => column);
}

class $$AppSettingEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $AppSettingEntriesTable,
    AppSettingEntry,
    $$AppSettingEntriesTableFilterComposer,
    $$AppSettingEntriesTableOrderingComposer,
    $$AppSettingEntriesTableAnnotationComposer,
    $$AppSettingEntriesTableCreateCompanionBuilder,
    $$AppSettingEntriesTableUpdateCompanionBuilder,
    (
      AppSettingEntry,
      BaseReferences<_$AppDatabase, $AppSettingEntriesTable, AppSettingEntry>
    ),
    AppSettingEntry,
    PrefetchHooks Function()> {
  $$AppSettingEntriesTableTableManager(
      _$AppDatabase db, $AppSettingEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingEntriesCompanion(
            key: key,
            value: value,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String key,
            required String value,
            Value<int> rowid = const Value.absent(),
          }) =>
              AppSettingEntriesCompanion.insert(
            key: key,
            value: value,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$AppSettingEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $AppSettingEntriesTable,
    AppSettingEntry,
    $$AppSettingEntriesTableFilterComposer,
    $$AppSettingEntriesTableOrderingComposer,
    $$AppSettingEntriesTableAnnotationComposer,
    $$AppSettingEntriesTableCreateCompanionBuilder,
    $$AppSettingEntriesTableUpdateCompanionBuilder,
    (
      AppSettingEntry,
      BaseReferences<_$AppDatabase, $AppSettingEntriesTable, AppSettingEntry>
    ),
    AppSettingEntry,
    PrefetchHooks Function()>;
typedef $$UserProfileEntriesTableCreateCompanionBuilder
    = UserProfileEntriesCompanion Function({
  required String id,
  required String name,
  Value<int?> age,
  Value<DateTime?> birthDate,
  Value<double?> weightKg,
  Value<double?> heightCm,
  Value<String?> sex,
  Value<String?> diagnosis,
  Value<String?> avatarData,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$UserProfileEntriesTableUpdateCompanionBuilder
    = UserProfileEntriesCompanion Function({
  Value<String> id,
  Value<String> name,
  Value<int?> age,
  Value<DateTime?> birthDate,
  Value<double?> weightKg,
  Value<double?> heightCm,
  Value<String?> sex,
  Value<String?> diagnosis,
  Value<String?> avatarData,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$UserProfileEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $UserProfileEntriesTable> {
  $$UserProfileEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get avatarData => $composableBuilder(
      column: $table.avatarData, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$UserProfileEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $UserProfileEntriesTable> {
  $$UserProfileEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get age => $composableBuilder(
      column: $table.age, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get birthDate => $composableBuilder(
      column: $table.birthDate, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get heightCm => $composableBuilder(
      column: $table.heightCm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get sex => $composableBuilder(
      column: $table.sex, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get diagnosis => $composableBuilder(
      column: $table.diagnosis, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get avatarData => $composableBuilder(
      column: $table.avatarData, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$UserProfileEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $UserProfileEntriesTable> {
  $$UserProfileEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get age =>
      $composableBuilder(column: $table.age, builder: (column) => column);

  GeneratedColumn<DateTime> get birthDate =>
      $composableBuilder(column: $table.birthDate, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<double> get heightCm =>
      $composableBuilder(column: $table.heightCm, builder: (column) => column);

  GeneratedColumn<String> get sex =>
      $composableBuilder(column: $table.sex, builder: (column) => column);

  GeneratedColumn<String> get diagnosis =>
      $composableBuilder(column: $table.diagnosis, builder: (column) => column);

  GeneratedColumn<String> get avatarData => $composableBuilder(
      column: $table.avatarData, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$UserProfileEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $UserProfileEntriesTable,
    UserProfileEntry,
    $$UserProfileEntriesTableFilterComposer,
    $$UserProfileEntriesTableOrderingComposer,
    $$UserProfileEntriesTableAnnotationComposer,
    $$UserProfileEntriesTableCreateCompanionBuilder,
    $$UserProfileEntriesTableUpdateCompanionBuilder,
    (
      UserProfileEntry,
      BaseReferences<_$AppDatabase, $UserProfileEntriesTable, UserProfileEntry>
    ),
    UserProfileEntry,
    PrefetchHooks Function()> {
  $$UserProfileEntriesTableTableManager(
      _$AppDatabase db, $UserProfileEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$UserProfileEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$UserProfileEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$UserProfileEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int?> age = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> avatarData = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfileEntriesCompanion(
            id: id,
            name: name,
            age: age,
            birthDate: birthDate,
            weightKg: weightKg,
            heightCm: heightCm,
            sex: sex,
            diagnosis: diagnosis,
            avatarData: avatarData,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required String name,
            Value<int?> age = const Value.absent(),
            Value<DateTime?> birthDate = const Value.absent(),
            Value<double?> weightKg = const Value.absent(),
            Value<double?> heightCm = const Value.absent(),
            Value<String?> sex = const Value.absent(),
            Value<String?> diagnosis = const Value.absent(),
            Value<String?> avatarData = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              UserProfileEntriesCompanion.insert(
            id: id,
            name: name,
            age: age,
            birthDate: birthDate,
            weightKg: weightKg,
            heightCm: heightCm,
            sex: sex,
            diagnosis: diagnosis,
            avatarData: avatarData,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$UserProfileEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $UserProfileEntriesTable,
    UserProfileEntry,
    $$UserProfileEntriesTableFilterComposer,
    $$UserProfileEntriesTableOrderingComposer,
    $$UserProfileEntriesTableAnnotationComposer,
    $$UserProfileEntriesTableCreateCompanionBuilder,
    $$UserProfileEntriesTableUpdateCompanionBuilder,
    (
      UserProfileEntry,
      BaseReferences<_$AppDatabase, $UserProfileEntriesTable, UserProfileEntry>
    ),
    UserProfileEntry,
    PrefetchHooks Function()>;
typedef $$MedicalMediaEntriesTableCreateCompanionBuilder
    = MedicalMediaEntriesCompanion Function({
  required String id,
  Value<String?> title,
  required String category,
  required String data,
  Value<String?> mimeType,
  Value<String?> comment,
  required DateTime createdAt,
  Value<int> rowid,
});
typedef $$MedicalMediaEntriesTableUpdateCompanionBuilder
    = MedicalMediaEntriesCompanion Function({
  Value<String> id,
  Value<String?> title,
  Value<String> category,
  Value<String> data,
  Value<String?> mimeType,
  Value<String?> comment,
  Value<DateTime> createdAt,
  Value<int> rowid,
});

class $$MedicalMediaEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $MedicalMediaEntriesTable> {
  $$MedicalMediaEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));
}

class $$MedicalMediaEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $MedicalMediaEntriesTable> {
  $$MedicalMediaEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get title => $composableBuilder(
      column: $table.title, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get category => $composableBuilder(
      column: $table.category, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get data => $composableBuilder(
      column: $table.data, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get mimeType => $composableBuilder(
      column: $table.mimeType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$MedicalMediaEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MedicalMediaEntriesTable> {
  $$MedicalMediaEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<String> get category =>
      $composableBuilder(column: $table.category, builder: (column) => column);

  GeneratedColumn<String> get data =>
      $composableBuilder(column: $table.data, builder: (column) => column);

  GeneratedColumn<String> get mimeType =>
      $composableBuilder(column: $table.mimeType, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);
}

class $$MedicalMediaEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $MedicalMediaEntriesTable,
    MedicalMediaEntry,
    $$MedicalMediaEntriesTableFilterComposer,
    $$MedicalMediaEntriesTableOrderingComposer,
    $$MedicalMediaEntriesTableAnnotationComposer,
    $$MedicalMediaEntriesTableCreateCompanionBuilder,
    $$MedicalMediaEntriesTableUpdateCompanionBuilder,
    (
      MedicalMediaEntry,
      BaseReferences<_$AppDatabase, $MedicalMediaEntriesTable,
          MedicalMediaEntry>
    ),
    MedicalMediaEntry,
    PrefetchHooks Function()> {
  $$MedicalMediaEntriesTableTableManager(
      _$AppDatabase db, $MedicalMediaEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MedicalMediaEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MedicalMediaEntriesTableOrderingComposer(
                  $db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MedicalMediaEntriesTableAnnotationComposer(
                  $db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<String?> title = const Value.absent(),
            Value<String> category = const Value.absent(),
            Value<String> data = const Value.absent(),
            Value<String?> mimeType = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<DateTime> createdAt = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicalMediaEntriesCompanion(
            id: id,
            title: title,
            category: category,
            data: data,
            mimeType: mimeType,
            comment: comment,
            createdAt: createdAt,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            Value<String?> title = const Value.absent(),
            required String category,
            required String data,
            Value<String?> mimeType = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            required DateTime createdAt,
            Value<int> rowid = const Value.absent(),
          }) =>
              MedicalMediaEntriesCompanion.insert(
            id: id,
            title: title,
            category: category,
            data: data,
            mimeType: mimeType,
            comment: comment,
            createdAt: createdAt,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$MedicalMediaEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $MedicalMediaEntriesTable,
    MedicalMediaEntry,
    $$MedicalMediaEntriesTableFilterComposer,
    $$MedicalMediaEntriesTableOrderingComposer,
    $$MedicalMediaEntriesTableAnnotationComposer,
    $$MedicalMediaEntriesTableCreateCompanionBuilder,
    $$MedicalMediaEntriesTableUpdateCompanionBuilder,
    (
      MedicalMediaEntry,
      BaseReferences<_$AppDatabase, $MedicalMediaEntriesTable,
          MedicalMediaEntry>
    ),
    MedicalMediaEntry,
    PrefetchHooks Function()>;
typedef $$SleepLogEntriesTableCreateCompanionBuilder = SleepLogEntriesCompanion
    Function({
  required String id,
  required DateTime date,
  Value<DateTime?> sleepStart,
  Value<DateTime?> sleepEnd,
  Value<int?> quality,
  Value<String?> comment,
  Value<int> rowid,
});
typedef $$SleepLogEntriesTableUpdateCompanionBuilder = SleepLogEntriesCompanion
    Function({
  Value<String> id,
  Value<DateTime> date,
  Value<DateTime?> sleepStart,
  Value<DateTime?> sleepEnd,
  Value<int?> quality,
  Value<String?> comment,
  Value<int> rowid,
});

class $$SleepLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $SleepLogEntriesTable> {
  $$SleepLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sleepStart => $composableBuilder(
      column: $table.sleepStart, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get sleepEnd => $composableBuilder(
      column: $table.sleepEnd, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));
}

class $$SleepLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $SleepLogEntriesTable> {
  $$SleepLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sleepStart => $composableBuilder(
      column: $table.sleepStart, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get sleepEnd => $composableBuilder(
      column: $table.sleepEnd, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get quality => $composableBuilder(
      column: $table.quality, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));
}

class $$SleepLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $SleepLogEntriesTable> {
  $$SleepLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<DateTime> get sleepStart => $composableBuilder(
      column: $table.sleepStart, builder: (column) => column);

  GeneratedColumn<DateTime> get sleepEnd =>
      $composableBuilder(column: $table.sleepEnd, builder: (column) => column);

  GeneratedColumn<int> get quality =>
      $composableBuilder(column: $table.quality, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$SleepLogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SleepLogEntriesTable,
    SleepLogEntry,
    $$SleepLogEntriesTableFilterComposer,
    $$SleepLogEntriesTableOrderingComposer,
    $$SleepLogEntriesTableAnnotationComposer,
    $$SleepLogEntriesTableCreateCompanionBuilder,
    $$SleepLogEntriesTableUpdateCompanionBuilder,
    (
      SleepLogEntry,
      BaseReferences<_$AppDatabase, $SleepLogEntriesTable, SleepLogEntry>
    ),
    SleepLogEntry,
    PrefetchHooks Function()> {
  $$SleepLogEntriesTableTableManager(
      _$AppDatabase db, $SleepLogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SleepLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SleepLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SleepLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<DateTime?> sleepStart = const Value.absent(),
            Value<DateTime?> sleepEnd = const Value.absent(),
            Value<int?> quality = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepLogEntriesCompanion(
            id: id,
            date: date,
            sleepStart: sleepStart,
            sleepEnd: sleepEnd,
            quality: quality,
            comment: comment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            Value<DateTime?> sleepStart = const Value.absent(),
            Value<DateTime?> sleepEnd = const Value.absent(),
            Value<int?> quality = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              SleepLogEntriesCompanion.insert(
            id: id,
            date: date,
            sleepStart: sleepStart,
            sleepEnd: sleepEnd,
            quality: quality,
            comment: comment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$SleepLogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SleepLogEntriesTable,
    SleepLogEntry,
    $$SleepLogEntriesTableFilterComposer,
    $$SleepLogEntriesTableOrderingComposer,
    $$SleepLogEntriesTableAnnotationComposer,
    $$SleepLogEntriesTableCreateCompanionBuilder,
    $$SleepLogEntriesTableUpdateCompanionBuilder,
    (
      SleepLogEntry,
      BaseReferences<_$AppDatabase, $SleepLogEntriesTable, SleepLogEntry>
    ),
    SleepLogEntry,
    PrefetchHooks Function()>;
typedef $$WeightLogEntriesTableCreateCompanionBuilder
    = WeightLogEntriesCompanion Function({
  required String id,
  required DateTime date,
  required double weightKg,
  Value<String?> comment,
  Value<int> rowid,
});
typedef $$WeightLogEntriesTableUpdateCompanionBuilder
    = WeightLogEntriesCompanion Function({
  Value<String> id,
  Value<DateTime> date,
  Value<double> weightKg,
  Value<String?> comment,
  Value<int> rowid,
});

class $$WeightLogEntriesTableFilterComposer
    extends Composer<_$AppDatabase, $WeightLogEntriesTable> {
  $$WeightLogEntriesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnFilters(column));
}

class $$WeightLogEntriesTableOrderingComposer
    extends Composer<_$AppDatabase, $WeightLogEntriesTable> {
  $$WeightLogEntriesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get date => $composableBuilder(
      column: $table.date, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get weightKg => $composableBuilder(
      column: $table.weightKg, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get comment => $composableBuilder(
      column: $table.comment, builder: (column) => ColumnOrderings(column));
}

class $$WeightLogEntriesTableAnnotationComposer
    extends Composer<_$AppDatabase, $WeightLogEntriesTable> {
  $$WeightLogEntriesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get date =>
      $composableBuilder(column: $table.date, builder: (column) => column);

  GeneratedColumn<double> get weightKg =>
      $composableBuilder(column: $table.weightKg, builder: (column) => column);

  GeneratedColumn<String> get comment =>
      $composableBuilder(column: $table.comment, builder: (column) => column);
}

class $$WeightLogEntriesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $WeightLogEntriesTable,
    WeightLogEntry,
    $$WeightLogEntriesTableFilterComposer,
    $$WeightLogEntriesTableOrderingComposer,
    $$WeightLogEntriesTableAnnotationComposer,
    $$WeightLogEntriesTableCreateCompanionBuilder,
    $$WeightLogEntriesTableUpdateCompanionBuilder,
    (
      WeightLogEntry,
      BaseReferences<_$AppDatabase, $WeightLogEntriesTable, WeightLogEntry>
    ),
    WeightLogEntry,
    PrefetchHooks Function()> {
  $$WeightLogEntriesTableTableManager(
      _$AppDatabase db, $WeightLogEntriesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeightLogEntriesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeightLogEntriesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeightLogEntriesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> id = const Value.absent(),
            Value<DateTime> date = const Value.absent(),
            Value<double> weightKg = const Value.absent(),
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightLogEntriesCompanion(
            id: id,
            date: date,
            weightKg: weightKg,
            comment: comment,
            rowid: rowid,
          ),
          createCompanionCallback: ({
            required String id,
            required DateTime date,
            required double weightKg,
            Value<String?> comment = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) =>
              WeightLogEntriesCompanion.insert(
            id: id,
            date: date,
            weightKg: weightKg,
            comment: comment,
            rowid: rowid,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$WeightLogEntriesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $WeightLogEntriesTable,
    WeightLogEntry,
    $$WeightLogEntriesTableFilterComposer,
    $$WeightLogEntriesTableOrderingComposer,
    $$WeightLogEntriesTableAnnotationComposer,
    $$WeightLogEntriesTableCreateCompanionBuilder,
    $$WeightLogEntriesTableUpdateCompanionBuilder,
    (
      WeightLogEntry,
      BaseReferences<_$AppDatabase, $WeightLogEntriesTable, WeightLogEntry>
    ),
    WeightLogEntry,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$LabResultEntriesTableTableManager get labResultEntries =>
      $$LabResultEntriesTableTableManager(_db, _db.labResultEntries);
  $$DoctorVisitEntriesTableTableManager get doctorVisitEntries =>
      $$DoctorVisitEntriesTableTableManager(_db, _db.doctorVisitEntries);
  $$MedicationPlanEntriesTableTableManager get medicationPlanEntries =>
      $$MedicationPlanEntriesTableTableManager(_db, _db.medicationPlanEntries);
  $$MedicationIntakeEntriesTableTableManager get medicationIntakeEntries =>
      $$MedicationIntakeEntriesTableTableManager(
          _db, _db.medicationIntakeEntries);
  $$AppSettingEntriesTableTableManager get appSettingEntries =>
      $$AppSettingEntriesTableTableManager(_db, _db.appSettingEntries);
  $$UserProfileEntriesTableTableManager get userProfileEntries =>
      $$UserProfileEntriesTableTableManager(_db, _db.userProfileEntries);
  $$MedicalMediaEntriesTableTableManager get medicalMediaEntries =>
      $$MedicalMediaEntriesTableTableManager(_db, _db.medicalMediaEntries);
  $$SleepLogEntriesTableTableManager get sleepLogEntries =>
      $$SleepLogEntriesTableTableManager(_db, _db.sleepLogEntries);
  $$WeightLogEntriesTableTableManager get weightLogEntries =>
      $$WeightLogEntriesTableTableManager(_db, _db.weightLogEntries);
}
