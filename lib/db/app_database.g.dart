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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $MeasurementsTable measurements = $MeasurementsTable(this);
  late final $AppSettingsTable appSettings = $AppSettingsTable(this);
  late final $OccasionDecisionsTable occasionDecisions =
      $OccasionDecisionsTable(this);
  late final $PhasesTable phases = $PhasesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    measurements,
    appSettings,
    occasionDecisions,
    phases,
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
          (Phase, BaseReferences<_$AppDatabase, $PhasesTable, Phase>),
          Phase,
          PrefetchHooks Function()
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
                  BaseReferences<_$AppDatabase, $PhasesTable, Phase>(
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
      (Phase, BaseReferences<_$AppDatabase, $PhasesTable, Phase>),
      Phase,
      PrefetchHooks Function()
    >;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$MeasurementsTableTableManager get measurements =>
      $$MeasurementsTableTableManager(_db, _db.measurements);
  $$AppSettingsTableTableManager get appSettings =>
      $$AppSettingsTableTableManager(_db, _db.appSettings);
  $$OccasionDecisionsTableTableManager get occasionDecisions =>
      $$OccasionDecisionsTableTableManager(_db, _db.occasionDecisions);
  $$PhasesTableTableManager get phases =>
      $$PhasesTableTableManager(_db, _db.phases);
}
