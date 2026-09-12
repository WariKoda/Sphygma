// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'app_database.dart';

// ignore_for_file: type=lint
class $MeasurementsTable extends Measurements
    with TableInfo<$MeasurementsTable, Measurement> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _systolicMeta = const VerificationMeta(
    'systolic',
  );
  @override
  late final GeneratedColumn<int> systolic = GeneratedColumn<int>(
    'systolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _diastolicMeta = const VerificationMeta(
    'diastolic',
  );
  @override
  late final GeneratedColumn<int> diastolic = GeneratedColumn<int>(
    'diastolic',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _pulseMeta = const VerificationMeta('pulse');
  @override
  late final GeneratedColumn<int> pulse = GeneratedColumn<int>(
    'pulse',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _measuredAtMeta = const VerificationMeta(
    'measuredAt',
  );
  @override
  late final GeneratedColumn<DateTime> measuredAt = GeneratedColumn<DateTime>(
    'measured_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _movementMeta = const VerificationMeta(
    'movement',
  );
  @override
  late final GeneratedColumn<bool> movement = GeneratedColumn<bool>(
    'movement',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("movement" IN (0, 1))',
    ),
  );
  static const VerificationMeta _arrhythmiaMeta = const VerificationMeta(
    'arrhythmia',
  );
  @override
  late final GeneratedColumn<bool> arrhythmia = GeneratedColumn<bool>(
    'arrhythmia',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("arrhythmia" IN (0, 1))',
    ),
  );
  static const VerificationMeta _rawBytesMeta = const VerificationMeta(
    'rawBytes',
  );
  @override
  late final GeneratedColumn<Uint8List> rawBytes = GeneratedColumn<Uint8List>(
    'raw_bytes',
    aliasedName,
    false,
    type: DriftSqlType.blob,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _importedAtMeta = const VerificationMeta(
    'importedAt',
  );
  @override
  late final GeneratedColumn<DateTime> importedAt = GeneratedColumn<DateTime>(
    'imported_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _exportedAtMeta = const VerificationMeta(
    'exportedAt',
  );
  @override
  late final GeneratedColumn<DateTime> exportedAt = GeneratedColumn<DateTime>(
    'exported_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userSlot,
    deviceSequence,
    systolic,
    diastolic,
    pulse,
    measuredAt,
    movement,
    arrhythmia,
    rawBytes,
    importedAt,
    exportedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurements';
  @override
  VerificationContext validateIntegrity(
    Insertable<Measurement> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('systolic')) {
      context.handle(
        _systolicMeta,
        systolic.isAcceptableOrUnknown(data['systolic']!, _systolicMeta),
      );
    } else if (isInserting) {
      context.missing(_systolicMeta);
    }
    if (data.containsKey('diastolic')) {
      context.handle(
        _diastolicMeta,
        diastolic.isAcceptableOrUnknown(data['diastolic']!, _diastolicMeta),
      );
    } else if (isInserting) {
      context.missing(_diastolicMeta);
    }
    if (data.containsKey('pulse')) {
      context.handle(
        _pulseMeta,
        pulse.isAcceptableOrUnknown(data['pulse']!, _pulseMeta),
      );
    } else if (isInserting) {
      context.missing(_pulseMeta);
    }
    if (data.containsKey('measured_at')) {
      context.handle(
        _measuredAtMeta,
        measuredAt.isAcceptableOrUnknown(data['measured_at']!, _measuredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_measuredAtMeta);
    }
    if (data.containsKey('movement')) {
      context.handle(
        _movementMeta,
        movement.isAcceptableOrUnknown(data['movement']!, _movementMeta),
      );
    } else if (isInserting) {
      context.missing(_movementMeta);
    }
    if (data.containsKey('arrhythmia')) {
      context.handle(
        _arrhythmiaMeta,
        arrhythmia.isAcceptableOrUnknown(data['arrhythmia']!, _arrhythmiaMeta),
      );
    } else if (isInserting) {
      context.missing(_arrhythmiaMeta);
    }
    if (data.containsKey('raw_bytes')) {
      context.handle(
        _rawBytesMeta,
        rawBytes.isAcceptableOrUnknown(data['raw_bytes']!, _rawBytesMeta),
      );
    } else if (isInserting) {
      context.missing(_rawBytesMeta);
    }
    if (data.containsKey('imported_at')) {
      context.handle(
        _importedAtMeta,
        importedAt.isAcceptableOrUnknown(data['imported_at']!, _importedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_importedAtMeta);
    }
    if (data.containsKey('exported_at')) {
      context.handle(
        _exportedAtMeta,
        exportedAt.isAcceptableOrUnknown(data['exported_at']!, _exportedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
  @override
  Measurement map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Measurement(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      systolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}systolic'],
      )!,
      diastolic: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}diastolic'],
      )!,
      pulse: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}pulse'],
      )!,
      measuredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}measured_at'],
      )!,
      movement: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}movement'],
      )!,
      arrhythmia: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}arrhythmia'],
      )!,
      rawBytes: attachedDatabase.typeMapping.read(
        DriftSqlType.blob,
        data['${effectivePrefix}raw_bytes'],
      )!,
      importedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}imported_at'],
      )!,
      exportedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}exported_at'],
      ),
    );
  }

  @override
  $MeasurementsTable createAlias(String alias) {
    return $MeasurementsTable(attachedDatabase, alias);
  }
}

class Measurement extends DataClass implements Insertable<Measurement> {
  final int id;

  /// 1 oder 2, wie am Geraet beschriftet.
  final int userSlot;

  /// Laufende Messungsnummer des Geraets (Record-Bytes 9-11).
  final int deviceSequence;
  final int systolic;
  final int diastolic;
  final int pulse;

  /// Zeitstempel laut Geraeteuhr - nur so plausibel wie die Uhr.
  final DateTime measuredAt;
  final bool movement;
  final bool arrhythmia;

  /// Die 14 Rohbytes des Records, fuer Nachvollziehbarkeit und spaetere
  /// Auswertung der noch ungeklaerten Bytes.
  final Uint8List rawBytes;
  final DateTime importedAt;

  /// Gesetzt, sobald der Datensatz nach Health Connect geschrieben wurde.
  final DateTime? exportedAt;
  const Measurement({
    required this.id,
    required this.userSlot,
    required this.deviceSequence,
    required this.systolic,
    required this.diastolic,
    required this.pulse,
    required this.measuredAt,
    required this.movement,
    required this.arrhythmia,
    required this.rawBytes,
    required this.importedAt,
    this.exportedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['systolic'] = Variable<int>(systolic);
    map['diastolic'] = Variable<int>(diastolic);
    map['pulse'] = Variable<int>(pulse);
    map['measured_at'] = Variable<DateTime>(measuredAt);
    map['movement'] = Variable<bool>(movement);
    map['arrhythmia'] = Variable<bool>(arrhythmia);
    map['raw_bytes'] = Variable<Uint8List>(rawBytes);
    map['imported_at'] = Variable<DateTime>(importedAt);
    if (!nullToAbsent || exportedAt != null) {
      map['exported_at'] = Variable<DateTime>(exportedAt);
    }
    return map;
  }

  MeasurementsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementsCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      systolic: Value(systolic),
      diastolic: Value(diastolic),
      pulse: Value(pulse),
      measuredAt: Value(measuredAt),
      movement: Value(movement),
      arrhythmia: Value(arrhythmia),
      rawBytes: Value(rawBytes),
      importedAt: Value(importedAt),
      exportedAt: exportedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(exportedAt),
    );
  }

  factory Measurement.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Measurement(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      systolic: serializer.fromJson<int>(json['systolic']),
      diastolic: serializer.fromJson<int>(json['diastolic']),
      pulse: serializer.fromJson<int>(json['pulse']),
      measuredAt: serializer.fromJson<DateTime>(json['measuredAt']),
      movement: serializer.fromJson<bool>(json['movement']),
      arrhythmia: serializer.fromJson<bool>(json['arrhythmia']),
      rawBytes: serializer.fromJson<Uint8List>(json['rawBytes']),
      importedAt: serializer.fromJson<DateTime>(json['importedAt']),
      exportedAt: serializer.fromJson<DateTime?>(json['exportedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'systolic': serializer.toJson<int>(systolic),
      'diastolic': serializer.toJson<int>(diastolic),
      'pulse': serializer.toJson<int>(pulse),
      'measuredAt': serializer.toJson<DateTime>(measuredAt),
      'movement': serializer.toJson<bool>(movement),
      'arrhythmia': serializer.toJson<bool>(arrhythmia),
      'rawBytes': serializer.toJson<Uint8List>(rawBytes),
      'importedAt': serializer.toJson<DateTime>(importedAt),
      'exportedAt': serializer.toJson<DateTime?>(exportedAt),
    };
  }

  Measurement copyWith({
    int? id,
    int? userSlot,
    int? deviceSequence,
    int? systolic,
    int? diastolic,
    int? pulse,
    DateTime? measuredAt,
    bool? movement,
    bool? arrhythmia,
    Uint8List? rawBytes,
    DateTime? importedAt,
    Value<DateTime?> exportedAt = const Value.absent(),
  }) => Measurement(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    systolic: systolic ?? this.systolic,
    diastolic: diastolic ?? this.diastolic,
    pulse: pulse ?? this.pulse,
    measuredAt: measuredAt ?? this.measuredAt,
    movement: movement ?? this.movement,
    arrhythmia: arrhythmia ?? this.arrhythmia,
    rawBytes: rawBytes ?? this.rawBytes,
    importedAt: importedAt ?? this.importedAt,
    exportedAt: exportedAt.present ? exportedAt.value : this.exportedAt,
  );
  Measurement copyWithCompanion(MeasurementsCompanion data) {
    return Measurement(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      systolic: data.systolic.present ? data.systolic.value : this.systolic,
      diastolic: data.diastolic.present ? data.diastolic.value : this.diastolic,
      pulse: data.pulse.present ? data.pulse.value : this.pulse,
      measuredAt: data.measuredAt.present
          ? data.measuredAt.value
          : this.measuredAt,
      movement: data.movement.present ? data.movement.value : this.movement,
      arrhythmia: data.arrhythmia.present
          ? data.arrhythmia.value
          : this.arrhythmia,
      rawBytes: data.rawBytes.present ? data.rawBytes.value : this.rawBytes,
      importedAt: data.importedAt.present
          ? data.importedAt.value
          : this.importedAt,
      exportedAt: data.exportedAt.present
          ? data.exportedAt.value
          : this.exportedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Measurement(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('movement: $movement, ')
          ..write('arrhythmia: $arrhythmia, ')
          ..write('rawBytes: $rawBytes, ')
          ..write('importedAt: $importedAt, ')
          ..write('exportedAt: $exportedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userSlot,
    deviceSequence,
    systolic,
    diastolic,
    pulse,
    measuredAt,
    movement,
    arrhythmia,
    $driftBlobEquality.hash(rawBytes),
    importedAt,
    exportedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Measurement &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.systolic == this.systolic &&
          other.diastolic == this.diastolic &&
          other.pulse == this.pulse &&
          other.measuredAt == this.measuredAt &&
          other.movement == this.movement &&
          other.arrhythmia == this.arrhythmia &&
          $driftBlobEquality.equals(other.rawBytes, this.rawBytes) &&
          other.importedAt == this.importedAt &&
          other.exportedAt == this.exportedAt);
}

class MeasurementsCompanion extends UpdateCompanion<Measurement> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<int> systolic;
  final Value<int> diastolic;
  final Value<int> pulse;
  final Value<DateTime> measuredAt;
  final Value<bool> movement;
  final Value<bool> arrhythmia;
  final Value<Uint8List> rawBytes;
  final Value<DateTime> importedAt;
  final Value<DateTime?> exportedAt;
  const MeasurementsCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.systolic = const Value.absent(),
    this.diastolic = const Value.absent(),
    this.pulse = const Value.absent(),
    this.measuredAt = const Value.absent(),
    this.movement = const Value.absent(),
    this.arrhythmia = const Value.absent(),
    this.rawBytes = const Value.absent(),
    this.importedAt = const Value.absent(),
    this.exportedAt = const Value.absent(),
  });
  MeasurementsCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    required int deviceSequence,
    required int systolic,
    required int diastolic,
    required int pulse,
    required DateTime measuredAt,
    required bool movement,
    required bool arrhythmia,
    required Uint8List rawBytes,
    required DateTime importedAt,
    this.exportedAt = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       systolic = Value(systolic),
       diastolic = Value(diastolic),
       pulse = Value(pulse),
       measuredAt = Value(measuredAt),
       movement = Value(movement),
       arrhythmia = Value(arrhythmia),
       rawBytes = Value(rawBytes),
       importedAt = Value(importedAt);
  static Insertable<Measurement> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<int>? systolic,
    Expression<int>? diastolic,
    Expression<int>? pulse,
    Expression<DateTime>? measuredAt,
    Expression<bool>? movement,
    Expression<bool>? arrhythmia,
    Expression<Uint8List>? rawBytes,
    Expression<DateTime>? importedAt,
    Expression<DateTime>? exportedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (systolic != null) 'systolic': systolic,
      if (diastolic != null) 'diastolic': diastolic,
      if (pulse != null) 'pulse': pulse,
      if (measuredAt != null) 'measured_at': measuredAt,
      if (movement != null) 'movement': movement,
      if (arrhythmia != null) 'arrhythmia': arrhythmia,
      if (rawBytes != null) 'raw_bytes': rawBytes,
      if (importedAt != null) 'imported_at': importedAt,
      if (exportedAt != null) 'exported_at': exportedAt,
    });
  }

  MeasurementsCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<int>? systolic,
    Value<int>? diastolic,
    Value<int>? pulse,
    Value<DateTime>? measuredAt,
    Value<bool>? movement,
    Value<bool>? arrhythmia,
    Value<Uint8List>? rawBytes,
    Value<DateTime>? importedAt,
    Value<DateTime?>? exportedAt,
  }) {
    return MeasurementsCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      systolic: systolic ?? this.systolic,
      diastolic: diastolic ?? this.diastolic,
      pulse: pulse ?? this.pulse,
      measuredAt: measuredAt ?? this.measuredAt,
      movement: movement ?? this.movement,
      arrhythmia: arrhythmia ?? this.arrhythmia,
      rawBytes: rawBytes ?? this.rawBytes,
      importedAt: importedAt ?? this.importedAt,
      exportedAt: exportedAt ?? this.exportedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (systolic.present) {
      map['systolic'] = Variable<int>(systolic.value);
    }
    if (diastolic.present) {
      map['diastolic'] = Variable<int>(diastolic.value);
    }
    if (pulse.present) {
      map['pulse'] = Variable<int>(pulse.value);
    }
    if (measuredAt.present) {
      map['measured_at'] = Variable<DateTime>(measuredAt.value);
    }
    if (movement.present) {
      map['movement'] = Variable<bool>(movement.value);
    }
    if (arrhythmia.present) {
      map['arrhythmia'] = Variable<bool>(arrhythmia.value);
    }
    if (rawBytes.present) {
      map['raw_bytes'] = Variable<Uint8List>(rawBytes.value);
    }
    if (importedAt.present) {
      map['imported_at'] = Variable<DateTime>(importedAt.value);
    }
    if (exportedAt.present) {
      map['exported_at'] = Variable<DateTime>(exportedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementsCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('systolic: $systolic, ')
          ..write('diastolic: $diastolic, ')
          ..write('pulse: $pulse, ')
          ..write('measuredAt: $measuredAt, ')
          ..write('movement: $movement, ')
          ..write('arrhythmia: $arrhythmia, ')
          ..write('rawBytes: $rawBytes, ')
          ..write('importedAt: $importedAt, ')
          ..write('exportedAt: $exportedAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementExportsTable extends MeasurementExports
    with TableInfo<$MeasurementExportsTable, MeasurementExport> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementExportsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _measurementIdMeta = const VerificationMeta(
    'measurementId',
  );
  @override
  late final GeneratedColumn<int> measurementId = GeneratedColumn<int>(
    'measurement_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurements (id)',
    ),
  );
  static const VerificationMeta _mayExistMeta = const VerificationMeta(
    'mayExist',
  );
  @override
  late final GeneratedColumn<bool> mayExist = GeneratedColumn<bool>(
    'may_exist',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("may_exist" IN (0, 1))',
    ),
  );
  static const VerificationMeta _withdrawnMeta = const VerificationMeta(
    'withdrawn',
  );
  @override
  late final GeneratedColumn<bool> withdrawn = GeneratedColumn<bool>(
    'withdrawn',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("withdrawn" IN (0, 1))',
    ),
  );
  static const VerificationMeta _legacyUnknownMeta = const VerificationMeta(
    'legacyUnknown',
  );
  @override
  late final GeneratedColumn<bool> legacyUnknown = GeneratedColumn<bool>(
    'legacy_unknown',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("legacy_unknown" IN (0, 1))',
    ),
    defaultValue: const Constant(false),
  );
  @override
  List<GeneratedColumn> get $columns => [
    measurementId,
    mayExist,
    withdrawn,
    legacyUnknown,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_exports';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementExport> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('measurement_id')) {
      context.handle(
        _measurementIdMeta,
        measurementId.isAcceptableOrUnknown(
          data['measurement_id']!,
          _measurementIdMeta,
        ),
      );
    }
    if (data.containsKey('may_exist')) {
      context.handle(
        _mayExistMeta,
        mayExist.isAcceptableOrUnknown(data['may_exist']!, _mayExistMeta),
      );
    } else if (isInserting) {
      context.missing(_mayExistMeta);
    }
    if (data.containsKey('withdrawn')) {
      context.handle(
        _withdrawnMeta,
        withdrawn.isAcceptableOrUnknown(data['withdrawn']!, _withdrawnMeta),
      );
    } else if (isInserting) {
      context.missing(_withdrawnMeta);
    }
    if (data.containsKey('legacy_unknown')) {
      context.handle(
        _legacyUnknownMeta,
        legacyUnknown.isAcceptableOrUnknown(
          data['legacy_unknown']!,
          _legacyUnknownMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {measurementId};
  @override
  MeasurementExport map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementExport(
      measurementId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}measurement_id'],
      )!,
      mayExist: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}may_exist'],
      )!,
      withdrawn: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}withdrawn'],
      )!,
      legacyUnknown: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}legacy_unknown'],
      )!,
    );
  }

  @override
  $MeasurementExportsTable createAlias(String alias) {
    return $MeasurementExportsTable(attachedDatabase, alias);
  }
}

class MeasurementExport extends DataClass
    implements Insertable<MeasurementExport> {
  final int measurementId;
  final bool mayExist;
  final bool withdrawn;
  final bool legacyUnknown;
  const MeasurementExport({
    required this.measurementId,
    required this.mayExist,
    required this.withdrawn,
    required this.legacyUnknown,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['measurement_id'] = Variable<int>(measurementId);
    map['may_exist'] = Variable<bool>(mayExist);
    map['withdrawn'] = Variable<bool>(withdrawn);
    map['legacy_unknown'] = Variable<bool>(legacyUnknown);
    return map;
  }

  MeasurementExportsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementExportsCompanion(
      measurementId: Value(measurementId),
      mayExist: Value(mayExist),
      withdrawn: Value(withdrawn),
      legacyUnknown: Value(legacyUnknown),
    );
  }

  factory MeasurementExport.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementExport(
      measurementId: serializer.fromJson<int>(json['measurementId']),
      mayExist: serializer.fromJson<bool>(json['mayExist']),
      withdrawn: serializer.fromJson<bool>(json['withdrawn']),
      legacyUnknown: serializer.fromJson<bool>(json['legacyUnknown']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'measurementId': serializer.toJson<int>(measurementId),
      'mayExist': serializer.toJson<bool>(mayExist),
      'withdrawn': serializer.toJson<bool>(withdrawn),
      'legacyUnknown': serializer.toJson<bool>(legacyUnknown),
    };
  }

  MeasurementExport copyWith({
    int? measurementId,
    bool? mayExist,
    bool? withdrawn,
    bool? legacyUnknown,
  }) => MeasurementExport(
    measurementId: measurementId ?? this.measurementId,
    mayExist: mayExist ?? this.mayExist,
    withdrawn: withdrawn ?? this.withdrawn,
    legacyUnknown: legacyUnknown ?? this.legacyUnknown,
  );
  MeasurementExport copyWithCompanion(MeasurementExportsCompanion data) {
    return MeasurementExport(
      measurementId: data.measurementId.present
          ? data.measurementId.value
          : this.measurementId,
      mayExist: data.mayExist.present ? data.mayExist.value : this.mayExist,
      withdrawn: data.withdrawn.present ? data.withdrawn.value : this.withdrawn,
      legacyUnknown: data.legacyUnknown.present
          ? data.legacyUnknown.value
          : this.legacyUnknown,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementExport(')
          ..write('measurementId: $measurementId, ')
          ..write('mayExist: $mayExist, ')
          ..write('withdrawn: $withdrawn, ')
          ..write('legacyUnknown: $legacyUnknown')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(measurementId, mayExist, withdrawn, legacyUnknown);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementExport &&
          other.measurementId == this.measurementId &&
          other.mayExist == this.mayExist &&
          other.withdrawn == this.withdrawn &&
          other.legacyUnknown == this.legacyUnknown);
}

class MeasurementExportsCompanion extends UpdateCompanion<MeasurementExport> {
  final Value<int> measurementId;
  final Value<bool> mayExist;
  final Value<bool> withdrawn;
  final Value<bool> legacyUnknown;
  const MeasurementExportsCompanion({
    this.measurementId = const Value.absent(),
    this.mayExist = const Value.absent(),
    this.withdrawn = const Value.absent(),
    this.legacyUnknown = const Value.absent(),
  });
  MeasurementExportsCompanion.insert({
    this.measurementId = const Value.absent(),
    required bool mayExist,
    required bool withdrawn,
    this.legacyUnknown = const Value.absent(),
  }) : mayExist = Value(mayExist),
       withdrawn = Value(withdrawn);
  static Insertable<MeasurementExport> custom({
    Expression<int>? measurementId,
    Expression<bool>? mayExist,
    Expression<bool>? withdrawn,
    Expression<bool>? legacyUnknown,
  }) {
    return RawValuesInsertable({
      if (measurementId != null) 'measurement_id': measurementId,
      if (mayExist != null) 'may_exist': mayExist,
      if (withdrawn != null) 'withdrawn': withdrawn,
      if (legacyUnknown != null) 'legacy_unknown': legacyUnknown,
    });
  }

  MeasurementExportsCompanion copyWith({
    Value<int>? measurementId,
    Value<bool>? mayExist,
    Value<bool>? withdrawn,
    Value<bool>? legacyUnknown,
  }) {
    return MeasurementExportsCompanion(
      measurementId: measurementId ?? this.measurementId,
      mayExist: mayExist ?? this.mayExist,
      withdrawn: withdrawn ?? this.withdrawn,
      legacyUnknown: legacyUnknown ?? this.legacyUnknown,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (measurementId.present) {
      map['measurement_id'] = Variable<int>(measurementId.value);
    }
    if (mayExist.present) {
      map['may_exist'] = Variable<bool>(mayExist.value);
    }
    if (withdrawn.present) {
      map['withdrawn'] = Variable<bool>(withdrawn.value);
    }
    if (legacyUnknown.present) {
      map['legacy_unknown'] = Variable<bool>(legacyUnknown.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementExportsCompanion(')
          ..write('measurementId: $measurementId, ')
          ..write('mayExist: $mayExist, ')
          ..write('withdrawn: $withdrawn, ')
          ..write('legacyUnknown: $legacyUnknown')
          ..write(')'))
        .toString();
  }
}

class $AppSettingsTable extends AppSettings
    with TableInfo<$AppSettingsTable, AppSetting> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AppSettingsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _keyMeta = const VerificationMeta('key');
  @override
  late final GeneratedColumn<String> key = GeneratedColumn<String>(
    'key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _valueMeta = const VerificationMeta('value');
  @override
  late final GeneratedColumn<String> value = GeneratedColumn<String>(
    'value',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [key, value];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'app_settings';
  @override
  VerificationContext validateIntegrity(
    Insertable<AppSetting> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('key')) {
      context.handle(
        _keyMeta,
        key.isAcceptableOrUnknown(data['key']!, _keyMeta),
      );
    } else if (isInserting) {
      context.missing(_keyMeta);
    }
    if (data.containsKey('value')) {
      context.handle(
        _valueMeta,
        value.isAcceptableOrUnknown(data['value']!, _valueMeta),
      );
    } else if (isInserting) {
      context.missing(_valueMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {key};
  @override
  AppSetting map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AppSetting(
      key: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}key'],
      )!,
      value: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}value'],
      )!,
    );
  }

  @override
  $AppSettingsTable createAlias(String alias) {
    return $AppSettingsTable(attachedDatabase, alias);
  }
}

class AppSetting extends DataClass implements Insertable<AppSetting> {
  final String key;
  final String value;
  const AppSetting({required this.key, required this.value});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['key'] = Variable<String>(key);
    map['value'] = Variable<String>(value);
    return map;
  }

  AppSettingsCompanion toCompanion(bool nullToAbsent) {
    return AppSettingsCompanion(key: Value(key), value: Value(value));
  }

  factory AppSetting.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AppSetting(
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

  AppSetting copyWith({String? key, String? value}) =>
      AppSetting(key: key ?? this.key, value: value ?? this.value);
  AppSetting copyWithCompanion(AppSettingsCompanion data) {
    return AppSetting(
      key: data.key.present ? data.key.value : this.key,
      value: data.value.present ? data.value.value : this.value,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AppSetting(')
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
      (other is AppSetting &&
          other.key == this.key &&
          other.value == this.value);
}

class AppSettingsCompanion extends UpdateCompanion<AppSetting> {
  final Value<String> key;
  final Value<String> value;
  final Value<int> rowid;
  const AppSettingsCompanion({
    this.key = const Value.absent(),
    this.value = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AppSettingsCompanion.insert({
    required String key,
    required String value,
    this.rowid = const Value.absent(),
  }) : key = Value(key),
       value = Value(value);
  static Insertable<AppSetting> custom({
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

  AppSettingsCompanion copyWith({
    Value<String>? key,
    Value<String>? value,
    Value<int>? rowid,
  }) {
    return AppSettingsCompanion(
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
    return (StringBuffer('AppSettingsCompanion(')
          ..write('key: $key, ')
          ..write('value: $value, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OccasionDecisionsTable extends OccasionDecisions
    with TableInfo<$OccasionDecisionsTable, OccasionDecision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OccasionDecisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decisionMeta = const VerificationMeta(
    'decision',
  );
  @override
  late final GeneratedColumn<String> decision = GeneratedColumn<String>(
    'decision',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userSlot,
    deviceSequence,
    decision,
    decidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'occasion_decisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<OccasionDecision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('decision')) {
      context.handle(
        _decisionMeta,
        decision.isAcceptableOrUnknown(data['decision']!, _decisionMeta),
      );
    } else if (isInserting) {
      context.missing(_decisionMeta);
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
  @override
  OccasionDecision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OccasionDecision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      decision: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}decision'],
      )!,
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      )!,
    );
  }

  @override
  $OccasionDecisionsTable createAlias(String alias) {
    return $OccasionDecisionsTable(attachedDatabase, alias);
  }
}

class OccasionDecision extends DataClass
    implements Insertable<OccasionDecision> {
  final int id;

  /// 1 oder 2, wie am Geraet beschriftet. Der Zaehler laeuft je Platz.
  final int userSlot;

  /// Die Messung, ueber deren Anschluss an ihren Vorgaenger entschieden wurde.
  final int deviceSequence;

  /// 'join' oder 'split' — angeschlossen oder getrennt.
  final String decision;
  final DateTime decidedAt;
  const OccasionDecision({
    required this.id,
    required this.userSlot,
    required this.deviceSequence,
    required this.decision,
    required this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['decision'] = Variable<String>(decision);
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  OccasionDecisionsCompanion toCompanion(bool nullToAbsent) {
    return OccasionDecisionsCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      decision: Value(decision),
      decidedAt: Value(decidedAt),
    );
  }

  factory OccasionDecision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OccasionDecision(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      decision: serializer.fromJson<String>(json['decision']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'decision': serializer.toJson<String>(decision),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  OccasionDecision copyWith({
    int? id,
    int? userSlot,
    int? deviceSequence,
    String? decision,
    DateTime? decidedAt,
  }) => OccasionDecision(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    decision: decision ?? this.decision,
    decidedAt: decidedAt ?? this.decidedAt,
  );
  OccasionDecision copyWithCompanion(OccasionDecisionsCompanion data) {
    return OccasionDecision(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      decision: data.decision.present ? data.decision.value : this.decision,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OccasionDecision(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userSlot, deviceSequence, decision, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OccasionDecision &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.decision == this.decision &&
          other.decidedAt == this.decidedAt);
}

class OccasionDecisionsCompanion extends UpdateCompanion<OccasionDecision> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<String> decision;
  final Value<DateTime> decidedAt;
  const OccasionDecisionsCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.decision = const Value.absent(),
    this.decidedAt = const Value.absent(),
  });
  OccasionDecisionsCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    required int deviceSequence,
    required String decision,
    required DateTime decidedAt,
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       decision = Value(decision),
       decidedAt = Value(decidedAt);
  static Insertable<OccasionDecision> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<String>? decision,
    Expression<DateTime>? decidedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (decision != null) 'decision': decision,
      if (decidedAt != null) 'decided_at': decidedAt,
    });
  }

  OccasionDecisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<String>? decision,
    Value<DateTime>? decidedAt,
  }) {
    return OccasionDecisionsCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      decision: decision ?? this.decision,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (decision.present) {
      map['decision'] = Variable<String>(decision.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OccasionDecisionsCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('decision: $decision, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }
}

class $PhasesTable extends Phases with TableInfo<$PhasesTable, Phase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beginsAtMeta = const VerificationMeta(
    'beginsAt',
  );
  @override
  late final GeneratedColumn<DateTime> beginsAt = GeneratedColumn<DateTime>(
    'begins_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<String> anchor = GeneratedColumn<String>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    name,
    beginsAt,
    endsAt,
    anchor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phases';
  @override
  VerificationContext validateIntegrity(
    Insertable<Phase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('begins_at')) {
      context.handle(
        _beginsAtMeta,
        beginsAt.isAcceptableOrUnknown(data['begins_at']!, _beginsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_beginsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Phase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Phase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      beginsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}begins_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $PhasesTable createAlias(String alias) {
    return $PhasesTable(attachedDatabase, alias);
  }
}

class Phase extends DataClass implements Insertable<Phase> {
  final int id;

  /// Frei vergeben: „Ramipril 5 mg", „Urlaub", „nach der Umstellung".
  final String name;
  final DateTime beginsAt;

  /// Null, solange die Phase laeuft.
  final DateTime? endsAt;

  /// Woher der Beginn stammt: 'jetzt' (App-Zeit beim Anlegen) oder
  /// 'bestaetigt' (vom Nutzer gesetztes Datum). Die Quelle gehoert dazu,
  /// weil die Geraeteuhr als Anker ausscheidet.
  final String anchor;
  final DateTime createdAt;
  const Phase({
    required this.id,
    required this.name,
    required this.beginsAt,
    this.endsAt,
    required this.anchor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['begins_at'] = Variable<DateTime>(beginsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    map['anchor'] = Variable<String>(anchor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  PhasesCompanion toCompanion(bool nullToAbsent) {
    return PhasesCompanion(
      id: Value(id),
      name: Value(name),
      beginsAt: Value(beginsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      anchor: Value(anchor),
      createdAt: Value(createdAt),
    );
  }

  factory Phase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Phase(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      beginsAt: serializer.fromJson<DateTime>(json['beginsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      anchor: serializer.fromJson<String>(json['anchor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'beginsAt': serializer.toJson<DateTime>(beginsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'anchor': serializer.toJson<String>(anchor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  Phase copyWith({
    int? id,
    String? name,
    DateTime? beginsAt,
    Value<DateTime?> endsAt = const Value.absent(),
    String? anchor,
    DateTime? createdAt,
  }) => Phase(
    id: id ?? this.id,
    name: name ?? this.name,
    beginsAt: beginsAt ?? this.beginsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    anchor: anchor ?? this.anchor,
    createdAt: createdAt ?? this.createdAt,
  );
  Phase copyWithCompanion(PhasesCompanion data) {
    return Phase(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      beginsAt: data.beginsAt.present ? data.beginsAt.value : this.beginsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Phase(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('beginsAt: $beginsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('anchor: $anchor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, beginsAt, endsAt, anchor, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Phase &&
          other.id == this.id &&
          other.name == this.name &&
          other.beginsAt == this.beginsAt &&
          other.endsAt == this.endsAt &&
          other.anchor == this.anchor &&
          other.createdAt == this.createdAt);
}

class PhasesCompanion extends UpdateCompanion<Phase> {
  final Value<int> id;
  final Value<String> name;
  final Value<DateTime> beginsAt;
  final Value<DateTime?> endsAt;
  final Value<String> anchor;
  final Value<DateTime> createdAt;
  const PhasesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.beginsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.anchor = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  PhasesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    required DateTime beginsAt,
    this.endsAt = const Value.absent(),
    required String anchor,
    required DateTime createdAt,
  }) : name = Value(name),
       beginsAt = Value(beginsAt),
       anchor = Value(anchor),
       createdAt = Value(createdAt);
  static Insertable<Phase> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<DateTime>? beginsAt,
    Expression<DateTime>? endsAt,
    Expression<String>? anchor,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (beginsAt != null) 'begins_at': beginsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (anchor != null) 'anchor': anchor,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  PhasesCompanion copyWith({
    Value<int>? id,
    Value<String>? name,
    Value<DateTime>? beginsAt,
    Value<DateTime?>? endsAt,
    Value<String>? anchor,
    Value<DateTime>? createdAt,
  }) {
    return PhasesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      beginsAt: beginsAt ?? this.beginsAt,
      endsAt: endsAt ?? this.endsAt,
      anchor: anchor ?? this.anchor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (beginsAt.present) {
      map['begins_at'] = Variable<DateTime>(beginsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(anchor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhasesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('beginsAt: $beginsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('anchor: $anchor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PhaseAssignmentsTable extends PhaseAssignments
    with TableInfo<$PhaseAssignmentsTable, PhaseAssignment> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhaseAssignmentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseIdMeta = const VerificationMeta(
    'phaseId',
  );
  @override
  late final GeneratedColumn<int> phaseId = GeneratedColumn<int>(
    'phase_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES phases (id)',
    ),
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userSlot,
    deviceSequence,
    phaseId,
    decidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phase_assignments';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhaseAssignment> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('phase_id')) {
      context.handle(
        _phaseIdMeta,
        phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userSlot, deviceSequence},
  ];
  @override
  PhaseAssignment map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseAssignment(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      phaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase_id'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      )!,
    );
  }

  @override
  $PhaseAssignmentsTable createAlias(String alias) {
    return $PhaseAssignmentsTable(attachedDatabase, alias);
  }
}

class PhaseAssignment extends DataClass implements Insertable<PhaseAssignment> {
  final int id;
  final int userSlot;
  final int deviceSequence;
  final int? phaseId;
  final DateTime decidedAt;
  const PhaseAssignment({
    required this.id,
    required this.userSlot,
    required this.deviceSequence,
    this.phaseId,
    required this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    if (!nullToAbsent || phaseId != null) {
      map['phase_id'] = Variable<int>(phaseId);
    }
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  PhaseAssignmentsCompanion toCompanion(bool nullToAbsent) {
    return PhaseAssignmentsCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      phaseId: phaseId == null && nullToAbsent
          ? const Value.absent()
          : Value(phaseId),
      decidedAt: Value(decidedAt),
    );
  }

  factory PhaseAssignment.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhaseAssignment(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      phaseId: serializer.fromJson<int?>(json['phaseId']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'phaseId': serializer.toJson<int?>(phaseId),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  PhaseAssignment copyWith({
    int? id,
    int? userSlot,
    int? deviceSequence,
    Value<int?> phaseId = const Value.absent(),
    DateTime? decidedAt,
  }) => PhaseAssignment(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    phaseId: phaseId.present ? phaseId.value : this.phaseId,
    decidedAt: decidedAt ?? this.decidedAt,
  );
  PhaseAssignment copyWithCompanion(PhaseAssignmentsCompanion data) {
    return PhaseAssignment(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhaseAssignment(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('phaseId: $phaseId, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, userSlot, deviceSequence, phaseId, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhaseAssignment &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.phaseId == this.phaseId &&
          other.decidedAt == this.decidedAt);
}

class PhaseAssignmentsCompanion extends UpdateCompanion<PhaseAssignment> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<int?> phaseId;
  final Value<DateTime> decidedAt;
  const PhaseAssignmentsCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.decidedAt = const Value.absent(),
  });
  PhaseAssignmentsCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    required int deviceSequence,
    this.phaseId = const Value.absent(),
    required DateTime decidedAt,
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       decidedAt = Value(decidedAt);
  static Insertable<PhaseAssignment> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<int>? phaseId,
    Expression<DateTime>? decidedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (phaseId != null) 'phase_id': phaseId,
      if (decidedAt != null) 'decided_at': decidedAt,
    });
  }

  PhaseAssignmentsCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<int?>? phaseId,
    Value<DateTime>? decidedAt,
  }) {
    return PhaseAssignmentsCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      phaseId: phaseId ?? this.phaseId,
      decidedAt: decidedAt ?? this.decidedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<int>(phaseId.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhaseAssignmentsCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('phaseId: $phaseId, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }
}

class $MeasurementNotesTable extends MeasurementNotes
    with TableInfo<$MeasurementNotesTable, MeasurementNote> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementNotesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _bodyMeta = const VerificationMeta('body');
  @override
  late final GeneratedColumn<String> body = GeneratedColumn<String>(
    'body',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _updatedAtMeta = const VerificationMeta(
    'updatedAt',
  );
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
    'updated_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userSlot,
    deviceSequence,
    body,
    updatedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_notes';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementNote> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userSlot, deviceSequence};
  @override
  MeasurementNote map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementNote(
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
    );
  }

  @override
  $MeasurementNotesTable createAlias(String alias) {
    return $MeasurementNotesTable(attachedDatabase, alias);
  }
}

class MeasurementNote extends DataClass implements Insertable<MeasurementNote> {
  final int userSlot;
  final int deviceSequence;
  final String body;
  final DateTime updatedAt;
  const MeasurementNote({
    required this.userSlot,
    required this.deviceSequence,
    required this.body,
    required this.updatedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['body'] = Variable<String>(body);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    return map;
  }

  MeasurementNotesCompanion toCompanion(bool nullToAbsent) {
    return MeasurementNotesCompanion(
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      body: Value(body),
      updatedAt: Value(updatedAt),
    );
  }

  factory MeasurementNote.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementNote(
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      body: serializer.fromJson<String>(json['body']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'body': serializer.toJson<String>(body),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
    };
  }

  MeasurementNote copyWith({
    int? userSlot,
    int? deviceSequence,
    String? body,
    DateTime? updatedAt,
  }) => MeasurementNote(
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    body: body ?? this.body,
    updatedAt: updatedAt ?? this.updatedAt,
  );
  MeasurementNote copyWithCompanion(MeasurementNotesCompanion data) {
    return MeasurementNote(
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      body: data.body.present ? data.body.value : this.body,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementNote(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userSlot, deviceSequence, body, updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementNote &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.body == this.body &&
          other.updatedAt == this.updatedAt);
}

class MeasurementNotesCompanion extends UpdateCompanion<MeasurementNote> {
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<String> body;
  final Value<DateTime> updatedAt;
  final Value<int> rowid;
  const MeasurementNotesCompanion({
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.body = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementNotesCompanion.insert({
    required int userSlot,
    required int deviceSequence,
    required String body,
    required DateTime updatedAt,
    this.rowid = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       body = Value(body),
       updatedAt = Value(updatedAt);
  static Insertable<MeasurementNote> custom({
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<String>? body,
    Expression<DateTime>? updatedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (body != null) 'body': body,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementNotesCompanion copyWith({
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<String>? body,
    Value<DateTime>? updatedAt,
    Value<int>? rowid,
  }) {
    return MeasurementNotesCompanion(
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      body: body ?? this.body,
      updatedAt: updatedAt ?? this.updatedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementNotesCompanion(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('body: $body, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementTagsTable extends MeasurementTags
    with TableInfo<$MeasurementTagsTable, MeasurementTag> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementTagsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _normalizedNameMeta = const VerificationMeta(
    'normalizedName',
  );
  @override
  late final GeneratedColumn<String> normalizedName = GeneratedColumn<String>(
    'normalized_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userSlot, name, normalizedName];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_tags';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementTag> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('normalized_name')) {
      context.handle(
        _normalizedNameMeta,
        normalizedName.isAcceptableOrUnknown(
          data['normalized_name']!,
          _normalizedNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_normalizedNameMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userSlot, normalizedName},
  ];
  @override
  MeasurementTag map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementTag(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      normalizedName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}normalized_name'],
      )!,
    );
  }

  @override
  $MeasurementTagsTable createAlias(String alias) {
    return $MeasurementTagsTable(attachedDatabase, alias);
  }
}

class MeasurementTag extends DataClass implements Insertable<MeasurementTag> {
  final int id;
  final int userSlot;
  final String name;
  final String normalizedName;
  const MeasurementTag({
    required this.id,
    required this.userSlot,
    required this.name,
    required this.normalizedName,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    map['name'] = Variable<String>(name);
    map['normalized_name'] = Variable<String>(normalizedName);
    return map;
  }

  MeasurementTagsCompanion toCompanion(bool nullToAbsent) {
    return MeasurementTagsCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      name: Value(name),
      normalizedName: Value(normalizedName),
    );
  }

  factory MeasurementTag.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementTag(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      name: serializer.fromJson<String>(json['name']),
      normalizedName: serializer.fromJson<String>(json['normalizedName']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'name': serializer.toJson<String>(name),
      'normalizedName': serializer.toJson<String>(normalizedName),
    };
  }

  MeasurementTag copyWith({
    int? id,
    int? userSlot,
    String? name,
    String? normalizedName,
  }) => MeasurementTag(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    name: name ?? this.name,
    normalizedName: normalizedName ?? this.normalizedName,
  );
  MeasurementTag copyWithCompanion(MeasurementTagsCompanion data) {
    return MeasurementTag(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      name: data.name.present ? data.name.value : this.name,
      normalizedName: data.normalizedName.present
          ? data.normalizedName.value
          : this.normalizedName,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTag(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userSlot, name, normalizedName);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementTag &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.name == this.name &&
          other.normalizedName == this.normalizedName);
}

class MeasurementTagsCompanion extends UpdateCompanion<MeasurementTag> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<String> name;
  final Value<String> normalizedName;
  const MeasurementTagsCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.name = const Value.absent(),
    this.normalizedName = const Value.absent(),
  });
  MeasurementTagsCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    required String name,
    required String normalizedName,
  }) : userSlot = Value(userSlot),
       name = Value(name),
       normalizedName = Value(normalizedName);
  static Insertable<MeasurementTag> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<String>? name,
    Expression<String>? normalizedName,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (name != null) 'name': name,
      if (normalizedName != null) 'normalized_name': normalizedName,
    });
  }

  MeasurementTagsCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<String>? name,
    Value<String>? normalizedName,
  }) {
    return MeasurementTagsCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      name: name ?? this.name,
      normalizedName: normalizedName ?? this.normalizedName,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (normalizedName.present) {
      map['normalized_name'] = Variable<String>(normalizedName.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTagsCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('name: $name, ')
          ..write('normalizedName: $normalizedName')
          ..write(')'))
        .toString();
  }
}

class $MeasurementTagLinksTable extends MeasurementTagLinks
    with TableInfo<$MeasurementTagLinksTable, MeasurementTagLink> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementTagLinksTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tagIdMeta = const VerificationMeta('tagId');
  @override
  late final GeneratedColumn<int> tagId = GeneratedColumn<int>(
    'tag_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_tags (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [userSlot, deviceSequence, tagId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_tag_links';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementTagLink> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('tag_id')) {
      context.handle(
        _tagIdMeta,
        tagId.isAcceptableOrUnknown(data['tag_id']!, _tagIdMeta),
      );
    } else if (isInserting) {
      context.missing(_tagIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userSlot, deviceSequence, tagId};
  @override
  MeasurementTagLink map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementTagLink(
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      tagId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}tag_id'],
      )!,
    );
  }

  @override
  $MeasurementTagLinksTable createAlias(String alias) {
    return $MeasurementTagLinksTable(attachedDatabase, alias);
  }
}

class MeasurementTagLink extends DataClass
    implements Insertable<MeasurementTagLink> {
  final int userSlot;
  final int deviceSequence;
  final int tagId;
  const MeasurementTagLink({
    required this.userSlot,
    required this.deviceSequence,
    required this.tagId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['tag_id'] = Variable<int>(tagId);
    return map;
  }

  MeasurementTagLinksCompanion toCompanion(bool nullToAbsent) {
    return MeasurementTagLinksCompanion(
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      tagId: Value(tagId),
    );
  }

  factory MeasurementTagLink.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementTagLink(
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      tagId: serializer.fromJson<int>(json['tagId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'tagId': serializer.toJson<int>(tagId),
    };
  }

  MeasurementTagLink copyWith({
    int? userSlot,
    int? deviceSequence,
    int? tagId,
  }) => MeasurementTagLink(
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    tagId: tagId ?? this.tagId,
  );
  MeasurementTagLink copyWithCompanion(MeasurementTagLinksCompanion data) {
    return MeasurementTagLink(
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      tagId: data.tagId.present ? data.tagId.value : this.tagId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTagLink(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('tagId: $tagId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userSlot, deviceSequence, tagId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementTagLink &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.tagId == this.tagId);
}

class MeasurementTagLinksCompanion extends UpdateCompanion<MeasurementTagLink> {
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<int> tagId;
  final Value<int> rowid;
  const MeasurementTagLinksCompanion({
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.tagId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MeasurementTagLinksCompanion.insert({
    required int userSlot,
    required int deviceSequence,
    required int tagId,
    this.rowid = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       tagId = Value(tagId);
  static Insertable<MeasurementTagLink> custom({
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<int>? tagId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (tagId != null) 'tag_id': tagId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MeasurementTagLinksCompanion copyWith({
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<int>? tagId,
    Value<int>? rowid,
  }) {
    return MeasurementTagLinksCompanion(
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      tagId: tagId ?? this.tagId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (tagId.present) {
      map['tag_id'] = Variable<int>(tagId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementTagLinksCompanion(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('tagId: $tagId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ScopedPhasesTable extends ScopedPhases
    with TableInfo<$ScopedPhasesTable, ScopedPhase> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ScopedPhasesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _legacyIdMeta = const VerificationMeta(
    'legacyId',
  );
  @override
  late final GeneratedColumn<int> legacyId = GeneratedColumn<int>(
    'legacy_id',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
    'name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _beginsAtMeta = const VerificationMeta(
    'beginsAt',
  );
  @override
  late final GeneratedColumn<DateTime> beginsAt = GeneratedColumn<DateTime>(
    'begins_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endsAtMeta = const VerificationMeta('endsAt');
  @override
  late final GeneratedColumn<DateTime> endsAt = GeneratedColumn<DateTime>(
    'ends_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _anchorMeta = const VerificationMeta('anchor');
  @override
  late final GeneratedColumn<String> anchor = GeneratedColumn<String>(
    'anchor',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _createdAtMeta = const VerificationMeta(
    'createdAt',
  );
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
    'created_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    userSlot,
    legacyId,
    name,
    beginsAt,
    endsAt,
    anchor,
    createdAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'scoped_phases';
  @override
  VerificationContext validateIntegrity(
    Insertable<ScopedPhase> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('legacy_id')) {
      context.handle(
        _legacyIdMeta,
        legacyId.isAcceptableOrUnknown(data['legacy_id']!, _legacyIdMeta),
      );
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('begins_at')) {
      context.handle(
        _beginsAtMeta,
        beginsAt.isAcceptableOrUnknown(data['begins_at']!, _beginsAtMeta),
      );
    } else if (isInserting) {
      context.missing(_beginsAtMeta);
    }
    if (data.containsKey('ends_at')) {
      context.handle(
        _endsAtMeta,
        endsAt.isAcceptableOrUnknown(data['ends_at']!, _endsAtMeta),
      );
    }
    if (data.containsKey('anchor')) {
      context.handle(
        _anchorMeta,
        anchor.isAcceptableOrUnknown(data['anchor']!, _anchorMeta),
      );
    } else if (isInserting) {
      context.missing(_anchorMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {userSlot, legacyId},
  ];
  @override
  ScopedPhase map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ScopedPhase(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      legacyId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}legacy_id'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      beginsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}begins_at'],
      )!,
      endsAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ends_at'],
      ),
      anchor: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}anchor'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
    );
  }

  @override
  $ScopedPhasesTable createAlias(String alias) {
    return $ScopedPhasesTable(attachedDatabase, alias);
  }
}

class ScopedPhase extends DataClass implements Insertable<ScopedPhase> {
  final int id;
  final int userSlot;
  final int? legacyId;
  final String name;
  final DateTime beginsAt;
  final DateTime? endsAt;
  final String anchor;
  final DateTime createdAt;
  const ScopedPhase({
    required this.id,
    required this.userSlot,
    this.legacyId,
    required this.name,
    required this.beginsAt,
    this.endsAt,
    required this.anchor,
    required this.createdAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    if (!nullToAbsent || legacyId != null) {
      map['legacy_id'] = Variable<int>(legacyId);
    }
    map['name'] = Variable<String>(name);
    map['begins_at'] = Variable<DateTime>(beginsAt);
    if (!nullToAbsent || endsAt != null) {
      map['ends_at'] = Variable<DateTime>(endsAt);
    }
    map['anchor'] = Variable<String>(anchor);
    map['created_at'] = Variable<DateTime>(createdAt);
    return map;
  }

  ScopedPhasesCompanion toCompanion(bool nullToAbsent) {
    return ScopedPhasesCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      legacyId: legacyId == null && nullToAbsent
          ? const Value.absent()
          : Value(legacyId),
      name: Value(name),
      beginsAt: Value(beginsAt),
      endsAt: endsAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endsAt),
      anchor: Value(anchor),
      createdAt: Value(createdAt),
    );
  }

  factory ScopedPhase.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ScopedPhase(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      legacyId: serializer.fromJson<int?>(json['legacyId']),
      name: serializer.fromJson<String>(json['name']),
      beginsAt: serializer.fromJson<DateTime>(json['beginsAt']),
      endsAt: serializer.fromJson<DateTime?>(json['endsAt']),
      anchor: serializer.fromJson<String>(json['anchor']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'legacyId': serializer.toJson<int?>(legacyId),
      'name': serializer.toJson<String>(name),
      'beginsAt': serializer.toJson<DateTime>(beginsAt),
      'endsAt': serializer.toJson<DateTime?>(endsAt),
      'anchor': serializer.toJson<String>(anchor),
      'createdAt': serializer.toJson<DateTime>(createdAt),
    };
  }

  ScopedPhase copyWith({
    int? id,
    int? userSlot,
    Value<int?> legacyId = const Value.absent(),
    String? name,
    DateTime? beginsAt,
    Value<DateTime?> endsAt = const Value.absent(),
    String? anchor,
    DateTime? createdAt,
  }) => ScopedPhase(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    legacyId: legacyId.present ? legacyId.value : this.legacyId,
    name: name ?? this.name,
    beginsAt: beginsAt ?? this.beginsAt,
    endsAt: endsAt.present ? endsAt.value : this.endsAt,
    anchor: anchor ?? this.anchor,
    createdAt: createdAt ?? this.createdAt,
  );
  ScopedPhase copyWithCompanion(ScopedPhasesCompanion data) {
    return ScopedPhase(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      legacyId: data.legacyId.present ? data.legacyId.value : this.legacyId,
      name: data.name.present ? data.name.value : this.name,
      beginsAt: data.beginsAt.present ? data.beginsAt.value : this.beginsAt,
      endsAt: data.endsAt.present ? data.endsAt.value : this.endsAt,
      anchor: data.anchor.present ? data.anchor.value : this.anchor,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ScopedPhase(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('legacyId: $legacyId, ')
          ..write('name: $name, ')
          ..write('beginsAt: $beginsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('anchor: $anchor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    userSlot,
    legacyId,
    name,
    beginsAt,
    endsAt,
    anchor,
    createdAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ScopedPhase &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.legacyId == this.legacyId &&
          other.name == this.name &&
          other.beginsAt == this.beginsAt &&
          other.endsAt == this.endsAt &&
          other.anchor == this.anchor &&
          other.createdAt == this.createdAt);
}

class ScopedPhasesCompanion extends UpdateCompanion<ScopedPhase> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<int?> legacyId;
  final Value<String> name;
  final Value<DateTime> beginsAt;
  final Value<DateTime?> endsAt;
  final Value<String> anchor;
  final Value<DateTime> createdAt;
  const ScopedPhasesCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.legacyId = const Value.absent(),
    this.name = const Value.absent(),
    this.beginsAt = const Value.absent(),
    this.endsAt = const Value.absent(),
    this.anchor = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  ScopedPhasesCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    this.legacyId = const Value.absent(),
    required String name,
    required DateTime beginsAt,
    this.endsAt = const Value.absent(),
    required String anchor,
    required DateTime createdAt,
  }) : userSlot = Value(userSlot),
       name = Value(name),
       beginsAt = Value(beginsAt),
       anchor = Value(anchor),
       createdAt = Value(createdAt);
  static Insertable<ScopedPhase> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<int>? legacyId,
    Expression<String>? name,
    Expression<DateTime>? beginsAt,
    Expression<DateTime>? endsAt,
    Expression<String>? anchor,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (legacyId != null) 'legacy_id': legacyId,
      if (name != null) 'name': name,
      if (beginsAt != null) 'begins_at': beginsAt,
      if (endsAt != null) 'ends_at': endsAt,
      if (anchor != null) 'anchor': anchor,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  ScopedPhasesCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<int?>? legacyId,
    Value<String>? name,
    Value<DateTime>? beginsAt,
    Value<DateTime?>? endsAt,
    Value<String>? anchor,
    Value<DateTime>? createdAt,
  }) {
    return ScopedPhasesCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      legacyId: legacyId ?? this.legacyId,
      name: name ?? this.name,
      beginsAt: beginsAt ?? this.beginsAt,
      endsAt: endsAt ?? this.endsAt,
      anchor: anchor ?? this.anchor,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (legacyId.present) {
      map['legacy_id'] = Variable<int>(legacyId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (beginsAt.present) {
      map['begins_at'] = Variable<DateTime>(beginsAt.value);
    }
    if (endsAt.present) {
      map['ends_at'] = Variable<DateTime>(endsAt.value);
    }
    if (anchor.present) {
      map['anchor'] = Variable<String>(anchor.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ScopedPhasesCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('legacyId: $legacyId, ')
          ..write('name: $name, ')
          ..write('beginsAt: $beginsAt, ')
          ..write('endsAt: $endsAt, ')
          ..write('anchor: $anchor, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $PhaseSelectionsTable extends PhaseSelections
    with TableInfo<$PhaseSelectionsTable, PhaseSelection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhaseSelectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [userSlot, deviceSequence, decidedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phase_selections';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhaseSelection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userSlot, deviceSequence};
  @override
  PhaseSelection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseSelection(
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      )!,
    );
  }

  @override
  $PhaseSelectionsTable createAlias(String alias) {
    return $PhaseSelectionsTable(attachedDatabase, alias);
  }
}

class PhaseSelection extends DataClass implements Insertable<PhaseSelection> {
  final int userSlot;
  final int deviceSequence;
  final DateTime decidedAt;
  const PhaseSelection({
    required this.userSlot,
    required this.deviceSequence,
    required this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  PhaseSelectionsCompanion toCompanion(bool nullToAbsent) {
    return PhaseSelectionsCompanion(
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      decidedAt: Value(decidedAt),
    );
  }

  factory PhaseSelection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhaseSelection(
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  PhaseSelection copyWith({
    int? userSlot,
    int? deviceSequence,
    DateTime? decidedAt,
  }) => PhaseSelection(
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    decidedAt: decidedAt ?? this.decidedAt,
  );
  PhaseSelection copyWithCompanion(PhaseSelectionsCompanion data) {
    return PhaseSelection(
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSelection(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userSlot, deviceSequence, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhaseSelection &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.decidedAt == this.decidedAt);
}

class PhaseSelectionsCompanion extends UpdateCompanion<PhaseSelection> {
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<DateTime> decidedAt;
  final Value<int> rowid;
  const PhaseSelectionsCompanion({
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhaseSelectionsCompanion.insert({
    required int userSlot,
    required int deviceSequence,
    required DateTime decidedAt,
    this.rowid = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       decidedAt = Value(decidedAt);
  static Insertable<PhaseSelection> custom({
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<DateTime>? decidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhaseSelectionsCompanion copyWith({
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<DateTime>? decidedAt,
    Value<int>? rowid,
  }) {
    return PhaseSelectionsCompanion(
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      decidedAt: decidedAt ?? this.decidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSelectionsCompanion(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PhaseSelectionMembersTable extends PhaseSelectionMembers
    with TableInfo<$PhaseSelectionMembersTable, PhaseSelectionMember> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PhaseSelectionMembersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _phaseIdMeta = const VerificationMeta(
    'phaseId',
  );
  @override
  late final GeneratedColumn<int> phaseId = GeneratedColumn<int>(
    'phase_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES scoped_phases (id)',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [userSlot, deviceSequence, phaseId];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'phase_selection_members';
  @override
  VerificationContext validateIntegrity(
    Insertable<PhaseSelectionMember> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('phase_id')) {
      context.handle(
        _phaseIdMeta,
        phaseId.isAcceptableOrUnknown(data['phase_id']!, _phaseIdMeta),
      );
    } else if (isInserting) {
      context.missing(_phaseIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userSlot, deviceSequence, phaseId};
  @override
  PhaseSelectionMember map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PhaseSelectionMember(
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      phaseId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}phase_id'],
      )!,
    );
  }

  @override
  $PhaseSelectionMembersTable createAlias(String alias) {
    return $PhaseSelectionMembersTable(attachedDatabase, alias);
  }
}

class PhaseSelectionMember extends DataClass
    implements Insertable<PhaseSelectionMember> {
  final int userSlot;
  final int deviceSequence;
  final int phaseId;
  const PhaseSelectionMember({
    required this.userSlot,
    required this.deviceSequence,
    required this.phaseId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    map['phase_id'] = Variable<int>(phaseId);
    return map;
  }

  PhaseSelectionMembersCompanion toCompanion(bool nullToAbsent) {
    return PhaseSelectionMembersCompanion(
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      phaseId: Value(phaseId),
    );
  }

  factory PhaseSelectionMember.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PhaseSelectionMember(
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      phaseId: serializer.fromJson<int>(json['phaseId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'phaseId': serializer.toJson<int>(phaseId),
    };
  }

  PhaseSelectionMember copyWith({
    int? userSlot,
    int? deviceSequence,
    int? phaseId,
  }) => PhaseSelectionMember(
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    phaseId: phaseId ?? this.phaseId,
  );
  PhaseSelectionMember copyWithCompanion(PhaseSelectionMembersCompanion data) {
    return PhaseSelectionMember(
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      phaseId: data.phaseId.present ? data.phaseId.value : this.phaseId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSelectionMember(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('phaseId: $phaseId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(userSlot, deviceSequence, phaseId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PhaseSelectionMember &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.phaseId == this.phaseId);
}

class PhaseSelectionMembersCompanion
    extends UpdateCompanion<PhaseSelectionMember> {
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<int> phaseId;
  final Value<int> rowid;
  const PhaseSelectionMembersCompanion({
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.phaseId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PhaseSelectionMembersCompanion.insert({
    required int userSlot,
    required int deviceSequence,
    required int phaseId,
    this.rowid = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       phaseId = Value(phaseId);
  static Insertable<PhaseSelectionMember> custom({
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<int>? phaseId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (phaseId != null) 'phase_id': phaseId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PhaseSelectionMembersCompanion copyWith({
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<int>? phaseId,
    Value<int>? rowid,
  }) {
    return PhaseSelectionMembersCompanion(
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      phaseId: phaseId ?? this.phaseId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (phaseId.present) {
      map['phase_id'] = Variable<int>(phaseId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PhaseSelectionMembersCompanion(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('phaseId: $phaseId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MeasurementPlansTable extends MeasurementPlans
    with TableInfo<$MeasurementPlansTable, MeasurementPlan> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MeasurementPlansTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _endedAtMeta = const VerificationMeta(
    'endedAt',
  );
  @override
  late final GeneratedColumn<DateTime> endedAt = GeneratedColumn<DateTime>(
    'ended_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [id, userSlot, startedAt, endedAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'measurement_plans';
  @override
  VerificationContext validateIntegrity(
    Insertable<MeasurementPlan> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_startedAtMeta);
    }
    if (data.containsKey('ended_at')) {
      context.handle(
        _endedAtMeta,
        endedAt.isAcceptableOrUnknown(data['ended_at']!, _endedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MeasurementPlan map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MeasurementPlan(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      )!,
      endedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}ended_at'],
      ),
    );
  }

  @override
  $MeasurementPlansTable createAlias(String alias) {
    return $MeasurementPlansTable(attachedDatabase, alias);
  }
}

class MeasurementPlan extends DataClass implements Insertable<MeasurementPlan> {
  final int id;
  final int userSlot;
  final DateTime startedAt;
  final DateTime? endedAt;
  const MeasurementPlan({
    required this.id,
    required this.userSlot,
    required this.startedAt,
    this.endedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['user_slot'] = Variable<int>(userSlot);
    map['started_at'] = Variable<DateTime>(startedAt);
    if (!nullToAbsent || endedAt != null) {
      map['ended_at'] = Variable<DateTime>(endedAt);
    }
    return map;
  }

  MeasurementPlansCompanion toCompanion(bool nullToAbsent) {
    return MeasurementPlansCompanion(
      id: Value(id),
      userSlot: Value(userSlot),
      startedAt: Value(startedAt),
      endedAt: endedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(endedAt),
    );
  }

  factory MeasurementPlan.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MeasurementPlan(
      id: serializer.fromJson<int>(json['id']),
      userSlot: serializer.fromJson<int>(json['userSlot']),
      startedAt: serializer.fromJson<DateTime>(json['startedAt']),
      endedAt: serializer.fromJson<DateTime?>(json['endedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'userSlot': serializer.toJson<int>(userSlot),
      'startedAt': serializer.toJson<DateTime>(startedAt),
      'endedAt': serializer.toJson<DateTime?>(endedAt),
    };
  }

  MeasurementPlan copyWith({
    int? id,
    int? userSlot,
    DateTime? startedAt,
    Value<DateTime?> endedAt = const Value.absent(),
  }) => MeasurementPlan(
    id: id ?? this.id,
    userSlot: userSlot ?? this.userSlot,
    startedAt: startedAt ?? this.startedAt,
    endedAt: endedAt.present ? endedAt.value : this.endedAt,
  );
  MeasurementPlan copyWithCompanion(MeasurementPlansCompanion data) {
    return MeasurementPlan(
      id: data.id.present ? data.id.value : this.id,
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      endedAt: data.endedAt.present ? data.endedAt.value : this.endedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementPlan(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, userSlot, startedAt, endedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MeasurementPlan &&
          other.id == this.id &&
          other.userSlot == this.userSlot &&
          other.startedAt == this.startedAt &&
          other.endedAt == this.endedAt);
}

class MeasurementPlansCompanion extends UpdateCompanion<MeasurementPlan> {
  final Value<int> id;
  final Value<int> userSlot;
  final Value<DateTime> startedAt;
  final Value<DateTime?> endedAt;
  const MeasurementPlansCompanion({
    this.id = const Value.absent(),
    this.userSlot = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.endedAt = const Value.absent(),
  });
  MeasurementPlansCompanion.insert({
    this.id = const Value.absent(),
    required int userSlot,
    required DateTime startedAt,
    this.endedAt = const Value.absent(),
  }) : userSlot = Value(userSlot),
       startedAt = Value(startedAt);
  static Insertable<MeasurementPlan> custom({
    Expression<int>? id,
    Expression<int>? userSlot,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? endedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (userSlot != null) 'user_slot': userSlot,
      if (startedAt != null) 'started_at': startedAt,
      if (endedAt != null) 'ended_at': endedAt,
    });
  }

  MeasurementPlansCompanion copyWith({
    Value<int>? id,
    Value<int>? userSlot,
    Value<DateTime>? startedAt,
    Value<DateTime?>? endedAt,
  }) {
    return MeasurementPlansCompanion(
      id: id ?? this.id,
      userSlot: userSlot ?? this.userSlot,
      startedAt: startedAt ?? this.startedAt,
      endedAt: endedAt ?? this.endedAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (endedAt.present) {
      map['ended_at'] = Variable<DateTime>(endedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MeasurementPlansCompanion(')
          ..write('id: $id, ')
          ..write('userSlot: $userSlot, ')
          ..write('startedAt: $startedAt, ')
          ..write('endedAt: $endedAt')
          ..write(')'))
        .toString();
  }
}

class $PlanRevisionsTable extends PlanRevisions
    with TableInfo<$PlanRevisionsTable, PlanRevision> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanRevisionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _planIdMeta = const VerificationMeta('planId');
  @override
  late final GeneratedColumn<int> planId = GeneratedColumn<int>(
    'plan_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES measurement_plans (id)',
    ),
  );
  static const VerificationMeta _effectiveAtMeta = const VerificationMeta(
    'effectiveAt',
  );
  @override
  late final GeneratedColumn<DateTime> effectiveAt = GeneratedColumn<DateTime>(
    'effective_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _enabledMeta = const VerificationMeta(
    'enabled',
  );
  @override
  late final GeneratedColumn<bool> enabled = GeneratedColumn<bool>(
    'enabled',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("enabled" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [id, planId, effectiveAt, enabled];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_revisions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanRevision> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('plan_id')) {
      context.handle(
        _planIdMeta,
        planId.isAcceptableOrUnknown(data['plan_id']!, _planIdMeta),
      );
    } else if (isInserting) {
      context.missing(_planIdMeta);
    }
    if (data.containsKey('effective_at')) {
      context.handle(
        _effectiveAtMeta,
        effectiveAt.isAcceptableOrUnknown(
          data['effective_at']!,
          _effectiveAtMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_effectiveAtMeta);
    }
    if (data.containsKey('enabled')) {
      context.handle(
        _enabledMeta,
        enabled.isAcceptableOrUnknown(data['enabled']!, _enabledMeta),
      );
    } else if (isInserting) {
      context.missing(_enabledMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlanRevision map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanRevision(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      planId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}plan_id'],
      )!,
      effectiveAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}effective_at'],
      )!,
      enabled: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}enabled'],
      )!,
    );
  }

  @override
  $PlanRevisionsTable createAlias(String alias) {
    return $PlanRevisionsTable(attachedDatabase, alias);
  }
}

class PlanRevision extends DataClass implements Insertable<PlanRevision> {
  final int id;
  final int planId;
  final DateTime effectiveAt;
  final bool enabled;
  const PlanRevision({
    required this.id,
    required this.planId,
    required this.effectiveAt,
    required this.enabled,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['plan_id'] = Variable<int>(planId);
    map['effective_at'] = Variable<DateTime>(effectiveAt);
    map['enabled'] = Variable<bool>(enabled);
    return map;
  }

  PlanRevisionsCompanion toCompanion(bool nullToAbsent) {
    return PlanRevisionsCompanion(
      id: Value(id),
      planId: Value(planId),
      effectiveAt: Value(effectiveAt),
      enabled: Value(enabled),
    );
  }

  factory PlanRevision.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanRevision(
      id: serializer.fromJson<int>(json['id']),
      planId: serializer.fromJson<int>(json['planId']),
      effectiveAt: serializer.fromJson<DateTime>(json['effectiveAt']),
      enabled: serializer.fromJson<bool>(json['enabled']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'planId': serializer.toJson<int>(planId),
      'effectiveAt': serializer.toJson<DateTime>(effectiveAt),
      'enabled': serializer.toJson<bool>(enabled),
    };
  }

  PlanRevision copyWith({
    int? id,
    int? planId,
    DateTime? effectiveAt,
    bool? enabled,
  }) => PlanRevision(
    id: id ?? this.id,
    planId: planId ?? this.planId,
    effectiveAt: effectiveAt ?? this.effectiveAt,
    enabled: enabled ?? this.enabled,
  );
  PlanRevision copyWithCompanion(PlanRevisionsCompanion data) {
    return PlanRevision(
      id: data.id.present ? data.id.value : this.id,
      planId: data.planId.present ? data.planId.value : this.planId,
      effectiveAt: data.effectiveAt.present
          ? data.effectiveAt.value
          : this.effectiveAt,
      enabled: data.enabled.present ? data.enabled.value : this.enabled,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanRevision(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, planId, effectiveAt, enabled);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanRevision &&
          other.id == this.id &&
          other.planId == this.planId &&
          other.effectiveAt == this.effectiveAt &&
          other.enabled == this.enabled);
}

class PlanRevisionsCompanion extends UpdateCompanion<PlanRevision> {
  final Value<int> id;
  final Value<int> planId;
  final Value<DateTime> effectiveAt;
  final Value<bool> enabled;
  const PlanRevisionsCompanion({
    this.id = const Value.absent(),
    this.planId = const Value.absent(),
    this.effectiveAt = const Value.absent(),
    this.enabled = const Value.absent(),
  });
  PlanRevisionsCompanion.insert({
    this.id = const Value.absent(),
    required int planId,
    required DateTime effectiveAt,
    required bool enabled,
  }) : planId = Value(planId),
       effectiveAt = Value(effectiveAt),
       enabled = Value(enabled);
  static Insertable<PlanRevision> custom({
    Expression<int>? id,
    Expression<int>? planId,
    Expression<DateTime>? effectiveAt,
    Expression<bool>? enabled,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (planId != null) 'plan_id': planId,
      if (effectiveAt != null) 'effective_at': effectiveAt,
      if (enabled != null) 'enabled': enabled,
    });
  }

  PlanRevisionsCompanion copyWith({
    Value<int>? id,
    Value<int>? planId,
    Value<DateTime>? effectiveAt,
    Value<bool>? enabled,
  }) {
    return PlanRevisionsCompanion(
      id: id ?? this.id,
      planId: planId ?? this.planId,
      effectiveAt: effectiveAt ?? this.effectiveAt,
      enabled: enabled ?? this.enabled,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (planId.present) {
      map['plan_id'] = Variable<int>(planId.value);
    }
    if (effectiveAt.present) {
      map['effective_at'] = Variable<DateTime>(effectiveAt.value);
    }
    if (enabled.present) {
      map['enabled'] = Variable<bool>(enabled.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanRevisionsCompanion(')
          ..write('id: $id, ')
          ..write('planId: $planId, ')
          ..write('effectiveAt: $effectiveAt, ')
          ..write('enabled: $enabled')
          ..write(')'))
        .toString();
  }
}

class $PlanTimesTable extends PlanTimes
    with TableInfo<$PlanTimesTable, PlanTime> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTimesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    hasAutoIncrement: true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'PRIMARY KEY AUTOINCREMENT',
    ),
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<int> revisionId = GeneratedColumn<int>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_revisions (id)',
    ),
  );
  static const VerificationMeta _minuteOfDayMeta = const VerificationMeta(
    'minuteOfDay',
  );
  @override
  late final GeneratedColumn<int> minuteOfDay = GeneratedColumn<int>(
    'minute_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [id, revisionId, minuteOfDay];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_times';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanTime> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('minute_of_day')) {
      context.handle(
        _minuteOfDayMeta,
        minuteOfDay.isAcceptableOrUnknown(
          data['minute_of_day']!,
          _minuteOfDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minuteOfDayMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {revisionId, minuteOfDay},
  ];
  @override
  PlanTime map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTime(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_id'],
      )!,
      minuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute_of_day'],
      )!,
    );
  }

  @override
  $PlanTimesTable createAlias(String alias) {
    return $PlanTimesTable(attachedDatabase, alias);
  }
}

class PlanTime extends DataClass implements Insertable<PlanTime> {
  final int id;
  final int revisionId;
  final int minuteOfDay;
  const PlanTime({
    required this.id,
    required this.revisionId,
    required this.minuteOfDay,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['revision_id'] = Variable<int>(revisionId);
    map['minute_of_day'] = Variable<int>(minuteOfDay);
    return map;
  }

  PlanTimesCompanion toCompanion(bool nullToAbsent) {
    return PlanTimesCompanion(
      id: Value(id),
      revisionId: Value(revisionId),
      minuteOfDay: Value(minuteOfDay),
    );
  }

  factory PlanTime.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTime(
      id: serializer.fromJson<int>(json['id']),
      revisionId: serializer.fromJson<int>(json['revisionId']),
      minuteOfDay: serializer.fromJson<int>(json['minuteOfDay']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'revisionId': serializer.toJson<int>(revisionId),
      'minuteOfDay': serializer.toJson<int>(minuteOfDay),
    };
  }

  PlanTime copyWith({int? id, int? revisionId, int? minuteOfDay}) => PlanTime(
    id: id ?? this.id,
    revisionId: revisionId ?? this.revisionId,
    minuteOfDay: minuteOfDay ?? this.minuteOfDay,
  );
  PlanTime copyWithCompanion(PlanTimesCompanion data) {
    return PlanTime(
      id: data.id.present ? data.id.value : this.id,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      minuteOfDay: data.minuteOfDay.present
          ? data.minuteOfDay.value
          : this.minuteOfDay,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTime(')
          ..write('id: $id, ')
          ..write('revisionId: $revisionId, ')
          ..write('minuteOfDay: $minuteOfDay')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, revisionId, minuteOfDay);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTime &&
          other.id == this.id &&
          other.revisionId == this.revisionId &&
          other.minuteOfDay == this.minuteOfDay);
}

class PlanTimesCompanion extends UpdateCompanion<PlanTime> {
  final Value<int> id;
  final Value<int> revisionId;
  final Value<int> minuteOfDay;
  const PlanTimesCompanion({
    this.id = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.minuteOfDay = const Value.absent(),
  });
  PlanTimesCompanion.insert({
    this.id = const Value.absent(),
    required int revisionId,
    required int minuteOfDay,
  }) : revisionId = Value(revisionId),
       minuteOfDay = Value(minuteOfDay);
  static Insertable<PlanTime> custom({
    Expression<int>? id,
    Expression<int>? revisionId,
    Expression<int>? minuteOfDay,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (revisionId != null) 'revision_id': revisionId,
      if (minuteOfDay != null) 'minute_of_day': minuteOfDay,
    });
  }

  PlanTimesCompanion copyWith({
    Value<int>? id,
    Value<int>? revisionId,
    Value<int>? minuteOfDay,
  }) {
    return PlanTimesCompanion(
      id: id ?? this.id,
      revisionId: revisionId ?? this.revisionId,
      minuteOfDay: minuteOfDay ?? this.minuteOfDay,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<int>(revisionId.value);
    }
    if (minuteOfDay.present) {
      map['minute_of_day'] = Variable<int>(minuteOfDay.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTimesCompanion(')
          ..write('id: $id, ')
          ..write('revisionId: $revisionId, ')
          ..write('minuteOfDay: $minuteOfDay')
          ..write(')'))
        .toString();
  }
}

class $PlanOccurrencesTable extends PlanOccurrences
    with TableInfo<$PlanOccurrencesTable, PlanOccurrence> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanOccurrencesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _occurrenceKeyMeta = const VerificationMeta(
    'occurrenceKey',
  );
  @override
  late final GeneratedColumn<String> occurrenceKey = GeneratedColumn<String>(
    'occurrence_key',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _revisionIdMeta = const VerificationMeta(
    'revisionId',
  );
  @override
  late final GeneratedColumn<int> revisionId = GeneratedColumn<int>(
    'revision_id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_revisions (id)',
    ),
  );
  static const VerificationMeta _dueAtMeta = const VerificationMeta('dueAt');
  @override
  late final GeneratedColumn<DateTime> dueAt = GeneratedColumn<DateTime>(
    'due_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _localDateMeta = const VerificationMeta(
    'localDate',
  );
  @override
  late final GeneratedColumn<String> localDate = GeneratedColumn<String>(
    'local_date',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _minuteOfDayMeta = const VerificationMeta(
    'minuteOfDay',
  );
  @override
  late final GeneratedColumn<int> minuteOfDay = GeneratedColumn<int>(
    'minute_of_day',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _zoneIdMeta = const VerificationMeta('zoneId');
  @override
  late final GeneratedColumn<String> zoneId = GeneratedColumn<String>(
    'zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _timeAmbiguousMeta = const VerificationMeta(
    'timeAmbiguous',
  );
  @override
  late final GeneratedColumn<bool> timeAmbiguous = GeneratedColumn<bool>(
    'time_ambiguous',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("time_ambiguous" IN (0, 1))',
    ),
  );
  @override
  List<GeneratedColumn> get $columns => [
    occurrenceKey,
    revisionId,
    dueAt,
    localDate,
    minuteOfDay,
    zoneId,
    timeAmbiguous,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_occurrences';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanOccurrence> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('occurrence_key')) {
      context.handle(
        _occurrenceKeyMeta,
        occurrenceKey.isAcceptableOrUnknown(
          data['occurrence_key']!,
          _occurrenceKeyMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_occurrenceKeyMeta);
    }
    if (data.containsKey('revision_id')) {
      context.handle(
        _revisionIdMeta,
        revisionId.isAcceptableOrUnknown(data['revision_id']!, _revisionIdMeta),
      );
    } else if (isInserting) {
      context.missing(_revisionIdMeta);
    }
    if (data.containsKey('due_at')) {
      context.handle(
        _dueAtMeta,
        dueAt.isAcceptableOrUnknown(data['due_at']!, _dueAtMeta),
      );
    }
    if (data.containsKey('local_date')) {
      context.handle(
        _localDateMeta,
        localDate.isAcceptableOrUnknown(data['local_date']!, _localDateMeta),
      );
    } else if (isInserting) {
      context.missing(_localDateMeta);
    }
    if (data.containsKey('minute_of_day')) {
      context.handle(
        _minuteOfDayMeta,
        minuteOfDay.isAcceptableOrUnknown(
          data['minute_of_day']!,
          _minuteOfDayMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_minuteOfDayMeta);
    }
    if (data.containsKey('zone_id')) {
      context.handle(
        _zoneIdMeta,
        zoneId.isAcceptableOrUnknown(data['zone_id']!, _zoneIdMeta),
      );
    }
    if (data.containsKey('time_ambiguous')) {
      context.handle(
        _timeAmbiguousMeta,
        timeAmbiguous.isAcceptableOrUnknown(
          data['time_ambiguous']!,
          _timeAmbiguousMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_timeAmbiguousMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {occurrenceKey};
  @override
  PlanOccurrence map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanOccurrence(
      occurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_key'],
      )!,
      revisionId: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}revision_id'],
      )!,
      dueAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}due_at'],
      ),
      localDate: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}local_date'],
      )!,
      minuteOfDay: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}minute_of_day'],
      )!,
      zoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}zone_id'],
      ),
      timeAmbiguous: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}time_ambiguous'],
      )!,
    );
  }

  @override
  $PlanOccurrencesTable createAlias(String alias) {
    return $PlanOccurrencesTable(attachedDatabase, alias);
  }
}

class PlanOccurrence extends DataClass implements Insertable<PlanOccurrence> {
  final String occurrenceKey;
  final int revisionId;
  final DateTime? dueAt;
  final String localDate;
  final int minuteOfDay;
  final String? zoneId;
  final bool timeAmbiguous;
  const PlanOccurrence({
    required this.occurrenceKey,
    required this.revisionId,
    this.dueAt,
    required this.localDate,
    required this.minuteOfDay,
    this.zoneId,
    required this.timeAmbiguous,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['occurrence_key'] = Variable<String>(occurrenceKey);
    map['revision_id'] = Variable<int>(revisionId);
    if (!nullToAbsent || dueAt != null) {
      map['due_at'] = Variable<DateTime>(dueAt);
    }
    map['local_date'] = Variable<String>(localDate);
    map['minute_of_day'] = Variable<int>(minuteOfDay);
    if (!nullToAbsent || zoneId != null) {
      map['zone_id'] = Variable<String>(zoneId);
    }
    map['time_ambiguous'] = Variable<bool>(timeAmbiguous);
    return map;
  }

  PlanOccurrencesCompanion toCompanion(bool nullToAbsent) {
    return PlanOccurrencesCompanion(
      occurrenceKey: Value(occurrenceKey),
      revisionId: Value(revisionId),
      dueAt: dueAt == null && nullToAbsent
          ? const Value.absent()
          : Value(dueAt),
      localDate: Value(localDate),
      minuteOfDay: Value(minuteOfDay),
      zoneId: zoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(zoneId),
      timeAmbiguous: Value(timeAmbiguous),
    );
  }

  factory PlanOccurrence.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanOccurrence(
      occurrenceKey: serializer.fromJson<String>(json['occurrenceKey']),
      revisionId: serializer.fromJson<int>(json['revisionId']),
      dueAt: serializer.fromJson<DateTime?>(json['dueAt']),
      localDate: serializer.fromJson<String>(json['localDate']),
      minuteOfDay: serializer.fromJson<int>(json['minuteOfDay']),
      zoneId: serializer.fromJson<String?>(json['zoneId']),
      timeAmbiguous: serializer.fromJson<bool>(json['timeAmbiguous']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'occurrenceKey': serializer.toJson<String>(occurrenceKey),
      'revisionId': serializer.toJson<int>(revisionId),
      'dueAt': serializer.toJson<DateTime?>(dueAt),
      'localDate': serializer.toJson<String>(localDate),
      'minuteOfDay': serializer.toJson<int>(minuteOfDay),
      'zoneId': serializer.toJson<String?>(zoneId),
      'timeAmbiguous': serializer.toJson<bool>(timeAmbiguous),
    };
  }

  PlanOccurrence copyWith({
    String? occurrenceKey,
    int? revisionId,
    Value<DateTime?> dueAt = const Value.absent(),
    String? localDate,
    int? minuteOfDay,
    Value<String?> zoneId = const Value.absent(),
    bool? timeAmbiguous,
  }) => PlanOccurrence(
    occurrenceKey: occurrenceKey ?? this.occurrenceKey,
    revisionId: revisionId ?? this.revisionId,
    dueAt: dueAt.present ? dueAt.value : this.dueAt,
    localDate: localDate ?? this.localDate,
    minuteOfDay: minuteOfDay ?? this.minuteOfDay,
    zoneId: zoneId.present ? zoneId.value : this.zoneId,
    timeAmbiguous: timeAmbiguous ?? this.timeAmbiguous,
  );
  PlanOccurrence copyWithCompanion(PlanOccurrencesCompanion data) {
    return PlanOccurrence(
      occurrenceKey: data.occurrenceKey.present
          ? data.occurrenceKey.value
          : this.occurrenceKey,
      revisionId: data.revisionId.present
          ? data.revisionId.value
          : this.revisionId,
      dueAt: data.dueAt.present ? data.dueAt.value : this.dueAt,
      localDate: data.localDate.present ? data.localDate.value : this.localDate,
      minuteOfDay: data.minuteOfDay.present
          ? data.minuteOfDay.value
          : this.minuteOfDay,
      zoneId: data.zoneId.present ? data.zoneId.value : this.zoneId,
      timeAmbiguous: data.timeAmbiguous.present
          ? data.timeAmbiguous.value
          : this.timeAmbiguous,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanOccurrence(')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('revisionId: $revisionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('localDate: $localDate, ')
          ..write('minuteOfDay: $minuteOfDay, ')
          ..write('zoneId: $zoneId, ')
          ..write('timeAmbiguous: $timeAmbiguous')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    occurrenceKey,
    revisionId,
    dueAt,
    localDate,
    minuteOfDay,
    zoneId,
    timeAmbiguous,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanOccurrence &&
          other.occurrenceKey == this.occurrenceKey &&
          other.revisionId == this.revisionId &&
          other.dueAt == this.dueAt &&
          other.localDate == this.localDate &&
          other.minuteOfDay == this.minuteOfDay &&
          other.zoneId == this.zoneId &&
          other.timeAmbiguous == this.timeAmbiguous);
}

class PlanOccurrencesCompanion extends UpdateCompanion<PlanOccurrence> {
  final Value<String> occurrenceKey;
  final Value<int> revisionId;
  final Value<DateTime?> dueAt;
  final Value<String> localDate;
  final Value<int> minuteOfDay;
  final Value<String?> zoneId;
  final Value<bool> timeAmbiguous;
  final Value<int> rowid;
  const PlanOccurrencesCompanion({
    this.occurrenceKey = const Value.absent(),
    this.revisionId = const Value.absent(),
    this.dueAt = const Value.absent(),
    this.localDate = const Value.absent(),
    this.minuteOfDay = const Value.absent(),
    this.zoneId = const Value.absent(),
    this.timeAmbiguous = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanOccurrencesCompanion.insert({
    required String occurrenceKey,
    required int revisionId,
    this.dueAt = const Value.absent(),
    required String localDate,
    required int minuteOfDay,
    this.zoneId = const Value.absent(),
    required bool timeAmbiguous,
    this.rowid = const Value.absent(),
  }) : occurrenceKey = Value(occurrenceKey),
       revisionId = Value(revisionId),
       localDate = Value(localDate),
       minuteOfDay = Value(minuteOfDay),
       timeAmbiguous = Value(timeAmbiguous);
  static Insertable<PlanOccurrence> custom({
    Expression<String>? occurrenceKey,
    Expression<int>? revisionId,
    Expression<DateTime>? dueAt,
    Expression<String>? localDate,
    Expression<int>? minuteOfDay,
    Expression<String>? zoneId,
    Expression<bool>? timeAmbiguous,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (occurrenceKey != null) 'occurrence_key': occurrenceKey,
      if (revisionId != null) 'revision_id': revisionId,
      if (dueAt != null) 'due_at': dueAt,
      if (localDate != null) 'local_date': localDate,
      if (minuteOfDay != null) 'minute_of_day': minuteOfDay,
      if (zoneId != null) 'zone_id': zoneId,
      if (timeAmbiguous != null) 'time_ambiguous': timeAmbiguous,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanOccurrencesCompanion copyWith({
    Value<String>? occurrenceKey,
    Value<int>? revisionId,
    Value<DateTime?>? dueAt,
    Value<String>? localDate,
    Value<int>? minuteOfDay,
    Value<String?>? zoneId,
    Value<bool>? timeAmbiguous,
    Value<int>? rowid,
  }) {
    return PlanOccurrencesCompanion(
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      revisionId: revisionId ?? this.revisionId,
      dueAt: dueAt ?? this.dueAt,
      localDate: localDate ?? this.localDate,
      minuteOfDay: minuteOfDay ?? this.minuteOfDay,
      zoneId: zoneId ?? this.zoneId,
      timeAmbiguous: timeAmbiguous ?? this.timeAmbiguous,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (occurrenceKey.present) {
      map['occurrence_key'] = Variable<String>(occurrenceKey.value);
    }
    if (revisionId.present) {
      map['revision_id'] = Variable<int>(revisionId.value);
    }
    if (dueAt.present) {
      map['due_at'] = Variable<DateTime>(dueAt.value);
    }
    if (localDate.present) {
      map['local_date'] = Variable<String>(localDate.value);
    }
    if (minuteOfDay.present) {
      map['minute_of_day'] = Variable<int>(minuteOfDay.value);
    }
    if (zoneId.present) {
      map['zone_id'] = Variable<String>(zoneId.value);
    }
    if (timeAmbiguous.present) {
      map['time_ambiguous'] = Variable<bool>(timeAmbiguous.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanOccurrencesCompanion(')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('revisionId: $revisionId, ')
          ..write('dueAt: $dueAt, ')
          ..write('localDate: $localDate, ')
          ..write('minuteOfDay: $minuteOfDay, ')
          ..write('zoneId: $zoneId, ')
          ..write('timeAmbiguous: $timeAmbiguous, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlanAssignmentOverridesTable extends PlanAssignmentOverrides
    with TableInfo<$PlanAssignmentOverridesTable, PlanAssignmentOverride> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanAssignmentOverridesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _userSlotMeta = const VerificationMeta(
    'userSlot',
  );
  @override
  late final GeneratedColumn<int> userSlot = GeneratedColumn<int>(
    'user_slot',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _deviceSequenceMeta = const VerificationMeta(
    'deviceSequence',
  );
  @override
  late final GeneratedColumn<int> deviceSequence = GeneratedColumn<int>(
    'device_sequence',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurrenceKeyMeta = const VerificationMeta(
    'occurrenceKey',
  );
  @override
  late final GeneratedColumn<String> occurrenceKey = GeneratedColumn<String>(
    'occurrence_key',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'REFERENCES plan_occurrences (occurrence_key)',
    ),
  );
  static const VerificationMeta _decidedAtMeta = const VerificationMeta(
    'decidedAt',
  );
  @override
  late final GeneratedColumn<DateTime> decidedAt = GeneratedColumn<DateTime>(
    'decided_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    userSlot,
    deviceSequence,
    occurrenceKey,
    decidedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_assignment_overrides';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanAssignmentOverride> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('user_slot')) {
      context.handle(
        _userSlotMeta,
        userSlot.isAcceptableOrUnknown(data['user_slot']!, _userSlotMeta),
      );
    } else if (isInserting) {
      context.missing(_userSlotMeta);
    }
    if (data.containsKey('device_sequence')) {
      context.handle(
        _deviceSequenceMeta,
        deviceSequence.isAcceptableOrUnknown(
          data['device_sequence']!,
          _deviceSequenceMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_deviceSequenceMeta);
    }
    if (data.containsKey('occurrence_key')) {
      context.handle(
        _occurrenceKeyMeta,
        occurrenceKey.isAcceptableOrUnknown(
          data['occurrence_key']!,
          _occurrenceKeyMeta,
        ),
      );
    }
    if (data.containsKey('decided_at')) {
      context.handle(
        _decidedAtMeta,
        decidedAt.isAcceptableOrUnknown(data['decided_at']!, _decidedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_decidedAtMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {userSlot, deviceSequence};
  @override
  List<Set<GeneratedColumn>> get uniqueKeys => [
    {occurrenceKey},
  ];
  @override
  PlanAssignmentOverride map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanAssignmentOverride(
      userSlot: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}user_slot'],
      )!,
      deviceSequence: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}device_sequence'],
      )!,
      occurrenceKey: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}occurrence_key'],
      ),
      decidedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}decided_at'],
      )!,
    );
  }

  @override
  $PlanAssignmentOverridesTable createAlias(String alias) {
    return $PlanAssignmentOverridesTable(attachedDatabase, alias);
  }
}

class PlanAssignmentOverride extends DataClass
    implements Insertable<PlanAssignmentOverride> {
  final int userSlot;
  final int deviceSequence;
  final String? occurrenceKey;
  final DateTime decidedAt;
  const PlanAssignmentOverride({
    required this.userSlot,
    required this.deviceSequence,
    this.occurrenceKey,
    required this.decidedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['user_slot'] = Variable<int>(userSlot);
    map['device_sequence'] = Variable<int>(deviceSequence);
    if (!nullToAbsent || occurrenceKey != null) {
      map['occurrence_key'] = Variable<String>(occurrenceKey);
    }
    map['decided_at'] = Variable<DateTime>(decidedAt);
    return map;
  }

  PlanAssignmentOverridesCompanion toCompanion(bool nullToAbsent) {
    return PlanAssignmentOverridesCompanion(
      userSlot: Value(userSlot),
      deviceSequence: Value(deviceSequence),
      occurrenceKey: occurrenceKey == null && nullToAbsent
          ? const Value.absent()
          : Value(occurrenceKey),
      decidedAt: Value(decidedAt),
    );
  }

  factory PlanAssignmentOverride.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanAssignmentOverride(
      userSlot: serializer.fromJson<int>(json['userSlot']),
      deviceSequence: serializer.fromJson<int>(json['deviceSequence']),
      occurrenceKey: serializer.fromJson<String?>(json['occurrenceKey']),
      decidedAt: serializer.fromJson<DateTime>(json['decidedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'userSlot': serializer.toJson<int>(userSlot),
      'deviceSequence': serializer.toJson<int>(deviceSequence),
      'occurrenceKey': serializer.toJson<String?>(occurrenceKey),
      'decidedAt': serializer.toJson<DateTime>(decidedAt),
    };
  }

  PlanAssignmentOverride copyWith({
    int? userSlot,
    int? deviceSequence,
    Value<String?> occurrenceKey = const Value.absent(),
    DateTime? decidedAt,
  }) => PlanAssignmentOverride(
    userSlot: userSlot ?? this.userSlot,
    deviceSequence: deviceSequence ?? this.deviceSequence,
    occurrenceKey: occurrenceKey.present
        ? occurrenceKey.value
        : this.occurrenceKey,
    decidedAt: decidedAt ?? this.decidedAt,
  );
  PlanAssignmentOverride copyWithCompanion(
    PlanAssignmentOverridesCompanion data,
  ) {
    return PlanAssignmentOverride(
      userSlot: data.userSlot.present ? data.userSlot.value : this.userSlot,
      deviceSequence: data.deviceSequence.present
          ? data.deviceSequence.value
          : this.deviceSequence,
      occurrenceKey: data.occurrenceKey.present
          ? data.occurrenceKey.value
          : this.occurrenceKey,
      decidedAt: data.decidedAt.present ? data.decidedAt.value : this.decidedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanAssignmentOverride(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('decidedAt: $decidedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(userSlot, deviceSequence, occurrenceKey, decidedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanAssignmentOverride &&
          other.userSlot == this.userSlot &&
          other.deviceSequence == this.deviceSequence &&
          other.occurrenceKey == this.occurrenceKey &&
          other.decidedAt == this.decidedAt);
}

class PlanAssignmentOverridesCompanion
    extends UpdateCompanion<PlanAssignmentOverride> {
  final Value<int> userSlot;
  final Value<int> deviceSequence;
  final Value<String?> occurrenceKey;
  final Value<DateTime> decidedAt;
  final Value<int> rowid;
  const PlanAssignmentOverridesCompanion({
    this.userSlot = const Value.absent(),
    this.deviceSequence = const Value.absent(),
    this.occurrenceKey = const Value.absent(),
    this.decidedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanAssignmentOverridesCompanion.insert({
    required int userSlot,
    required int deviceSequence,
    this.occurrenceKey = const Value.absent(),
    required DateTime decidedAt,
    this.rowid = const Value.absent(),
  }) : userSlot = Value(userSlot),
       deviceSequence = Value(deviceSequence),
       decidedAt = Value(decidedAt);
  static Insertable<PlanAssignmentOverride> custom({
    Expression<int>? userSlot,
    Expression<int>? deviceSequence,
    Expression<String>? occurrenceKey,
    Expression<DateTime>? decidedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (userSlot != null) 'user_slot': userSlot,
      if (deviceSequence != null) 'device_sequence': deviceSequence,
      if (occurrenceKey != null) 'occurrence_key': occurrenceKey,
      if (decidedAt != null) 'decided_at': decidedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanAssignmentOverridesCompanion copyWith({
    Value<int>? userSlot,
    Value<int>? deviceSequence,
    Value<String?>? occurrenceKey,
    Value<DateTime>? decidedAt,
    Value<int>? rowid,
  }) {
    return PlanAssignmentOverridesCompanion(
      userSlot: userSlot ?? this.userSlot,
      deviceSequence: deviceSequence ?? this.deviceSequence,
      occurrenceKey: occurrenceKey ?? this.occurrenceKey,
      decidedAt: decidedAt ?? this.decidedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (userSlot.present) {
      map['user_slot'] = Variable<int>(userSlot.value);
    }
    if (deviceSequence.present) {
      map['device_sequence'] = Variable<int>(deviceSequence.value);
    }
    if (occurrenceKey.present) {
      map['occurrence_key'] = Variable<String>(occurrenceKey.value);
    }
    if (decidedAt.present) {
      map['decided_at'] = Variable<DateTime>(decidedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanAssignmentOverridesCompanion(')
          ..write('userSlot: $userSlot, ')
          ..write('deviceSequence: $deviceSequence, ')
          ..write('occurrenceKey: $occurrenceKey, ')
          ..write('decidedAt: $decidedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReminderSyncTable extends ReminderSync
    with TableInfo<$ReminderSyncTable, ReminderSyncState> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReminderSyncTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _desiredGenerationMeta = const VerificationMeta(
    'desiredGeneration',
  );
  @override
  late final GeneratedColumn<int> desiredGeneration = GeneratedColumn<int>(
    'desired_generation',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _appliedGenerationMeta = const VerificationMeta(
    'appliedGeneration',
  );
  @override
  late final GeneratedColumn<int> appliedGeneration = GeneratedColumn<int>(
    'applied_generation',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastErrorMeta = const VerificationMeta(
    'lastError',
  );
  @override
  late final GeneratedColumn<String> lastError = GeneratedColumn<String>(
    'last_error',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    desiredGeneration,
    appliedGeneration,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reminder_sync';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReminderSyncState> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('desired_generation')) {
      context.handle(
        _desiredGenerationMeta,
        desiredGeneration.isAcceptableOrUnknown(
          data['desired_generation']!,
          _desiredGenerationMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_desiredGenerationMeta);
    }
    if (data.containsKey('applied_generation')) {
      context.handle(
        _appliedGenerationMeta,
        appliedGeneration.isAcceptableOrUnknown(
          data['applied_generation']!,
          _appliedGenerationMeta,
        ),
      );
    }
    if (data.containsKey('last_error')) {
      context.handle(
        _lastErrorMeta,
        lastError.isAcceptableOrUnknown(data['last_error']!, _lastErrorMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReminderSyncState map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReminderSyncState(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}id'],
      )!,
      desiredGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}desired_generation'],
      )!,
      appliedGeneration: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}applied_generation'],
      ),
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $ReminderSyncTable createAlias(String alias) {
    return $ReminderSyncTable(attachedDatabase, alias);
  }
}

class ReminderSyncState extends DataClass
    implements Insertable<ReminderSyncState> {
  final int id;
  final int desiredGeneration;
  final int? appliedGeneration;
  final String? lastError;
  const ReminderSyncState({
    required this.id,
    required this.desiredGeneration,
    this.appliedGeneration,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['desired_generation'] = Variable<int>(desiredGeneration);
    if (!nullToAbsent || appliedGeneration != null) {
      map['applied_generation'] = Variable<int>(appliedGeneration);
    }
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  ReminderSyncCompanion toCompanion(bool nullToAbsent) {
    return ReminderSyncCompanion(
      id: Value(id),
      desiredGeneration: Value(desiredGeneration),
      appliedGeneration: appliedGeneration == null && nullToAbsent
          ? const Value.absent()
          : Value(appliedGeneration),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory ReminderSyncState.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReminderSyncState(
      id: serializer.fromJson<int>(json['id']),
      desiredGeneration: serializer.fromJson<int>(json['desiredGeneration']),
      appliedGeneration: serializer.fromJson<int?>(json['appliedGeneration']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'desiredGeneration': serializer.toJson<int>(desiredGeneration),
      'appliedGeneration': serializer.toJson<int?>(appliedGeneration),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  ReminderSyncState copyWith({
    int? id,
    int? desiredGeneration,
    Value<int?> appliedGeneration = const Value.absent(),
    Value<String?> lastError = const Value.absent(),
  }) => ReminderSyncState(
    id: id ?? this.id,
    desiredGeneration: desiredGeneration ?? this.desiredGeneration,
    appliedGeneration: appliedGeneration.present
        ? appliedGeneration.value
        : this.appliedGeneration,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  ReminderSyncState copyWithCompanion(ReminderSyncCompanion data) {
    return ReminderSyncState(
      id: data.id.present ? data.id.value : this.id,
      desiredGeneration: data.desiredGeneration.present
          ? data.desiredGeneration.value
          : this.desiredGeneration,
      appliedGeneration: data.appliedGeneration.present
          ? data.appliedGeneration.value
          : this.appliedGeneration,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSyncState(')
          ..write('id: $id, ')
          ..write('desiredGeneration: $desiredGeneration, ')
          ..write('appliedGeneration: $appliedGeneration, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, desiredGeneration, appliedGeneration, lastError);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReminderSyncState &&
          other.id == this.id &&
          other.desiredGeneration == this.desiredGeneration &&
          other.appliedGeneration == this.appliedGeneration &&
          other.lastError == this.lastError);
}

class ReminderSyncCompanion extends UpdateCompanion<ReminderSyncState> {
  final Value<int> id;
  final Value<int> desiredGeneration;
  final Value<int?> appliedGeneration;
  final Value<String?> lastError;
  const ReminderSyncCompanion({
    this.id = const Value.absent(),
    this.desiredGeneration = const Value.absent(),
    this.appliedGeneration = const Value.absent(),
    this.lastError = const Value.absent(),
  });
  ReminderSyncCompanion.insert({
    this.id = const Value.absent(),
    required int desiredGeneration,
    this.appliedGeneration = const Value.absent(),
    this.lastError = const Value.absent(),
  }) : desiredGeneration = Value(desiredGeneration);
  static Insertable<ReminderSyncState> custom({
    Expression<int>? id,
    Expression<int>? desiredGeneration,
    Expression<int>? appliedGeneration,
    Expression<String>? lastError,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (desiredGeneration != null) 'desired_generation': desiredGeneration,
      if (appliedGeneration != null) 'applied_generation': appliedGeneration,
      if (lastError != null) 'last_error': lastError,
    });
  }

  ReminderSyncCompanion copyWith({
    Value<int>? id,
    Value<int>? desiredGeneration,
    Value<int?>? appliedGeneration,
    Value<String?>? lastError,
  }) {
    return ReminderSyncCompanion(
      id: id ?? this.id,
      desiredGeneration: desiredGeneration ?? this.desiredGeneration,
      appliedGeneration: appliedGeneration ?? this.appliedGeneration,
      lastError: lastError ?? this.lastError,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (desiredGeneration.present) {
      map['desired_generation'] = Variable<int>(desiredGeneration.value);
    }
    if (appliedGeneration.present) {
      map['applied_generation'] = Variable<int>(appliedGeneration.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReminderSyncCompanion(')
          ..write('id: $id, ')
          ..write('desiredGeneration: $desiredGeneration, ')
          ..write('appliedGeneration: $appliedGeneration, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }
}

class $PlanTimeChangesTable extends PlanTimeChanges
    with TableInfo<$PlanTimeChangesTable, PlanTimeChange> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlanTimeChangesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _eventIdMeta = const VerificationMeta(
    'eventId',
  );
  @override
  late final GeneratedColumn<String> eventId = GeneratedColumn<String>(
    'event_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _occurredAtMeta = const VerificationMeta(
    'occurredAt',
  );
  @override
  late final GeneratedColumn<DateTime> occurredAt = GeneratedColumn<DateTime>(
    'occurred_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _oldZoneIdMeta = const VerificationMeta(
    'oldZoneId',
  );
  @override
  late final GeneratedColumn<String> oldZoneId = GeneratedColumn<String>(
    'old_zone_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newZoneIdMeta = const VerificationMeta(
    'newZoneId',
  );
  @override
  late final GeneratedColumn<String> newZoneId = GeneratedColumn<String>(
    'new_zone_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    eventId,
    occurredAt,
    oldZoneId,
    newZoneId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'plan_time_changes';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlanTimeChange> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('event_id')) {
      context.handle(
        _eventIdMeta,
        eventId.isAcceptableOrUnknown(data['event_id']!, _eventIdMeta),
      );
    } else if (isInserting) {
      context.missing(_eventIdMeta);
    }
    if (data.containsKey('occurred_at')) {
      context.handle(
        _occurredAtMeta,
        occurredAt.isAcceptableOrUnknown(data['occurred_at']!, _occurredAtMeta),
      );
    } else if (isInserting) {
      context.missing(_occurredAtMeta);
    }
    if (data.containsKey('old_zone_id')) {
      context.handle(
        _oldZoneIdMeta,
        oldZoneId.isAcceptableOrUnknown(data['old_zone_id']!, _oldZoneIdMeta),
      );
    }
    if (data.containsKey('new_zone_id')) {
      context.handle(
        _newZoneIdMeta,
        newZoneId.isAcceptableOrUnknown(data['new_zone_id']!, _newZoneIdMeta),
      );
    } else if (isInserting) {
      context.missing(_newZoneIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {eventId};
  @override
  PlanTimeChange map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlanTimeChange(
      eventId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}event_id'],
      )!,
      occurredAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}occurred_at'],
      )!,
      oldZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}old_zone_id'],
      ),
      newZoneId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_zone_id'],
      )!,
    );
  }

  @override
  $PlanTimeChangesTable createAlias(String alias) {
    return $PlanTimeChangesTable(attachedDatabase, alias);
  }
}

class PlanTimeChange extends DataClass implements Insertable<PlanTimeChange> {
  final String eventId;
  final DateTime occurredAt;
  final String? oldZoneId;
  final String newZoneId;
  const PlanTimeChange({
    required this.eventId,
    required this.occurredAt,
    this.oldZoneId,
    required this.newZoneId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['event_id'] = Variable<String>(eventId);
    map['occurred_at'] = Variable<DateTime>(occurredAt);
    if (!nullToAbsent || oldZoneId != null) {
      map['old_zone_id'] = Variable<String>(oldZoneId);
    }
    map['new_zone_id'] = Variable<String>(newZoneId);
    return map;
  }

  PlanTimeChangesCompanion toCompanion(bool nullToAbsent) {
    return PlanTimeChangesCompanion(
      eventId: Value(eventId),
      occurredAt: Value(occurredAt),
      oldZoneId: oldZoneId == null && nullToAbsent
          ? const Value.absent()
          : Value(oldZoneId),
      newZoneId: Value(newZoneId),
    );
  }

  factory PlanTimeChange.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlanTimeChange(
      eventId: serializer.fromJson<String>(json['eventId']),
      occurredAt: serializer.fromJson<DateTime>(json['occurredAt']),
      oldZoneId: serializer.fromJson<String?>(json['oldZoneId']),
      newZoneId: serializer.fromJson<String>(json['newZoneId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'eventId': serializer.toJson<String>(eventId),
      'occurredAt': serializer.toJson<DateTime>(occurredAt),
      'oldZoneId': serializer.toJson<String?>(oldZoneId),
      'newZoneId': serializer.toJson<String>(newZoneId),
    };
  }

  PlanTimeChange copyWith({
    String? eventId,
    DateTime? occurredAt,
    Value<String?> oldZoneId = const Value.absent(),
    String? newZoneId,
  }) => PlanTimeChange(
    eventId: eventId ?? this.eventId,
    occurredAt: occurredAt ?? this.occurredAt,
    oldZoneId: oldZoneId.present ? oldZoneId.value : this.oldZoneId,
    newZoneId: newZoneId ?? this.newZoneId,
  );
  PlanTimeChange copyWithCompanion(PlanTimeChangesCompanion data) {
    return PlanTimeChange(
      eventId: data.eventId.present ? data.eventId.value : this.eventId,
      occurredAt: data.occurredAt.present
          ? data.occurredAt.value
          : this.occurredAt,
      oldZoneId: data.oldZoneId.present ? data.oldZoneId.value : this.oldZoneId,
      newZoneId: data.newZoneId.present ? data.newZoneId.value : this.newZoneId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlanTimeChange(')
          ..write('eventId: $eventId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('oldZoneId: $oldZoneId, ')
          ..write('newZoneId: $newZoneId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(eventId, occurredAt, oldZoneId, newZoneId);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlanTimeChange &&
          other.eventId == this.eventId &&
          other.occurredAt == this.occurredAt &&
          other.oldZoneId == this.oldZoneId &&
          other.newZoneId == this.newZoneId);
}

class PlanTimeChangesCompanion extends UpdateCompanion<PlanTimeChange> {
  final Value<String> eventId;
  final Value<DateTime> occurredAt;
  final Value<String?> oldZoneId;
  final Value<String> newZoneId;
  final Value<int> rowid;
  const PlanTimeChangesCompanion({
    this.eventId = const Value.absent(),
    this.occurredAt = const Value.absent(),
    this.oldZoneId = const Value.absent(),
    this.newZoneId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlanTimeChangesCompanion.insert({
    required String eventId,
    required DateTime occurredAt,
    this.oldZoneId = const Value.absent(),
    required String newZoneId,
    this.rowid = const Value.absent(),
  }) : eventId = Value(eventId),
       occurredAt = Value(occurredAt),
       newZoneId = Value(newZoneId);
  static Insertable<PlanTimeChange> custom({
    Expression<String>? eventId,
    Expression<DateTime>? occurredAt,
    Expression<String>? oldZoneId,
    Expression<String>? newZoneId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (eventId != null) 'event_id': eventId,
      if (occurredAt != null) 'occurred_at': occurredAt,
      if (oldZoneId != null) 'old_zone_id': oldZoneId,
      if (newZoneId != null) 'new_zone_id': newZoneId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlanTimeChangesCompanion copyWith({
    Value<String>? eventId,
    Value<DateTime>? occurredAt,
    Value<String?>? oldZoneId,
    Value<String>? newZoneId,
    Value<int>? rowid,
  }) {
    return PlanTimeChangesCompanion(
      eventId: eventId ?? this.eventId,
      occurredAt: occurredAt ?? this.occurredAt,
      oldZoneId: oldZoneId ?? this.oldZoneId,
      newZoneId: newZoneId ?? this.newZoneId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (eventId.present) {
      map['event_id'] = Variable<String>(eventId.value);
    }
    if (occurredAt.present) {
      map['occurred_at'] = Variable<DateTime>(occurredAt.value);
    }
    if (oldZoneId.present) {
      map['old_zone_id'] = Variable<String>(oldZoneId.value);
    }
    if (newZoneId.present) {
      map['new_zone_id'] = Variable<String>(newZoneId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlanTimeChangesCompanion(')
          ..write('eventId: $eventId, ')
          ..write('occurredAt: $occurredAt, ')
          ..write('oldZoneId: $oldZoneId, ')
          ..write('newZoneId: $newZoneId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $MeasurementExportsTable measurementExports =
      $MeasurementExportsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $OccasionDecisionsTable occasionDecisions =
      $OccasionDecisionsTable(this);
  late final $PhasesTable phases = $PhasesTable(this);
  late final $PhaseAssignmentsTable phaseAssignments = $PhaseAssignmentsTable(
    this,
  );
  late final $MeasurementNotesTable measurementNotes = $MeasurementNotesTable(
    this,
  );
  late final $MeasurementTagsTable measurementTags = $MeasurementTagsTable(
    this,
  );
  late final $MeasurementTagLinksTable measurementTagLinks =
      $MeasurementTagLinksTable(this);
  late final $ScopedPhasesTable scopedPhases = $ScopedPhasesTable(this);
  late final $PhaseSelectionsTable phaseSelections = $PhaseSelectionsTable(
    this,
  );
  late final $PhaseSelectionMembersTable phaseSelectionMembers =
      $PhaseSelectionMembersTable(this);
  late final $MeasurementPlansTable measurementPlans = $MeasurementPlansTable(
    this,
  );
  late final $PlanRevisionsTable planRevisions = $PlanRevisionsTable(this);
  late final $PlanTimesTable planTimes = $PlanTimesTable(this);
  late final $PlanOccurrencesTable planOccurrences = $PlanOccurrencesTable(
    this,
  );
  late final $PlanAssignmentOverridesTable planAssignmentOverrides =
      $PlanAssignmentOverridesTable(this);
  late final $ReminderSyncTable reminderSync = $ReminderSyncTable(this);
  late final $PlanTimeChangesTable planTimeChanges = $PlanTimeChangesTable(
    this,
  );
  late final Index oneOpenPlanPerSlot = Index(
    'one_open_plan_per_slot',
    'CREATE UNIQUE INDEX one_open_plan_per_slot ON measurement_plans (user_slot) WHERE ended_at IS NULL',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    measurements,
    measurementExports,
    appSettings,
    occasionDecisions,
    phases,
    phaseAssignments,
    measurementNotes,
    measurementTags,
    measurementTagLinks,
    scopedPhases,
    phaseSelections,
    phaseSelectionMembers,
    measurementPlans,
    planRevisions,
    planTimes,
    planOccurrences,
    planAssignmentOverrides,
    reminderSync,
    planTimeChanges,
    oneOpenPlanPerSlot,
  ];
}

typedef $$MeasurementsTableCreateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      required int userSlot,
      required int deviceSequence,
      required int systolic,
      required int diastolic,
      required int pulse,
      required DateTime measuredAt,
      required bool movement,
      required bool arrhythmia,
      required Uint8List rawBytes,
      required DateTime importedAt,
      Value<DateTime?> exportedAt,
    });
typedef $$MeasurementsTableUpdateCompanionBuilder =
    MeasurementsCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<int> systolic,
      Value<int> diastolic,
      Value<int> pulse,
      Value<DateTime> measuredAt,
      Value<bool> movement,
      Value<bool> arrhythmia,
      Value<Uint8List> rawBytes,
      Value<DateTime> importedAt,
      Value<DateTime?> exportedAt,
    });

final class $$MeasurementsTableReferences
    extends BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement> {
  $$MeasurementsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$MeasurementExportsTable, List<MeasurementExport>>
  _measurementExportsRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementExports,
        aliasName: 'measurements__id__measurement_exports__measurement_id',
      );

  $$MeasurementExportsTableProcessedTableManager get measurementExportsRefs {
    final manager = $$MeasurementExportsTableTableManager(
      $_db,
      $_db.measurementExports,
    ).filter((f) => f.measurementId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementExportsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get movement => $composableBuilder(
    column: $table.movement,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get arrhythmia => $composableBuilder(
    column: $table.arrhythmia,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<Uint8List> get rawBytes => $composableBuilder(
    column: $table.rawBytes,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementExportsRefs(
    Expression<bool> Function($$MeasurementExportsTableFilterComposer f) f,
  ) {
    final $$MeasurementExportsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementExports,
      getReferencedColumn: (t) => t.measurementId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementExportsTableFilterComposer(
            $db: $db,
            $table: $db.measurementExports,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get systolic => $composableBuilder(
    column: $table.systolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get diastolic => $composableBuilder(
    column: $table.diastolic,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get pulse => $composableBuilder(
    column: $table.pulse,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get movement => $composableBuilder(
    column: $table.movement,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get arrhythmia => $composableBuilder(
    column: $table.arrhythmia,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<Uint8List> get rawBytes => $composableBuilder(
    column: $table.rawBytes,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementsTable> {
  $$MeasurementsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<int> get systolic =>
      $composableBuilder(column: $table.systolic, builder: (column) => column);

  GeneratedColumn<int> get diastolic =>
      $composableBuilder(column: $table.diastolic, builder: (column) => column);

  GeneratedColumn<int> get pulse =>
      $composableBuilder(column: $table.pulse, builder: (column) => column);

  GeneratedColumn<DateTime> get measuredAt => $composableBuilder(
    column: $table.measuredAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get movement =>
      $composableBuilder(column: $table.movement, builder: (column) => column);

  GeneratedColumn<bool> get arrhythmia => $composableBuilder(
    column: $table.arrhythmia,
    builder: (column) => column,
  );

  GeneratedColumn<Uint8List> get rawBytes =>
      $composableBuilder(column: $table.rawBytes, builder: (column) => column);

  GeneratedColumn<DateTime> get importedAt => $composableBuilder(
    column: $table.importedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get exportedAt => $composableBuilder(
    column: $table.exportedAt,
    builder: (column) => column,
  );

  Expression<T> measurementExportsRefs<T extends Object>(
    Expression<T> Function($$MeasurementExportsTableAnnotationComposer a) f,
  ) {
    final $$MeasurementExportsTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementExports,
          getReferencedColumn: (t) => t.measurementId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementExportsTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementExports,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementsTable,
          Measurement,
          $$MeasurementsTableFilterComposer,
          $$MeasurementsTableOrderingComposer,
          $$MeasurementsTableAnnotationComposer,
          $$MeasurementsTableCreateCompanionBuilder,
          $$MeasurementsTableUpdateCompanionBuilder,
          (Measurement, $$MeasurementsTableReferences),
          Measurement,
          PrefetchHooks Function({bool measurementExportsRefs})
        > {
  $$MeasurementsTableTableManager(_$AppDatabase db, $MeasurementsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<int> systolic = const Value.absent(),
                Value<int> diastolic = const Value.absent(),
                Value<int> pulse = const Value.absent(),
                Value<DateTime> measuredAt = const Value.absent(),
                Value<bool> movement = const Value.absent(),
                Value<bool> arrhythmia = const Value.absent(),
                Value<Uint8List> rawBytes = const Value.absent(),
                Value<DateTime> importedAt = const Value.absent(),
                Value<DateTime?> exportedAt = const Value.absent(),
              }) => MeasurementsCompanion(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                measuredAt: measuredAt,
                movement: movement,
                arrhythmia: arrhythmia,
                rawBytes: rawBytes,
                importedAt: importedAt,
                exportedAt: exportedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                required int deviceSequence,
                required int systolic,
                required int diastolic,
                required int pulse,
                required DateTime measuredAt,
                required bool movement,
                required bool arrhythmia,
                required Uint8List rawBytes,
                required DateTime importedAt,
                Value<DateTime?> exportedAt = const Value.absent(),
              }) => MeasurementsCompanion.insert(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                systolic: systolic,
                diastolic: diastolic,
                pulse: pulse,
                measuredAt: measuredAt,
                movement: movement,
                arrhythmia: arrhythmia,
                rawBytes: rawBytes,
                importedAt: importedAt,
                exportedAt: exportedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementsTable, Measurement>(table),
                  $$MeasurementsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementExportsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementExportsRefs) db.measurementExports,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementExportsRefs)
                    await $_getPrefetchedData<
                      Measurement,
                      $MeasurementsTable,
                      MeasurementExport
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementsTableReferences
                          ._measurementExportsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementsTableReferences(
                            db,
                            table,
                            p0,
                          ).measurementExportsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where(
                            (e) => e.measurementId == item.id,
                          ),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementsTable,
      Measurement,
      $$MeasurementsTableFilterComposer,
      $$MeasurementsTableOrderingComposer,
      $$MeasurementsTableAnnotationComposer,
      $$MeasurementsTableCreateCompanionBuilder,
      $$MeasurementsTableUpdateCompanionBuilder,
      (Measurement, $$MeasurementsTableReferences),
      Measurement,
      PrefetchHooks Function({bool measurementExportsRefs})
    >;
typedef $$MeasurementExportsTableCreateCompanionBuilder =
    MeasurementExportsCompanion Function({
      Value<int> measurementId,
      required bool mayExist,
      required bool withdrawn,
      Value<bool> legacyUnknown,
    });
typedef $$MeasurementExportsTableUpdateCompanionBuilder =
    MeasurementExportsCompanion Function({
      Value<int> measurementId,
      Value<bool> mayExist,
      Value<bool> withdrawn,
      Value<bool> legacyUnknown,
    });

final class $$MeasurementExportsTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementExportsTable,
          MeasurementExport
        > {
  $$MeasurementExportsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementsTable _measurementIdTable(_$AppDatabase db) => db
      .measurements
      .createAlias('measurement_exports__measurement_id__measurements__id');

  $$MeasurementsTableProcessedTableManager get measurementId {
    final $_column = $_itemColumn<int>('measurement_id')!;

    final manager = $$MeasurementsTableTableManager(
      $_db,
      $_db.measurements,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_measurementIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementExportsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementExportsTable> {
  $$MeasurementExportsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<bool> get mayExist => $composableBuilder(
    column: $table.mayExist,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get withdrawn => $composableBuilder(
    column: $table.withdrawn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get legacyUnknown => $composableBuilder(
    column: $table.legacyUnknown,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementsTableFilterComposer get measurementId {
    final $$MeasurementsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementId,
      referencedTable: $db.measurements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementsTableFilterComposer(
            $db: $db,
            $table: $db.measurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementExportsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementExportsTable> {
  $$MeasurementExportsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<bool> get mayExist => $composableBuilder(
    column: $table.mayExist,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get withdrawn => $composableBuilder(
    column: $table.withdrawn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get legacyUnknown => $composableBuilder(
    column: $table.legacyUnknown,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementsTableOrderingComposer get measurementId {
    final $$MeasurementsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementId,
      referencedTable: $db.measurements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementsTableOrderingComposer(
            $db: $db,
            $table: $db.measurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementExportsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementExportsTable> {
  $$MeasurementExportsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<bool> get mayExist =>
      $composableBuilder(column: $table.mayExist, builder: (column) => column);

  GeneratedColumn<bool> get withdrawn =>
      $composableBuilder(column: $table.withdrawn, builder: (column) => column);

  GeneratedColumn<bool> get legacyUnknown => $composableBuilder(
    column: $table.legacyUnknown,
    builder: (column) => column,
  );

  $$MeasurementsTableAnnotationComposer get measurementId {
    final $$MeasurementsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.measurementId,
      referencedTable: $db.measurements,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurements,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementExportsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementExportsTable,
          MeasurementExport,
          $$MeasurementExportsTableFilterComposer,
          $$MeasurementExportsTableOrderingComposer,
          $$MeasurementExportsTableAnnotationComposer,
          $$MeasurementExportsTableCreateCompanionBuilder,
          $$MeasurementExportsTableUpdateCompanionBuilder,
          (MeasurementExport, $$MeasurementExportsTableReferences),
          MeasurementExport,
          PrefetchHooks Function({bool measurementId})
        > {
  $$MeasurementExportsTableTableManager(
    _$AppDatabase db,
    $MeasurementExportsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementExportsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementExportsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementExportsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> measurementId = const Value.absent(),
                Value<bool> mayExist = const Value.absent(),
                Value<bool> withdrawn = const Value.absent(),
                Value<bool> legacyUnknown = const Value.absent(),
              }) => MeasurementExportsCompanion(
                measurementId: measurementId,
                mayExist: mayExist,
                withdrawn: withdrawn,
                legacyUnknown: legacyUnknown,
              ),
          createCompanionCallback:
              ({
                Value<int> measurementId = const Value.absent(),
                required bool mayExist,
                required bool withdrawn,
                Value<bool> legacyUnknown = const Value.absent(),
              }) => MeasurementExportsCompanion.insert(
                measurementId: measurementId,
                mayExist: mayExist,
                withdrawn: withdrawn,
                legacyUnknown: legacyUnknown,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementExportsTable, MeasurementExport>(
                    table,
                  ),
                  $$MeasurementExportsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (measurementId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.measurementId,
                        referencedTable: $$MeasurementExportsTableReferences
                            ._measurementIdTable(db),
                        referencedColumn: $$MeasurementExportsTableReferences
                            ._measurementIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementExportsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementExportsTable,
      MeasurementExport,
      $$MeasurementExportsTableFilterComposer,
      $$MeasurementExportsTableOrderingComposer,
      $$MeasurementExportsTableAnnotationComposer,
      $$MeasurementExportsTableCreateCompanionBuilder,
      $$MeasurementExportsTableUpdateCompanionBuilder,
      (MeasurementExport, $$MeasurementExportsTableReferences),
      MeasurementExport,
      PrefetchHooks Function({bool measurementId})
    >;
typedef $$AppSettingsTableCreateCompanionBuilder =
    AppSettingsCompanion Function({
      required String key,
      required String value,
      Value<int> rowid,
    });
typedef $$AppSettingsTableUpdateCompanionBuilder =
    AppSettingsCompanion Function({
      Value<String> key,
      Value<String> value,
      Value<int> rowid,
    });

class $$AppSettingsTableFilterComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AppSettingsTableOrderingComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get key => $composableBuilder(
    column: $table.key,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get value => $composableBuilder(
    column: $table.value,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AppSettingsTableAnnotationComposer
    extends Composer<_$AppDatabase, $AppSettingsTable> {
  $$AppSettingsTableAnnotationComposer({
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

class $$AppSettingsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $AppSettingsTable,
          AppSetting,
          $$AppSettingsTableFilterComposer,
          $$AppSettingsTableOrderingComposer,
          $$AppSettingsTableAnnotationComposer,
          $$AppSettingsTableCreateCompanionBuilder,
          $$AppSettingsTableUpdateCompanionBuilder,
          (
            AppSetting,
            BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
          ),
          AppSetting,
          PrefetchHooks Function()
        > {
  $$AppSettingsTableTableManager(_$AppDatabase db, $AppSettingsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AppSettingsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AppSettingsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AppSettingsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<String> key = const Value.absent(),
            Value<String> value = const Value.absent(),
            Value<int> rowid = const Value.absent(),
          }) => AppSettingsCompanion(key: key, value: value, rowid: rowid),
          createCompanionCallback:
              ({
                required String key,
                required String value,
                Value<int> rowid = const Value.absent(),
              }) => AppSettingsCompanion.insert(
                key: key,
                value: value,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$AppSettingsTable, AppSetting>(table),
                  BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>(
                    db,
                    table,
                    e,
                  ),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AppSettingsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $AppSettingsTable,
      AppSetting,
      $$AppSettingsTableFilterComposer,
      $$AppSettingsTableOrderingComposer,
      $$AppSettingsTableAnnotationComposer,
      $$AppSettingsTableCreateCompanionBuilder,
      $$AppSettingsTableUpdateCompanionBuilder,
      (
        AppSetting,
        BaseReferences<_$AppDatabase, $AppSettingsTable, AppSetting>,
      ),
      AppSetting,
      PrefetchHooks Function()
    >;
typedef $$OccasionDecisionsTableCreateCompanionBuilder =
    OccasionDecisionsCompanion Function({
      Value<int> id,
      required int userSlot,
      required int deviceSequence,
      required String decision,
      required DateTime decidedAt,
    });
typedef $$OccasionDecisionsTableUpdateCompanionBuilder =
    OccasionDecisionsCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<String> decision,
      Value<DateTime> decidedAt,
    });

class $$OccasionDecisionsTableFilterComposer
    extends Composer<_$AppDatabase, $OccasionDecisionsTable> {
  $$OccasionDecisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OccasionDecisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $OccasionDecisionsTable> {
  $$OccasionDecisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get decision => $composableBuilder(
    column: $table.decision,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OccasionDecisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $OccasionDecisionsTable> {
  $$OccasionDecisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get decision =>
      $composableBuilder(column: $table.decision, builder: (column) => column);

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$OccasionDecisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $OccasionDecisionsTable,
          OccasionDecision,
          $$OccasionDecisionsTableFilterComposer,
          $$OccasionDecisionsTableOrderingComposer,
          $$OccasionDecisionsTableAnnotationComposer,
          $$OccasionDecisionsTableCreateCompanionBuilder,
          $$OccasionDecisionsTableUpdateCompanionBuilder,
          (
            OccasionDecision,
            BaseReferences<
              _$AppDatabase,
              $OccasionDecisionsTable,
              OccasionDecision
            >,
          ),
          OccasionDecision,
          PrefetchHooks Function()
        > {
  $$OccasionDecisionsTableTableManager(
    _$AppDatabase db,
    $OccasionDecisionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OccasionDecisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OccasionDecisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OccasionDecisionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<String> decision = const Value.absent(),
                Value<DateTime> decidedAt = const Value.absent(),
              }) => OccasionDecisionsCompanion(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                decision: decision,
                decidedAt: decidedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                required int deviceSequence,
                required String decision,
                required DateTime decidedAt,
              }) => OccasionDecisionsCompanion.insert(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                decision: decision,
                decidedAt: decidedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$OccasionDecisionsTable, OccasionDecision>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $OccasionDecisionsTable,
                    OccasionDecision
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OccasionDecisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $OccasionDecisionsTable,
      OccasionDecision,
      $$OccasionDecisionsTableFilterComposer,
      $$OccasionDecisionsTableOrderingComposer,
      $$OccasionDecisionsTableAnnotationComposer,
      $$OccasionDecisionsTableCreateCompanionBuilder,
      $$OccasionDecisionsTableUpdateCompanionBuilder,
      (
        OccasionDecision,
        BaseReferences<
          _$AppDatabase,
          $OccasionDecisionsTable,
          OccasionDecision
        >,
      ),
      OccasionDecision,
      PrefetchHooks Function()
    >;
typedef $$PhasesTableCreateCompanionBuilder = PhasesCompanion Function({
  Value<int> id,
  required String name,
  required DateTime beginsAt,
  Value<DateTime?> endsAt,
  required String anchor,
  required DateTime createdAt,
});
typedef $$PhasesTableUpdateCompanionBuilder = PhasesCompanion Function({
  Value<int> id,
  Value<String> name,
  Value<DateTime> beginsAt,
  Value<DateTime?> endsAt,
  Value<String> anchor,
  Value<DateTime> createdAt,
});

final class $$PhasesTableReferences
    extends BaseReferences<_$AppDatabase, $PhasesTable, Phase> {
  $$PhasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$PhaseAssignmentsTable, List<PhaseAssignment>>
  _phaseAssignmentsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.phaseAssignments,
    aliasName: 'phases__id__phase_assignments__phase_id',
  );

  $$PhaseAssignmentsTableProcessedTableManager get phaseAssignmentsRefs {
    final manager = $$PhaseAssignmentsTableTableManager(
      $_db,
      $_db.phaseAssignments,
    ).filter((f) => f.phaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _phaseAssignmentsRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PhasesTableFilterComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get beginsAt => $composableBuilder(
    column: $table.beginsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> phaseAssignmentsRefs(
    Expression<bool> Function($$PhaseAssignmentsTableFilterComposer f) f,
  ) {
    final $$PhaseAssignmentsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phaseAssignments,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhaseAssignmentsTableFilterComposer(
            $db: $db,
            $table: $db.phaseAssignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhasesTableOrderingComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get beginsAt => $composableBuilder(
    column: $table.beginsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhasesTable> {
  $$PhasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get beginsAt =>
      $composableBuilder(column: $table.beginsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> phaseAssignmentsRefs<T extends Object>(
    Expression<T> Function($$PhaseAssignmentsTableAnnotationComposer a) f,
  ) {
    final $$PhaseAssignmentsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.phaseAssignments,
      getReferencedColumn: (t) => t.phaseId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhaseAssignmentsTableAnnotationComposer(
            $db: $db,
            $table: $db.phaseAssignments,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PhasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhasesTable,
          Phase,
          $$PhasesTableFilterComposer,
          $$PhasesTableOrderingComposer,
          $$PhasesTableAnnotationComposer,
          $$PhasesTableCreateCompanionBuilder,
          $$PhasesTableUpdateCompanionBuilder,
          (Phase, $$PhasesTableReferences),
          Phase,
          PrefetchHooks Function({bool phaseAssignmentsRefs})
        > {
  $$PhasesTableTableManager(_$AppDatabase db, $PhasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> beginsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String> anchor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => PhasesCompanion(
                id: id,
                name: name,
                beginsAt: beginsAt,
                endsAt: endsAt,
                anchor: anchor,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required String name,
                required DateTime beginsAt,
                Value<DateTime?> endsAt = const Value.absent(),
                required String anchor,
                required DateTime createdAt,
              }) => PhasesCompanion.insert(
                id: id,
                name: name,
                beginsAt: beginsAt,
                endsAt: endsAt,
                anchor: anchor,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhasesTable, Phase>(table),
                  $$PhasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({phaseAssignmentsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (phaseAssignmentsRefs) db.phaseAssignments,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (phaseAssignmentsRefs)
                    await $_getPrefetchedData<
                      Phase,
                      $PhasesTable,
                      PhaseAssignment
                    >(
                      currentTable: table,
                      referencedTable: $$PhasesTableReferences
                          ._phaseAssignmentsRefsTable(db),
                      managerFromTypedResult: (p0) => $$PhasesTableReferences(
                        db,
                        table,
                        p0,
                      ).phaseAssignmentsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.phaseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$PhasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhasesTable,
      Phase,
      $$PhasesTableFilterComposer,
      $$PhasesTableOrderingComposer,
      $$PhasesTableAnnotationComposer,
      $$PhasesTableCreateCompanionBuilder,
      $$PhasesTableUpdateCompanionBuilder,
      (Phase, $$PhasesTableReferences),
      Phase,
      PrefetchHooks Function({bool phaseAssignmentsRefs})
    >;
typedef $$PhaseAssignmentsTableCreateCompanionBuilder =
    PhaseAssignmentsCompanion Function({
      Value<int> id,
      required int userSlot,
      required int deviceSequence,
      Value<int?> phaseId,
      required DateTime decidedAt,
    });
typedef $$PhaseAssignmentsTableUpdateCompanionBuilder =
    PhaseAssignmentsCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<int?> phaseId,
      Value<DateTime> decidedAt,
    });

final class $$PhaseAssignmentsTableReferences
    extends
        BaseReferences<_$AppDatabase, $PhaseAssignmentsTable, PhaseAssignment> {
  $$PhaseAssignmentsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PhasesTable _phaseIdTable(_$AppDatabase db) =>
      db.phases.createAlias('phase_assignments__phase_id__phases__id');

  $$PhasesTableProcessedTableManager? get phaseId {
    final $_column = $_itemColumn<int>('phase_id');
    if ($_column == null) return null;
    final manager = $$PhasesTableTableManager(
      $_db,
      $_db.phases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhaseAssignmentsTableFilterComposer
    extends Composer<_$AppDatabase, $PhaseAssignmentsTable> {
  $$PhaseAssignmentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PhasesTableFilterComposer get phaseId {
    final $$PhasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableFilterComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseAssignmentsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhaseAssignmentsTable> {
  $$PhaseAssignmentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PhasesTableOrderingComposer get phaseId {
    final $$PhasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableOrderingComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseAssignmentsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhaseAssignmentsTable> {
  $$PhaseAssignmentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  $$PhasesTableAnnotationComposer get phaseId {
    final $$PhasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.phases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PhasesTableAnnotationComposer(
            $db: $db,
            $table: $db.phases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseAssignmentsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhaseAssignmentsTable,
          PhaseAssignment,
          $$PhaseAssignmentsTableFilterComposer,
          $$PhaseAssignmentsTableOrderingComposer,
          $$PhaseAssignmentsTableAnnotationComposer,
          $$PhaseAssignmentsTableCreateCompanionBuilder,
          $$PhaseAssignmentsTableUpdateCompanionBuilder,
          (PhaseAssignment, $$PhaseAssignmentsTableReferences),
          PhaseAssignment,
          PrefetchHooks Function({bool phaseId})
        > {
  $$PhaseAssignmentsTableTableManager(
    _$AppDatabase db,
    $PhaseAssignmentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhaseAssignmentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhaseAssignmentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhaseAssignmentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<int?> phaseId = const Value.absent(),
                Value<DateTime> decidedAt = const Value.absent(),
              }) => PhaseAssignmentsCompanion(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                phaseId: phaseId,
                decidedAt: decidedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                required int deviceSequence,
                Value<int?> phaseId = const Value.absent(),
                required DateTime decidedAt,
              }) => PhaseAssignmentsCompanion.insert(
                id: id,
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                phaseId: phaseId,
                decidedAt: decidedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhaseAssignmentsTable, PhaseAssignment>(table),
                  $$PhaseAssignmentsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({phaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (phaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.phaseId,
                        referencedTable: $$PhaseAssignmentsTableReferences
                            ._phaseIdTable(db),
                        referencedColumn: $$PhaseAssignmentsTableReferences
                            ._phaseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhaseAssignmentsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhaseAssignmentsTable,
      PhaseAssignment,
      $$PhaseAssignmentsTableFilterComposer,
      $$PhaseAssignmentsTableOrderingComposer,
      $$PhaseAssignmentsTableAnnotationComposer,
      $$PhaseAssignmentsTableCreateCompanionBuilder,
      $$PhaseAssignmentsTableUpdateCompanionBuilder,
      (PhaseAssignment, $$PhaseAssignmentsTableReferences),
      PhaseAssignment,
      PrefetchHooks Function({bool phaseId})
    >;
typedef $$MeasurementNotesTableCreateCompanionBuilder =
    MeasurementNotesCompanion Function({
      required int userSlot,
      required int deviceSequence,
      required String body,
      required DateTime updatedAt,
      Value<int> rowid,
    });
typedef $$MeasurementNotesTableUpdateCompanionBuilder =
    MeasurementNotesCompanion Function({
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<String> body,
      Value<DateTime> updatedAt,
      Value<int> rowid,
    });

class $$MeasurementNotesTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementNotesTable> {
  $$MeasurementNotesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MeasurementNotesTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementNotesTable> {
  $$MeasurementNotesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementNotesTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementNotesTable> {
  $$MeasurementNotesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$MeasurementNotesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementNotesTable,
          MeasurementNote,
          $$MeasurementNotesTableFilterComposer,
          $$MeasurementNotesTableOrderingComposer,
          $$MeasurementNotesTableAnnotationComposer,
          $$MeasurementNotesTableCreateCompanionBuilder,
          $$MeasurementNotesTableUpdateCompanionBuilder,
          (
            MeasurementNote,
            BaseReferences<
              _$AppDatabase,
              $MeasurementNotesTable,
              MeasurementNote
            >,
          ),
          MeasurementNote,
          PrefetchHooks Function()
        > {
  $$MeasurementNotesTableTableManager(
    _$AppDatabase db,
    $MeasurementNotesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementNotesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementNotesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementNotesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementNotesCompanion(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                body: body,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userSlot,
                required int deviceSequence,
                required String body,
                required DateTime updatedAt,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementNotesCompanion.insert(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                body: body,
                updatedAt: updatedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementNotesTable, MeasurementNote>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $MeasurementNotesTable,
                    MeasurementNote
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MeasurementNotesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementNotesTable,
      MeasurementNote,
      $$MeasurementNotesTableFilterComposer,
      $$MeasurementNotesTableOrderingComposer,
      $$MeasurementNotesTableAnnotationComposer,
      $$MeasurementNotesTableCreateCompanionBuilder,
      $$MeasurementNotesTableUpdateCompanionBuilder,
      (
        MeasurementNote,
        BaseReferences<_$AppDatabase, $MeasurementNotesTable, MeasurementNote>,
      ),
      MeasurementNote,
      PrefetchHooks Function()
    >;
typedef $$MeasurementTagsTableCreateCompanionBuilder =
    MeasurementTagsCompanion Function({
      Value<int> id,
      required int userSlot,
      required String name,
      required String normalizedName,
    });
typedef $$MeasurementTagsTableUpdateCompanionBuilder =
    MeasurementTagsCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<String> name,
      Value<String> normalizedName,
    });

final class $$MeasurementTagsTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementTagsTable, MeasurementTag> {
  $$MeasurementTagsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<
    $MeasurementTagLinksTable,
    List<MeasurementTagLink>
  >
  _measurementTagLinksRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.measurementTagLinks,
        aliasName: 'measurement_tags__id__measurement_tag_links__tag_id',
      );

  $$MeasurementTagLinksTableProcessedTableManager get measurementTagLinksRefs {
    final manager = $$MeasurementTagLinksTableTableManager(
      $_db,
      $_db.measurementTagLinks,
    ).filter((f) => f.tagId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _measurementTagLinksRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementTagsTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementTagsTable> {
  $$MeasurementTagsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> measurementTagLinksRefs(
    Expression<bool> Function($$MeasurementTagLinksTableFilterComposer f) f,
  ) {
    final $$MeasurementTagLinksTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.measurementTagLinks,
      getReferencedColumn: (t) => t.tagId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTagLinksTableFilterComposer(
            $db: $db,
            $table: $db.measurementTagLinks,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementTagsTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementTagsTable> {
  $$MeasurementTagsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementTagsTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementTagsTable> {
  $$MeasurementTagsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get normalizedName => $composableBuilder(
    column: $table.normalizedName,
    builder: (column) => column,
  );

  Expression<T> measurementTagLinksRefs<T extends Object>(
    Expression<T> Function($$MeasurementTagLinksTableAnnotationComposer a) f,
  ) {
    final $$MeasurementTagLinksTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.measurementTagLinks,
          getReferencedColumn: (t) => t.tagId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$MeasurementTagLinksTableAnnotationComposer(
                $db: $db,
                $table: $db.measurementTagLinks,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$MeasurementTagsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementTagsTable,
          MeasurementTag,
          $$MeasurementTagsTableFilterComposer,
          $$MeasurementTagsTableOrderingComposer,
          $$MeasurementTagsTableAnnotationComposer,
          $$MeasurementTagsTableCreateCompanionBuilder,
          $$MeasurementTagsTableUpdateCompanionBuilder,
          (MeasurementTag, $$MeasurementTagsTableReferences),
          MeasurementTag,
          PrefetchHooks Function({bool measurementTagLinksRefs})
        > {
  $$MeasurementTagsTableTableManager(
    _$AppDatabase db,
    $MeasurementTagsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementTagsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementTagsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementTagsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> normalizedName = const Value.absent(),
              }) => MeasurementTagsCompanion(
                id: id,
                userSlot: userSlot,
                name: name,
                normalizedName: normalizedName,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                required String name,
                required String normalizedName,
              }) => MeasurementTagsCompanion.insert(
                id: id,
                userSlot: userSlot,
                name: name,
                normalizedName: normalizedName,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementTagsTable, MeasurementTag>(table),
                  $$MeasurementTagsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({measurementTagLinksRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (measurementTagLinksRefs) db.measurementTagLinks,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (measurementTagLinksRefs)
                    await $_getPrefetchedData<
                      MeasurementTag,
                      $MeasurementTagsTable,
                      MeasurementTagLink
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementTagsTableReferences
                          ._measurementTagLinksRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementTagsTableReferences(
                            db,
                            table,
                            p0,
                          ).measurementTagLinksRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.tagId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementTagsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementTagsTable,
      MeasurementTag,
      $$MeasurementTagsTableFilterComposer,
      $$MeasurementTagsTableOrderingComposer,
      $$MeasurementTagsTableAnnotationComposer,
      $$MeasurementTagsTableCreateCompanionBuilder,
      $$MeasurementTagsTableUpdateCompanionBuilder,
      (MeasurementTag, $$MeasurementTagsTableReferences),
      MeasurementTag,
      PrefetchHooks Function({bool measurementTagLinksRefs})
    >;
typedef $$MeasurementTagLinksTableCreateCompanionBuilder =
    MeasurementTagLinksCompanion Function({
      required int userSlot,
      required int deviceSequence,
      required int tagId,
      Value<int> rowid,
    });
typedef $$MeasurementTagLinksTableUpdateCompanionBuilder =
    MeasurementTagLinksCompanion Function({
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<int> tagId,
      Value<int> rowid,
    });

final class $$MeasurementTagLinksTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $MeasurementTagLinksTable,
          MeasurementTagLink
        > {
  $$MeasurementTagLinksTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementTagsTable _tagIdTable(_$AppDatabase db) => db
      .measurementTags
      .createAlias('measurement_tag_links__tag_id__measurement_tags__id');

  $$MeasurementTagsTableProcessedTableManager get tagId {
    final $_column = $_itemColumn<int>('tag_id')!;

    final manager = $$MeasurementTagsTableTableManager(
      $_db,
      $_db.measurementTags,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_tagIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$MeasurementTagLinksTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementTagLinksTable> {
  $$MeasurementTagLinksTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementTagsTableFilterComposer get tagId {
    final $$MeasurementTagsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.measurementTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTagsTableFilterComposer(
            $db: $db,
            $table: $db.measurementTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementTagLinksTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementTagLinksTable> {
  $$MeasurementTagLinksTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementTagsTableOrderingComposer get tagId {
    final $$MeasurementTagsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.measurementTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTagsTableOrderingComposer(
            $db: $db,
            $table: $db.measurementTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementTagLinksTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementTagLinksTable> {
  $$MeasurementTagLinksTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  $$MeasurementTagsTableAnnotationComposer get tagId {
    final $$MeasurementTagsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.tagId,
      referencedTable: $db.measurementTags,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementTagsTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementTags,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$MeasurementTagLinksTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementTagLinksTable,
          MeasurementTagLink,
          $$MeasurementTagLinksTableFilterComposer,
          $$MeasurementTagLinksTableOrderingComposer,
          $$MeasurementTagLinksTableAnnotationComposer,
          $$MeasurementTagLinksTableCreateCompanionBuilder,
          $$MeasurementTagLinksTableUpdateCompanionBuilder,
          (MeasurementTagLink, $$MeasurementTagLinksTableReferences),
          MeasurementTagLink,
          PrefetchHooks Function({bool tagId})
        > {
  $$MeasurementTagLinksTableTableManager(
    _$AppDatabase db,
    $MeasurementTagLinksTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementTagLinksTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementTagLinksTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MeasurementTagLinksTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<int> tagId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MeasurementTagLinksCompanion(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                tagId: tagId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userSlot,
                required int deviceSequence,
                required int tagId,
                Value<int> rowid = const Value.absent(),
              }) => MeasurementTagLinksCompanion.insert(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                tagId: tagId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementTagLinksTable, MeasurementTagLink>(
                    table,
                  ),
                  $$MeasurementTagLinksTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({tagId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (tagId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.tagId,
                        referencedTable: $$MeasurementTagLinksTableReferences
                            ._tagIdTable(db),
                        referencedColumn: $$MeasurementTagLinksTableReferences
                            ._tagIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementTagLinksTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementTagLinksTable,
      MeasurementTagLink,
      $$MeasurementTagLinksTableFilterComposer,
      $$MeasurementTagLinksTableOrderingComposer,
      $$MeasurementTagLinksTableAnnotationComposer,
      $$MeasurementTagLinksTableCreateCompanionBuilder,
      $$MeasurementTagLinksTableUpdateCompanionBuilder,
      (MeasurementTagLink, $$MeasurementTagLinksTableReferences),
      MeasurementTagLink,
      PrefetchHooks Function({bool tagId})
    >;
typedef $$ScopedPhasesTableCreateCompanionBuilder =
    ScopedPhasesCompanion Function({
      Value<int> id,
      required int userSlot,
      Value<int?> legacyId,
      required String name,
      required DateTime beginsAt,
      Value<DateTime?> endsAt,
      required String anchor,
      required DateTime createdAt,
    });
typedef $$ScopedPhasesTableUpdateCompanionBuilder =
    ScopedPhasesCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<int?> legacyId,
      Value<String> name,
      Value<DateTime> beginsAt,
      Value<DateTime?> endsAt,
      Value<String> anchor,
      Value<DateTime> createdAt,
    });

final class $$ScopedPhasesTableReferences
    extends BaseReferences<_$AppDatabase, $ScopedPhasesTable, ScopedPhase> {
  $$ScopedPhasesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<
    $PhaseSelectionMembersTable,
    List<PhaseSelectionMember>
  >
  _phaseSelectionMembersRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.phaseSelectionMembers,
        aliasName: 'scoped_phases__id__phase_selection_members__phase_id',
      );

  $$PhaseSelectionMembersTableProcessedTableManager
  get phaseSelectionMembersRefs {
    final manager = $$PhaseSelectionMembersTableTableManager(
      $_db,
      $_db.phaseSelectionMembers,
    ).filter((f) => f.phaseId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _phaseSelectionMembersRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$ScopedPhasesTableFilterComposer
    extends Composer<_$AppDatabase, $ScopedPhasesTable> {
  $$ScopedPhasesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get beginsAt => $composableBuilder(
    column: $table.beginsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> phaseSelectionMembersRefs(
    Expression<bool> Function($$PhaseSelectionMembersTableFilterComposer f) f,
  ) {
    final $$PhaseSelectionMembersTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.phaseSelectionMembers,
          getReferencedColumn: (t) => t.phaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PhaseSelectionMembersTableFilterComposer(
                $db: $db,
                $table: $db.phaseSelectionMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScopedPhasesTableOrderingComposer
    extends Composer<_$AppDatabase, $ScopedPhasesTable> {
  $$ScopedPhasesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get legacyId => $composableBuilder(
    column: $table.legacyId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get beginsAt => $composableBuilder(
    column: $table.beginsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endsAt => $composableBuilder(
    column: $table.endsAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get anchor => $composableBuilder(
    column: $table.anchor,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ScopedPhasesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ScopedPhasesTable> {
  $$ScopedPhasesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get legacyId =>
      $composableBuilder(column: $table.legacyId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<DateTime> get beginsAt =>
      $composableBuilder(column: $table.beginsAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endsAt =>
      $composableBuilder(column: $table.endsAt, builder: (column) => column);

  GeneratedColumn<String> get anchor =>
      $composableBuilder(column: $table.anchor, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> phaseSelectionMembersRefs<T extends Object>(
    Expression<T> Function($$PhaseSelectionMembersTableAnnotationComposer a) f,
  ) {
    final $$PhaseSelectionMembersTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.id,
          referencedTable: $db.phaseSelectionMembers,
          getReferencedColumn: (t) => t.phaseId,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PhaseSelectionMembersTableAnnotationComposer(
                $db: $db,
                $table: $db.phaseSelectionMembers,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$ScopedPhasesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ScopedPhasesTable,
          ScopedPhase,
          $$ScopedPhasesTableFilterComposer,
          $$ScopedPhasesTableOrderingComposer,
          $$ScopedPhasesTableAnnotationComposer,
          $$ScopedPhasesTableCreateCompanionBuilder,
          $$ScopedPhasesTableUpdateCompanionBuilder,
          (ScopedPhase, $$ScopedPhasesTableReferences),
          ScopedPhase,
          PrefetchHooks Function({bool phaseSelectionMembersRefs})
        > {
  $$ScopedPhasesTableTableManager(_$AppDatabase db, $ScopedPhasesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ScopedPhasesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ScopedPhasesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ScopedPhasesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<int?> legacyId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<DateTime> beginsAt = const Value.absent(),
                Value<DateTime?> endsAt = const Value.absent(),
                Value<String> anchor = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
              }) => ScopedPhasesCompanion(
                id: id,
                userSlot: userSlot,
                legacyId: legacyId,
                name: name,
                beginsAt: beginsAt,
                endsAt: endsAt,
                anchor: anchor,
                createdAt: createdAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                Value<int?> legacyId = const Value.absent(),
                required String name,
                required DateTime beginsAt,
                Value<DateTime?> endsAt = const Value.absent(),
                required String anchor,
                required DateTime createdAt,
              }) => ScopedPhasesCompanion.insert(
                id: id,
                userSlot: userSlot,
                legacyId: legacyId,
                name: name,
                beginsAt: beginsAt,
                endsAt: endsAt,
                anchor: anchor,
                createdAt: createdAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ScopedPhasesTable, ScopedPhase>(table),
                  $$ScopedPhasesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({phaseSelectionMembersRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (phaseSelectionMembersRefs) db.phaseSelectionMembers,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (phaseSelectionMembersRefs)
                    await $_getPrefetchedData<
                      ScopedPhase,
                      $ScopedPhasesTable,
                      PhaseSelectionMember
                    >(
                      currentTable: table,
                      referencedTable: $$ScopedPhasesTableReferences
                          ._phaseSelectionMembersRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$ScopedPhasesTableReferences(
                            db,
                            table,
                            p0,
                          ).phaseSelectionMembersRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.phaseId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$ScopedPhasesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ScopedPhasesTable,
      ScopedPhase,
      $$ScopedPhasesTableFilterComposer,
      $$ScopedPhasesTableOrderingComposer,
      $$ScopedPhasesTableAnnotationComposer,
      $$ScopedPhasesTableCreateCompanionBuilder,
      $$ScopedPhasesTableUpdateCompanionBuilder,
      (ScopedPhase, $$ScopedPhasesTableReferences),
      ScopedPhase,
      PrefetchHooks Function({bool phaseSelectionMembersRefs})
    >;
typedef $$PhaseSelectionsTableCreateCompanionBuilder =
    PhaseSelectionsCompanion Function({
      required int userSlot,
      required int deviceSequence,
      required DateTime decidedAt,
      Value<int> rowid,
    });
typedef $$PhaseSelectionsTableUpdateCompanionBuilder =
    PhaseSelectionsCompanion Function({
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<DateTime> decidedAt,
      Value<int> rowid,
    });

class $$PhaseSelectionsTableFilterComposer
    extends Composer<_$AppDatabase, $PhaseSelectionsTable> {
  $$PhaseSelectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PhaseSelectionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PhaseSelectionsTable> {
  $$PhaseSelectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PhaseSelectionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhaseSelectionsTable> {
  $$PhaseSelectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);
}

class $$PhaseSelectionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhaseSelectionsTable,
          PhaseSelection,
          $$PhaseSelectionsTableFilterComposer,
          $$PhaseSelectionsTableOrderingComposer,
          $$PhaseSelectionsTableAnnotationComposer,
          $$PhaseSelectionsTableCreateCompanionBuilder,
          $$PhaseSelectionsTableUpdateCompanionBuilder,
          (
            PhaseSelection,
            BaseReferences<
              _$AppDatabase,
              $PhaseSelectionsTable,
              PhaseSelection
            >,
          ),
          PhaseSelection,
          PrefetchHooks Function()
        > {
  $$PhaseSelectionsTableTableManager(
    _$AppDatabase db,
    $PhaseSelectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhaseSelectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PhaseSelectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PhaseSelectionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<DateTime> decidedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhaseSelectionsCompanion(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userSlot,
                required int deviceSequence,
                required DateTime decidedAt,
                Value<int> rowid = const Value.absent(),
              }) => PhaseSelectionsCompanion.insert(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PhaseSelectionsTable, PhaseSelection>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PhaseSelectionsTable,
                    PhaseSelection
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PhaseSelectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhaseSelectionsTable,
      PhaseSelection,
      $$PhaseSelectionsTableFilterComposer,
      $$PhaseSelectionsTableOrderingComposer,
      $$PhaseSelectionsTableAnnotationComposer,
      $$PhaseSelectionsTableCreateCompanionBuilder,
      $$PhaseSelectionsTableUpdateCompanionBuilder,
      (
        PhaseSelection,
        BaseReferences<_$AppDatabase, $PhaseSelectionsTable, PhaseSelection>,
      ),
      PhaseSelection,
      PrefetchHooks Function()
    >;
typedef $$PhaseSelectionMembersTableCreateCompanionBuilder =
    PhaseSelectionMembersCompanion Function({
      required int userSlot,
      required int deviceSequence,
      required int phaseId,
      Value<int> rowid,
    });
typedef $$PhaseSelectionMembersTableUpdateCompanionBuilder =
    PhaseSelectionMembersCompanion Function({
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<int> phaseId,
      Value<int> rowid,
    });

final class $$PhaseSelectionMembersTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PhaseSelectionMembersTable,
          PhaseSelectionMember
        > {
  $$PhaseSelectionMembersTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $ScopedPhasesTable _phaseIdTable(_$AppDatabase db) => db.scopedPhases
      .createAlias('phase_selection_members__phase_id__scoped_phases__id');

  $$ScopedPhasesTableProcessedTableManager get phaseId {
    final $_column = $_itemColumn<int>('phase_id')!;

    final manager = $$ScopedPhasesTableTableManager(
      $_db,
      $_db.scopedPhases,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_phaseIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PhaseSelectionMembersTableFilterComposer
    extends Composer<_$AppDatabase, $PhaseSelectionMembersTable> {
  $$PhaseSelectionMembersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  $$ScopedPhasesTableFilterComposer get phaseId {
    final $$ScopedPhasesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.scopedPhases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScopedPhasesTableFilterComposer(
            $db: $db,
            $table: $db.scopedPhases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseSelectionMembersTableOrderingComposer
    extends Composer<_$AppDatabase, $PhaseSelectionMembersTable> {
  $$PhaseSelectionMembersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  $$ScopedPhasesTableOrderingComposer get phaseId {
    final $$ScopedPhasesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.scopedPhases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScopedPhasesTableOrderingComposer(
            $db: $db,
            $table: $db.scopedPhases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseSelectionMembersTableAnnotationComposer
    extends Composer<_$AppDatabase, $PhaseSelectionMembersTable> {
  $$PhaseSelectionMembersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  $$ScopedPhasesTableAnnotationComposer get phaseId {
    final $$ScopedPhasesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.phaseId,
      referencedTable: $db.scopedPhases,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$ScopedPhasesTableAnnotationComposer(
            $db: $db,
            $table: $db.scopedPhases,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PhaseSelectionMembersTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PhaseSelectionMembersTable,
          PhaseSelectionMember,
          $$PhaseSelectionMembersTableFilterComposer,
          $$PhaseSelectionMembersTableOrderingComposer,
          $$PhaseSelectionMembersTableAnnotationComposer,
          $$PhaseSelectionMembersTableCreateCompanionBuilder,
          $$PhaseSelectionMembersTableUpdateCompanionBuilder,
          (PhaseSelectionMember, $$PhaseSelectionMembersTableReferences),
          PhaseSelectionMember,
          PrefetchHooks Function({bool phaseId})
        > {
  $$PhaseSelectionMembersTableTableManager(
    _$AppDatabase db,
    $PhaseSelectionMembersTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PhaseSelectionMembersTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PhaseSelectionMembersTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PhaseSelectionMembersTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<int> phaseId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PhaseSelectionMembersCompanion(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                phaseId: phaseId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userSlot,
                required int deviceSequence,
                required int phaseId,
                Value<int> rowid = const Value.absent(),
              }) => PhaseSelectionMembersCompanion.insert(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                phaseId: phaseId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PhaseSelectionMembersTable,
                    PhaseSelectionMember
                  >(table),
                  $$PhaseSelectionMembersTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({phaseId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (phaseId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.phaseId,
                        referencedTable: $$PhaseSelectionMembersTableReferences
                            ._phaseIdTable(db),
                        referencedColumn: $$PhaseSelectionMembersTableReferences
                            ._phaseIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PhaseSelectionMembersTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PhaseSelectionMembersTable,
      PhaseSelectionMember,
      $$PhaseSelectionMembersTableFilterComposer,
      $$PhaseSelectionMembersTableOrderingComposer,
      $$PhaseSelectionMembersTableAnnotationComposer,
      $$PhaseSelectionMembersTableCreateCompanionBuilder,
      $$PhaseSelectionMembersTableUpdateCompanionBuilder,
      (PhaseSelectionMember, $$PhaseSelectionMembersTableReferences),
      PhaseSelectionMember,
      PrefetchHooks Function({bool phaseId})
    >;
typedef $$MeasurementPlansTableCreateCompanionBuilder =
    MeasurementPlansCompanion Function({
      Value<int> id,
      required int userSlot,
      required DateTime startedAt,
      Value<DateTime?> endedAt,
    });
typedef $$MeasurementPlansTableUpdateCompanionBuilder =
    MeasurementPlansCompanion Function({
      Value<int> id,
      Value<int> userSlot,
      Value<DateTime> startedAt,
      Value<DateTime?> endedAt,
    });

final class $$MeasurementPlansTableReferences
    extends
        BaseReferences<_$AppDatabase, $MeasurementPlansTable, MeasurementPlan> {
  $$MeasurementPlansTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static MultiTypedResultKey<$PlanRevisionsTable, List<PlanRevision>>
  _planRevisionsRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planRevisions,
    aliasName: 'measurement_plans__id__plan_revisions__plan_id',
  );

  $$PlanRevisionsTableProcessedTableManager get planRevisionsRefs {
    final manager = $$PlanRevisionsTableTableManager(
      $_db,
      $_db.planRevisions,
    ).filter((f) => f.planId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planRevisionsRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$MeasurementPlansTableFilterComposer
    extends Composer<_$AppDatabase, $MeasurementPlansTable> {
  $$MeasurementPlansTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnFilters(column),
  );

  Expression<bool> planRevisionsRefs(
    Expression<bool> Function($$PlanRevisionsTableFilterComposer f) f,
  ) {
    final $$PlanRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementPlansTableOrderingComposer
    extends Composer<_$AppDatabase, $MeasurementPlansTable> {
  $$MeasurementPlansTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get endedAt => $composableBuilder(
    column: $table.endedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MeasurementPlansTableAnnotationComposer
    extends Composer<_$AppDatabase, $MeasurementPlansTable> {
  $$MeasurementPlansTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get endedAt =>
      $composableBuilder(column: $table.endedAt, builder: (column) => column);

  Expression<T> planRevisionsRefs<T extends Object>(
    Expression<T> Function($$PlanRevisionsTableAnnotationComposer a) f,
  ) {
    final $$PlanRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.planId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$MeasurementPlansTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $MeasurementPlansTable,
          MeasurementPlan,
          $$MeasurementPlansTableFilterComposer,
          $$MeasurementPlansTableOrderingComposer,
          $$MeasurementPlansTableAnnotationComposer,
          $$MeasurementPlansTableCreateCompanionBuilder,
          $$MeasurementPlansTableUpdateCompanionBuilder,
          (MeasurementPlan, $$MeasurementPlansTableReferences),
          MeasurementPlan,
          PrefetchHooks Function({bool planRevisionsRefs})
        > {
  $$MeasurementPlansTableTableManager(
    _$AppDatabase db,
    $MeasurementPlansTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MeasurementPlansTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MeasurementPlansTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MeasurementPlansTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> userSlot = const Value.absent(),
                Value<DateTime> startedAt = const Value.absent(),
                Value<DateTime?> endedAt = const Value.absent(),
              }) => MeasurementPlansCompanion(
                id: id,
                userSlot: userSlot,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int userSlot,
                required DateTime startedAt,
                Value<DateTime?> endedAt = const Value.absent(),
              }) => MeasurementPlansCompanion.insert(
                id: id,
                userSlot: userSlot,
                startedAt: startedAt,
                endedAt: endedAt,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$MeasurementPlansTable, MeasurementPlan>(table),
                  $$MeasurementPlansTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({planRevisionsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [
                if (planRevisionsRefs) db.planRevisions,
              ],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (planRevisionsRefs)
                    await $_getPrefetchedData<
                      MeasurementPlan,
                      $MeasurementPlansTable,
                      PlanRevision
                    >(
                      currentTable: table,
                      referencedTable: $$MeasurementPlansTableReferences
                          ._planRevisionsRefsTable(db),
                      managerFromTypedResult: (p0) =>
                          $$MeasurementPlansTableReferences(
                            db,
                            table,
                            p0,
                          ).planRevisionsRefs,
                      referencedItemsForCurrentItem: (item, referencedItems) =>
                          referencedItems.where((e) => e.planId == item.id),
                      typedResults: items,
                    ),
                ];
              },
            );
          },
        ),
      );
}

typedef $$MeasurementPlansTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $MeasurementPlansTable,
      MeasurementPlan,
      $$MeasurementPlansTableFilterComposer,
      $$MeasurementPlansTableOrderingComposer,
      $$MeasurementPlansTableAnnotationComposer,
      $$MeasurementPlansTableCreateCompanionBuilder,
      $$MeasurementPlansTableUpdateCompanionBuilder,
      (MeasurementPlan, $$MeasurementPlansTableReferences),
      MeasurementPlan,
      PrefetchHooks Function({bool planRevisionsRefs})
    >;
typedef $$PlanRevisionsTableCreateCompanionBuilder =
    PlanRevisionsCompanion Function({
      Value<int> id,
      required int planId,
      required DateTime effectiveAt,
      required bool enabled,
    });
typedef $$PlanRevisionsTableUpdateCompanionBuilder =
    PlanRevisionsCompanion Function({
      Value<int> id,
      Value<int> planId,
      Value<DateTime> effectiveAt,
      Value<bool> enabled,
    });

final class $$PlanRevisionsTableReferences
    extends BaseReferences<_$AppDatabase, $PlanRevisionsTable, PlanRevision> {
  $$PlanRevisionsTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $MeasurementPlansTable _planIdTable(_$AppDatabase db) => db
      .measurementPlans
      .createAlias('plan_revisions__plan_id__measurement_plans__id');

  $$MeasurementPlansTableProcessedTableManager get planId {
    final $_column = $_itemColumn<int>('plan_id')!;

    final manager = $$MeasurementPlansTableTableManager(
      $_db,
      $_db.measurementPlans,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_planIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<$PlanTimesTable, List<PlanTime>>
  _planTimesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planTimes,
    aliasName: 'plan_revisions__id__plan_times__revision_id',
  );

  $$PlanTimesTableProcessedTableManager get planTimesRefs {
    final manager = $$PlanTimesTableTableManager(
      $_db,
      $_db.planTimes,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_planTimesRefsTable($_db));
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }

  static MultiTypedResultKey<$PlanOccurrencesTable, List<PlanOccurrence>>
  _planOccurrencesRefsTable(_$AppDatabase db) => MultiTypedResultKey.fromTable(
    db.planOccurrences,
    aliasName: 'plan_revisions__id__plan_occurrences__revision_id',
  );

  $$PlanOccurrencesTableProcessedTableManager get planOccurrencesRefs {
    final manager = $$PlanOccurrencesTableTableManager(
      $_db,
      $_db.planOccurrences,
    ).filter((f) => f.revisionId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(
      _planOccurrencesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanRevisionsTableFilterComposer
    extends Composer<_$AppDatabase, $PlanRevisionsTable> {
  $$PlanRevisionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnFilters(column),
  );

  $$MeasurementPlansTableFilterComposer get planId {
    final $$MeasurementPlansTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.measurementPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementPlansTableFilterComposer(
            $db: $db,
            $table: $db.measurementPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planTimesRefs(
    Expression<bool> Function($$PlanTimesTableFilterComposer f) f,
  ) {
    final $$PlanTimesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planTimes,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanTimesTableFilterComposer(
            $db: $db,
            $table: $db.planTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<bool> planOccurrencesRefs(
    Expression<bool> Function($$PlanOccurrencesTableFilterComposer f) f,
  ) {
    final $$PlanOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planOccurrences,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.planOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanRevisionsTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanRevisionsTable> {
  $$PlanRevisionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get enabled => $composableBuilder(
    column: $table.enabled,
    builder: (column) => ColumnOrderings(column),
  );

  $$MeasurementPlansTableOrderingComposer get planId {
    final $$MeasurementPlansTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.measurementPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementPlansTableOrderingComposer(
            $db: $db,
            $table: $db.measurementPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanRevisionsTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanRevisionsTable> {
  $$PlanRevisionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get effectiveAt => $composableBuilder(
    column: $table.effectiveAt,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get enabled =>
      $composableBuilder(column: $table.enabled, builder: (column) => column);

  $$MeasurementPlansTableAnnotationComposer get planId {
    final $$MeasurementPlansTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.planId,
      referencedTable: $db.measurementPlans,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$MeasurementPlansTableAnnotationComposer(
            $db: $db,
            $table: $db.measurementPlans,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planTimesRefs<T extends Object>(
    Expression<T> Function($$PlanTimesTableAnnotationComposer a) f,
  ) {
    final $$PlanTimesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planTimes,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanTimesTableAnnotationComposer(
            $db: $db,
            $table: $db.planTimes,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }

  Expression<T> planOccurrencesRefs<T extends Object>(
    Expression<T> Function($$PlanOccurrencesTableAnnotationComposer a) f,
  ) {
    final $$PlanOccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.id,
      referencedTable: $db.planOccurrences,
      getReferencedColumn: (t) => t.revisionId,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanOccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.planOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return f(composer);
  }
}

class $$PlanRevisionsTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanRevisionsTable,
          PlanRevision,
          $$PlanRevisionsTableFilterComposer,
          $$PlanRevisionsTableOrderingComposer,
          $$PlanRevisionsTableAnnotationComposer,
          $$PlanRevisionsTableCreateCompanionBuilder,
          $$PlanRevisionsTableUpdateCompanionBuilder,
          (PlanRevision, $$PlanRevisionsTableReferences),
          PlanRevision,
          PrefetchHooks Function({
            bool planId,
            bool planTimesRefs,
            bool planOccurrencesRefs,
          })
        > {
  $$PlanRevisionsTableTableManager(_$AppDatabase db, $PlanRevisionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanRevisionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanRevisionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanRevisionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> planId = const Value.absent(),
                Value<DateTime> effectiveAt = const Value.absent(),
                Value<bool> enabled = const Value.absent(),
              }) => PlanRevisionsCompanion(
                id: id,
                planId: planId,
                effectiveAt: effectiveAt,
                enabled: enabled,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int planId,
                required DateTime effectiveAt,
                required bool enabled,
              }) => PlanRevisionsCompanion.insert(
                id: id,
                planId: planId,
                effectiveAt: effectiveAt,
                enabled: enabled,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanRevisionsTable, PlanRevision>(table),
                  $$PlanRevisionsTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({
                planId = false,
                planTimesRefs = false,
                planOccurrencesRefs = false,
              }) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planTimesRefs) db.planTimes,
                    if (planOccurrencesRefs) db.planOccurrences,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (planId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.planId,
                            referencedTable: $$PlanRevisionsTableReferences
                                ._planIdTable(db),
                            referencedColumn: $$PlanRevisionsTableReferences
                                ._planIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planTimesRefs)
                        await $_getPrefetchedData<
                          PlanRevision,
                          $PlanRevisionsTable,
                          PlanTime
                        >(
                          currentTable: table,
                          referencedTable: $$PlanRevisionsTableReferences
                              ._planTimesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).planTimesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                      if (planOccurrencesRefs)
                        await $_getPrefetchedData<
                          PlanRevision,
                          $PlanRevisionsTable,
                          PlanOccurrence
                        >(
                          currentTable: table,
                          referencedTable: $$PlanRevisionsTableReferences
                              ._planOccurrencesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanRevisionsTableReferences(
                                db,
                                table,
                                p0,
                              ).planOccurrencesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.revisionId == item.id,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlanRevisionsTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanRevisionsTable,
      PlanRevision,
      $$PlanRevisionsTableFilterComposer,
      $$PlanRevisionsTableOrderingComposer,
      $$PlanRevisionsTableAnnotationComposer,
      $$PlanRevisionsTableCreateCompanionBuilder,
      $$PlanRevisionsTableUpdateCompanionBuilder,
      (PlanRevision, $$PlanRevisionsTableReferences),
      PlanRevision,
      PrefetchHooks Function({
        bool planId,
        bool planTimesRefs,
        bool planOccurrencesRefs,
      })
    >;
typedef $$PlanTimesTableCreateCompanionBuilder = PlanTimesCompanion Function({
  Value<int> id,
  required int revisionId,
  required int minuteOfDay,
});
typedef $$PlanTimesTableUpdateCompanionBuilder = PlanTimesCompanion Function({
  Value<int> id,
  Value<int> revisionId,
  Value<int> minuteOfDay,
});

final class $$PlanTimesTableReferences
    extends BaseReferences<_$AppDatabase, $PlanTimesTable, PlanTime> {
  $$PlanTimesTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $PlanRevisionsTable _revisionIdTable(_$AppDatabase db) => db
      .planRevisions
      .createAlias('plan_times__revision_id__plan_revisions__id');

  $$PlanRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<int>('revision_id')!;

    final manager = $$PlanRevisionsTableTableManager(
      $_db,
      $_db.planRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanTimesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTimesTable> {
  $$PlanTimesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanRevisionsTableFilterComposer get revisionId {
    final $$PlanRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanTimesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTimesTable> {
  $$PlanTimesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanRevisionsTableOrderingComposer get revisionId {
    final $$PlanRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanTimesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTimesTable> {
  $$PlanTimesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => column,
  );

  $$PlanRevisionsTableAnnotationComposer get revisionId {
    final $$PlanRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanTimesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanTimesTable,
          PlanTime,
          $$PlanTimesTableFilterComposer,
          $$PlanTimesTableOrderingComposer,
          $$PlanTimesTableAnnotationComposer,
          $$PlanTimesTableCreateCompanionBuilder,
          $$PlanTimesTableUpdateCompanionBuilder,
          (PlanTime, $$PlanTimesTableReferences),
          PlanTime,
          PrefetchHooks Function({bool revisionId})
        > {
  $$PlanTimesTableTableManager(_$AppDatabase db, $PlanTimesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTimesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTimesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTimesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> revisionId = const Value.absent(),
                Value<int> minuteOfDay = const Value.absent(),
              }) => PlanTimesCompanion(
                id: id,
                revisionId: revisionId,
                minuteOfDay: minuteOfDay,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int revisionId,
                required int minuteOfDay,
              }) => PlanTimesCompanion.insert(
                id: id,
                revisionId: revisionId,
                minuteOfDay: minuteOfDay,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanTimesTable, PlanTime>(table),
                  $$PlanTimesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({revisionId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (revisionId) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.revisionId,
                        referencedTable: $$PlanTimesTableReferences
                            ._revisionIdTable(db),
                        referencedColumn: $$PlanTimesTableReferences
                            ._revisionIdTable(db)
                            .id,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanTimesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanTimesTable,
      PlanTime,
      $$PlanTimesTableFilterComposer,
      $$PlanTimesTableOrderingComposer,
      $$PlanTimesTableAnnotationComposer,
      $$PlanTimesTableCreateCompanionBuilder,
      $$PlanTimesTableUpdateCompanionBuilder,
      (PlanTime, $$PlanTimesTableReferences),
      PlanTime,
      PrefetchHooks Function({bool revisionId})
    >;
typedef $$PlanOccurrencesTableCreateCompanionBuilder =
    PlanOccurrencesCompanion Function({
      required String occurrenceKey,
      required int revisionId,
      Value<DateTime?> dueAt,
      required String localDate,
      required int minuteOfDay,
      Value<String?> zoneId,
      required bool timeAmbiguous,
      Value<int> rowid,
    });
typedef $$PlanOccurrencesTableUpdateCompanionBuilder =
    PlanOccurrencesCompanion Function({
      Value<String> occurrenceKey,
      Value<int> revisionId,
      Value<DateTime?> dueAt,
      Value<String> localDate,
      Value<int> minuteOfDay,
      Value<String?> zoneId,
      Value<bool> timeAmbiguous,
      Value<int> rowid,
    });

final class $$PlanOccurrencesTableReferences
    extends
        BaseReferences<_$AppDatabase, $PlanOccurrencesTable, PlanOccurrence> {
  $$PlanOccurrencesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlanRevisionsTable _revisionIdTable(_$AppDatabase db) => db
      .planRevisions
      .createAlias('plan_occurrences__revision_id__plan_revisions__id');

  $$PlanRevisionsTableProcessedTableManager get revisionId {
    final $_column = $_itemColumn<int>('revision_id')!;

    final manager = $$PlanRevisionsTableTableManager(
      $_db,
      $_db.planRevisions,
    ).filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_revisionIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }

  static MultiTypedResultKey<
    $PlanAssignmentOverridesTable,
    List<PlanAssignmentOverride>
  >
  _planAssignmentOverridesRefsTable(_$AppDatabase db) =>
      MultiTypedResultKey.fromTable(
        db.planAssignmentOverrides,
        aliasName: 'plan_occurrences__occurrence_key__plan_assignment_overrides__occurrence_key',
      );

  $$PlanAssignmentOverridesTableProcessedTableManager
  get planAssignmentOverridesRefs {
    final manager =
        $$PlanAssignmentOverridesTableTableManager(
          $_db,
          $_db.planAssignmentOverrides,
        ).filter(
          (f) => f.occurrenceKey.occurrenceKey.sqlEquals(
            $_itemColumn<String>('occurrence_key')!,
          ),
        );

    final cache = $_typedResult.readTableOrNull(
      _planAssignmentOverridesRefsTable($_db),
    );
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: cache),
    );
  }
}

class $$PlanOccurrencesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanOccurrencesTable> {
  $$PlanOccurrencesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get timeAmbiguous => $composableBuilder(
    column: $table.timeAmbiguous,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanRevisionsTableFilterComposer get revisionId {
    final $$PlanRevisionsTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableFilterComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<bool> planAssignmentOverridesRefs(
    Expression<bool> Function($$PlanAssignmentOverridesTableFilterComposer f) f,
  ) {
    final $$PlanAssignmentOverridesTableFilterComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.occurrenceKey,
          referencedTable: $db.planAssignmentOverrides,
          getReferencedColumn: (t) => t.occurrenceKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlanAssignmentOverridesTableFilterComposer(
                $db: $db,
                $table: $db.planAssignmentOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlanOccurrencesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanOccurrencesTable> {
  $$PlanOccurrencesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get dueAt => $composableBuilder(
    column: $table.dueAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get localDate => $composableBuilder(
    column: $table.localDate,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get zoneId => $composableBuilder(
    column: $table.zoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get timeAmbiguous => $composableBuilder(
    column: $table.timeAmbiguous,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanRevisionsTableOrderingComposer get revisionId {
    final $$PlanRevisionsTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableOrderingComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanOccurrencesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanOccurrencesTable> {
  $$PlanOccurrencesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get occurrenceKey => $composableBuilder(
    column: $table.occurrenceKey,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get dueAt =>
      $composableBuilder(column: $table.dueAt, builder: (column) => column);

  GeneratedColumn<String> get localDate =>
      $composableBuilder(column: $table.localDate, builder: (column) => column);

  GeneratedColumn<int> get minuteOfDay => $composableBuilder(
    column: $table.minuteOfDay,
    builder: (column) => column,
  );

  GeneratedColumn<String> get zoneId =>
      $composableBuilder(column: $table.zoneId, builder: (column) => column);

  GeneratedColumn<bool> get timeAmbiguous => $composableBuilder(
    column: $table.timeAmbiguous,
    builder: (column) => column,
  );

  $$PlanRevisionsTableAnnotationComposer get revisionId {
    final $$PlanRevisionsTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.revisionId,
      referencedTable: $db.planRevisions,
      getReferencedColumn: (t) => t.id,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanRevisionsTableAnnotationComposer(
            $db: $db,
            $table: $db.planRevisions,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }

  Expression<T> planAssignmentOverridesRefs<T extends Object>(
    Expression<T> Function($$PlanAssignmentOverridesTableAnnotationComposer a)
    f,
  ) {
    final $$PlanAssignmentOverridesTableAnnotationComposer composer =
        $composerBuilder(
          composer: this,
          getCurrentColumn: (t) => t.occurrenceKey,
          referencedTable: $db.planAssignmentOverrides,
          getReferencedColumn: (t) => t.occurrenceKey,
          builder:
              (
                joinBuilder, {
                $addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer,
              }) => $$PlanAssignmentOverridesTableAnnotationComposer(
                $db: $db,
                $table: $db.planAssignmentOverrides,
                $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
                joinBuilder: joinBuilder,
                $removeJoinBuilderFromRootComposer:
                    $removeJoinBuilderFromRootComposer,
              ),
        );
    return f(composer);
  }
}

class $$PlanOccurrencesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanOccurrencesTable,
          PlanOccurrence,
          $$PlanOccurrencesTableFilterComposer,
          $$PlanOccurrencesTableOrderingComposer,
          $$PlanOccurrencesTableAnnotationComposer,
          $$PlanOccurrencesTableCreateCompanionBuilder,
          $$PlanOccurrencesTableUpdateCompanionBuilder,
          (PlanOccurrence, $$PlanOccurrencesTableReferences),
          PlanOccurrence,
          PrefetchHooks Function({
            bool revisionId,
            bool planAssignmentOverridesRefs,
          })
        > {
  $$PlanOccurrencesTableTableManager(
    _$AppDatabase db,
    $PlanOccurrencesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanOccurrencesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanOccurrencesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanOccurrencesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> occurrenceKey = const Value.absent(),
                Value<int> revisionId = const Value.absent(),
                Value<DateTime?> dueAt = const Value.absent(),
                Value<String> localDate = const Value.absent(),
                Value<int> minuteOfDay = const Value.absent(),
                Value<String?> zoneId = const Value.absent(),
                Value<bool> timeAmbiguous = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanOccurrencesCompanion(
                occurrenceKey: occurrenceKey,
                revisionId: revisionId,
                dueAt: dueAt,
                localDate: localDate,
                minuteOfDay: minuteOfDay,
                zoneId: zoneId,
                timeAmbiguous: timeAmbiguous,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String occurrenceKey,
                required int revisionId,
                Value<DateTime?> dueAt = const Value.absent(),
                required String localDate,
                required int minuteOfDay,
                Value<String?> zoneId = const Value.absent(),
                required bool timeAmbiguous,
                Value<int> rowid = const Value.absent(),
              }) => PlanOccurrencesCompanion.insert(
                occurrenceKey: occurrenceKey,
                revisionId: revisionId,
                dueAt: dueAt,
                localDate: localDate,
                minuteOfDay: minuteOfDay,
                zoneId: zoneId,
                timeAmbiguous: timeAmbiguous,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanOccurrencesTable, PlanOccurrence>(table),
                  $$PlanOccurrencesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback:
              ({revisionId = false, planAssignmentOverridesRefs = false}) {
                return PrefetchHooks(
                  db: db,
                  explicitlyWatchedTables: [
                    if (planAssignmentOverridesRefs) db.planAssignmentOverrides,
                  ],
                  addJoins:
                      <
                        T extends TableManagerState<
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic,
                          dynamic
                        >
                      >(state) {
                        if (revisionId) {
                          state = state.withJoin(
                            currentTable: table,
                            currentColumn: table.revisionId,
                            referencedTable: $$PlanOccurrencesTableReferences
                                ._revisionIdTable(db),
                            referencedColumn: $$PlanOccurrencesTableReferences
                                ._revisionIdTable(db)
                                .id,
                          ) as T;
                        }

                        return state;
                      },
                  getPrefetchedDataCallback: (items) async {
                    return [
                      if (planAssignmentOverridesRefs)
                        await $_getPrefetchedData<
                          PlanOccurrence,
                          $PlanOccurrencesTable,
                          PlanAssignmentOverride
                        >(
                          currentTable: table,
                          referencedTable: $$PlanOccurrencesTableReferences
                              ._planAssignmentOverridesRefsTable(db),
                          managerFromTypedResult: (p0) =>
                              $$PlanOccurrencesTableReferences(
                                db,
                                table,
                                p0,
                              ).planAssignmentOverridesRefs,
                          referencedItemsForCurrentItem:
                              (item, referencedItems) => referencedItems.where(
                                (e) => e.occurrenceKey == item.occurrenceKey,
                              ),
                          typedResults: items,
                        ),
                    ];
                  },
                );
              },
        ),
      );
}

typedef $$PlanOccurrencesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanOccurrencesTable,
      PlanOccurrence,
      $$PlanOccurrencesTableFilterComposer,
      $$PlanOccurrencesTableOrderingComposer,
      $$PlanOccurrencesTableAnnotationComposer,
      $$PlanOccurrencesTableCreateCompanionBuilder,
      $$PlanOccurrencesTableUpdateCompanionBuilder,
      (PlanOccurrence, $$PlanOccurrencesTableReferences),
      PlanOccurrence,
      PrefetchHooks Function({
        bool revisionId,
        bool planAssignmentOverridesRefs,
      })
    >;
typedef $$PlanAssignmentOverridesTableCreateCompanionBuilder =
    PlanAssignmentOverridesCompanion Function({
      required int userSlot,
      required int deviceSequence,
      Value<String?> occurrenceKey,
      required DateTime decidedAt,
      Value<int> rowid,
    });
typedef $$PlanAssignmentOverridesTableUpdateCompanionBuilder =
    PlanAssignmentOverridesCompanion Function({
      Value<int> userSlot,
      Value<int> deviceSequence,
      Value<String?> occurrenceKey,
      Value<DateTime> decidedAt,
      Value<int> rowid,
    });

final class $$PlanAssignmentOverridesTableReferences
    extends
        BaseReferences<
          _$AppDatabase,
          $PlanAssignmentOverridesTable,
          PlanAssignmentOverride
        > {
  $$PlanAssignmentOverridesTableReferences(
    super.$_db,
    super.$_table,
    super.$_typedResult,
  );

  static $PlanOccurrencesTable _occurrenceKeyTable(_$AppDatabase db) =>
      db.planOccurrences.createAlias(
        'plan_assignment_overrides__occurrence_key__plan_occurrences__occurrence_key',
      );

  $$PlanOccurrencesTableProcessedTableManager? get occurrenceKey {
    final $_column = $_itemColumn<String>('occurrence_key');
    if ($_column == null) return null;
    final manager = $$PlanOccurrencesTableTableManager(
      $_db,
      $_db.planOccurrences,
    ).filter((f) => f.occurrenceKey.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_occurrenceKeyTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
      manager.$state.copyWith(prefetchedData: [item]),
    );
  }
}

class $$PlanAssignmentOverridesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanAssignmentOverridesTable> {
  $$PlanAssignmentOverridesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnFilters(column),
  );

  $$PlanOccurrencesTableFilterComposer get occurrenceKey {
    final $$PlanOccurrencesTableFilterComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceKey,
      referencedTable: $db.planOccurrences,
      getReferencedColumn: (t) => t.occurrenceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanOccurrencesTableFilterComposer(
            $db: $db,
            $table: $db.planOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanAssignmentOverridesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanAssignmentOverridesTable> {
  $$PlanAssignmentOverridesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get userSlot => $composableBuilder(
    column: $table.userSlot,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get decidedAt => $composableBuilder(
    column: $table.decidedAt,
    builder: (column) => ColumnOrderings(column),
  );

  $$PlanOccurrencesTableOrderingComposer get occurrenceKey {
    final $$PlanOccurrencesTableOrderingComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceKey,
      referencedTable: $db.planOccurrences,
      getReferencedColumn: (t) => t.occurrenceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanOccurrencesTableOrderingComposer(
            $db: $db,
            $table: $db.planOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanAssignmentOverridesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanAssignmentOverridesTable> {
  $$PlanAssignmentOverridesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get userSlot =>
      $composableBuilder(column: $table.userSlot, builder: (column) => column);

  GeneratedColumn<int> get deviceSequence => $composableBuilder(
    column: $table.deviceSequence,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get decidedAt =>
      $composableBuilder(column: $table.decidedAt, builder: (column) => column);

  $$PlanOccurrencesTableAnnotationComposer get occurrenceKey {
    final $$PlanOccurrencesTableAnnotationComposer composer = $composerBuilder(
      composer: this,
      getCurrentColumn: (t) => t.occurrenceKey,
      referencedTable: $db.planOccurrences,
      getReferencedColumn: (t) => t.occurrenceKey,
      builder:
          (
            joinBuilder, {
            $addJoinBuilderToRootComposer,
            $removeJoinBuilderFromRootComposer,
          }) => $$PlanOccurrencesTableAnnotationComposer(
            $db: $db,
            $table: $db.planOccurrences,
            $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
            joinBuilder: joinBuilder,
            $removeJoinBuilderFromRootComposer:
                $removeJoinBuilderFromRootComposer,
          ),
    );
    return composer;
  }
}

class $$PlanAssignmentOverridesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanAssignmentOverridesTable,
          PlanAssignmentOverride,
          $$PlanAssignmentOverridesTableFilterComposer,
          $$PlanAssignmentOverridesTableOrderingComposer,
          $$PlanAssignmentOverridesTableAnnotationComposer,
          $$PlanAssignmentOverridesTableCreateCompanionBuilder,
          $$PlanAssignmentOverridesTableUpdateCompanionBuilder,
          (PlanAssignmentOverride, $$PlanAssignmentOverridesTableReferences),
          PlanAssignmentOverride,
          PrefetchHooks Function({bool occurrenceKey})
        > {
  $$PlanAssignmentOverridesTableTableManager(
    _$AppDatabase db,
    $PlanAssignmentOverridesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanAssignmentOverridesTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$PlanAssignmentOverridesTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlanAssignmentOverridesTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<int> userSlot = const Value.absent(),
                Value<int> deviceSequence = const Value.absent(),
                Value<String?> occurrenceKey = const Value.absent(),
                Value<DateTime> decidedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanAssignmentOverridesCompanion(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                occurrenceKey: occurrenceKey,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required int userSlot,
                required int deviceSequence,
                Value<String?> occurrenceKey = const Value.absent(),
                required DateTime decidedAt,
                Value<int> rowid = const Value.absent(),
              }) => PlanAssignmentOverridesCompanion.insert(
                userSlot: userSlot,
                deviceSequence: deviceSequence,
                occurrenceKey: occurrenceKey,
                decidedAt: decidedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<
                    $PlanAssignmentOverridesTable,
                    PlanAssignmentOverride
                  >(table),
                  $$PlanAssignmentOverridesTableReferences(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: ({occurrenceKey = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins:
                  <
                    T extends TableManagerState<
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic,
                      dynamic
                    >
                  >(state) {
                    if (occurrenceKey) {
                      state = state.withJoin(
                        currentTable: table,
                        currentColumn: table.occurrenceKey,
                        referencedTable:
                            $$PlanAssignmentOverridesTableReferences
                                ._occurrenceKeyTable(db),
                        referencedColumn:
                            $$PlanAssignmentOverridesTableReferences
                                ._occurrenceKeyTable(db)
                                .occurrenceKey,
                      ) as T;
                    }

                    return state;
                  },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ),
      );
}

typedef $$PlanAssignmentOverridesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanAssignmentOverridesTable,
      PlanAssignmentOverride,
      $$PlanAssignmentOverridesTableFilterComposer,
      $$PlanAssignmentOverridesTableOrderingComposer,
      $$PlanAssignmentOverridesTableAnnotationComposer,
      $$PlanAssignmentOverridesTableCreateCompanionBuilder,
      $$PlanAssignmentOverridesTableUpdateCompanionBuilder,
      (PlanAssignmentOverride, $$PlanAssignmentOverridesTableReferences),
      PlanAssignmentOverride,
      PrefetchHooks Function({bool occurrenceKey})
    >;
typedef $$ReminderSyncTableCreateCompanionBuilder =
    ReminderSyncCompanion Function({
      Value<int> id,
      required int desiredGeneration,
      Value<int?> appliedGeneration,
      Value<String?> lastError,
    });
typedef $$ReminderSyncTableUpdateCompanionBuilder =
    ReminderSyncCompanion Function({
      Value<int> id,
      Value<int> desiredGeneration,
      Value<int?> appliedGeneration,
      Value<String?> lastError,
    });

class $$ReminderSyncTableFilterComposer
    extends Composer<_$AppDatabase, $ReminderSyncTable> {
  $$ReminderSyncTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get desiredGeneration => $composableBuilder(
    column: $table.desiredGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get appliedGeneration => $composableBuilder(
    column: $table.appliedGeneration,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReminderSyncTableOrderingComposer
    extends Composer<_$AppDatabase, $ReminderSyncTable> {
  $$ReminderSyncTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get desiredGeneration => $composableBuilder(
    column: $table.desiredGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get appliedGeneration => $composableBuilder(
    column: $table.appliedGeneration,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReminderSyncTableAnnotationComposer
    extends Composer<_$AppDatabase, $ReminderSyncTable> {
  $$ReminderSyncTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<int> get desiredGeneration => $composableBuilder(
    column: $table.desiredGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<int> get appliedGeneration => $composableBuilder(
    column: $table.appliedGeneration,
    builder: (column) => column,
  );

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$ReminderSyncTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $ReminderSyncTable,
          ReminderSyncState,
          $$ReminderSyncTableFilterComposer,
          $$ReminderSyncTableOrderingComposer,
          $$ReminderSyncTableAnnotationComposer,
          $$ReminderSyncTableCreateCompanionBuilder,
          $$ReminderSyncTableUpdateCompanionBuilder,
          (
            ReminderSyncState,
            BaseReferences<
              _$AppDatabase,
              $ReminderSyncTable,
              ReminderSyncState
            >,
          ),
          ReminderSyncState,
          PrefetchHooks Function()
        > {
  $$ReminderSyncTableTableManager(_$AppDatabase db, $ReminderSyncTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReminderSyncTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReminderSyncTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ReminderSyncTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                Value<int> desiredGeneration = const Value.absent(),
                Value<int?> appliedGeneration = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ReminderSyncCompanion(
                id: id,
                desiredGeneration: desiredGeneration,
                appliedGeneration: appliedGeneration,
                lastError: lastError,
              ),
          createCompanionCallback:
              ({
                Value<int> id = const Value.absent(),
                required int desiredGeneration,
                Value<int?> appliedGeneration = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
              }) => ReminderSyncCompanion.insert(
                id: id,
                desiredGeneration: desiredGeneration,
                appliedGeneration: appliedGeneration,
                lastError: lastError,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$ReminderSyncTable, ReminderSyncState>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $ReminderSyncTable,
                    ReminderSyncState
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReminderSyncTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $ReminderSyncTable,
      ReminderSyncState,
      $$ReminderSyncTableFilterComposer,
      $$ReminderSyncTableOrderingComposer,
      $$ReminderSyncTableAnnotationComposer,
      $$ReminderSyncTableCreateCompanionBuilder,
      $$ReminderSyncTableUpdateCompanionBuilder,
      (
        ReminderSyncState,
        BaseReferences<_$AppDatabase, $ReminderSyncTable, ReminderSyncState>,
      ),
      ReminderSyncState,
      PrefetchHooks Function()
    >;
typedef $$PlanTimeChangesTableCreateCompanionBuilder =
    PlanTimeChangesCompanion Function({
      required String eventId,
      required DateTime occurredAt,
      Value<String?> oldZoneId,
      required String newZoneId,
      Value<int> rowid,
    });
typedef $$PlanTimeChangesTableUpdateCompanionBuilder =
    PlanTimeChangesCompanion Function({
      Value<String> eventId,
      Value<DateTime> occurredAt,
      Value<String?> oldZoneId,
      Value<String> newZoneId,
      Value<int> rowid,
    });

class $$PlanTimeChangesTableFilterComposer
    extends Composer<_$AppDatabase, $PlanTimeChangesTable> {
  $$PlanTimeChangesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get oldZoneId => $composableBuilder(
    column: $table.oldZoneId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newZoneId => $composableBuilder(
    column: $table.newZoneId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlanTimeChangesTableOrderingComposer
    extends Composer<_$AppDatabase, $PlanTimeChangesTable> {
  $$PlanTimeChangesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get eventId => $composableBuilder(
    column: $table.eventId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get oldZoneId => $composableBuilder(
    column: $table.oldZoneId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newZoneId => $composableBuilder(
    column: $table.newZoneId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlanTimeChangesTableAnnotationComposer
    extends Composer<_$AppDatabase, $PlanTimeChangesTable> {
  $$PlanTimeChangesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get eventId =>
      $composableBuilder(column: $table.eventId, builder: (column) => column);

  GeneratedColumn<DateTime> get occurredAt => $composableBuilder(
    column: $table.occurredAt,
    builder: (column) => column,
  );

  GeneratedColumn<String> get oldZoneId =>
      $composableBuilder(column: $table.oldZoneId, builder: (column) => column);

  GeneratedColumn<String> get newZoneId =>
      $composableBuilder(column: $table.newZoneId, builder: (column) => column);
}

class $$PlanTimeChangesTableTableManager
    extends
        RootTableManager<
          _$AppDatabase,
          $PlanTimeChangesTable,
          PlanTimeChange,
          $$PlanTimeChangesTableFilterComposer,
          $$PlanTimeChangesTableOrderingComposer,
          $$PlanTimeChangesTableAnnotationComposer,
          $$PlanTimeChangesTableCreateCompanionBuilder,
          $$PlanTimeChangesTableUpdateCompanionBuilder,
          (
            PlanTimeChange,
            BaseReferences<
              _$AppDatabase,
              $PlanTimeChangesTable,
              PlanTimeChange
            >,
          ),
          PlanTimeChange,
          PrefetchHooks Function()
        > {
  $$PlanTimeChangesTableTableManager(
    _$AppDatabase db,
    $PlanTimeChangesTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlanTimeChangesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlanTimeChangesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PlanTimeChangesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> eventId = const Value.absent(),
                Value<DateTime> occurredAt = const Value.absent(),
                Value<String?> oldZoneId = const Value.absent(),
                Value<String> newZoneId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlanTimeChangesCompanion(
                eventId: eventId,
                occurredAt: occurredAt,
                oldZoneId: oldZoneId,
                newZoneId: newZoneId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String eventId,
                required DateTime occurredAt,
                Value<String?> oldZoneId = const Value.absent(),
                required String newZoneId,
                Value<int> rowid = const Value.absent(),
              }) => PlanTimeChangesCompanion.insert(
                eventId: eventId,
                occurredAt: occurredAt,
                oldZoneId: oldZoneId,
                newZoneId: newZoneId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map(
                (e) => (
                  e.readTable<$PlanTimeChangesTable, PlanTimeChange>(table),
                  BaseReferences<
                    _$AppDatabase,
                    $PlanTimeChangesTable,
                    PlanTimeChange
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlanTimeChangesTableProcessedTableManager =
    ProcessedTableManager<
      _$AppDatabase,
      $PlanTimeChangesTable,
      PlanTimeChange,
      $$PlanTimeChangesTableFilterComposer,
      $$PlanTimeChangesTableOrderingComposer,
      $$PlanTimeChangesTableAnnotationComposer,
      $$PlanTimeChangesTableCreateCompanionBuilder,
      $$PlanTimeChangesTableUpdateCompanionBuilder,
      (
        PlanTimeChange,
        BaseReferences<_$AppDatabase, $PlanTimeChangesTable, PlanTimeChange>,
      ),
      PlanTimeChange,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$MeasurementExportsTableTableManager get measurementExports =>
      $$MeasurementExportsTableTableManager(_db, _db.measurementExports);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$OccasionDecisionsTableTableManager get occasionDecisions =>
      $$OccasionDecisionsTableTableManager(_db, _db.occasionDecisions);
  $$PhasesTableTableManager get phases =>
      $$PhasesTableTableManager(_db, _db.phases);
  $$PhaseAssignmentsTableTableManager get phaseAssignments =>
      $$PhaseAssignmentsTableTableManager(_db, _db.phaseAssignments);
  $$MeasurementNotesTableTableManager get measurementNotes =>
      $$MeasurementNotesTableTableManager(_db, _db.measurementNotes);
  $$MeasurementTagsTableTableManager get measurementTags =>
      $$MeasurementTagsTableTableManager(_db, _db.measurementTags);
  $$MeasurementTagLinksTableTableManager get measurementTagLinks =>
      $$MeasurementTagLinksTableTableManager(_db, _db.measurementTagLinks);
  $$ScopedPhasesTableTableManager get scopedPhases =>
      $$ScopedPhasesTableTableManager(_db, _db.scopedPhases);
  $$PhaseSelectionsTableTableManager get phaseSelections =>
      $$PhaseSelectionsTableTableManager(_db, _db.phaseSelections);
  $$PhaseSelectionMembersTableTableManager get phaseSelectionMembers =>
      $$PhaseSelectionMembersTableTableManager(_db, _db.phaseSelectionMembers);
  $$MeasurementPlansTableTableManager get measurementPlans =>
      $$MeasurementPlansTableTableManager(_db, _db.measurementPlans);
  $$PlanRevisionsTableTableManager get planRevisions =>
      $$PlanRevisionsTableTableManager(_db, _db.planRevisions);
  $$PlanTimesTableTableManager get planTimes =>
      $$PlanTimesTableTableManager(_db, _db.planTimes);
  $$PlanOccurrencesTableTableManager get planOccurrences =>
      $$PlanOccurrencesTableTableManager(_db, _db.planOccurrences);
  $$PlanAssignmentOverridesTableTableManager get planAssignmentOverrides =>
      $$PlanAssignmentOverridesTableTableManager(
        _db,
        _db.planAssignmentOverrides,
      );
  $$ReminderSyncTableTableManager get reminderSync =>
      $$ReminderSyncTableTableManager(_db, _db.reminderSync);
  $$PlanTimeChangesTableTableManager get planTimeChanges =>
      $$PlanTimeChangesTableTableManager(_db, _db.planTimeChanges);
}
