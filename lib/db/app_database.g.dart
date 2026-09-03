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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    measurements,
    appSettings,
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
          (
            Measurement,
            BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement>,
          ),
          Measurement,
          PrefetchHooks Function()
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
                  BaseReferences<
                    _$AppDatabase,
                    $MeasurementsTable,
                    Measurement
                  >(db, table, e),
                ),
              )
              .toList(),
          prefetchHooksCallback: null,
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
      (
        Measurement,
        BaseReferences<_$AppDatabase, $MeasurementsTable, Measurement>,
      ),
      Measurement,
      PrefetchHooks Function()
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
}
