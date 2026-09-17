// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SchoolsTable extends Schools with TableInfo<$SchoolsTable, School> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SchoolsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
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
  static const VerificationMeta _educationLevelMeta = const VerificationMeta(
    'educationLevel',
  );
  @override
  late final GeneratedColumn<String> educationLevel = GeneratedColumn<String>(
    'education_level',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _contentLanguageMeta = const VerificationMeta(
    'contentLanguage',
  );
  @override
  late final GeneratedColumn<String> contentLanguage = GeneratedColumn<String>(
    'content_language',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('en'),
  );
  static const VerificationMeta _maxOfflineDaysMeta = const VerificationMeta(
    'maxOfflineDays',
  );
  @override
  late final GeneratedColumn<int> maxOfflineDays = GeneratedColumn<int>(
    'max_offline_days',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(30),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    educationLevel,
    contentLanguage,
    maxOfflineDays,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'schools';
  @override
  VerificationContext validateIntegrity(
    Insertable<School> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
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
    if (data.containsKey('education_level')) {
      context.handle(
        _educationLevelMeta,
        educationLevel.isAcceptableOrUnknown(
          data['education_level']!,
          _educationLevelMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_educationLevelMeta);
    }
    if (data.containsKey('content_language')) {
      context.handle(
        _contentLanguageMeta,
        contentLanguage.isAcceptableOrUnknown(
          data['content_language']!,
          _contentLanguageMeta,
        ),
      );
    }
    if (data.containsKey('max_offline_days')) {
      context.handle(
        _maxOfflineDaysMeta,
        maxOfflineDays.isAcceptableOrUnknown(
          data['max_offline_days']!,
          _maxOfflineDaysMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  School map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return School(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      educationLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}education_level'],
      )!,
      contentLanguage: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}content_language'],
      )!,
      maxOfflineDays: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}max_offline_days'],
      )!,
    );
  }

  @override
  $SchoolsTable createAlias(String alias) {
    return $SchoolsTable(attachedDatabase, alias);
  }
}

class School extends DataClass implements Insertable<School> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String name;
  final String educationLevel;
  final String contentLanguage;
  final int maxOfflineDays;
  const School({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.name,
    required this.educationLevel,
    required this.contentLanguage,
    required this.maxOfflineDays,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['name'] = Variable<String>(name);
    map['education_level'] = Variable<String>(educationLevel);
    map['content_language'] = Variable<String>(contentLanguage);
    map['max_offline_days'] = Variable<int>(maxOfflineDays);
    return map;
  }

  SchoolsCompanion toCompanion(bool nullToAbsent) {
    return SchoolsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      name: Value(name),
      educationLevel: Value(educationLevel),
      contentLanguage: Value(contentLanguage),
      maxOfflineDays: Value(maxOfflineDays),
    );
  }

  factory School.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return School(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      name: serializer.fromJson<String>(json['name']),
      educationLevel: serializer.fromJson<String>(json['educationLevel']),
      contentLanguage: serializer.fromJson<String>(json['contentLanguage']),
      maxOfflineDays: serializer.fromJson<int>(json['maxOfflineDays']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'name': serializer.toJson<String>(name),
      'educationLevel': serializer.toJson<String>(educationLevel),
      'contentLanguage': serializer.toJson<String>(contentLanguage),
      'maxOfflineDays': serializer.toJson<int>(maxOfflineDays),
    };
  }

  School copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? name,
    String? educationLevel,
    String? contentLanguage,
    int? maxOfflineDays,
  }) => School(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    name: name ?? this.name,
    educationLevel: educationLevel ?? this.educationLevel,
    contentLanguage: contentLanguage ?? this.contentLanguage,
    maxOfflineDays: maxOfflineDays ?? this.maxOfflineDays,
  );
  School copyWithCompanion(SchoolsCompanion data) {
    return School(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      name: data.name.present ? data.name.value : this.name,
      educationLevel: data.educationLevel.present
          ? data.educationLevel.value
          : this.educationLevel,
      contentLanguage: data.contentLanguage.present
          ? data.contentLanguage.value
          : this.contentLanguage,
      maxOfflineDays: data.maxOfflineDays.present
          ? data.maxOfflineDays.value
          : this.maxOfflineDays,
    );
  }

  @override
  String toString() {
    return (StringBuffer('School(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('contentLanguage: $contentLanguage, ')
          ..write('maxOfflineDays: $maxOfflineDays')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    name,
    educationLevel,
    contentLanguage,
    maxOfflineDays,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is School &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.name == this.name &&
          other.educationLevel == this.educationLevel &&
          other.contentLanguage == this.contentLanguage &&
          other.maxOfflineDays == this.maxOfflineDays);
}

class SchoolsCompanion extends UpdateCompanion<School> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> name;
  final Value<String> educationLevel;
  final Value<String> contentLanguage;
  final Value<int> maxOfflineDays;
  final Value<int> rowid;
  const SchoolsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.name = const Value.absent(),
    this.educationLevel = const Value.absent(),
    this.contentLanguage = const Value.absent(),
    this.maxOfflineDays = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SchoolsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String name,
    required String educationLevel,
    this.contentLanguage = const Value.absent(),
    this.maxOfflineDays = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       name = Value(name),
       educationLevel = Value(educationLevel);
  static Insertable<School> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? name,
    Expression<String>? educationLevel,
    Expression<String>? contentLanguage,
    Expression<int>? maxOfflineDays,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (name != null) 'name': name,
      if (educationLevel != null) 'education_level': educationLevel,
      if (contentLanguage != null) 'content_language': contentLanguage,
      if (maxOfflineDays != null) 'max_offline_days': maxOfflineDays,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SchoolsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? name,
    Value<String>? educationLevel,
    Value<String>? contentLanguage,
    Value<int>? maxOfflineDays,
    Value<int>? rowid,
  }) {
    return SchoolsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      name: name ?? this.name,
      educationLevel: educationLevel ?? this.educationLevel,
      contentLanguage: contentLanguage ?? this.contentLanguage,
      maxOfflineDays: maxOfflineDays ?? this.maxOfflineDays,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (educationLevel.present) {
      map['education_level'] = Variable<String>(educationLevel.value);
    }
    if (contentLanguage.present) {
      map['content_language'] = Variable<String>(contentLanguage.value);
    }
    if (maxOfflineDays.present) {
      map['max_offline_days'] = Variable<int>(maxOfflineDays.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SchoolsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('name: $name, ')
          ..write('educationLevel: $educationLevel, ')
          ..write('contentLanguage: $contentLanguage, ')
          ..write('maxOfflineDays: $maxOfflineDays, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ProfilesTable extends Profiles with TableInfo<$ProfilesTable, Profile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _roleMeta = const VerificationMeta('role');
  @override
  late final GeneratedColumn<String> role = GeneratedColumn<String>(
    'role',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fullNameMeta = const VerificationMeta(
    'fullName',
  );
  @override
  late final GeneratedColumn<String> fullName = GeneratedColumn<String>(
    'full_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _emailMeta = const VerificationMeta('email');
  @override
  late final GeneratedColumn<String> email = GeneratedColumn<String>(
    'email',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    role,
    fullName,
    email,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'profiles';
  @override
  VerificationContext validateIntegrity(
    Insertable<Profile> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('role')) {
      context.handle(
        _roleMeta,
        role.isAcceptableOrUnknown(data['role']!, _roleMeta),
      );
    } else if (isInserting) {
      context.missing(_roleMeta);
    }
    if (data.containsKey('full_name')) {
      context.handle(
        _fullNameMeta,
        fullName.isAcceptableOrUnknown(data['full_name']!, _fullNameMeta),
      );
    } else if (isInserting) {
      context.missing(_fullNameMeta);
    }
    if (data.containsKey('email')) {
      context.handle(
        _emailMeta,
        email.isAcceptableOrUnknown(data['email']!, _emailMeta),
      );
    } else if (isInserting) {
      context.missing(_emailMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Profile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Profile(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      role: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}role'],
      )!,
      fullName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}full_name'],
      )!,
      email: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}email'],
      )!,
    );
  }

  @override
  $ProfilesTable createAlias(String alias) {
    return $ProfilesTable(attachedDatabase, alias);
  }
}

class Profile extends DataClass implements Insertable<Profile> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String role;
  final String fullName;
  final String email;
  const Profile({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.role,
    required this.fullName,
    required this.email,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['role'] = Variable<String>(role);
    map['full_name'] = Variable<String>(fullName);
    map['email'] = Variable<String>(email);
    return map;
  }

  ProfilesCompanion toCompanion(bool nullToAbsent) {
    return ProfilesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      role: Value(role),
      fullName: Value(fullName),
      email: Value(email),
    );
  }

  factory Profile.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Profile(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      role: serializer.fromJson<String>(json['role']),
      fullName: serializer.fromJson<String>(json['fullName']),
      email: serializer.fromJson<String>(json['email']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'role': serializer.toJson<String>(role),
      'fullName': serializer.toJson<String>(fullName),
      'email': serializer.toJson<String>(email),
    };
  }

  Profile copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? role,
    String? fullName,
    String? email,
  }) => Profile(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    role: role ?? this.role,
    fullName: fullName ?? this.fullName,
    email: email ?? this.email,
  );
  Profile copyWithCompanion(ProfilesCompanion data) {
    return Profile(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      role: data.role.present ? data.role.value : this.role,
      fullName: data.fullName.present ? data.fullName.value : this.fullName,
      email: data.email.present ? data.email.value : this.email,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Profile(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    role,
    fullName,
    email,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Profile &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.role == this.role &&
          other.fullName == this.fullName &&
          other.email == this.email);
}

class ProfilesCompanion extends UpdateCompanion<Profile> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> role;
  final Value<String> fullName;
  final Value<String> email;
  final Value<int> rowid;
  const ProfilesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.role = const Value.absent(),
    this.fullName = const Value.absent(),
    this.email = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ProfilesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String role,
    required String fullName,
    required String email,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       role = Value(role),
       fullName = Value(fullName),
       email = Value(email);
  static Insertable<Profile> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? role,
    Expression<String>? fullName,
    Expression<String>? email,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (role != null) 'role': role,
      if (fullName != null) 'full_name': fullName,
      if (email != null) 'email': email,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ProfilesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? role,
    Value<String>? fullName,
    Value<String>? email,
    Value<int>? rowid,
  }) {
    return ProfilesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      role: role ?? this.role,
      fullName: fullName ?? this.fullName,
      email: email ?? this.email,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (role.present) {
      map['role'] = Variable<String>(role.value);
    }
    if (fullName.present) {
      map['full_name'] = Variable<String>(fullName.value);
    }
    if (email.present) {
      map['email'] = Variable<String>(email.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ProfilesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('role: $role, ')
          ..write('fullName: $fullName, ')
          ..write('email: $email, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $StudentsTable extends Students with TableInfo<$StudentsTable, Student> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $StudentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _profileIdMeta = const VerificationMeta(
    'profileId',
  );
  @override
  late final GeneratedColumn<String> profileId = GeneratedColumn<String>(
    'profile_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _specialNeedsMeta = const VerificationMeta(
    'specialNeeds',
  );
  @override
  late final GeneratedColumn<String> specialNeeds = GeneratedColumn<String>(
    'special_needs',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _specialNeedsNoteMeta = const VerificationMeta(
    'specialNeedsNote',
  );
  @override
  late final GeneratedColumn<String> specialNeedsNote = GeneratedColumn<String>(
    'special_needs_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _preAdmissionCompletedAtMeta =
      const VerificationMeta('preAdmissionCompletedAt');
  @override
  late final GeneratedColumn<DateTime> preAdmissionCompletedAt =
      GeneratedColumn<DateTime>(
        'pre_admission_completed_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    profileId,
    classId,
    specialNeeds,
    specialNeedsNote,
    preAdmissionCompletedAt,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'students';
  @override
  VerificationContext validateIntegrity(
    Insertable<Student> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('profile_id')) {
      context.handle(
        _profileIdMeta,
        profileId.isAcceptableOrUnknown(data['profile_id']!, _profileIdMeta),
      );
    } else if (isInserting) {
      context.missing(_profileIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    }
    if (data.containsKey('special_needs')) {
      context.handle(
        _specialNeedsMeta,
        specialNeeds.isAcceptableOrUnknown(
          data['special_needs']!,
          _specialNeedsMeta,
        ),
      );
    }
    if (data.containsKey('special_needs_note')) {
      context.handle(
        _specialNeedsNoteMeta,
        specialNeedsNote.isAcceptableOrUnknown(
          data['special_needs_note']!,
          _specialNeedsNoteMeta,
        ),
      );
    }
    if (data.containsKey('pre_admission_completed_at')) {
      context.handle(
        _preAdmissionCompletedAtMeta,
        preAdmissionCompletedAt.isAcceptableOrUnknown(
          data['pre_admission_completed_at']!,
          _preAdmissionCompletedAtMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Student map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Student(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      profileId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}profile_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      ),
      specialNeeds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_needs'],
      )!,
      specialNeedsNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}special_needs_note'],
      ),
      preAdmissionCompletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}pre_admission_completed_at'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $StudentsTable createAlias(String alias) {
    return $StudentsTable(attachedDatabase, alias);
  }
}

class Student extends DataClass implements Insertable<Student> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String profileId;
  final String? classId;
  final String specialNeeds;
  final String? specialNeedsNote;
  final DateTime? preAdmissionCompletedAt;
  final int version;
  const Student({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.profileId,
    this.classId,
    required this.specialNeeds,
    this.specialNeedsNote,
    this.preAdmissionCompletedAt,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['profile_id'] = Variable<String>(profileId);
    if (!nullToAbsent || classId != null) {
      map['class_id'] = Variable<String>(classId);
    }
    map['special_needs'] = Variable<String>(specialNeeds);
    if (!nullToAbsent || specialNeedsNote != null) {
      map['special_needs_note'] = Variable<String>(specialNeedsNote);
    }
    if (!nullToAbsent || preAdmissionCompletedAt != null) {
      map['pre_admission_completed_at'] = Variable<DateTime>(
        preAdmissionCompletedAt,
      );
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  StudentsCompanion toCompanion(bool nullToAbsent) {
    return StudentsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      profileId: Value(profileId),
      classId: classId == null && nullToAbsent
          ? const Value.absent()
          : Value(classId),
      specialNeeds: Value(specialNeeds),
      specialNeedsNote: specialNeedsNote == null && nullToAbsent
          ? const Value.absent()
          : Value(specialNeedsNote),
      preAdmissionCompletedAt: preAdmissionCompletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(preAdmissionCompletedAt),
      version: Value(version),
    );
  }

  factory Student.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Student(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      profileId: serializer.fromJson<String>(json['profileId']),
      classId: serializer.fromJson<String?>(json['classId']),
      specialNeeds: serializer.fromJson<String>(json['specialNeeds']),
      specialNeedsNote: serializer.fromJson<String?>(json['specialNeedsNote']),
      preAdmissionCompletedAt: serializer.fromJson<DateTime?>(
        json['preAdmissionCompletedAt'],
      ),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'profileId': serializer.toJson<String>(profileId),
      'classId': serializer.toJson<String?>(classId),
      'specialNeeds': serializer.toJson<String>(specialNeeds),
      'specialNeedsNote': serializer.toJson<String?>(specialNeedsNote),
      'preAdmissionCompletedAt': serializer.toJson<DateTime?>(
        preAdmissionCompletedAt,
      ),
      'version': serializer.toJson<int>(version),
    };
  }

  Student copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? profileId,
    Value<String?> classId = const Value.absent(),
    String? specialNeeds,
    Value<String?> specialNeedsNote = const Value.absent(),
    Value<DateTime?> preAdmissionCompletedAt = const Value.absent(),
    int? version,
  }) => Student(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    profileId: profileId ?? this.profileId,
    classId: classId.present ? classId.value : this.classId,
    specialNeeds: specialNeeds ?? this.specialNeeds,
    specialNeedsNote: specialNeedsNote.present
        ? specialNeedsNote.value
        : this.specialNeedsNote,
    preAdmissionCompletedAt: preAdmissionCompletedAt.present
        ? preAdmissionCompletedAt.value
        : this.preAdmissionCompletedAt,
    version: version ?? this.version,
  );
  Student copyWithCompanion(StudentsCompanion data) {
    return Student(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      profileId: data.profileId.present ? data.profileId.value : this.profileId,
      classId: data.classId.present ? data.classId.value : this.classId,
      specialNeeds: data.specialNeeds.present
          ? data.specialNeeds.value
          : this.specialNeeds,
      specialNeedsNote: data.specialNeedsNote.present
          ? data.specialNeedsNote.value
          : this.specialNeedsNote,
      preAdmissionCompletedAt: data.preAdmissionCompletedAt.present
          ? data.preAdmissionCompletedAt.value
          : this.preAdmissionCompletedAt,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Student(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('profileId: $profileId, ')
          ..write('classId: $classId, ')
          ..write('specialNeeds: $specialNeeds, ')
          ..write('specialNeedsNote: $specialNeedsNote, ')
          ..write('preAdmissionCompletedAt: $preAdmissionCompletedAt, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    profileId,
    classId,
    specialNeeds,
    specialNeedsNote,
    preAdmissionCompletedAt,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Student &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.profileId == this.profileId &&
          other.classId == this.classId &&
          other.specialNeeds == this.specialNeeds &&
          other.specialNeedsNote == this.specialNeedsNote &&
          other.preAdmissionCompletedAt == this.preAdmissionCompletedAt &&
          other.version == this.version);
}

class StudentsCompanion extends UpdateCompanion<Student> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> profileId;
  final Value<String?> classId;
  final Value<String> specialNeeds;
  final Value<String?> specialNeedsNote;
  final Value<DateTime?> preAdmissionCompletedAt;
  final Value<int> version;
  final Value<int> rowid;
  const StudentsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.profileId = const Value.absent(),
    this.classId = const Value.absent(),
    this.specialNeeds = const Value.absent(),
    this.specialNeedsNote = const Value.absent(),
    this.preAdmissionCompletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  StudentsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String profileId,
    this.classId = const Value.absent(),
    this.specialNeeds = const Value.absent(),
    this.specialNeedsNote = const Value.absent(),
    this.preAdmissionCompletedAt = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       profileId = Value(profileId);
  static Insertable<Student> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? profileId,
    Expression<String>? classId,
    Expression<String>? specialNeeds,
    Expression<String>? specialNeedsNote,
    Expression<DateTime>? preAdmissionCompletedAt,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (profileId != null) 'profile_id': profileId,
      if (classId != null) 'class_id': classId,
      if (specialNeeds != null) 'special_needs': specialNeeds,
      if (specialNeedsNote != null) 'special_needs_note': specialNeedsNote,
      if (preAdmissionCompletedAt != null)
        'pre_admission_completed_at': preAdmissionCompletedAt,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  StudentsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? profileId,
    Value<String?>? classId,
    Value<String>? specialNeeds,
    Value<String?>? specialNeedsNote,
    Value<DateTime?>? preAdmissionCompletedAt,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return StudentsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      profileId: profileId ?? this.profileId,
      classId: classId ?? this.classId,
      specialNeeds: specialNeeds ?? this.specialNeeds,
      specialNeedsNote: specialNeedsNote ?? this.specialNeedsNote,
      preAdmissionCompletedAt:
          preAdmissionCompletedAt ?? this.preAdmissionCompletedAt,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (profileId.present) {
      map['profile_id'] = Variable<String>(profileId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (specialNeeds.present) {
      map['special_needs'] = Variable<String>(specialNeeds.value);
    }
    if (specialNeedsNote.present) {
      map['special_needs_note'] = Variable<String>(specialNeedsNote.value);
    }
    if (preAdmissionCompletedAt.present) {
      map['pre_admission_completed_at'] = Variable<DateTime>(
        preAdmissionCompletedAt.value,
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('StudentsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('profileId: $profileId, ')
          ..write('classId: $classId, ')
          ..write('specialNeeds: $specialNeeds, ')
          ..write('specialNeedsNote: $specialNeedsNote, ')
          ..write('preAdmissionCompletedAt: $preAdmissionCompletedAt, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SubjectsTable extends Subjects with TableInfo<$SubjectsTable, Subject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _chapterCountMeta = const VerificationMeta(
    'chapterCount',
  );
  @override
  late final GeneratedColumn<int> chapterCount = GeneratedColumn<int>(
    'chapter_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    name,
    chapterCount,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<Subject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('chapter_count')) {
      context.handle(
        _chapterCountMeta,
        chapterCount.isAcceptableOrUnknown(
          data['chapter_count']!,
          _chapterCountMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Subject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Subject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      chapterCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}chapter_count'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $SubjectsTable createAlias(String alias) {
    return $SubjectsTable(attachedDatabase, alias);
  }
}

class Subject extends DataClass implements Insertable<Subject> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String name;
  final int chapterCount;
  final int version;
  const Subject({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.name,
    required this.chapterCount,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['name'] = Variable<String>(name);
    map['chapter_count'] = Variable<int>(chapterCount);
    map['version'] = Variable<int>(version);
    return map;
  }

  SubjectsCompanion toCompanion(bool nullToAbsent) {
    return SubjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      name: Value(name),
      chapterCount: Value(chapterCount),
      version: Value(version),
    );
  }

  factory Subject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Subject(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
      chapterCount: serializer.fromJson<int>(json['chapterCount']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'name': serializer.toJson<String>(name),
      'chapterCount': serializer.toJson<int>(chapterCount),
      'version': serializer.toJson<int>(version),
    };
  }

  Subject copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? name,
    int? chapterCount,
    int? version,
  }) => Subject(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    name: name ?? this.name,
    chapterCount: chapterCount ?? this.chapterCount,
    version: version ?? this.version,
  );
  Subject copyWithCompanion(SubjectsCompanion data) {
    return Subject(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
      chapterCount: data.chapterCount.present
          ? data.chapterCount.value
          : this.chapterCount,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Subject(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    name,
    chapterCount,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Subject &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.name == this.name &&
          other.chapterCount == this.chapterCount &&
          other.version == this.version);
}

class SubjectsCompanion extends UpdateCompanion<Subject> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> name;
  final Value<int> chapterCount;
  final Value<int> version;
  final Value<int> rowid;
  const SubjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.chapterCount = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SubjectsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String name,
    this.chapterCount = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       name = Value(name);
  static Insertable<Subject> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? name,
    Expression<int>? chapterCount,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (chapterCount != null) 'chapter_count': chapterCount,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SubjectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? name,
    Value<int>? chapterCount,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return SubjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      chapterCount: chapterCount ?? this.chapterCount,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (chapterCount.present) {
      map['chapter_count'] = Variable<int>(chapterCount.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SubjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('chapterCount: $chapterCount, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ChaptersTable extends Chapters with TableInfo<$ChaptersTable, Chapter> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ChaptersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _titleMeta = const VerificationMeta('title');
  @override
  late final GeneratedColumn<String> title = GeneratedColumn<String>(
    'title',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _microSkillsLockedAtMeta =
      const VerificationMeta('microSkillsLockedAt');
  @override
  late final GeneratedColumn<DateTime> microSkillsLockedAt =
      GeneratedColumn<DateTime>(
        'micro_skills_locked_at',
        aliasedName,
        true,
        type: DriftSqlType.dateTime,
        requiredDuringInsert: false,
      );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    subjectId,
    ordinal,
    title,
    microSkillsLockedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'chapters';
  @override
  VerificationContext validateIntegrity(
    Insertable<Chapter> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    if (data.containsKey('title')) {
      context.handle(
        _titleMeta,
        title.isAcceptableOrUnknown(data['title']!, _titleMeta),
      );
    } else if (isInserting) {
      context.missing(_titleMeta);
    }
    if (data.containsKey('micro_skills_locked_at')) {
      context.handle(
        _microSkillsLockedAtMeta,
        microSkillsLockedAt.isAcceptableOrUnknown(
          data['micro_skills_locked_at']!,
          _microSkillsLockedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Chapter map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Chapter(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
      title: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}title'],
      )!,
      microSkillsLockedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}micro_skills_locked_at'],
      ),
    );
  }

  @override
  $ChaptersTable createAlias(String alias) {
    return $ChaptersTable(attachedDatabase, alias);
  }
}

class Chapter extends DataClass implements Insertable<Chapter> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String subjectId;
  final int ordinal;
  final String title;
  final DateTime? microSkillsLockedAt;
  const Chapter({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.subjectId,
    required this.ordinal,
    required this.title,
    this.microSkillsLockedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['subject_id'] = Variable<String>(subjectId);
    map['ordinal'] = Variable<int>(ordinal);
    map['title'] = Variable<String>(title);
    if (!nullToAbsent || microSkillsLockedAt != null) {
      map['micro_skills_locked_at'] = Variable<DateTime>(microSkillsLockedAt);
    }
    return map;
  }

  ChaptersCompanion toCompanion(bool nullToAbsent) {
    return ChaptersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      subjectId: Value(subjectId),
      ordinal: Value(ordinal),
      title: Value(title),
      microSkillsLockedAt: microSkillsLockedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(microSkillsLockedAt),
    );
  }

  factory Chapter.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Chapter(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
      title: serializer.fromJson<String>(json['title']),
      microSkillsLockedAt: serializer.fromJson<DateTime?>(
        json['microSkillsLockedAt'],
      ),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'subjectId': serializer.toJson<String>(subjectId),
      'ordinal': serializer.toJson<int>(ordinal),
      'title': serializer.toJson<String>(title),
      'microSkillsLockedAt': serializer.toJson<DateTime?>(microSkillsLockedAt),
    };
  }

  Chapter copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? subjectId,
    int? ordinal,
    String? title,
    Value<DateTime?> microSkillsLockedAt = const Value.absent(),
  }) => Chapter(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    subjectId: subjectId ?? this.subjectId,
    ordinal: ordinal ?? this.ordinal,
    title: title ?? this.title,
    microSkillsLockedAt: microSkillsLockedAt.present
        ? microSkillsLockedAt.value
        : this.microSkillsLockedAt,
  );
  Chapter copyWithCompanion(ChaptersCompanion data) {
    return Chapter(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
      title: data.title.present ? data.title.value : this.title,
      microSkillsLockedAt: data.microSkillsLockedAt.present
          ? data.microSkillsLockedAt.value
          : this.microSkillsLockedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Chapter(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('subjectId: $subjectId, ')
          ..write('ordinal: $ordinal, ')
          ..write('title: $title, ')
          ..write('microSkillsLockedAt: $microSkillsLockedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    subjectId,
    ordinal,
    title,
    microSkillsLockedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Chapter &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.subjectId == this.subjectId &&
          other.ordinal == this.ordinal &&
          other.title == this.title &&
          other.microSkillsLockedAt == this.microSkillsLockedAt);
}

class ChaptersCompanion extends UpdateCompanion<Chapter> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> subjectId;
  final Value<int> ordinal;
  final Value<String> title;
  final Value<DateTime?> microSkillsLockedAt;
  final Value<int> rowid;
  const ChaptersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.title = const Value.absent(),
    this.microSkillsLockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ChaptersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String subjectId,
    required int ordinal,
    required String title,
    this.microSkillsLockedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       subjectId = Value(subjectId),
       ordinal = Value(ordinal),
       title = Value(title);
  static Insertable<Chapter> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? subjectId,
    Expression<int>? ordinal,
    Expression<String>? title,
    Expression<DateTime>? microSkillsLockedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (subjectId != null) 'subject_id': subjectId,
      if (ordinal != null) 'ordinal': ordinal,
      if (title != null) 'title': title,
      if (microSkillsLockedAt != null)
        'micro_skills_locked_at': microSkillsLockedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ChaptersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? subjectId,
    Value<int>? ordinal,
    Value<String>? title,
    Value<DateTime?>? microSkillsLockedAt,
    Value<int>? rowid,
  }) {
    return ChaptersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      subjectId: subjectId ?? this.subjectId,
      ordinal: ordinal ?? this.ordinal,
      title: title ?? this.title,
      microSkillsLockedAt: microSkillsLockedAt ?? this.microSkillsLockedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (title.present) {
      map['title'] = Variable<String>(title.value);
    }
    if (microSkillsLockedAt.present) {
      map['micro_skills_locked_at'] = Variable<DateTime>(
        microSkillsLockedAt.value,
      );
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ChaptersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('subjectId: $subjectId, ')
          ..write('ordinal: $ordinal, ')
          ..write('title: $title, ')
          ..write('microSkillsLockedAt: $microSkillsLockedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassesTable extends Classes with TableInfo<$ClassesTable, ClassesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  static const VerificationMeta _yearLevelMeta = const VerificationMeta(
    'yearLevel',
  );
  @override
  late final GeneratedColumn<int> yearLevel = GeneratedColumn<int>(
    'year_level',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _targetLearningStyleMeta =
      const VerificationMeta('targetLearningStyle');
  @override
  late final GeneratedColumn<String> targetLearningStyle =
      GeneratedColumn<String>(
        'target_learning_style',
        aliasedName,
        true,
        type: DriftSqlType.string,
        requiredDuringInsert: false,
      );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    name,
    yearLevel,
    targetLearningStyle,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'classes';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('name')) {
      context.handle(
        _nameMeta,
        name.isAcceptableOrUnknown(data['name']!, _nameMeta),
      );
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('year_level')) {
      context.handle(
        _yearLevelMeta,
        yearLevel.isAcceptableOrUnknown(data['year_level']!, _yearLevelMeta),
      );
    } else if (isInserting) {
      context.missing(_yearLevelMeta);
    }
    if (data.containsKey('target_learning_style')) {
      context.handle(
        _targetLearningStyleMeta,
        targetLearningStyle.isAcceptableOrUnknown(
          data['target_learning_style']!,
          _targetLearningStyleMeta,
        ),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      name: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}name'],
      )!,
      yearLevel: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}year_level'],
      )!,
      targetLearningStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}target_learning_style'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ClassesTable createAlias(String alias) {
    return $ClassesTable(attachedDatabase, alias);
  }
}

class ClassesData extends DataClass implements Insertable<ClassesData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String name;
  final int yearLevel;
  final String? targetLearningStyle;
  final int version;
  const ClassesData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.name,
    required this.yearLevel,
    this.targetLearningStyle,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['name'] = Variable<String>(name);
    map['year_level'] = Variable<int>(yearLevel);
    if (!nullToAbsent || targetLearningStyle != null) {
      map['target_learning_style'] = Variable<String>(targetLearningStyle);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  ClassesCompanion toCompanion(bool nullToAbsent) {
    return ClassesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      name: Value(name),
      yearLevel: Value(yearLevel),
      targetLearningStyle: targetLearningStyle == null && nullToAbsent
          ? const Value.absent()
          : Value(targetLearningStyle),
      version: Value(version),
    );
  }

  factory ClassesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassesData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      name: serializer.fromJson<String>(json['name']),
      yearLevel: serializer.fromJson<int>(json['yearLevel']),
      targetLearningStyle: serializer.fromJson<String?>(
        json['targetLearningStyle'],
      ),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'name': serializer.toJson<String>(name),
      'yearLevel': serializer.toJson<int>(yearLevel),
      'targetLearningStyle': serializer.toJson<String?>(targetLearningStyle),
      'version': serializer.toJson<int>(version),
    };
  }

  ClassesData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? name,
    int? yearLevel,
    Value<String?> targetLearningStyle = const Value.absent(),
    int? version,
  }) => ClassesData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    name: name ?? this.name,
    yearLevel: yearLevel ?? this.yearLevel,
    targetLearningStyle: targetLearningStyle.present
        ? targetLearningStyle.value
        : this.targetLearningStyle,
    version: version ?? this.version,
  );
  ClassesData copyWithCompanion(ClassesCompanion data) {
    return ClassesData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      name: data.name.present ? data.name.value : this.name,
      yearLevel: data.yearLevel.present ? data.yearLevel.value : this.yearLevel,
      targetLearningStyle: data.targetLearningStyle.present
          ? data.targetLearningStyle.value
          : this.targetLearningStyle,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassesData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('yearLevel: $yearLevel, ')
          ..write('targetLearningStyle: $targetLearningStyle, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    name,
    yearLevel,
    targetLearningStyle,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassesData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.name == this.name &&
          other.yearLevel == this.yearLevel &&
          other.targetLearningStyle == this.targetLearningStyle &&
          other.version == this.version);
}

class ClassesCompanion extends UpdateCompanion<ClassesData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> name;
  final Value<int> yearLevel;
  final Value<String?> targetLearningStyle;
  final Value<int> version;
  final Value<int> rowid;
  const ClassesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.name = const Value.absent(),
    this.yearLevel = const Value.absent(),
    this.targetLearningStyle = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String name,
    required int yearLevel,
    this.targetLearningStyle = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       name = Value(name),
       yearLevel = Value(yearLevel);
  static Insertable<ClassesData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? name,
    Expression<int>? yearLevel,
    Expression<String>? targetLearningStyle,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (name != null) 'name': name,
      if (yearLevel != null) 'year_level': yearLevel,
      if (targetLearningStyle != null)
        'target_learning_style': targetLearningStyle,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? name,
    Value<int>? yearLevel,
    Value<String?>? targetLearningStyle,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ClassesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      name: name ?? this.name,
      yearLevel: yearLevel ?? this.yearLevel,
      targetLearningStyle: targetLearningStyle ?? this.targetLearningStyle,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (name.present) {
      map['name'] = Variable<String>(name.value);
    }
    if (yearLevel.present) {
      map['year_level'] = Variable<int>(yearLevel.value);
    }
    if (targetLearningStyle.present) {
      map['target_learning_style'] = Variable<String>(
        targetLearningStyle.value,
      );
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('name: $name, ')
          ..write('yearLevel: $yearLevel, ')
          ..write('targetLearningStyle: $targetLearningStyle, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassSubjectsTable extends ClassSubjects
    with TableInfo<$ClassSubjectsTable, ClassSubject> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassSubjectsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _subjectIdMeta = const VerificationMeta(
    'subjectId',
  );
  @override
  late final GeneratedColumn<String> subjectId = GeneratedColumn<String>(
    'subject_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    classId,
    subjectId,
    teacherId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_subjects';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassSubject> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('subject_id')) {
      context.handle(
        _subjectIdMeta,
        subjectId.isAcceptableOrUnknown(data['subject_id']!, _subjectIdMeta),
      );
    } else if (isInserting) {
      context.missing(_subjectIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassSubject map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassSubject(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      subjectId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}subject_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
    );
  }

  @override
  $ClassSubjectsTable createAlias(String alias) {
    return $ClassSubjectsTable(attachedDatabase, alias);
  }
}

class ClassSubject extends DataClass implements Insertable<ClassSubject> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String classId;
  final String subjectId;
  final String teacherId;
  const ClassSubject({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.classId,
    required this.subjectId,
    required this.teacherId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['class_id'] = Variable<String>(classId);
    map['subject_id'] = Variable<String>(subjectId);
    map['teacher_id'] = Variable<String>(teacherId);
    return map;
  }

  ClassSubjectsCompanion toCompanion(bool nullToAbsent) {
    return ClassSubjectsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      classId: Value(classId),
      subjectId: Value(subjectId),
      teacherId: Value(teacherId),
    );
  }

  factory ClassSubject.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassSubject(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      classId: serializer.fromJson<String>(json['classId']),
      subjectId: serializer.fromJson<String>(json['subjectId']),
      teacherId: serializer.fromJson<String>(json['teacherId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'classId': serializer.toJson<String>(classId),
      'subjectId': serializer.toJson<String>(subjectId),
      'teacherId': serializer.toJson<String>(teacherId),
    };
  }

  ClassSubject copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? classId,
    String? subjectId,
    String? teacherId,
  }) => ClassSubject(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    classId: classId ?? this.classId,
    subjectId: subjectId ?? this.subjectId,
    teacherId: teacherId ?? this.teacherId,
  );
  ClassSubject copyWithCompanion(ClassSubjectsCompanion data) {
    return ClassSubject(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      subjectId: data.subjectId.present ? data.subjectId.value : this.subjectId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassSubject(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('subjectId: $subjectId, ')
          ..write('teacherId: $teacherId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    classId,
    subjectId,
    teacherId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassSubject &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.subjectId == this.subjectId &&
          other.teacherId == this.teacherId);
}

class ClassSubjectsCompanion extends UpdateCompanion<ClassSubject> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> classId;
  final Value<String> subjectId;
  final Value<String> teacherId;
  final Value<int> rowid;
  const ClassSubjectsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.subjectId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassSubjectsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String classId,
    required String subjectId,
    required String teacherId,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       classId = Value(classId),
       subjectId = Value(subjectId),
       teacherId = Value(teacherId);
  static Insertable<ClassSubject> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? classId,
    Expression<String>? subjectId,
    Expression<String>? teacherId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (subjectId != null) 'subject_id': subjectId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassSubjectsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? classId,
    Value<String>? subjectId,
    Value<String>? teacherId,
    Value<int>? rowid,
  }) {
    return ClassSubjectsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      subjectId: subjectId ?? this.subjectId,
      teacherId: teacherId ?? this.teacherId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (subjectId.present) {
      map['subject_id'] = Variable<String>(subjectId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassSubjectsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('subjectId: $subjectId, ')
          ..write('teacherId: $teacherId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ClassChapterSchedTable extends ClassChapterSched
    with TableInfo<$ClassChapterSchedTable, ClassChapterSchedData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ClassChapterSchedTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _taughtOnMeta = const VerificationMeta(
    'taughtOn',
  );
  @override
  late final GeneratedColumn<DateTime> taughtOn = GeneratedColumn<DateTime>(
    'taught_on',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    classId,
    chapterId,
    taughtOn,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'class_chapter_sched';
  @override
  VerificationContext validateIntegrity(
    Insertable<ClassChapterSchedData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('taught_on')) {
      context.handle(
        _taughtOnMeta,
        taughtOn.isAcceptableOrUnknown(data['taught_on']!, _taughtOnMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ClassChapterSchedData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ClassChapterSchedData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      taughtOn: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}taught_on'],
      ),
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $ClassChapterSchedTable createAlias(String alias) {
    return $ClassChapterSchedTable(attachedDatabase, alias);
  }
}

class ClassChapterSchedData extends DataClass
    implements Insertable<ClassChapterSchedData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String classId;
  final String chapterId;
  final DateTime? taughtOn;
  final int version;
  const ClassChapterSchedData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.classId,
    required this.chapterId,
    this.taughtOn,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['class_id'] = Variable<String>(classId);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || taughtOn != null) {
      map['taught_on'] = Variable<DateTime>(taughtOn);
    }
    map['version'] = Variable<int>(version);
    return map;
  }

  ClassChapterSchedCompanion toCompanion(bool nullToAbsent) {
    return ClassChapterSchedCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      classId: Value(classId),
      chapterId: Value(chapterId),
      taughtOn: taughtOn == null && nullToAbsent
          ? const Value.absent()
          : Value(taughtOn),
      version: Value(version),
    );
  }

  factory ClassChapterSchedData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ClassChapterSchedData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      classId: serializer.fromJson<String>(json['classId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      taughtOn: serializer.fromJson<DateTime?>(json['taughtOn']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'classId': serializer.toJson<String>(classId),
      'chapterId': serializer.toJson<String>(chapterId),
      'taughtOn': serializer.toJson<DateTime?>(taughtOn),
      'version': serializer.toJson<int>(version),
    };
  }

  ClassChapterSchedData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? classId,
    String? chapterId,
    Value<DateTime?> taughtOn = const Value.absent(),
    int? version,
  }) => ClassChapterSchedData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    classId: classId ?? this.classId,
    chapterId: chapterId ?? this.chapterId,
    taughtOn: taughtOn.present ? taughtOn.value : this.taughtOn,
    version: version ?? this.version,
  );
  ClassChapterSchedData copyWithCompanion(ClassChapterSchedCompanion data) {
    return ClassChapterSchedData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      classId: data.classId.present ? data.classId.value : this.classId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      taughtOn: data.taughtOn.present ? data.taughtOn.value : this.taughtOn,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ClassChapterSchedData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('chapterId: $chapterId, ')
          ..write('taughtOn: $taughtOn, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    classId,
    chapterId,
    taughtOn,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ClassChapterSchedData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.classId == this.classId &&
          other.chapterId == this.chapterId &&
          other.taughtOn == this.taughtOn &&
          other.version == this.version);
}

class ClassChapterSchedCompanion
    extends UpdateCompanion<ClassChapterSchedData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> classId;
  final Value<String> chapterId;
  final Value<DateTime?> taughtOn;
  final Value<int> version;
  final Value<int> rowid;
  const ClassChapterSchedCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.classId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.taughtOn = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ClassChapterSchedCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String classId,
    required String chapterId,
    this.taughtOn = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       classId = Value(classId),
       chapterId = Value(chapterId);
  static Insertable<ClassChapterSchedData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? classId,
    Expression<String>? chapterId,
    Expression<DateTime>? taughtOn,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (classId != null) 'class_id': classId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (taughtOn != null) 'taught_on': taughtOn,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ClassChapterSchedCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? classId,
    Value<String>? chapterId,
    Value<DateTime?>? taughtOn,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return ClassChapterSchedCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      classId: classId ?? this.classId,
      chapterId: chapterId ?? this.chapterId,
      taughtOn: taughtOn ?? this.taughtOn,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (taughtOn.present) {
      map['taught_on'] = Variable<DateTime>(taughtOn.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ClassChapterSchedCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('classId: $classId, ')
          ..write('chapterId: $chapterId, ')
          ..write('taughtOn: $taughtOn, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MicroSkillsTable extends MicroSkills
    with TableInfo<$MicroSkillsTable, MicroSkill> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MicroSkillsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _slugMeta = const VerificationMeta('slug');
  @override
  late final GeneratedColumn<String> slug = GeneratedColumn<String>(
    'slug',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _labelMeta = const VerificationMeta('label');
  @override
  late final GeneratedColumn<String> label = GeneratedColumn<String>(
    'label',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _descriptionMeta = const VerificationMeta(
    'description',
  );
  @override
  late final GeneratedColumn<String> description = GeneratedColumn<String>(
    'description',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    slug,
    label,
    description,
    ordinal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'micro_skills';
  @override
  VerificationContext validateIntegrity(
    Insertable<MicroSkill> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('slug')) {
      context.handle(
        _slugMeta,
        slug.isAcceptableOrUnknown(data['slug']!, _slugMeta),
      );
    } else if (isInserting) {
      context.missing(_slugMeta);
    }
    if (data.containsKey('label')) {
      context.handle(
        _labelMeta,
        label.isAcceptableOrUnknown(data['label']!, _labelMeta),
      );
    } else if (isInserting) {
      context.missing(_labelMeta);
    }
    if (data.containsKey('description')) {
      context.handle(
        _descriptionMeta,
        description.isAcceptableOrUnknown(
          data['description']!,
          _descriptionMeta,
        ),
      );
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MicroSkill map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MicroSkill(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      slug: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}slug'],
      )!,
      label: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}label'],
      )!,
      description: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}description'],
      ),
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
    );
  }

  @override
  $MicroSkillsTable createAlias(String alias) {
    return $MicroSkillsTable(attachedDatabase, alias);
  }
}

class MicroSkill extends DataClass implements Insertable<MicroSkill> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String chapterId;
  final String slug;
  final String label;
  final String? description;
  final int ordinal;
  const MicroSkill({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.chapterId,
    required this.slug,
    required this.label,
    this.description,
    required this.ordinal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['slug'] = Variable<String>(slug);
    map['label'] = Variable<String>(label);
    if (!nullToAbsent || description != null) {
      map['description'] = Variable<String>(description);
    }
    map['ordinal'] = Variable<int>(ordinal);
    return map;
  }

  MicroSkillsCompanion toCompanion(bool nullToAbsent) {
    return MicroSkillsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      chapterId: Value(chapterId),
      slug: Value(slug),
      label: Value(label),
      description: description == null && nullToAbsent
          ? const Value.absent()
          : Value(description),
      ordinal: Value(ordinal),
    );
  }

  factory MicroSkill.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MicroSkill(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      slug: serializer.fromJson<String>(json['slug']),
      label: serializer.fromJson<String>(json['label']),
      description: serializer.fromJson<String?>(json['description']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'chapterId': serializer.toJson<String>(chapterId),
      'slug': serializer.toJson<String>(slug),
      'label': serializer.toJson<String>(label),
      'description': serializer.toJson<String?>(description),
      'ordinal': serializer.toJson<int>(ordinal),
    };
  }

  MicroSkill copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? chapterId,
    String? slug,
    String? label,
    Value<String?> description = const Value.absent(),
    int? ordinal,
  }) => MicroSkill(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    chapterId: chapterId ?? this.chapterId,
    slug: slug ?? this.slug,
    label: label ?? this.label,
    description: description.present ? description.value : this.description,
    ordinal: ordinal ?? this.ordinal,
  );
  MicroSkill copyWithCompanion(MicroSkillsCompanion data) {
    return MicroSkill(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      slug: data.slug.present ? data.slug.value : this.slug,
      label: data.label.present ? data.label.value : this.label,
      description: data.description.present
          ? data.description.value
          : this.description,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MicroSkill(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('slug: $slug, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('ordinal: $ordinal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    slug,
    label,
    description,
    ordinal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MicroSkill &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.chapterId == this.chapterId &&
          other.slug == this.slug &&
          other.label == this.label &&
          other.description == this.description &&
          other.ordinal == this.ordinal);
}

class MicroSkillsCompanion extends UpdateCompanion<MicroSkill> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> chapterId;
  final Value<String> slug;
  final Value<String> label;
  final Value<String?> description;
  final Value<int> ordinal;
  final Value<int> rowid;
  const MicroSkillsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.slug = const Value.absent(),
    this.label = const Value.absent(),
    this.description = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MicroSkillsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String chapterId,
    required String slug,
    required String label,
    this.description = const Value.absent(),
    required int ordinal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       chapterId = Value(chapterId),
       slug = Value(slug),
       label = Value(label),
       ordinal = Value(ordinal);
  static Insertable<MicroSkill> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? chapterId,
    Expression<String>? slug,
    Expression<String>? label,
    Expression<String>? description,
    Expression<int>? ordinal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (slug != null) 'slug': slug,
      if (label != null) 'label': label,
      if (description != null) 'description': description,
      if (ordinal != null) 'ordinal': ordinal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MicroSkillsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? chapterId,
    Value<String>? slug,
    Value<String>? label,
    Value<String?>? description,
    Value<int>? ordinal,
    Value<int>? rowid,
  }) {
    return MicroSkillsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      chapterId: chapterId ?? this.chapterId,
      slug: slug ?? this.slug,
      label: label ?? this.label,
      description: description ?? this.description,
      ordinal: ordinal ?? this.ordinal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (slug.present) {
      map['slug'] = Variable<String>(slug.value);
    }
    if (label.present) {
      map['label'] = Variable<String>(label.value);
    }
    if (description.present) {
      map['description'] = Variable<String>(description.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MicroSkillsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('slug: $slug, ')
          ..write('label: $label, ')
          ..write('description: $description, ')
          ..write('ordinal: $ordinal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MicroSkillExplanationsTable extends MicroSkillExplanations
    with TableInfo<$MicroSkillExplanationsTable, MicroSkillExplanation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MicroSkillExplanationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _microSkillIdMeta = const VerificationMeta(
    'microSkillId',
  );
  @override
  late final GeneratedColumn<String> microSkillId = GeneratedColumn<String>(
    'micro_skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    microSkillId,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'micro_skill_explanations';
  @override
  VerificationContext validateIntegrity(
    Insertable<MicroSkillExplanation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('micro_skill_id')) {
      context.handle(
        _microSkillIdMeta,
        microSkillId.isAcceptableOrUnknown(
          data['micro_skill_id']!,
          _microSkillIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_microSkillIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  MicroSkillExplanation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return MicroSkillExplanation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      microSkillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}micro_skill_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $MicroSkillExplanationsTable createAlias(String alias) {
    return $MicroSkillExplanationsTable(attachedDatabase, alias);
  }
}

class MicroSkillExplanation extends DataClass
    implements Insertable<MicroSkillExplanation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String microSkillId;
  final String body;
  const MicroSkillExplanation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.microSkillId,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['micro_skill_id'] = Variable<String>(microSkillId);
    map['body'] = Variable<String>(body);
    return map;
  }

  MicroSkillExplanationsCompanion toCompanion(bool nullToAbsent) {
    return MicroSkillExplanationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      microSkillId: Value(microSkillId),
      body: Value(body),
    );
  }

  factory MicroSkillExplanation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return MicroSkillExplanation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      microSkillId: serializer.fromJson<String>(json['microSkillId']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'microSkillId': serializer.toJson<String>(microSkillId),
      'body': serializer.toJson<String>(body),
    };
  }

  MicroSkillExplanation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? microSkillId,
    String? body,
  }) => MicroSkillExplanation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    microSkillId: microSkillId ?? this.microSkillId,
    body: body ?? this.body,
  );
  MicroSkillExplanation copyWithCompanion(
    MicroSkillExplanationsCompanion data,
  ) {
    return MicroSkillExplanation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      microSkillId: data.microSkillId.present
          ? data.microSkillId.value
          : this.microSkillId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('MicroSkillExplanation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    microSkillId,
    body,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is MicroSkillExplanation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.microSkillId == this.microSkillId &&
          other.body == this.body);
}

class MicroSkillExplanationsCompanion
    extends UpdateCompanion<MicroSkillExplanation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> microSkillId;
  final Value<String> body;
  final Value<int> rowid;
  const MicroSkillExplanationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.microSkillId = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MicroSkillExplanationsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String microSkillId,
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       microSkillId = Value(microSkillId),
       body = Value(body);
  static Insertable<MicroSkillExplanation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? microSkillId,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (microSkillId != null) 'micro_skill_id': microSkillId,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MicroSkillExplanationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? microSkillId,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return MicroSkillExplanationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      microSkillId: microSkillId ?? this.microSkillId,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (microSkillId.present) {
      map['micro_skill_id'] = Variable<String>(microSkillId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MicroSkillExplanationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $QuestionsTable extends Questions
    with TableInfo<$QuestionsTable, Question> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $QuestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _microSkillIdMeta = const VerificationMeta(
    'microSkillId',
  );
  @override
  late final GeneratedColumn<String> microSkillId = GeneratedColumn<String>(
    'micro_skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _difficultyMeta = const VerificationMeta(
    'difficulty',
  );
  @override
  late final GeneratedColumn<int> difficulty = GeneratedColumn<int>(
    'difficulty',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _stemMeta = const VerificationMeta('stem');
  @override
  late final GeneratedColumn<String> stem = GeneratedColumn<String>(
    'stem',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _optionsMeta = const VerificationMeta(
    'options',
  );
  @override
  late final GeneratedColumn<String> options = GeneratedColumn<String>(
    'options',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _correctIndexMeta = const VerificationMeta(
    'correctIndex',
  );
  @override
  late final GeneratedColumn<int> correctIndex = GeneratedColumn<int>(
    'correct_index',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rationaleMeta = const VerificationMeta(
    'rationale',
  );
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
    'rationale',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _provenanceMeta = const VerificationMeta(
    'provenance',
  );
  @override
  late final GeneratedColumn<String> provenance = GeneratedColumn<String>(
    'provenance',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pool'),
  );
  static const VerificationMeta _forStudentIdMeta = const VerificationMeta(
    'forStudentId',
  );
  @override
  late final GeneratedColumn<String> forStudentId = GeneratedColumn<String>(
    'for_student_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _materialIdMeta = const VerificationMeta(
    'materialId',
  );
  @override
  late final GeneratedColumn<String> materialId = GeneratedColumn<String>(
    'material_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    microSkillId,
    difficulty,
    stem,
    options,
    correctIndex,
    rationale,
    provenance,
    forStudentId,
    materialId,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'questions';
  @override
  VerificationContext validateIntegrity(
    Insertable<Question> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('micro_skill_id')) {
      context.handle(
        _microSkillIdMeta,
        microSkillId.isAcceptableOrUnknown(
          data['micro_skill_id']!,
          _microSkillIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_microSkillIdMeta);
    }
    if (data.containsKey('difficulty')) {
      context.handle(
        _difficultyMeta,
        difficulty.isAcceptableOrUnknown(data['difficulty']!, _difficultyMeta),
      );
    } else if (isInserting) {
      context.missing(_difficultyMeta);
    }
    if (data.containsKey('stem')) {
      context.handle(
        _stemMeta,
        stem.isAcceptableOrUnknown(data['stem']!, _stemMeta),
      );
    } else if (isInserting) {
      context.missing(_stemMeta);
    }
    if (data.containsKey('options')) {
      context.handle(
        _optionsMeta,
        options.isAcceptableOrUnknown(data['options']!, _optionsMeta),
      );
    } else if (isInserting) {
      context.missing(_optionsMeta);
    }
    if (data.containsKey('correct_index')) {
      context.handle(
        _correctIndexMeta,
        correctIndex.isAcceptableOrUnknown(
          data['correct_index']!,
          _correctIndexMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_correctIndexMeta);
    }
    if (data.containsKey('rationale')) {
      context.handle(
        _rationaleMeta,
        rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta),
      );
    }
    if (data.containsKey('provenance')) {
      context.handle(
        _provenanceMeta,
        provenance.isAcceptableOrUnknown(data['provenance']!, _provenanceMeta),
      );
    }
    if (data.containsKey('for_student_id')) {
      context.handle(
        _forStudentIdMeta,
        forStudentId.isAcceptableOrUnknown(
          data['for_student_id']!,
          _forStudentIdMeta,
        ),
      );
    }
    if (data.containsKey('material_id')) {
      context.handle(
        _materialIdMeta,
        materialId.isAcceptableOrUnknown(data['material_id']!, _materialIdMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Question map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Question(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      microSkillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}micro_skill_id'],
      )!,
      difficulty: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}difficulty'],
      )!,
      stem: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}stem'],
      )!,
      options: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}options'],
      )!,
      correctIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}correct_index'],
      )!,
      rationale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rationale'],
      ),
      provenance: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}provenance'],
      )!,
      forStudentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}for_student_id'],
      ),
      materialId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}material_id'],
      ),
    );
  }

  @override
  $QuestionsTable createAlias(String alias) {
    return $QuestionsTable(attachedDatabase, alias);
  }
}

class Question extends DataClass implements Insertable<Question> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String chapterId;
  final String microSkillId;
  final int difficulty;
  final String stem;
  final String options;
  final int correctIndex;
  final String? rationale;
  final String provenance;
  final String? forStudentId;
  final String? materialId;
  const Question({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.chapterId,
    required this.microSkillId,
    required this.difficulty,
    required this.stem,
    required this.options,
    required this.correctIndex,
    this.rationale,
    required this.provenance,
    this.forStudentId,
    this.materialId,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['micro_skill_id'] = Variable<String>(microSkillId);
    map['difficulty'] = Variable<int>(difficulty);
    map['stem'] = Variable<String>(stem);
    map['options'] = Variable<String>(options);
    map['correct_index'] = Variable<int>(correctIndex);
    if (!nullToAbsent || rationale != null) {
      map['rationale'] = Variable<String>(rationale);
    }
    map['provenance'] = Variable<String>(provenance);
    if (!nullToAbsent || forStudentId != null) {
      map['for_student_id'] = Variable<String>(forStudentId);
    }
    if (!nullToAbsent || materialId != null) {
      map['material_id'] = Variable<String>(materialId);
    }
    return map;
  }

  QuestionsCompanion toCompanion(bool nullToAbsent) {
    return QuestionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      chapterId: Value(chapterId),
      microSkillId: Value(microSkillId),
      difficulty: Value(difficulty),
      stem: Value(stem),
      options: Value(options),
      correctIndex: Value(correctIndex),
      rationale: rationale == null && nullToAbsent
          ? const Value.absent()
          : Value(rationale),
      provenance: Value(provenance),
      forStudentId: forStudentId == null && nullToAbsent
          ? const Value.absent()
          : Value(forStudentId),
      materialId: materialId == null && nullToAbsent
          ? const Value.absent()
          : Value(materialId),
    );
  }

  factory Question.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Question(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      microSkillId: serializer.fromJson<String>(json['microSkillId']),
      difficulty: serializer.fromJson<int>(json['difficulty']),
      stem: serializer.fromJson<String>(json['stem']),
      options: serializer.fromJson<String>(json['options']),
      correctIndex: serializer.fromJson<int>(json['correctIndex']),
      rationale: serializer.fromJson<String?>(json['rationale']),
      provenance: serializer.fromJson<String>(json['provenance']),
      forStudentId: serializer.fromJson<String?>(json['forStudentId']),
      materialId: serializer.fromJson<String?>(json['materialId']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'chapterId': serializer.toJson<String>(chapterId),
      'microSkillId': serializer.toJson<String>(microSkillId),
      'difficulty': serializer.toJson<int>(difficulty),
      'stem': serializer.toJson<String>(stem),
      'options': serializer.toJson<String>(options),
      'correctIndex': serializer.toJson<int>(correctIndex),
      'rationale': serializer.toJson<String?>(rationale),
      'provenance': serializer.toJson<String>(provenance),
      'forStudentId': serializer.toJson<String?>(forStudentId),
      'materialId': serializer.toJson<String?>(materialId),
    };
  }

  Question copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? chapterId,
    String? microSkillId,
    int? difficulty,
    String? stem,
    String? options,
    int? correctIndex,
    Value<String?> rationale = const Value.absent(),
    String? provenance,
    Value<String?> forStudentId = const Value.absent(),
    Value<String?> materialId = const Value.absent(),
  }) => Question(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    chapterId: chapterId ?? this.chapterId,
    microSkillId: microSkillId ?? this.microSkillId,
    difficulty: difficulty ?? this.difficulty,
    stem: stem ?? this.stem,
    options: options ?? this.options,
    correctIndex: correctIndex ?? this.correctIndex,
    rationale: rationale.present ? rationale.value : this.rationale,
    provenance: provenance ?? this.provenance,
    forStudentId: forStudentId.present ? forStudentId.value : this.forStudentId,
    materialId: materialId.present ? materialId.value : this.materialId,
  );
  Question copyWithCompanion(QuestionsCompanion data) {
    return Question(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      microSkillId: data.microSkillId.present
          ? data.microSkillId.value
          : this.microSkillId,
      difficulty: data.difficulty.present
          ? data.difficulty.value
          : this.difficulty,
      stem: data.stem.present ? data.stem.value : this.stem,
      options: data.options.present ? data.options.value : this.options,
      correctIndex: data.correctIndex.present
          ? data.correctIndex.value
          : this.correctIndex,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      provenance: data.provenance.present
          ? data.provenance.value
          : this.provenance,
      forStudentId: data.forStudentId.present
          ? data.forStudentId.value
          : this.forStudentId,
      materialId: data.materialId.present
          ? data.materialId.value
          : this.materialId,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Question(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('difficulty: $difficulty, ')
          ..write('stem: $stem, ')
          ..write('options: $options, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('rationale: $rationale, ')
          ..write('provenance: $provenance, ')
          ..write('forStudentId: $forStudentId, ')
          ..write('materialId: $materialId')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    microSkillId,
    difficulty,
    stem,
    options,
    correctIndex,
    rationale,
    provenance,
    forStudentId,
    materialId,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Question &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.chapterId == this.chapterId &&
          other.microSkillId == this.microSkillId &&
          other.difficulty == this.difficulty &&
          other.stem == this.stem &&
          other.options == this.options &&
          other.correctIndex == this.correctIndex &&
          other.rationale == this.rationale &&
          other.provenance == this.provenance &&
          other.forStudentId == this.forStudentId &&
          other.materialId == this.materialId);
}

class QuestionsCompanion extends UpdateCompanion<Question> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> chapterId;
  final Value<String> microSkillId;
  final Value<int> difficulty;
  final Value<String> stem;
  final Value<String> options;
  final Value<int> correctIndex;
  final Value<String?> rationale;
  final Value<String> provenance;
  final Value<String?> forStudentId;
  final Value<String?> materialId;
  final Value<int> rowid;
  const QuestionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.microSkillId = const Value.absent(),
    this.difficulty = const Value.absent(),
    this.stem = const Value.absent(),
    this.options = const Value.absent(),
    this.correctIndex = const Value.absent(),
    this.rationale = const Value.absent(),
    this.provenance = const Value.absent(),
    this.forStudentId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  QuestionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String chapterId,
    required String microSkillId,
    required int difficulty,
    required String stem,
    required String options,
    required int correctIndex,
    this.rationale = const Value.absent(),
    this.provenance = const Value.absent(),
    this.forStudentId = const Value.absent(),
    this.materialId = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       chapterId = Value(chapterId),
       microSkillId = Value(microSkillId),
       difficulty = Value(difficulty),
       stem = Value(stem),
       options = Value(options),
       correctIndex = Value(correctIndex);
  static Insertable<Question> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? chapterId,
    Expression<String>? microSkillId,
    Expression<int>? difficulty,
    Expression<String>? stem,
    Expression<String>? options,
    Expression<int>? correctIndex,
    Expression<String>? rationale,
    Expression<String>? provenance,
    Expression<String>? forStudentId,
    Expression<String>? materialId,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (microSkillId != null) 'micro_skill_id': microSkillId,
      if (difficulty != null) 'difficulty': difficulty,
      if (stem != null) 'stem': stem,
      if (options != null) 'options': options,
      if (correctIndex != null) 'correct_index': correctIndex,
      if (rationale != null) 'rationale': rationale,
      if (provenance != null) 'provenance': provenance,
      if (forStudentId != null) 'for_student_id': forStudentId,
      if (materialId != null) 'material_id': materialId,
      if (rowid != null) 'rowid': rowid,
    });
  }

  QuestionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? chapterId,
    Value<String>? microSkillId,
    Value<int>? difficulty,
    Value<String>? stem,
    Value<String>? options,
    Value<int>? correctIndex,
    Value<String?>? rationale,
    Value<String>? provenance,
    Value<String?>? forStudentId,
    Value<String?>? materialId,
    Value<int>? rowid,
  }) {
    return QuestionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      chapterId: chapterId ?? this.chapterId,
      microSkillId: microSkillId ?? this.microSkillId,
      difficulty: difficulty ?? this.difficulty,
      stem: stem ?? this.stem,
      options: options ?? this.options,
      correctIndex: correctIndex ?? this.correctIndex,
      rationale: rationale ?? this.rationale,
      provenance: provenance ?? this.provenance,
      forStudentId: forStudentId ?? this.forStudentId,
      materialId: materialId ?? this.materialId,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (microSkillId.present) {
      map['micro_skill_id'] = Variable<String>(microSkillId.value);
    }
    if (difficulty.present) {
      map['difficulty'] = Variable<int>(difficulty.value);
    }
    if (stem.present) {
      map['stem'] = Variable<String>(stem.value);
    }
    if (options.present) {
      map['options'] = Variable<String>(options.value);
    }
    if (correctIndex.present) {
      map['correct_index'] = Variable<int>(correctIndex.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (provenance.present) {
      map['provenance'] = Variable<String>(provenance.value);
    }
    if (forStudentId.present) {
      map['for_student_id'] = Variable<String>(forStudentId.value);
    }
    if (materialId.present) {
      map['material_id'] = Variable<String>(materialId.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('QuestionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('difficulty: $difficulty, ')
          ..write('stem: $stem, ')
          ..write('options: $options, ')
          ..write('correctIndex: $correctIndex, ')
          ..write('rationale: $rationale, ')
          ..write('provenance: $provenance, ')
          ..write('forStudentId: $forStudentId, ')
          ..write('materialId: $materialId, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptsTable extends Attempts with TableInfo<$AttemptsTable, Attempt> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdsMeta = const VerificationMeta(
    'chapterIds',
  );
  @override
  late final GeneratedColumn<String> chapterIds = GeneratedColumn<String>(
    'chapter_ids',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _modeMeta = const VerificationMeta('mode');
  @override
  late final GeneratedColumn<String> mode = GeneratedColumn<String>(
    'mode',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptNumberMeta = const VerificationMeta(
    'attemptNumber',
  );
  @override
  late final GeneratedColumn<int> attemptNumber = GeneratedColumn<int>(
    'attempt_number',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  static const VerificationMeta _parentAttemptIdMeta = const VerificationMeta(
    'parentAttemptId',
  );
  @override
  late final GeneratedColumn<String> parentAttemptId = GeneratedColumn<String>(
    'parent_attempt_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _questionCountMeta = const VerificationMeta(
    'questionCount',
  );
  @override
  late final GeneratedColumn<int> questionCount = GeneratedColumn<int>(
    'question_count',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _scoreMeta = const VerificationMeta('score');
  @override
  late final GeneratedColumn<int> score = GeneratedColumn<int>(
    'score',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _startedAtMeta = const VerificationMeta(
    'startedAt',
  );
  @override
  late final GeneratedColumn<DateTime> startedAt = GeneratedColumn<DateTime>(
    'started_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _submittedAtMeta = const VerificationMeta(
    'submittedAt',
  );
  @override
  late final GeneratedColumn<DateTime> submittedAt = GeneratedColumn<DateTime>(
    'submitted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    chapterIds,
    mode,
    attemptNumber,
    parentAttemptId,
    questionCount,
    score,
    startedAt,
    submittedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempts';
  @override
  VerificationContext validateIntegrity(
    Insertable<Attempt> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('chapter_ids')) {
      context.handle(
        _chapterIdsMeta,
        chapterIds.isAcceptableOrUnknown(data['chapter_ids']!, _chapterIdsMeta),
      );
    }
    if (data.containsKey('mode')) {
      context.handle(
        _modeMeta,
        mode.isAcceptableOrUnknown(data['mode']!, _modeMeta),
      );
    } else if (isInserting) {
      context.missing(_modeMeta);
    }
    if (data.containsKey('attempt_number')) {
      context.handle(
        _attemptNumberMeta,
        attemptNumber.isAcceptableOrUnknown(
          data['attempt_number']!,
          _attemptNumberMeta,
        ),
      );
    }
    if (data.containsKey('parent_attempt_id')) {
      context.handle(
        _parentAttemptIdMeta,
        parentAttemptId.isAcceptableOrUnknown(
          data['parent_attempt_id']!,
          _parentAttemptIdMeta,
        ),
      );
    }
    if (data.containsKey('question_count')) {
      context.handle(
        _questionCountMeta,
        questionCount.isAcceptableOrUnknown(
          data['question_count']!,
          _questionCountMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_questionCountMeta);
    }
    if (data.containsKey('score')) {
      context.handle(
        _scoreMeta,
        score.isAcceptableOrUnknown(data['score']!, _scoreMeta),
      );
    }
    if (data.containsKey('started_at')) {
      context.handle(
        _startedAtMeta,
        startedAt.isAcceptableOrUnknown(data['started_at']!, _startedAtMeta),
      );
    }
    if (data.containsKey('submitted_at')) {
      context.handle(
        _submittedAtMeta,
        submittedAt.isAcceptableOrUnknown(
          data['submitted_at']!,
          _submittedAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Attempt map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Attempt(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      chapterIds: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_ids'],
      )!,
      mode: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mode'],
      )!,
      attemptNumber: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempt_number'],
      )!,
      parentAttemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}parent_attempt_id'],
      ),
      questionCount: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}question_count'],
      )!,
      score: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}score'],
      )!,
      startedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}started_at'],
      ),
      submittedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}submitted_at'],
      ),
    );
  }

  @override
  $AttemptsTable createAlias(String alias) {
    return $AttemptsTable(attachedDatabase, alias);
  }
}

class Attempt extends DataClass implements Insertable<Attempt> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String chapterIds;
  final String mode;
  final int attemptNumber;
  final String? parentAttemptId;
  final int questionCount;
  final int score;
  final DateTime? startedAt;
  final DateTime? submittedAt;
  const Attempt({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    required this.chapterIds,
    required this.mode,
    required this.attemptNumber,
    this.parentAttemptId,
    required this.questionCount,
    required this.score,
    this.startedAt,
    this.submittedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['chapter_ids'] = Variable<String>(chapterIds);
    map['mode'] = Variable<String>(mode);
    map['attempt_number'] = Variable<int>(attemptNumber);
    if (!nullToAbsent || parentAttemptId != null) {
      map['parent_attempt_id'] = Variable<String>(parentAttemptId);
    }
    map['question_count'] = Variable<int>(questionCount);
    map['score'] = Variable<int>(score);
    if (!nullToAbsent || startedAt != null) {
      map['started_at'] = Variable<DateTime>(startedAt);
    }
    if (!nullToAbsent || submittedAt != null) {
      map['submitted_at'] = Variable<DateTime>(submittedAt);
    }
    return map;
  }

  AttemptsCompanion toCompanion(bool nullToAbsent) {
    return AttemptsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      chapterIds: Value(chapterIds),
      mode: Value(mode),
      attemptNumber: Value(attemptNumber),
      parentAttemptId: parentAttemptId == null && nullToAbsent
          ? const Value.absent()
          : Value(parentAttemptId),
      questionCount: Value(questionCount),
      score: Value(score),
      startedAt: startedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(startedAt),
      submittedAt: submittedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(submittedAt),
    );
  }

  factory Attempt.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Attempt(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      chapterIds: serializer.fromJson<String>(json['chapterIds']),
      mode: serializer.fromJson<String>(json['mode']),
      attemptNumber: serializer.fromJson<int>(json['attemptNumber']),
      parentAttemptId: serializer.fromJson<String?>(json['parentAttemptId']),
      questionCount: serializer.fromJson<int>(json['questionCount']),
      score: serializer.fromJson<int>(json['score']),
      startedAt: serializer.fromJson<DateTime?>(json['startedAt']),
      submittedAt: serializer.fromJson<DateTime?>(json['submittedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'chapterIds': serializer.toJson<String>(chapterIds),
      'mode': serializer.toJson<String>(mode),
      'attemptNumber': serializer.toJson<int>(attemptNumber),
      'parentAttemptId': serializer.toJson<String?>(parentAttemptId),
      'questionCount': serializer.toJson<int>(questionCount),
      'score': serializer.toJson<int>(score),
      'startedAt': serializer.toJson<DateTime?>(startedAt),
      'submittedAt': serializer.toJson<DateTime?>(submittedAt),
    };
  }

  Attempt copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    String? chapterIds,
    String? mode,
    int? attemptNumber,
    Value<String?> parentAttemptId = const Value.absent(),
    int? questionCount,
    int? score,
    Value<DateTime?> startedAt = const Value.absent(),
    Value<DateTime?> submittedAt = const Value.absent(),
  }) => Attempt(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    chapterIds: chapterIds ?? this.chapterIds,
    mode: mode ?? this.mode,
    attemptNumber: attemptNumber ?? this.attemptNumber,
    parentAttemptId: parentAttemptId.present
        ? parentAttemptId.value
        : this.parentAttemptId,
    questionCount: questionCount ?? this.questionCount,
    score: score ?? this.score,
    startedAt: startedAt.present ? startedAt.value : this.startedAt,
    submittedAt: submittedAt.present ? submittedAt.value : this.submittedAt,
  );
  Attempt copyWithCompanion(AttemptsCompanion data) {
    return Attempt(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      chapterIds: data.chapterIds.present
          ? data.chapterIds.value
          : this.chapterIds,
      mode: data.mode.present ? data.mode.value : this.mode,
      attemptNumber: data.attemptNumber.present
          ? data.attemptNumber.value
          : this.attemptNumber,
      parentAttemptId: data.parentAttemptId.present
          ? data.parentAttemptId.value
          : this.parentAttemptId,
      questionCount: data.questionCount.present
          ? data.questionCount.value
          : this.questionCount,
      score: data.score.present ? data.score.value : this.score,
      startedAt: data.startedAt.present ? data.startedAt.value : this.startedAt,
      submittedAt: data.submittedAt.present
          ? data.submittedAt.value
          : this.submittedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Attempt(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('chapterIds: $chapterIds, ')
          ..write('mode: $mode, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('parentAttemptId: $parentAttemptId, ')
          ..write('questionCount: $questionCount, ')
          ..write('score: $score, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    chapterIds,
    mode,
    attemptNumber,
    parentAttemptId,
    questionCount,
    score,
    startedAt,
    submittedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Attempt &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.chapterIds == this.chapterIds &&
          other.mode == this.mode &&
          other.attemptNumber == this.attemptNumber &&
          other.parentAttemptId == this.parentAttemptId &&
          other.questionCount == this.questionCount &&
          other.score == this.score &&
          other.startedAt == this.startedAt &&
          other.submittedAt == this.submittedAt);
}

class AttemptsCompanion extends UpdateCompanion<Attempt> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> chapterIds;
  final Value<String> mode;
  final Value<int> attemptNumber;
  final Value<String?> parentAttemptId;
  final Value<int> questionCount;
  final Value<int> score;
  final Value<DateTime?> startedAt;
  final Value<DateTime?> submittedAt;
  final Value<int> rowid;
  const AttemptsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.chapterIds = const Value.absent(),
    this.mode = const Value.absent(),
    this.attemptNumber = const Value.absent(),
    this.parentAttemptId = const Value.absent(),
    this.questionCount = const Value.absent(),
    this.score = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    this.chapterIds = const Value.absent(),
    required String mode,
    this.attemptNumber = const Value.absent(),
    this.parentAttemptId = const Value.absent(),
    required int questionCount,
    this.score = const Value.absent(),
    this.startedAt = const Value.absent(),
    this.submittedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       mode = Value(mode),
       questionCount = Value(questionCount);
  static Insertable<Attempt> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? chapterIds,
    Expression<String>? mode,
    Expression<int>? attemptNumber,
    Expression<String>? parentAttemptId,
    Expression<int>? questionCount,
    Expression<int>? score,
    Expression<DateTime>? startedAt,
    Expression<DateTime>? submittedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (chapterIds != null) 'chapter_ids': chapterIds,
      if (mode != null) 'mode': mode,
      if (attemptNumber != null) 'attempt_number': attemptNumber,
      if (parentAttemptId != null) 'parent_attempt_id': parentAttemptId,
      if (questionCount != null) 'question_count': questionCount,
      if (score != null) 'score': score,
      if (startedAt != null) 'started_at': startedAt,
      if (submittedAt != null) 'submitted_at': submittedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? chapterIds,
    Value<String>? mode,
    Value<int>? attemptNumber,
    Value<String?>? parentAttemptId,
    Value<int>? questionCount,
    Value<int>? score,
    Value<DateTime?>? startedAt,
    Value<DateTime?>? submittedAt,
    Value<int>? rowid,
  }) {
    return AttemptsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      chapterIds: chapterIds ?? this.chapterIds,
      mode: mode ?? this.mode,
      attemptNumber: attemptNumber ?? this.attemptNumber,
      parentAttemptId: parentAttemptId ?? this.parentAttemptId,
      questionCount: questionCount ?? this.questionCount,
      score: score ?? this.score,
      startedAt: startedAt ?? this.startedAt,
      submittedAt: submittedAt ?? this.submittedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (chapterIds.present) {
      map['chapter_ids'] = Variable<String>(chapterIds.value);
    }
    if (mode.present) {
      map['mode'] = Variable<String>(mode.value);
    }
    if (attemptNumber.present) {
      map['attempt_number'] = Variable<int>(attemptNumber.value);
    }
    if (parentAttemptId.present) {
      map['parent_attempt_id'] = Variable<String>(parentAttemptId.value);
    }
    if (questionCount.present) {
      map['question_count'] = Variable<int>(questionCount.value);
    }
    if (score.present) {
      map['score'] = Variable<int>(score.value);
    }
    if (startedAt.present) {
      map['started_at'] = Variable<DateTime>(startedAt.value);
    }
    if (submittedAt.present) {
      map['submitted_at'] = Variable<DateTime>(submittedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('chapterIds: $chapterIds, ')
          ..write('mode: $mode, ')
          ..write('attemptNumber: $attemptNumber, ')
          ..write('parentAttemptId: $parentAttemptId, ')
          ..write('questionCount: $questionCount, ')
          ..write('score: $score, ')
          ..write('startedAt: $startedAt, ')
          ..write('submittedAt: $submittedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $AttemptItemsTable extends AttemptItems
    with TableInfo<$AttemptItemsTable, AttemptItem> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $AttemptItemsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptIdMeta = const VerificationMeta(
    'attemptId',
  );
  @override
  late final GeneratedColumn<String> attemptId = GeneratedColumn<String>(
    'attempt_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _questionIdMeta = const VerificationMeta(
    'questionId',
  );
  @override
  late final GeneratedColumn<String> questionId = GeneratedColumn<String>(
    'question_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _microSkillIdMeta = const VerificationMeta(
    'microSkillId',
  );
  @override
  late final GeneratedColumn<String> microSkillId = GeneratedColumn<String>(
    'micro_skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _selectedIndexMeta = const VerificationMeta(
    'selectedIndex',
  );
  @override
  late final GeneratedColumn<int> selectedIndex = GeneratedColumn<int>(
    'selected_index',
    aliasedName,
    true,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _isCorrectMeta = const VerificationMeta(
    'isCorrect',
  );
  @override
  late final GeneratedColumn<bool> isCorrect = GeneratedColumn<bool>(
    'is_correct',
    aliasedName,
    false,
    type: DriftSqlType.bool,
    requiredDuringInsert: true,
    defaultConstraints: GeneratedColumn.constraintIsAlways(
      'CHECK ("is_correct" IN (0, 1))',
    ),
  );
  static const VerificationMeta _ordinalMeta = const VerificationMeta(
    'ordinal',
  );
  @override
  late final GeneratedColumn<int> ordinal = GeneratedColumn<int>(
    'ordinal',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    attemptId,
    questionId,
    microSkillId,
    selectedIndex,
    isCorrect,
    ordinal,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'attempt_items';
  @override
  VerificationContext validateIntegrity(
    Insertable<AttemptItem> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('attempt_id')) {
      context.handle(
        _attemptIdMeta,
        attemptId.isAcceptableOrUnknown(data['attempt_id']!, _attemptIdMeta),
      );
    } else if (isInserting) {
      context.missing(_attemptIdMeta);
    }
    if (data.containsKey('question_id')) {
      context.handle(
        _questionIdMeta,
        questionId.isAcceptableOrUnknown(data['question_id']!, _questionIdMeta),
      );
    }
    if (data.containsKey('micro_skill_id')) {
      context.handle(
        _microSkillIdMeta,
        microSkillId.isAcceptableOrUnknown(
          data['micro_skill_id']!,
          _microSkillIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_microSkillIdMeta);
    }
    if (data.containsKey('selected_index')) {
      context.handle(
        _selectedIndexMeta,
        selectedIndex.isAcceptableOrUnknown(
          data['selected_index']!,
          _selectedIndexMeta,
        ),
      );
    }
    if (data.containsKey('is_correct')) {
      context.handle(
        _isCorrectMeta,
        isCorrect.isAcceptableOrUnknown(data['is_correct']!, _isCorrectMeta),
      );
    } else if (isInserting) {
      context.missing(_isCorrectMeta);
    }
    if (data.containsKey('ordinal')) {
      context.handle(
        _ordinalMeta,
        ordinal.isAcceptableOrUnknown(data['ordinal']!, _ordinalMeta),
      );
    } else if (isInserting) {
      context.missing(_ordinalMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  AttemptItem map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return AttemptItem(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      attemptId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempt_id'],
      )!,
      questionId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}question_id'],
      ),
      microSkillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}micro_skill_id'],
      )!,
      selectedIndex: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}selected_index'],
      ),
      isCorrect: attachedDatabase.typeMapping.read(
        DriftSqlType.bool,
        data['${effectivePrefix}is_correct'],
      )!,
      ordinal: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}ordinal'],
      )!,
    );
  }

  @override
  $AttemptItemsTable createAlias(String alias) {
    return $AttemptItemsTable(attachedDatabase, alias);
  }
}

class AttemptItem extends DataClass implements Insertable<AttemptItem> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String attemptId;
  final String? questionId;
  final String microSkillId;
  final int? selectedIndex;
  final bool isCorrect;
  final int ordinal;
  const AttemptItem({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.attemptId,
    this.questionId,
    required this.microSkillId,
    this.selectedIndex,
    required this.isCorrect,
    required this.ordinal,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['attempt_id'] = Variable<String>(attemptId);
    if (!nullToAbsent || questionId != null) {
      map['question_id'] = Variable<String>(questionId);
    }
    map['micro_skill_id'] = Variable<String>(microSkillId);
    if (!nullToAbsent || selectedIndex != null) {
      map['selected_index'] = Variable<int>(selectedIndex);
    }
    map['is_correct'] = Variable<bool>(isCorrect);
    map['ordinal'] = Variable<int>(ordinal);
    return map;
  }

  AttemptItemsCompanion toCompanion(bool nullToAbsent) {
    return AttemptItemsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      attemptId: Value(attemptId),
      questionId: questionId == null && nullToAbsent
          ? const Value.absent()
          : Value(questionId),
      microSkillId: Value(microSkillId),
      selectedIndex: selectedIndex == null && nullToAbsent
          ? const Value.absent()
          : Value(selectedIndex),
      isCorrect: Value(isCorrect),
      ordinal: Value(ordinal),
    );
  }

  factory AttemptItem.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return AttemptItem(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      attemptId: serializer.fromJson<String>(json['attemptId']),
      questionId: serializer.fromJson<String?>(json['questionId']),
      microSkillId: serializer.fromJson<String>(json['microSkillId']),
      selectedIndex: serializer.fromJson<int?>(json['selectedIndex']),
      isCorrect: serializer.fromJson<bool>(json['isCorrect']),
      ordinal: serializer.fromJson<int>(json['ordinal']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'attemptId': serializer.toJson<String>(attemptId),
      'questionId': serializer.toJson<String?>(questionId),
      'microSkillId': serializer.toJson<String>(microSkillId),
      'selectedIndex': serializer.toJson<int?>(selectedIndex),
      'isCorrect': serializer.toJson<bool>(isCorrect),
      'ordinal': serializer.toJson<int>(ordinal),
    };
  }

  AttemptItem copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? attemptId,
    Value<String?> questionId = const Value.absent(),
    String? microSkillId,
    Value<int?> selectedIndex = const Value.absent(),
    bool? isCorrect,
    int? ordinal,
  }) => AttemptItem(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    attemptId: attemptId ?? this.attemptId,
    questionId: questionId.present ? questionId.value : this.questionId,
    microSkillId: microSkillId ?? this.microSkillId,
    selectedIndex: selectedIndex.present
        ? selectedIndex.value
        : this.selectedIndex,
    isCorrect: isCorrect ?? this.isCorrect,
    ordinal: ordinal ?? this.ordinal,
  );
  AttemptItem copyWithCompanion(AttemptItemsCompanion data) {
    return AttemptItem(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      attemptId: data.attemptId.present ? data.attemptId.value : this.attemptId,
      questionId: data.questionId.present
          ? data.questionId.value
          : this.questionId,
      microSkillId: data.microSkillId.present
          ? data.microSkillId.value
          : this.microSkillId,
      selectedIndex: data.selectedIndex.present
          ? data.selectedIndex.value
          : this.selectedIndex,
      isCorrect: data.isCorrect.present ? data.isCorrect.value : this.isCorrect,
      ordinal: data.ordinal.present ? data.ordinal.value : this.ordinal,
    );
  }

  @override
  String toString() {
    return (StringBuffer('AttemptItem(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('ordinal: $ordinal')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    attemptId,
    questionId,
    microSkillId,
    selectedIndex,
    isCorrect,
    ordinal,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is AttemptItem &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.attemptId == this.attemptId &&
          other.questionId == this.questionId &&
          other.microSkillId == this.microSkillId &&
          other.selectedIndex == this.selectedIndex &&
          other.isCorrect == this.isCorrect &&
          other.ordinal == this.ordinal);
}

class AttemptItemsCompanion extends UpdateCompanion<AttemptItem> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> attemptId;
  final Value<String?> questionId;
  final Value<String> microSkillId;
  final Value<int?> selectedIndex;
  final Value<bool> isCorrect;
  final Value<int> ordinal;
  final Value<int> rowid;
  const AttemptItemsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.attemptId = const Value.absent(),
    this.questionId = const Value.absent(),
    this.microSkillId = const Value.absent(),
    this.selectedIndex = const Value.absent(),
    this.isCorrect = const Value.absent(),
    this.ordinal = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  AttemptItemsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String attemptId,
    this.questionId = const Value.absent(),
    required String microSkillId,
    this.selectedIndex = const Value.absent(),
    required bool isCorrect,
    required int ordinal,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       attemptId = Value(attemptId),
       microSkillId = Value(microSkillId),
       isCorrect = Value(isCorrect),
       ordinal = Value(ordinal);
  static Insertable<AttemptItem> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? attemptId,
    Expression<String>? questionId,
    Expression<String>? microSkillId,
    Expression<int>? selectedIndex,
    Expression<bool>? isCorrect,
    Expression<int>? ordinal,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (attemptId != null) 'attempt_id': attemptId,
      if (questionId != null) 'question_id': questionId,
      if (microSkillId != null) 'micro_skill_id': microSkillId,
      if (selectedIndex != null) 'selected_index': selectedIndex,
      if (isCorrect != null) 'is_correct': isCorrect,
      if (ordinal != null) 'ordinal': ordinal,
      if (rowid != null) 'rowid': rowid,
    });
  }

  AttemptItemsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? attemptId,
    Value<String?>? questionId,
    Value<String>? microSkillId,
    Value<int?>? selectedIndex,
    Value<bool>? isCorrect,
    Value<int>? ordinal,
    Value<int>? rowid,
  }) {
    return AttemptItemsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      attemptId: attemptId ?? this.attemptId,
      questionId: questionId ?? this.questionId,
      microSkillId: microSkillId ?? this.microSkillId,
      selectedIndex: selectedIndex ?? this.selectedIndex,
      isCorrect: isCorrect ?? this.isCorrect,
      ordinal: ordinal ?? this.ordinal,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (attemptId.present) {
      map['attempt_id'] = Variable<String>(attemptId.value);
    }
    if (questionId.present) {
      map['question_id'] = Variable<String>(questionId.value);
    }
    if (microSkillId.present) {
      map['micro_skill_id'] = Variable<String>(microSkillId.value);
    }
    if (selectedIndex.present) {
      map['selected_index'] = Variable<int>(selectedIndex.value);
    }
    if (isCorrect.present) {
      map['is_correct'] = Variable<bool>(isCorrect.value);
    }
    if (ordinal.present) {
      map['ordinal'] = Variable<int>(ordinal.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('AttemptItemsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('attemptId: $attemptId, ')
          ..write('questionId: $questionId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('selectedIndex: $selectedIndex, ')
          ..write('isCorrect: $isCorrect, ')
          ..write('ordinal: $ordinal, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $WeaknessesTable extends Weaknesses
    with TableInfo<$WeaknessesTable, WeaknessesData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $WeaknessesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _microSkillIdMeta = const VerificationMeta(
    'microSkillId',
  );
  @override
  late final GeneratedColumn<String> microSkillId = GeneratedColumn<String>(
    'micro_skill_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _weightMeta = const VerificationMeta('weight');
  @override
  late final GeneratedColumn<double> weight = GeneratedColumn<double>(
    'weight',
    aliasedName,
    false,
    type: DriftSqlType.double,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    microSkillId,
    weight,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'weaknesses';
  @override
  VerificationContext validateIntegrity(
    Insertable<WeaknessesData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('micro_skill_id')) {
      context.handle(
        _microSkillIdMeta,
        microSkillId.isAcceptableOrUnknown(
          data['micro_skill_id']!,
          _microSkillIdMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_microSkillIdMeta);
    }
    if (data.containsKey('weight')) {
      context.handle(
        _weightMeta,
        weight.isAcceptableOrUnknown(data['weight']!, _weightMeta),
      );
    } else if (isInserting) {
      context.missing(_weightMeta);
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    } else if (isInserting) {
      context.missing(_sourceMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  WeaknessesData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return WeaknessesData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      microSkillId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}micro_skill_id'],
      )!,
      weight: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}weight'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $WeaknessesTable createAlias(String alias) {
    return $WeaknessesTable(attachedDatabase, alias);
  }
}

class WeaknessesData extends DataClass implements Insertable<WeaknessesData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String microSkillId;
  final double weight;
  final String source;
  const WeaknessesData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    required this.microSkillId,
    required this.weight,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['micro_skill_id'] = Variable<String>(microSkillId);
    map['weight'] = Variable<double>(weight);
    map['source'] = Variable<String>(source);
    return map;
  }

  WeaknessesCompanion toCompanion(bool nullToAbsent) {
    return WeaknessesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      microSkillId: Value(microSkillId),
      weight: Value(weight),
      source: Value(source),
    );
  }

  factory WeaknessesData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return WeaknessesData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      microSkillId: serializer.fromJson<String>(json['microSkillId']),
      weight: serializer.fromJson<double>(json['weight']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'microSkillId': serializer.toJson<String>(microSkillId),
      'weight': serializer.toJson<double>(weight),
      'source': serializer.toJson<String>(source),
    };
  }

  WeaknessesData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    String? microSkillId,
    double? weight,
    String? source,
  }) => WeaknessesData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    microSkillId: microSkillId ?? this.microSkillId,
    weight: weight ?? this.weight,
    source: source ?? this.source,
  );
  WeaknessesData copyWithCompanion(WeaknessesCompanion data) {
    return WeaknessesData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      microSkillId: data.microSkillId.present
          ? data.microSkillId.value
          : this.microSkillId,
      weight: data.weight.present ? data.weight.value : this.weight,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('WeaknessesData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('weight: $weight, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    microSkillId,
    weight,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is WeaknessesData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.microSkillId == this.microSkillId &&
          other.weight == this.weight &&
          other.source == this.source);
}

class WeaknessesCompanion extends UpdateCompanion<WeaknessesData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> microSkillId;
  final Value<double> weight;
  final Value<String> source;
  final Value<int> rowid;
  const WeaknessesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.microSkillId = const Value.absent(),
    this.weight = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  WeaknessesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    required String microSkillId,
    required double weight,
    required String source,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       microSkillId = Value(microSkillId),
       weight = Value(weight),
       source = Value(source);
  static Insertable<WeaknessesData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? microSkillId,
    Expression<double>? weight,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (microSkillId != null) 'micro_skill_id': microSkillId,
      if (weight != null) 'weight': weight,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  WeaknessesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? microSkillId,
    Value<double>? weight,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return WeaknessesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      microSkillId: microSkillId ?? this.microSkillId,
      weight: weight ?? this.weight,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (microSkillId.present) {
      map['micro_skill_id'] = Variable<String>(microSkillId.value);
    }
    if (weight.present) {
      map['weight'] = Variable<double>(weight.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('WeaknessesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('microSkillId: $microSkillId, ')
          ..write('weight: $weight, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $MaterialsTable extends Materials
    with TableInfo<$MaterialsTable, Material> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $MaterialsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _mimeMeta = const VerificationMeta('mime');
  @override
  late final GeneratedColumn<String> mime = GeneratedColumn<String>(
    'mime',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _ingestionStatusMeta = const VerificationMeta(
    'ingestionStatus',
  );
  @override
  late final GeneratedColumn<String> ingestionStatus = GeneratedColumn<String>(
    'ingestion_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    storagePath,
    mime,
    ingestionStatus,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'materials';
  @override
  VerificationContext validateIntegrity(
    Insertable<Material> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    }
    if (data.containsKey('mime')) {
      context.handle(
        _mimeMeta,
        mime.isAcceptableOrUnknown(data['mime']!, _mimeMeta),
      );
    } else if (isInserting) {
      context.missing(_mimeMeta);
    }
    if (data.containsKey('ingestion_status')) {
      context.handle(
        _ingestionStatusMeta,
        ingestionStatus.isAcceptableOrUnknown(
          data['ingestion_status']!,
          _ingestionStatusMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  Material map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return Material(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      ),
      mime: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}mime'],
      )!,
      ingestionStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}ingestion_status'],
      )!,
    );
  }

  @override
  $MaterialsTable createAlias(String alias) {
    return $MaterialsTable(attachedDatabase, alias);
  }
}

class Material extends DataClass implements Insertable<Material> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String chapterId;
  final String? storagePath;
  final String mime;
  final String ingestionStatus;
  const Material({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.chapterId,
    this.storagePath,
    required this.mime,
    required this.ingestionStatus,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || storagePath != null) {
      map['storage_path'] = Variable<String>(storagePath);
    }
    map['mime'] = Variable<String>(mime);
    map['ingestion_status'] = Variable<String>(ingestionStatus);
    return map;
  }

  MaterialsCompanion toCompanion(bool nullToAbsent) {
    return MaterialsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      chapterId: Value(chapterId),
      storagePath: storagePath == null && nullToAbsent
          ? const Value.absent()
          : Value(storagePath),
      mime: Value(mime),
      ingestionStatus: Value(ingestionStatus),
    );
  }

  factory Material.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return Material(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      storagePath: serializer.fromJson<String?>(json['storagePath']),
      mime: serializer.fromJson<String>(json['mime']),
      ingestionStatus: serializer.fromJson<String>(json['ingestionStatus']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'chapterId': serializer.toJson<String>(chapterId),
      'storagePath': serializer.toJson<String?>(storagePath),
      'mime': serializer.toJson<String>(mime),
      'ingestionStatus': serializer.toJson<String>(ingestionStatus),
    };
  }

  Material copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? chapterId,
    Value<String?> storagePath = const Value.absent(),
    String? mime,
    String? ingestionStatus,
  }) => Material(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    chapterId: chapterId ?? this.chapterId,
    storagePath: storagePath.present ? storagePath.value : this.storagePath,
    mime: mime ?? this.mime,
    ingestionStatus: ingestionStatus ?? this.ingestionStatus,
  );
  Material copyWithCompanion(MaterialsCompanion data) {
    return Material(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      mime: data.mime.present ? data.mime.value : this.mime,
      ingestionStatus: data.ingestionStatus.present
          ? data.ingestionStatus.value
          : this.ingestionStatus,
    );
  }

  @override
  String toString() {
    return (StringBuffer('Material(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('storagePath: $storagePath, ')
          ..write('mime: $mime, ')
          ..write('ingestionStatus: $ingestionStatus')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    storagePath,
    mime,
    ingestionStatus,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Material &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.chapterId == this.chapterId &&
          other.storagePath == this.storagePath &&
          other.mime == this.mime &&
          other.ingestionStatus == this.ingestionStatus);
}

class MaterialsCompanion extends UpdateCompanion<Material> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> chapterId;
  final Value<String?> storagePath;
  final Value<String> mime;
  final Value<String> ingestionStatus;
  final Value<int> rowid;
  const MaterialsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.mime = const Value.absent(),
    this.ingestionStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  MaterialsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String chapterId,
    this.storagePath = const Value.absent(),
    required String mime,
    this.ingestionStatus = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       chapterId = Value(chapterId),
       mime = Value(mime);
  static Insertable<Material> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? chapterId,
    Expression<String>? storagePath,
    Expression<String>? mime,
    Expression<String>? ingestionStatus,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (storagePath != null) 'storage_path': storagePath,
      if (mime != null) 'mime': mime,
      if (ingestionStatus != null) 'ingestion_status': ingestionStatus,
      if (rowid != null) 'rowid': rowid,
    });
  }

  MaterialsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? chapterId,
    Value<String?>? storagePath,
    Value<String>? mime,
    Value<String>? ingestionStatus,
    Value<int>? rowid,
  }) {
    return MaterialsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      chapterId: chapterId ?? this.chapterId,
      storagePath: storagePath ?? this.storagePath,
      mime: mime ?? this.mime,
      ingestionStatus: ingestionStatus ?? this.ingestionStatus,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (mime.present) {
      map['mime'] = Variable<String>(mime.value);
    }
    if (ingestionStatus.present) {
      map['ingestion_status'] = Variable<String>(ingestionStatus.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('MaterialsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('storagePath: $storagePath, ')
          ..write('mime: $mime, ')
          ..write('ingestionStatus: $ingestionStatus, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeacherObservationsTable extends TeacherObservations
    with TableInfo<$TeacherObservationsTable, TeacherObservation> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeacherObservationsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
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
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    teacherId,
    body,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teacher_observations';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeacherObservation> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('body')) {
      context.handle(
        _bodyMeta,
        body.isAcceptableOrUnknown(data['body']!, _bodyMeta),
      );
    } else if (isInserting) {
      context.missing(_bodyMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeacherObservation map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeacherObservation(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      body: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}body'],
      )!,
    );
  }

  @override
  $TeacherObservationsTable createAlias(String alias) {
    return $TeacherObservationsTable(attachedDatabase, alias);
  }
}

class TeacherObservation extends DataClass
    implements Insertable<TeacherObservation> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String teacherId;
  final String body;
  const TeacherObservation({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    required this.teacherId,
    required this.body,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['body'] = Variable<String>(body);
    return map;
  }

  TeacherObservationsCompanion toCompanion(bool nullToAbsent) {
    return TeacherObservationsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      teacherId: Value(teacherId),
      body: Value(body),
    );
  }

  factory TeacherObservation.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeacherObservation(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      teacherId: serializer.fromJson<String>(json['teacherId']),
      body: serializer.fromJson<String>(json['body']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'teacherId': serializer.toJson<String>(teacherId),
      'body': serializer.toJson<String>(body),
    };
  }

  TeacherObservation copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    String? teacherId,
    String? body,
  }) => TeacherObservation(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    teacherId: teacherId ?? this.teacherId,
    body: body ?? this.body,
  );
  TeacherObservation copyWithCompanion(TeacherObservationsCompanion data) {
    return TeacherObservation(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      body: data.body.present ? data.body.value : this.body,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeacherObservation(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('teacherId: $teacherId, ')
          ..write('body: $body')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    teacherId,
    body,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeacherObservation &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.teacherId == this.teacherId &&
          other.body == this.body);
}

class TeacherObservationsCompanion extends UpdateCompanion<TeacherObservation> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> teacherId;
  final Value<String> body;
  final Value<int> rowid;
  const TeacherObservationsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.body = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeacherObservationsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    required String teacherId,
    required String body,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       teacherId = Value(teacherId),
       body = Value(body);
  static Insertable<TeacherObservation> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? teacherId,
    Expression<String>? body,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (body != null) 'body': body,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeacherObservationsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? teacherId,
    Value<String>? body,
    Value<int>? rowid,
  }) {
    return TeacherObservationsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      teacherId: teacherId ?? this.teacherId,
      body: body ?? this.body,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (body.present) {
      map['body'] = Variable<String>(body.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeacherObservationsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('teacherId: $teacherId, ')
          ..write('body: $body, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $GeneratedContentTable extends GeneratedContent
    with TableInfo<$GeneratedContentTable, GeneratedContentData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $GeneratedContentTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _kindMeta = const VerificationMeta('kind');
  @override
  late final GeneratedColumn<String> kind = GeneratedColumn<String>(
    'kind',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    studentId,
    kind,
    payload,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'generated_content';
  @override
  VerificationContext validateIntegrity(
    Insertable<GeneratedContentData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    }
    if (data.containsKey('kind')) {
      context.handle(
        _kindMeta,
        kind.isAcceptableOrUnknown(data['kind']!, _kindMeta),
      );
    } else if (isInserting) {
      context.missing(_kindMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  GeneratedContentData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return GeneratedContentData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      ),
      kind: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}kind'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
    );
  }

  @override
  $GeneratedContentTable createAlias(String alias) {
    return $GeneratedContentTable(attachedDatabase, alias);
  }
}

class GeneratedContentData extends DataClass
    implements Insertable<GeneratedContentData> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String chapterId;
  final String? studentId;
  final String kind;
  final String payload;
  const GeneratedContentData({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.chapterId,
    this.studentId,
    required this.kind,
    required this.payload,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['chapter_id'] = Variable<String>(chapterId);
    if (!nullToAbsent || studentId != null) {
      map['student_id'] = Variable<String>(studentId);
    }
    map['kind'] = Variable<String>(kind);
    map['payload'] = Variable<String>(payload);
    return map;
  }

  GeneratedContentCompanion toCompanion(bool nullToAbsent) {
    return GeneratedContentCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      chapterId: Value(chapterId),
      studentId: studentId == null && nullToAbsent
          ? const Value.absent()
          : Value(studentId),
      kind: Value(kind),
      payload: Value(payload),
    );
  }

  factory GeneratedContentData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return GeneratedContentData(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      studentId: serializer.fromJson<String?>(json['studentId']),
      kind: serializer.fromJson<String>(json['kind']),
      payload: serializer.fromJson<String>(json['payload']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'chapterId': serializer.toJson<String>(chapterId),
      'studentId': serializer.toJson<String?>(studentId),
      'kind': serializer.toJson<String>(kind),
      'payload': serializer.toJson<String>(payload),
    };
  }

  GeneratedContentData copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? chapterId,
    Value<String?> studentId = const Value.absent(),
    String? kind,
    String? payload,
  }) => GeneratedContentData(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    chapterId: chapterId ?? this.chapterId,
    studentId: studentId.present ? studentId.value : this.studentId,
    kind: kind ?? this.kind,
    payload: payload ?? this.payload,
  );
  GeneratedContentData copyWithCompanion(GeneratedContentCompanion data) {
    return GeneratedContentData(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      kind: data.kind.present ? data.kind.value : this.kind,
      payload: data.payload.present ? data.payload.value : this.payload,
    );
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedContentData(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    chapterId,
    studentId,
    kind,
    payload,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is GeneratedContentData &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.chapterId == this.chapterId &&
          other.studentId == this.studentId &&
          other.kind == this.kind &&
          other.payload == this.payload);
}

class GeneratedContentCompanion extends UpdateCompanion<GeneratedContentData> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> chapterId;
  final Value<String?> studentId;
  final Value<String> kind;
  final Value<String> payload;
  final Value<int> rowid;
  const GeneratedContentCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.kind = const Value.absent(),
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  GeneratedContentCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String chapterId,
    this.studentId = const Value.absent(),
    required String kind,
    this.payload = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       chapterId = Value(chapterId),
       kind = Value(kind);
  static Insertable<GeneratedContentData> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? chapterId,
    Expression<String>? studentId,
    Expression<String>? kind,
    Expression<String>? payload,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (studentId != null) 'student_id': studentId,
      if (kind != null) 'kind': kind,
      if (payload != null) 'payload': payload,
      if (rowid != null) 'rowid': rowid,
    });
  }

  GeneratedContentCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? chapterId,
    Value<String?>? studentId,
    Value<String>? kind,
    Value<String>? payload,
    Value<int>? rowid,
  }) {
    return GeneratedContentCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      chapterId: chapterId ?? this.chapterId,
      studentId: studentId ?? this.studentId,
      kind: kind ?? this.kind,
      payload: payload ?? this.payload,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (kind.present) {
      map['kind'] = Variable<String>(kind.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('GeneratedContentCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('chapterId: $chapterId, ')
          ..write('studentId: $studentId, ')
          ..write('kind: $kind, ')
          ..write('payload: $payload, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PreAdmissionResultsTable extends PreAdmissionResults
    with TableInfo<$PreAdmissionResultsTable, PreAdmissionResult> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PreAdmissionResultsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _varkMeta = const VerificationMeta('vark');
  @override
  late final GeneratedColumn<String> vark = GeneratedColumn<String>(
    'vark',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _structuredMeta = const VerificationMeta(
    'structured',
  );
  @override
  late final GeneratedColumn<int> structured = GeneratedColumn<int>(
    'structured',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _exploratoryMeta = const VerificationMeta(
    'exploratory',
  );
  @override
  late final GeneratedColumn<int> exploratory = GeneratedColumn<int>(
    'exploratory',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _introvertMeta = const VerificationMeta(
    'introvert',
  );
  @override
  late final GeneratedColumn<int> introvert = GeneratedColumn<int>(
    'introvert',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _extrovertMeta = const VerificationMeta(
    'extrovert',
  );
  @override
  late final GeneratedColumn<int> extrovert = GeneratedColumn<int>(
    'extrovert',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _impulsivityMeta = const VerificationMeta(
    'impulsivity',
  );
  @override
  late final GeneratedColumn<int> impulsivity = GeneratedColumn<int>(
    'impulsivity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _reflectivityMeta = const VerificationMeta(
    'reflectivity',
  );
  @override
  late final GeneratedColumn<int> reflectivity = GeneratedColumn<int>(
    'reflectivity',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
  );
  static const VerificationMeta _dominantStyleMeta = const VerificationMeta(
    'dominantStyle',
  );
  @override
  late final GeneratedColumn<String> dominantStyle = GeneratedColumn<String>(
    'dominant_style',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _answersMeta = const VerificationMeta(
    'answers',
  );
  @override
  late final GeneratedColumn<String> answers = GeneratedColumn<String>(
    'answers',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    vark,
    structured,
    exploratory,
    introvert,
    extrovert,
    impulsivity,
    reflectivity,
    dominantStyle,
    answers,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pre_admission_results';
  @override
  VerificationContext validateIntegrity(
    Insertable<PreAdmissionResult> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('vark')) {
      context.handle(
        _varkMeta,
        vark.isAcceptableOrUnknown(data['vark']!, _varkMeta),
      );
    }
    if (data.containsKey('structured')) {
      context.handle(
        _structuredMeta,
        structured.isAcceptableOrUnknown(data['structured']!, _structuredMeta),
      );
    }
    if (data.containsKey('exploratory')) {
      context.handle(
        _exploratoryMeta,
        exploratory.isAcceptableOrUnknown(
          data['exploratory']!,
          _exploratoryMeta,
        ),
      );
    }
    if (data.containsKey('introvert')) {
      context.handle(
        _introvertMeta,
        introvert.isAcceptableOrUnknown(data['introvert']!, _introvertMeta),
      );
    }
    if (data.containsKey('extrovert')) {
      context.handle(
        _extrovertMeta,
        extrovert.isAcceptableOrUnknown(data['extrovert']!, _extrovertMeta),
      );
    }
    if (data.containsKey('impulsivity')) {
      context.handle(
        _impulsivityMeta,
        impulsivity.isAcceptableOrUnknown(
          data['impulsivity']!,
          _impulsivityMeta,
        ),
      );
    }
    if (data.containsKey('reflectivity')) {
      context.handle(
        _reflectivityMeta,
        reflectivity.isAcceptableOrUnknown(
          data['reflectivity']!,
          _reflectivityMeta,
        ),
      );
    }
    if (data.containsKey('dominant_style')) {
      context.handle(
        _dominantStyleMeta,
        dominantStyle.isAcceptableOrUnknown(
          data['dominant_style']!,
          _dominantStyleMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_dominantStyleMeta);
    }
    if (data.containsKey('answers')) {
      context.handle(
        _answersMeta,
        answers.isAcceptableOrUnknown(data['answers']!, _answersMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PreAdmissionResult map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PreAdmissionResult(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      vark: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}vark'],
      )!,
      structured: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}structured'],
      )!,
      exploratory: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}exploratory'],
      )!,
      introvert: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}introvert'],
      )!,
      extrovert: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}extrovert'],
      )!,
      impulsivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}impulsivity'],
      )!,
      reflectivity: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}reflectivity'],
      )!,
      dominantStyle: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}dominant_style'],
      )!,
      answers: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}answers'],
      )!,
    );
  }

  @override
  $PreAdmissionResultsTable createAlias(String alias) {
    return $PreAdmissionResultsTable(attachedDatabase, alias);
  }
}

class PreAdmissionResult extends DataClass
    implements Insertable<PreAdmissionResult> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String vark;
  final int structured;
  final int exploratory;
  final int introvert;
  final int extrovert;
  final int impulsivity;
  final int reflectivity;
  final String dominantStyle;
  final String answers;
  const PreAdmissionResult({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    required this.vark,
    required this.structured,
    required this.exploratory,
    required this.introvert,
    required this.extrovert,
    required this.impulsivity,
    required this.reflectivity,
    required this.dominantStyle,
    required this.answers,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['vark'] = Variable<String>(vark);
    map['structured'] = Variable<int>(structured);
    map['exploratory'] = Variable<int>(exploratory);
    map['introvert'] = Variable<int>(introvert);
    map['extrovert'] = Variable<int>(extrovert);
    map['impulsivity'] = Variable<int>(impulsivity);
    map['reflectivity'] = Variable<int>(reflectivity);
    map['dominant_style'] = Variable<String>(dominantStyle);
    map['answers'] = Variable<String>(answers);
    return map;
  }

  PreAdmissionResultsCompanion toCompanion(bool nullToAbsent) {
    return PreAdmissionResultsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      vark: Value(vark),
      structured: Value(structured),
      exploratory: Value(exploratory),
      introvert: Value(introvert),
      extrovert: Value(extrovert),
      impulsivity: Value(impulsivity),
      reflectivity: Value(reflectivity),
      dominantStyle: Value(dominantStyle),
      answers: Value(answers),
    );
  }

  factory PreAdmissionResult.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PreAdmissionResult(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      vark: serializer.fromJson<String>(json['vark']),
      structured: serializer.fromJson<int>(json['structured']),
      exploratory: serializer.fromJson<int>(json['exploratory']),
      introvert: serializer.fromJson<int>(json['introvert']),
      extrovert: serializer.fromJson<int>(json['extrovert']),
      impulsivity: serializer.fromJson<int>(json['impulsivity']),
      reflectivity: serializer.fromJson<int>(json['reflectivity']),
      dominantStyle: serializer.fromJson<String>(json['dominantStyle']),
      answers: serializer.fromJson<String>(json['answers']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'vark': serializer.toJson<String>(vark),
      'structured': serializer.toJson<int>(structured),
      'exploratory': serializer.toJson<int>(exploratory),
      'introvert': serializer.toJson<int>(introvert),
      'extrovert': serializer.toJson<int>(extrovert),
      'impulsivity': serializer.toJson<int>(impulsivity),
      'reflectivity': serializer.toJson<int>(reflectivity),
      'dominantStyle': serializer.toJson<String>(dominantStyle),
      'answers': serializer.toJson<String>(answers),
    };
  }

  PreAdmissionResult copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    String? vark,
    int? structured,
    int? exploratory,
    int? introvert,
    int? extrovert,
    int? impulsivity,
    int? reflectivity,
    String? dominantStyle,
    String? answers,
  }) => PreAdmissionResult(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    vark: vark ?? this.vark,
    structured: structured ?? this.structured,
    exploratory: exploratory ?? this.exploratory,
    introvert: introvert ?? this.introvert,
    extrovert: extrovert ?? this.extrovert,
    impulsivity: impulsivity ?? this.impulsivity,
    reflectivity: reflectivity ?? this.reflectivity,
    dominantStyle: dominantStyle ?? this.dominantStyle,
    answers: answers ?? this.answers,
  );
  PreAdmissionResult copyWithCompanion(PreAdmissionResultsCompanion data) {
    return PreAdmissionResult(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      vark: data.vark.present ? data.vark.value : this.vark,
      structured: data.structured.present
          ? data.structured.value
          : this.structured,
      exploratory: data.exploratory.present
          ? data.exploratory.value
          : this.exploratory,
      introvert: data.introvert.present ? data.introvert.value : this.introvert,
      extrovert: data.extrovert.present ? data.extrovert.value : this.extrovert,
      impulsivity: data.impulsivity.present
          ? data.impulsivity.value
          : this.impulsivity,
      reflectivity: data.reflectivity.present
          ? data.reflectivity.value
          : this.reflectivity,
      dominantStyle: data.dominantStyle.present
          ? data.dominantStyle.value
          : this.dominantStyle,
      answers: data.answers.present ? data.answers.value : this.answers,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PreAdmissionResult(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('vark: $vark, ')
          ..write('structured: $structured, ')
          ..write('exploratory: $exploratory, ')
          ..write('introvert: $introvert, ')
          ..write('extrovert: $extrovert, ')
          ..write('impulsivity: $impulsivity, ')
          ..write('reflectivity: $reflectivity, ')
          ..write('dominantStyle: $dominantStyle, ')
          ..write('answers: $answers')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    vark,
    structured,
    exploratory,
    introvert,
    extrovert,
    impulsivity,
    reflectivity,
    dominantStyle,
    answers,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PreAdmissionResult &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.vark == this.vark &&
          other.structured == this.structured &&
          other.exploratory == this.exploratory &&
          other.introvert == this.introvert &&
          other.extrovert == this.extrovert &&
          other.impulsivity == this.impulsivity &&
          other.reflectivity == this.reflectivity &&
          other.dominantStyle == this.dominantStyle &&
          other.answers == this.answers);
}

class PreAdmissionResultsCompanion extends UpdateCompanion<PreAdmissionResult> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> vark;
  final Value<int> structured;
  final Value<int> exploratory;
  final Value<int> introvert;
  final Value<int> extrovert;
  final Value<int> impulsivity;
  final Value<int> reflectivity;
  final Value<String> dominantStyle;
  final Value<String> answers;
  final Value<int> rowid;
  const PreAdmissionResultsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.vark = const Value.absent(),
    this.structured = const Value.absent(),
    this.exploratory = const Value.absent(),
    this.introvert = const Value.absent(),
    this.extrovert = const Value.absent(),
    this.impulsivity = const Value.absent(),
    this.reflectivity = const Value.absent(),
    this.dominantStyle = const Value.absent(),
    this.answers = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PreAdmissionResultsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    this.vark = const Value.absent(),
    this.structured = const Value.absent(),
    this.exploratory = const Value.absent(),
    this.introvert = const Value.absent(),
    this.extrovert = const Value.absent(),
    this.impulsivity = const Value.absent(),
    this.reflectivity = const Value.absent(),
    required String dominantStyle,
    this.answers = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       dominantStyle = Value(dominantStyle);
  static Insertable<PreAdmissionResult> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? vark,
    Expression<int>? structured,
    Expression<int>? exploratory,
    Expression<int>? introvert,
    Expression<int>? extrovert,
    Expression<int>? impulsivity,
    Expression<int>? reflectivity,
    Expression<String>? dominantStyle,
    Expression<String>? answers,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (vark != null) 'vark': vark,
      if (structured != null) 'structured': structured,
      if (exploratory != null) 'exploratory': exploratory,
      if (introvert != null) 'introvert': introvert,
      if (extrovert != null) 'extrovert': extrovert,
      if (impulsivity != null) 'impulsivity': impulsivity,
      if (reflectivity != null) 'reflectivity': reflectivity,
      if (dominantStyle != null) 'dominant_style': dominantStyle,
      if (answers != null) 'answers': answers,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PreAdmissionResultsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? vark,
    Value<int>? structured,
    Value<int>? exploratory,
    Value<int>? introvert,
    Value<int>? extrovert,
    Value<int>? impulsivity,
    Value<int>? reflectivity,
    Value<String>? dominantStyle,
    Value<String>? answers,
    Value<int>? rowid,
  }) {
    return PreAdmissionResultsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      vark: vark ?? this.vark,
      structured: structured ?? this.structured,
      exploratory: exploratory ?? this.exploratory,
      introvert: introvert ?? this.introvert,
      extrovert: extrovert ?? this.extrovert,
      impulsivity: impulsivity ?? this.impulsivity,
      reflectivity: reflectivity ?? this.reflectivity,
      dominantStyle: dominantStyle ?? this.dominantStyle,
      answers: answers ?? this.answers,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (vark.present) {
      map['vark'] = Variable<String>(vark.value);
    }
    if (structured.present) {
      map['structured'] = Variable<int>(structured.value);
    }
    if (exploratory.present) {
      map['exploratory'] = Variable<int>(exploratory.value);
    }
    if (introvert.present) {
      map['introvert'] = Variable<int>(introvert.value);
    }
    if (extrovert.present) {
      map['extrovert'] = Variable<int>(extrovert.value);
    }
    if (impulsivity.present) {
      map['impulsivity'] = Variable<int>(impulsivity.value);
    }
    if (reflectivity.present) {
      map['reflectivity'] = Variable<int>(reflectivity.value);
    }
    if (dominantStyle.present) {
      map['dominant_style'] = Variable<String>(dominantStyle.value);
    }
    if (answers.present) {
      map['answers'] = Variable<String>(answers.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PreAdmissionResultsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('vark: $vark, ')
          ..write('structured: $structured, ')
          ..write('exploratory: $exploratory, ')
          ..write('introvert: $introvert, ')
          ..write('extrovert: $extrovert, ')
          ..write('impulsivity: $impulsivity, ')
          ..write('reflectivity: $reflectivity, ')
          ..write('dominantStyle: $dominantStyle, ')
          ..write('answers: $answers, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ReflectionCampaignsTable extends ReflectionCampaigns
    with TableInfo<$ReflectionCampaignsTable, ReflectionCampaign> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ReflectionCampaignsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _openedAtMeta = const VerificationMeta(
    'openedAt',
  );
  @override
  late final GeneratedColumn<DateTime> openedAt = GeneratedColumn<DateTime>(
    'opened_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _closedAtMeta = const VerificationMeta(
    'closedAt',
  );
  @override
  late final GeneratedColumn<DateTime> closedAt = GeneratedColumn<DateTime>(
    'closed_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    academicYear,
    openedAt,
    closedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'reflection_campaigns';
  @override
  VerificationContext validateIntegrity(
    Insertable<ReflectionCampaign> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearMeta);
    }
    if (data.containsKey('opened_at')) {
      context.handle(
        _openedAtMeta,
        openedAt.isAcceptableOrUnknown(data['opened_at']!, _openedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_openedAtMeta);
    }
    if (data.containsKey('closed_at')) {
      context.handle(
        _closedAtMeta,
        closedAt.isAcceptableOrUnknown(data['closed_at']!, _closedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ReflectionCampaign map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ReflectionCampaign(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      )!,
      openedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}opened_at'],
      )!,
      closedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}closed_at'],
      ),
    );
  }

  @override
  $ReflectionCampaignsTable createAlias(String alias) {
    return $ReflectionCampaignsTable(attachedDatabase, alias);
  }
}

class ReflectionCampaign extends DataClass
    implements Insertable<ReflectionCampaign> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String academicYear;
  final DateTime openedAt;
  final DateTime? closedAt;
  const ReflectionCampaign({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.academicYear,
    required this.openedAt,
    this.closedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['academic_year'] = Variable<String>(academicYear);
    map['opened_at'] = Variable<DateTime>(openedAt);
    if (!nullToAbsent || closedAt != null) {
      map['closed_at'] = Variable<DateTime>(closedAt);
    }
    return map;
  }

  ReflectionCampaignsCompanion toCompanion(bool nullToAbsent) {
    return ReflectionCampaignsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      academicYear: Value(academicYear),
      openedAt: Value(openedAt),
      closedAt: closedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(closedAt),
    );
  }

  factory ReflectionCampaign.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ReflectionCampaign(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      academicYear: serializer.fromJson<String>(json['academicYear']),
      openedAt: serializer.fromJson<DateTime>(json['openedAt']),
      closedAt: serializer.fromJson<DateTime?>(json['closedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'academicYear': serializer.toJson<String>(academicYear),
      'openedAt': serializer.toJson<DateTime>(openedAt),
      'closedAt': serializer.toJson<DateTime?>(closedAt),
    };
  }

  ReflectionCampaign copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? academicYear,
    DateTime? openedAt,
    Value<DateTime?> closedAt = const Value.absent(),
  }) => ReflectionCampaign(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    academicYear: academicYear ?? this.academicYear,
    openedAt: openedAt ?? this.openedAt,
    closedAt: closedAt.present ? closedAt.value : this.closedAt,
  );
  ReflectionCampaign copyWithCompanion(ReflectionCampaignsCompanion data) {
    return ReflectionCampaign(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      academicYear: data.academicYear.present
          ? data.academicYear.value
          : this.academicYear,
      openedAt: data.openedAt.present ? data.openedAt.value : this.openedAt,
      closedAt: data.closedAt.present ? data.closedAt.value : this.closedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionCampaign(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('academicYear: $academicYear, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    academicYear,
    openedAt,
    closedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ReflectionCampaign &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.academicYear == this.academicYear &&
          other.openedAt == this.openedAt &&
          other.closedAt == this.closedAt);
}

class ReflectionCampaignsCompanion extends UpdateCompanion<ReflectionCampaign> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> academicYear;
  final Value<DateTime> openedAt;
  final Value<DateTime?> closedAt;
  final Value<int> rowid;
  const ReflectionCampaignsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.openedAt = const Value.absent(),
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ReflectionCampaignsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String academicYear,
    required DateTime openedAt,
    this.closedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       academicYear = Value(academicYear),
       openedAt = Value(openedAt);
  static Insertable<ReflectionCampaign> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? academicYear,
    Expression<DateTime>? openedAt,
    Expression<DateTime>? closedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (academicYear != null) 'academic_year': academicYear,
      if (openedAt != null) 'opened_at': openedAt,
      if (closedAt != null) 'closed_at': closedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ReflectionCampaignsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? academicYear,
    Value<DateTime>? openedAt,
    Value<DateTime?>? closedAt,
    Value<int>? rowid,
  }) {
    return ReflectionCampaignsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      academicYear: academicYear ?? this.academicYear,
      openedAt: openedAt ?? this.openedAt,
      closedAt: closedAt ?? this.closedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (openedAt.present) {
      map['opened_at'] = Variable<DateTime>(openedAt.value);
    }
    if (closedAt.present) {
      map['closed_at'] = Variable<DateTime>(closedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ReflectionCampaignsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('academicYear: $academicYear, ')
          ..write('openedAt: $openedAt, ')
          ..write('closedAt: $closedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $YearEndReflectionsTable extends YearEndReflections
    with TableInfo<$YearEndReflectionsTable, YearEndReflection> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $YearEndReflectionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _campaignIdMeta = const VerificationMeta(
    'campaignId',
  );
  @override
  late final GeneratedColumn<String> campaignId = GeneratedColumn<String>(
    'campaign_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _academicYearMeta = const VerificationMeta(
    'academicYear',
  );
  @override
  late final GeneratedColumn<String> academicYear = GeneratedColumn<String>(
    'academic_year',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _responsesMeta = const VerificationMeta(
    'responses',
  );
  @override
  late final GeneratedColumn<String> responses = GeneratedColumn<String>(
    'responses',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _studentPctMeta = const VerificationMeta(
    'studentPct',
  );
  @override
  late final GeneratedColumn<double> studentPct = GeneratedColumn<double>(
    'student_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    campaignId,
    academicYear,
    responses,
    studentPct,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'year_end_reflections';
  @override
  VerificationContext validateIntegrity(
    Insertable<YearEndReflection> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('campaign_id')) {
      context.handle(
        _campaignIdMeta,
        campaignId.isAcceptableOrUnknown(data['campaign_id']!, _campaignIdMeta),
      );
    }
    if (data.containsKey('academic_year')) {
      context.handle(
        _academicYearMeta,
        academicYear.isAcceptableOrUnknown(
          data['academic_year']!,
          _academicYearMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_academicYearMeta);
    }
    if (data.containsKey('responses')) {
      context.handle(
        _responsesMeta,
        responses.isAcceptableOrUnknown(data['responses']!, _responsesMeta),
      );
    }
    if (data.containsKey('student_pct')) {
      context.handle(
        _studentPctMeta,
        studentPct.isAcceptableOrUnknown(data['student_pct']!, _studentPctMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  YearEndReflection map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return YearEndReflection(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      campaignId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}campaign_id'],
      ),
      academicYear: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}academic_year'],
      )!,
      responses: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}responses'],
      )!,
      studentPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}student_pct'],
      ),
    );
  }

  @override
  $YearEndReflectionsTable createAlias(String alias) {
    return $YearEndReflectionsTable(attachedDatabase, alias);
  }
}

class YearEndReflection extends DataClass
    implements Insertable<YearEndReflection> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String? campaignId;
  final String academicYear;
  final String responses;
  final double? studentPct;
  const YearEndReflection({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    this.campaignId,
    required this.academicYear,
    required this.responses,
    this.studentPct,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || campaignId != null) {
      map['campaign_id'] = Variable<String>(campaignId);
    }
    map['academic_year'] = Variable<String>(academicYear);
    map['responses'] = Variable<String>(responses);
    if (!nullToAbsent || studentPct != null) {
      map['student_pct'] = Variable<double>(studentPct);
    }
    return map;
  }

  YearEndReflectionsCompanion toCompanion(bool nullToAbsent) {
    return YearEndReflectionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      campaignId: campaignId == null && nullToAbsent
          ? const Value.absent()
          : Value(campaignId),
      academicYear: Value(academicYear),
      responses: Value(responses),
      studentPct: studentPct == null && nullToAbsent
          ? const Value.absent()
          : Value(studentPct),
    );
  }

  factory YearEndReflection.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return YearEndReflection(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      campaignId: serializer.fromJson<String?>(json['campaignId']),
      academicYear: serializer.fromJson<String>(json['academicYear']),
      responses: serializer.fromJson<String>(json['responses']),
      studentPct: serializer.fromJson<double?>(json['studentPct']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'campaignId': serializer.toJson<String?>(campaignId),
      'academicYear': serializer.toJson<String>(academicYear),
      'responses': serializer.toJson<String>(responses),
      'studentPct': serializer.toJson<double?>(studentPct),
    };
  }

  YearEndReflection copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    Value<String?> campaignId = const Value.absent(),
    String? academicYear,
    String? responses,
    Value<double?> studentPct = const Value.absent(),
  }) => YearEndReflection(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    campaignId: campaignId.present ? campaignId.value : this.campaignId,
    academicYear: academicYear ?? this.academicYear,
    responses: responses ?? this.responses,
    studentPct: studentPct.present ? studentPct.value : this.studentPct,
  );
  YearEndReflection copyWithCompanion(YearEndReflectionsCompanion data) {
    return YearEndReflection(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      campaignId: data.campaignId.present
          ? data.campaignId.value
          : this.campaignId,
      academicYear: data.academicYear.present
          ? data.academicYear.value
          : this.academicYear,
      responses: data.responses.present ? data.responses.value : this.responses,
      studentPct: data.studentPct.present
          ? data.studentPct.value
          : this.studentPct,
    );
  }

  @override
  String toString() {
    return (StringBuffer('YearEndReflection(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('campaignId: $campaignId, ')
          ..write('academicYear: $academicYear, ')
          ..write('responses: $responses, ')
          ..write('studentPct: $studentPct')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    campaignId,
    academicYear,
    responses,
    studentPct,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is YearEndReflection &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.campaignId == this.campaignId &&
          other.academicYear == this.academicYear &&
          other.responses == this.responses &&
          other.studentPct == this.studentPct);
}

class YearEndReflectionsCompanion extends UpdateCompanion<YearEndReflection> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String?> campaignId;
  final Value<String> academicYear;
  final Value<String> responses;
  final Value<double?> studentPct;
  final Value<int> rowid;
  const YearEndReflectionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.campaignId = const Value.absent(),
    this.academicYear = const Value.absent(),
    this.responses = const Value.absent(),
    this.studentPct = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  YearEndReflectionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    this.campaignId = const Value.absent(),
    required String academicYear,
    this.responses = const Value.absent(),
    this.studentPct = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       academicYear = Value(academicYear);
  static Insertable<YearEndReflection> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? campaignId,
    Expression<String>? academicYear,
    Expression<String>? responses,
    Expression<double>? studentPct,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (campaignId != null) 'campaign_id': campaignId,
      if (academicYear != null) 'academic_year': academicYear,
      if (responses != null) 'responses': responses,
      if (studentPct != null) 'student_pct': studentPct,
      if (rowid != null) 'rowid': rowid,
    });
  }

  YearEndReflectionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String?>? campaignId,
    Value<String>? academicYear,
    Value<String>? responses,
    Value<double?>? studentPct,
    Value<int>? rowid,
  }) {
    return YearEndReflectionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      campaignId: campaignId ?? this.campaignId,
      academicYear: academicYear ?? this.academicYear,
      responses: responses ?? this.responses,
      studentPct: studentPct ?? this.studentPct,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (campaignId.present) {
      map['campaign_id'] = Variable<String>(campaignId.value);
    }
    if (academicYear.present) {
      map['academic_year'] = Variable<String>(academicYear.value);
    }
    if (responses.present) {
      map['responses'] = Variable<String>(responses.value);
    }
    if (studentPct.present) {
      map['student_pct'] = Variable<double>(studentPct.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('YearEndReflectionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('campaignId: $campaignId, ')
          ..write('academicYear: $academicYear, ')
          ..write('responses: $responses, ')
          ..write('studentPct: $studentPct, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $FitAnalysesTable extends FitAnalyses
    with TableInfo<$FitAnalysesTable, FitAnalyse> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $FitAnalysesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _academicPctMeta = const VerificationMeta(
    'academicPct',
  );
  @override
  late final GeneratedColumn<double> academicPct = GeneratedColumn<double>(
    'academic_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _studentPctMeta = const VerificationMeta(
    'studentPct',
  );
  @override
  late final GeneratedColumn<double> studentPct = GeneratedColumn<double>(
    'student_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _teacherPctMeta = const VerificationMeta(
    'teacherPct',
  );
  @override
  late final GeneratedColumn<double> teacherPct = GeneratedColumn<double>(
    'teacher_pct',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _fitScoreMeta = const VerificationMeta(
    'fitScore',
  );
  @override
  late final GeneratedColumn<double> fitScore = GeneratedColumn<double>(
    'fit_score',
    aliasedName,
    true,
    type: DriftSqlType.double,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _verdictMeta = const VerificationMeta(
    'verdict',
  );
  @override
  late final GeneratedColumn<String> verdict = GeneratedColumn<String>(
    'verdict',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _recommendationMeta = const VerificationMeta(
    'recommendation',
  );
  @override
  late final GeneratedColumn<String> recommendation = GeneratedColumn<String>(
    'recommendation',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rule'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    academicPct,
    studentPct,
    teacherPct,
    fitScore,
    verdict,
    recommendation,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'fit_analyses';
  @override
  VerificationContext validateIntegrity(
    Insertable<FitAnalyse> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('academic_pct')) {
      context.handle(
        _academicPctMeta,
        academicPct.isAcceptableOrUnknown(
          data['academic_pct']!,
          _academicPctMeta,
        ),
      );
    }
    if (data.containsKey('student_pct')) {
      context.handle(
        _studentPctMeta,
        studentPct.isAcceptableOrUnknown(data['student_pct']!, _studentPctMeta),
      );
    }
    if (data.containsKey('teacher_pct')) {
      context.handle(
        _teacherPctMeta,
        teacherPct.isAcceptableOrUnknown(data['teacher_pct']!, _teacherPctMeta),
      );
    }
    if (data.containsKey('fit_score')) {
      context.handle(
        _fitScoreMeta,
        fitScore.isAcceptableOrUnknown(data['fit_score']!, _fitScoreMeta),
      );
    }
    if (data.containsKey('verdict')) {
      context.handle(
        _verdictMeta,
        verdict.isAcceptableOrUnknown(data['verdict']!, _verdictMeta),
      );
    }
    if (data.containsKey('recommendation')) {
      context.handle(
        _recommendationMeta,
        recommendation.isAcceptableOrUnknown(
          data['recommendation']!,
          _recommendationMeta,
        ),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  FitAnalyse map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return FitAnalyse(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      academicPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}academic_pct'],
      ),
      studentPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}student_pct'],
      ),
      teacherPct: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}teacher_pct'],
      ),
      fitScore: attachedDatabase.typeMapping.read(
        DriftSqlType.double,
        data['${effectivePrefix}fit_score'],
      ),
      verdict: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}verdict'],
      ),
      recommendation: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}recommendation'],
      ),
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $FitAnalysesTable createAlias(String alias) {
    return $FitAnalysesTable(attachedDatabase, alias);
  }
}

class FitAnalyse extends DataClass implements Insertable<FitAnalyse> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final double? academicPct;
  final double? studentPct;
  final double? teacherPct;
  final double? fitScore;
  final String? verdict;
  final String? recommendation;
  final String source;
  const FitAnalyse({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    this.academicPct,
    this.studentPct,
    this.teacherPct,
    this.fitScore,
    this.verdict,
    this.recommendation,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || academicPct != null) {
      map['academic_pct'] = Variable<double>(academicPct);
    }
    if (!nullToAbsent || studentPct != null) {
      map['student_pct'] = Variable<double>(studentPct);
    }
    if (!nullToAbsent || teacherPct != null) {
      map['teacher_pct'] = Variable<double>(teacherPct);
    }
    if (!nullToAbsent || fitScore != null) {
      map['fit_score'] = Variable<double>(fitScore);
    }
    if (!nullToAbsent || verdict != null) {
      map['verdict'] = Variable<String>(verdict);
    }
    if (!nullToAbsent || recommendation != null) {
      map['recommendation'] = Variable<String>(recommendation);
    }
    map['source'] = Variable<String>(source);
    return map;
  }

  FitAnalysesCompanion toCompanion(bool nullToAbsent) {
    return FitAnalysesCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      academicPct: academicPct == null && nullToAbsent
          ? const Value.absent()
          : Value(academicPct),
      studentPct: studentPct == null && nullToAbsent
          ? const Value.absent()
          : Value(studentPct),
      teacherPct: teacherPct == null && nullToAbsent
          ? const Value.absent()
          : Value(teacherPct),
      fitScore: fitScore == null && nullToAbsent
          ? const Value.absent()
          : Value(fitScore),
      verdict: verdict == null && nullToAbsent
          ? const Value.absent()
          : Value(verdict),
      recommendation: recommendation == null && nullToAbsent
          ? const Value.absent()
          : Value(recommendation),
      source: Value(source),
    );
  }

  factory FitAnalyse.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return FitAnalyse(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      academicPct: serializer.fromJson<double?>(json['academicPct']),
      studentPct: serializer.fromJson<double?>(json['studentPct']),
      teacherPct: serializer.fromJson<double?>(json['teacherPct']),
      fitScore: serializer.fromJson<double?>(json['fitScore']),
      verdict: serializer.fromJson<String?>(json['verdict']),
      recommendation: serializer.fromJson<String?>(json['recommendation']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'academicPct': serializer.toJson<double?>(academicPct),
      'studentPct': serializer.toJson<double?>(studentPct),
      'teacherPct': serializer.toJson<double?>(teacherPct),
      'fitScore': serializer.toJson<double?>(fitScore),
      'verdict': serializer.toJson<String?>(verdict),
      'recommendation': serializer.toJson<String?>(recommendation),
      'source': serializer.toJson<String>(source),
    };
  }

  FitAnalyse copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    Value<double?> academicPct = const Value.absent(),
    Value<double?> studentPct = const Value.absent(),
    Value<double?> teacherPct = const Value.absent(),
    Value<double?> fitScore = const Value.absent(),
    Value<String?> verdict = const Value.absent(),
    Value<String?> recommendation = const Value.absent(),
    String? source,
  }) => FitAnalyse(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    academicPct: academicPct.present ? academicPct.value : this.academicPct,
    studentPct: studentPct.present ? studentPct.value : this.studentPct,
    teacherPct: teacherPct.present ? teacherPct.value : this.teacherPct,
    fitScore: fitScore.present ? fitScore.value : this.fitScore,
    verdict: verdict.present ? verdict.value : this.verdict,
    recommendation: recommendation.present
        ? recommendation.value
        : this.recommendation,
    source: source ?? this.source,
  );
  FitAnalyse copyWithCompanion(FitAnalysesCompanion data) {
    return FitAnalyse(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      academicPct: data.academicPct.present
          ? data.academicPct.value
          : this.academicPct,
      studentPct: data.studentPct.present
          ? data.studentPct.value
          : this.studentPct,
      teacherPct: data.teacherPct.present
          ? data.teacherPct.value
          : this.teacherPct,
      fitScore: data.fitScore.present ? data.fitScore.value : this.fitScore,
      verdict: data.verdict.present ? data.verdict.value : this.verdict,
      recommendation: data.recommendation.present
          ? data.recommendation.value
          : this.recommendation,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('FitAnalyse(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('academicPct: $academicPct, ')
          ..write('studentPct: $studentPct, ')
          ..write('teacherPct: $teacherPct, ')
          ..write('fitScore: $fitScore, ')
          ..write('verdict: $verdict, ')
          ..write('recommendation: $recommendation, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    academicPct,
    studentPct,
    teacherPct,
    fitScore,
    verdict,
    recommendation,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is FitAnalyse &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.academicPct == this.academicPct &&
          other.studentPct == this.studentPct &&
          other.teacherPct == this.teacherPct &&
          other.fitScore == this.fitScore &&
          other.verdict == this.verdict &&
          other.recommendation == this.recommendation &&
          other.source == this.source);
}

class FitAnalysesCompanion extends UpdateCompanion<FitAnalyse> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<double?> academicPct;
  final Value<double?> studentPct;
  final Value<double?> teacherPct;
  final Value<double?> fitScore;
  final Value<String?> verdict;
  final Value<String?> recommendation;
  final Value<String> source;
  final Value<int> rowid;
  const FitAnalysesCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.academicPct = const Value.absent(),
    this.studentPct = const Value.absent(),
    this.teacherPct = const Value.absent(),
    this.fitScore = const Value.absent(),
    this.verdict = const Value.absent(),
    this.recommendation = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  FitAnalysesCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    this.academicPct = const Value.absent(),
    this.studentPct = const Value.absent(),
    this.teacherPct = const Value.absent(),
    this.fitScore = const Value.absent(),
    this.verdict = const Value.absent(),
    this.recommendation = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId);
  static Insertable<FitAnalyse> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<double>? academicPct,
    Expression<double>? studentPct,
    Expression<double>? teacherPct,
    Expression<double>? fitScore,
    Expression<String>? verdict,
    Expression<String>? recommendation,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (academicPct != null) 'academic_pct': academicPct,
      if (studentPct != null) 'student_pct': studentPct,
      if (teacherPct != null) 'teacher_pct': teacherPct,
      if (fitScore != null) 'fit_score': fitScore,
      if (verdict != null) 'verdict': verdict,
      if (recommendation != null) 'recommendation': recommendation,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  FitAnalysesCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<double?>? academicPct,
    Value<double?>? studentPct,
    Value<double?>? teacherPct,
    Value<double?>? fitScore,
    Value<String?>? verdict,
    Value<String?>? recommendation,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return FitAnalysesCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      academicPct: academicPct ?? this.academicPct,
      studentPct: studentPct ?? this.studentPct,
      teacherPct: teacherPct ?? this.teacherPct,
      fitScore: fitScore ?? this.fitScore,
      verdict: verdict ?? this.verdict,
      recommendation: recommendation ?? this.recommendation,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (academicPct.present) {
      map['academic_pct'] = Variable<double>(academicPct.value);
    }
    if (studentPct.present) {
      map['student_pct'] = Variable<double>(studentPct.value);
    }
    if (teacherPct.present) {
      map['teacher_pct'] = Variable<double>(teacherPct.value);
    }
    if (fitScore.present) {
      map['fit_score'] = Variable<double>(fitScore.value);
    }
    if (verdict.present) {
      map['verdict'] = Variable<String>(verdict.value);
    }
    if (recommendation.present) {
      map['recommendation'] = Variable<String>(recommendation.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('FitAnalysesCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('academicPct: $academicPct, ')
          ..write('studentPct: $studentPct, ')
          ..write('teacherPct: $teacherPct, ')
          ..write('fitScore: $fitScore, ')
          ..write('verdict: $verdict, ')
          ..write('recommendation: $recommendation, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PlacementSuggestionsTable extends PlacementSuggestions
    with TableInfo<$PlacementSuggestionsTable, PlacementSuggestion> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PlacementSuggestionsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _suggestedClassIdMeta = const VerificationMeta(
    'suggestedClassId',
  );
  @override
  late final GeneratedColumn<String> suggestedClassId = GeneratedColumn<String>(
    'suggested_class_id',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _rationaleMeta = const VerificationMeta(
    'rationale',
  );
  @override
  late final GeneratedColumn<String> rationale = GeneratedColumn<String>(
    'rationale',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _versionMeta = const VerificationMeta(
    'version',
  );
  @override
  late final GeneratedColumn<int> version = GeneratedColumn<int>(
    'version',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(1),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    suggestedClassId,
    rationale,
    status,
    version,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'placement_suggestions';
  @override
  VerificationContext validateIntegrity(
    Insertable<PlacementSuggestion> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('suggested_class_id')) {
      context.handle(
        _suggestedClassIdMeta,
        suggestedClassId.isAcceptableOrUnknown(
          data['suggested_class_id']!,
          _suggestedClassIdMeta,
        ),
      );
    }
    if (data.containsKey('rationale')) {
      context.handle(
        _rationaleMeta,
        rationale.isAcceptableOrUnknown(data['rationale']!, _rationaleMeta),
      );
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('version')) {
      context.handle(
        _versionMeta,
        version.isAcceptableOrUnknown(data['version']!, _versionMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  PlacementSuggestion map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PlacementSuggestion(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      suggestedClassId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}suggested_class_id'],
      ),
      rationale: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}rationale'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      version: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}version'],
      )!,
    );
  }

  @override
  $PlacementSuggestionsTable createAlias(String alias) {
    return $PlacementSuggestionsTable(attachedDatabase, alias);
  }
}

class PlacementSuggestion extends DataClass
    implements Insertable<PlacementSuggestion> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String? suggestedClassId;
  final String rationale;
  final String status;
  final int version;
  const PlacementSuggestion({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    this.suggestedClassId,
    required this.rationale,
    required this.status,
    required this.version,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    if (!nullToAbsent || suggestedClassId != null) {
      map['suggested_class_id'] = Variable<String>(suggestedClassId);
    }
    map['rationale'] = Variable<String>(rationale);
    map['status'] = Variable<String>(status);
    map['version'] = Variable<int>(version);
    return map;
  }

  PlacementSuggestionsCompanion toCompanion(bool nullToAbsent) {
    return PlacementSuggestionsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      suggestedClassId: suggestedClassId == null && nullToAbsent
          ? const Value.absent()
          : Value(suggestedClassId),
      rationale: Value(rationale),
      status: Value(status),
      version: Value(version),
    );
  }

  factory PlacementSuggestion.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PlacementSuggestion(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      suggestedClassId: serializer.fromJson<String?>(json['suggestedClassId']),
      rationale: serializer.fromJson<String>(json['rationale']),
      status: serializer.fromJson<String>(json['status']),
      version: serializer.fromJson<int>(json['version']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'suggestedClassId': serializer.toJson<String?>(suggestedClassId),
      'rationale': serializer.toJson<String>(rationale),
      'status': serializer.toJson<String>(status),
      'version': serializer.toJson<int>(version),
    };
  }

  PlacementSuggestion copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    Value<String?> suggestedClassId = const Value.absent(),
    String? rationale,
    String? status,
    int? version,
  }) => PlacementSuggestion(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    suggestedClassId: suggestedClassId.present
        ? suggestedClassId.value
        : this.suggestedClassId,
    rationale: rationale ?? this.rationale,
    status: status ?? this.status,
    version: version ?? this.version,
  );
  PlacementSuggestion copyWithCompanion(PlacementSuggestionsCompanion data) {
    return PlacementSuggestion(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      suggestedClassId: data.suggestedClassId.present
          ? data.suggestedClassId.value
          : this.suggestedClassId,
      rationale: data.rationale.present ? data.rationale.value : this.rationale,
      status: data.status.present ? data.status.value : this.status,
      version: data.version.present ? data.version.value : this.version,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PlacementSuggestion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('suggestedClassId: $suggestedClassId, ')
          ..write('rationale: $rationale, ')
          ..write('status: $status, ')
          ..write('version: $version')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    suggestedClassId,
    rationale,
    status,
    version,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PlacementSuggestion &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.suggestedClassId == this.suggestedClassId &&
          other.rationale == this.rationale &&
          other.status == this.status &&
          other.version == this.version);
}

class PlacementSuggestionsCompanion
    extends UpdateCompanion<PlacementSuggestion> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String?> suggestedClassId;
  final Value<String> rationale;
  final Value<String> status;
  final Value<int> version;
  final Value<int> rowid;
  const PlacementSuggestionsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.suggestedClassId = const Value.absent(),
    this.rationale = const Value.absent(),
    this.status = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PlacementSuggestionsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    this.suggestedClassId = const Value.absent(),
    this.rationale = const Value.absent(),
    this.status = const Value.absent(),
    this.version = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId);
  static Insertable<PlacementSuggestion> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? suggestedClassId,
    Expression<String>? rationale,
    Expression<String>? status,
    Expression<int>? version,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (suggestedClassId != null) 'suggested_class_id': suggestedClassId,
      if (rationale != null) 'rationale': rationale,
      if (status != null) 'status': status,
      if (version != null) 'version': version,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PlacementSuggestionsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String?>? suggestedClassId,
    Value<String>? rationale,
    Value<String>? status,
    Value<int>? version,
    Value<int>? rowid,
  }) {
    return PlacementSuggestionsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      suggestedClassId: suggestedClassId ?? this.suggestedClassId,
      rationale: rationale ?? this.rationale,
      status: status ?? this.status,
      version: version ?? this.version,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (suggestedClassId.present) {
      map['suggested_class_id'] = Variable<String>(suggestedClassId.value);
    }
    if (rationale.present) {
      map['rationale'] = Variable<String>(rationale.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (version.present) {
      map['version'] = Variable<int>(version.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PlacementSuggestionsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('suggestedClassId: $suggestedClassId, ')
          ..write('rationale: $rationale, ')
          ..write('status: $status, ')
          ..write('version: $version, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $ExamPapersTable extends ExamPapers
    with TableInfo<$ExamPapersTable, ExamPaper> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ExamPapersTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _studentIdMeta = const VerificationMeta(
    'studentId',
  );
  @override
  late final GeneratedColumn<String> studentId = GeneratedColumn<String>(
    'student_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _storagePathMeta = const VerificationMeta(
    'storagePath',
  );
  @override
  late final GeneratedColumn<String> storagePath = GeneratedColumn<String>(
    'storage_path',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _analysisStatusMeta = const VerificationMeta(
    'analysisStatus',
  );
  @override
  late final GeneratedColumn<String> analysisStatus = GeneratedColumn<String>(
    'analysis_status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
  );
  static const VerificationMeta _analysisNoteMeta = const VerificationMeta(
    'analysisNote',
  );
  @override
  late final GeneratedColumn<String> analysisNote = GeneratedColumn<String>(
    'analysis_note',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _uploadedByMeta = const VerificationMeta(
    'uploadedBy',
  );
  @override
  late final GeneratedColumn<String> uploadedBy = GeneratedColumn<String>(
    'uploaded_by',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    chapterId,
    storagePath,
    analysisStatus,
    analysisNote,
    uploadedBy,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'exam_papers';
  @override
  VerificationContext validateIntegrity(
    Insertable<ExamPaper> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('student_id')) {
      context.handle(
        _studentIdMeta,
        studentId.isAcceptableOrUnknown(data['student_id']!, _studentIdMeta),
      );
    } else if (isInserting) {
      context.missing(_studentIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('storage_path')) {
      context.handle(
        _storagePathMeta,
        storagePath.isAcceptableOrUnknown(
          data['storage_path']!,
          _storagePathMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_storagePathMeta);
    }
    if (data.containsKey('analysis_status')) {
      context.handle(
        _analysisStatusMeta,
        analysisStatus.isAcceptableOrUnknown(
          data['analysis_status']!,
          _analysisStatusMeta,
        ),
      );
    }
    if (data.containsKey('analysis_note')) {
      context.handle(
        _analysisNoteMeta,
        analysisNote.isAcceptableOrUnknown(
          data['analysis_note']!,
          _analysisNoteMeta,
        ),
      );
    }
    if (data.containsKey('uploaded_by')) {
      context.handle(
        _uploadedByMeta,
        uploadedBy.isAcceptableOrUnknown(data['uploaded_by']!, _uploadedByMeta),
      );
    } else if (isInserting) {
      context.missing(_uploadedByMeta);
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ExamPaper map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ExamPaper(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      studentId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}student_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      storagePath: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}storage_path'],
      )!,
      analysisStatus: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_status'],
      )!,
      analysisNote: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}analysis_note'],
      ),
      uploadedBy: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}uploaded_by'],
      )!,
    );
  }

  @override
  $ExamPapersTable createAlias(String alias) {
    return $ExamPapersTable(attachedDatabase, alias);
  }
}

class ExamPaper extends DataClass implements Insertable<ExamPaper> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String studentId;
  final String chapterId;
  final String storagePath;
  final String analysisStatus;
  final String? analysisNote;
  final String uploadedBy;
  const ExamPaper({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.studentId,
    required this.chapterId,
    required this.storagePath,
    required this.analysisStatus,
    this.analysisNote,
    required this.uploadedBy,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['student_id'] = Variable<String>(studentId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['storage_path'] = Variable<String>(storagePath);
    map['analysis_status'] = Variable<String>(analysisStatus);
    if (!nullToAbsent || analysisNote != null) {
      map['analysis_note'] = Variable<String>(analysisNote);
    }
    map['uploaded_by'] = Variable<String>(uploadedBy);
    return map;
  }

  ExamPapersCompanion toCompanion(bool nullToAbsent) {
    return ExamPapersCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      studentId: Value(studentId),
      chapterId: Value(chapterId),
      storagePath: Value(storagePath),
      analysisStatus: Value(analysisStatus),
      analysisNote: analysisNote == null && nullToAbsent
          ? const Value.absent()
          : Value(analysisNote),
      uploadedBy: Value(uploadedBy),
    );
  }

  factory ExamPaper.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ExamPaper(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      studentId: serializer.fromJson<String>(json['studentId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      storagePath: serializer.fromJson<String>(json['storagePath']),
      analysisStatus: serializer.fromJson<String>(json['analysisStatus']),
      analysisNote: serializer.fromJson<String?>(json['analysisNote']),
      uploadedBy: serializer.fromJson<String>(json['uploadedBy']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'studentId': serializer.toJson<String>(studentId),
      'chapterId': serializer.toJson<String>(chapterId),
      'storagePath': serializer.toJson<String>(storagePath),
      'analysisStatus': serializer.toJson<String>(analysisStatus),
      'analysisNote': serializer.toJson<String?>(analysisNote),
      'uploadedBy': serializer.toJson<String>(uploadedBy),
    };
  }

  ExamPaper copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? studentId,
    String? chapterId,
    String? storagePath,
    String? analysisStatus,
    Value<String?> analysisNote = const Value.absent(),
    String? uploadedBy,
  }) => ExamPaper(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    studentId: studentId ?? this.studentId,
    chapterId: chapterId ?? this.chapterId,
    storagePath: storagePath ?? this.storagePath,
    analysisStatus: analysisStatus ?? this.analysisStatus,
    analysisNote: analysisNote.present ? analysisNote.value : this.analysisNote,
    uploadedBy: uploadedBy ?? this.uploadedBy,
  );
  ExamPaper copyWithCompanion(ExamPapersCompanion data) {
    return ExamPaper(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      studentId: data.studentId.present ? data.studentId.value : this.studentId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      storagePath: data.storagePath.present
          ? data.storagePath.value
          : this.storagePath,
      analysisStatus: data.analysisStatus.present
          ? data.analysisStatus.value
          : this.analysisStatus,
      analysisNote: data.analysisNote.present
          ? data.analysisNote.value
          : this.analysisNote,
      uploadedBy: data.uploadedBy.present
          ? data.uploadedBy.value
          : this.uploadedBy,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ExamPaper(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('storagePath: $storagePath, ')
          ..write('analysisStatus: $analysisStatus, ')
          ..write('analysisNote: $analysisNote, ')
          ..write('uploadedBy: $uploadedBy')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    studentId,
    chapterId,
    storagePath,
    analysisStatus,
    analysisNote,
    uploadedBy,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ExamPaper &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.studentId == this.studentId &&
          other.chapterId == this.chapterId &&
          other.storagePath == this.storagePath &&
          other.analysisStatus == this.analysisStatus &&
          other.analysisNote == this.analysisNote &&
          other.uploadedBy == this.uploadedBy);
}

class ExamPapersCompanion extends UpdateCompanion<ExamPaper> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> studentId;
  final Value<String> chapterId;
  final Value<String> storagePath;
  final Value<String> analysisStatus;
  final Value<String?> analysisNote;
  final Value<String> uploadedBy;
  final Value<int> rowid;
  const ExamPapersCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.studentId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.storagePath = const Value.absent(),
    this.analysisStatus = const Value.absent(),
    this.analysisNote = const Value.absent(),
    this.uploadedBy = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  ExamPapersCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String studentId,
    required String chapterId,
    required String storagePath,
    this.analysisStatus = const Value.absent(),
    this.analysisNote = const Value.absent(),
    required String uploadedBy,
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       studentId = Value(studentId),
       chapterId = Value(chapterId),
       storagePath = Value(storagePath),
       uploadedBy = Value(uploadedBy);
  static Insertable<ExamPaper> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? studentId,
    Expression<String>? chapterId,
    Expression<String>? storagePath,
    Expression<String>? analysisStatus,
    Expression<String>? analysisNote,
    Expression<String>? uploadedBy,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (studentId != null) 'student_id': studentId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (storagePath != null) 'storage_path': storagePath,
      if (analysisStatus != null) 'analysis_status': analysisStatus,
      if (analysisNote != null) 'analysis_note': analysisNote,
      if (uploadedBy != null) 'uploaded_by': uploadedBy,
      if (rowid != null) 'rowid': rowid,
    });
  }

  ExamPapersCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? studentId,
    Value<String>? chapterId,
    Value<String>? storagePath,
    Value<String>? analysisStatus,
    Value<String?>? analysisNote,
    Value<String>? uploadedBy,
    Value<int>? rowid,
  }) {
    return ExamPapersCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      studentId: studentId ?? this.studentId,
      chapterId: chapterId ?? this.chapterId,
      storagePath: storagePath ?? this.storagePath,
      analysisStatus: analysisStatus ?? this.analysisStatus,
      analysisNote: analysisNote ?? this.analysisNote,
      uploadedBy: uploadedBy ?? this.uploadedBy,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (studentId.present) {
      map['student_id'] = Variable<String>(studentId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (storagePath.present) {
      map['storage_path'] = Variable<String>(storagePath.value);
    }
    if (analysisStatus.present) {
      map['analysis_status'] = Variable<String>(analysisStatus.value);
    }
    if (analysisNote.present) {
      map['analysis_note'] = Variable<String>(analysisNote.value);
    }
    if (uploadedBy.present) {
      map['uploaded_by'] = Variable<String>(uploadedBy.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ExamPapersCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('studentId: $studentId, ')
          ..write('chapterId: $chapterId, ')
          ..write('storagePath: $storagePath, ')
          ..write('analysisStatus: $analysisStatus, ')
          ..write('analysisNote: $analysisNote, ')
          ..write('uploadedBy: $uploadedBy, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $TeachingInsightsTable extends TeachingInsights
    with TableInfo<$TeachingInsightsTable, TeachingInsightRecord> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $TeachingInsightsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
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
  static const VerificationMeta _deletedAtMeta = const VerificationMeta(
    'deletedAt',
  );
  @override
  late final GeneratedColumn<DateTime> deletedAt = GeneratedColumn<DateTime>(
    'deleted_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _schoolIdMeta = const VerificationMeta(
    'schoolId',
  );
  @override
  late final GeneratedColumn<String> schoolId = GeneratedColumn<String>(
    'school_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _teacherIdMeta = const VerificationMeta(
    'teacherId',
  );
  @override
  late final GeneratedColumn<String> teacherId = GeneratedColumn<String>(
    'teacher_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _classIdMeta = const VerificationMeta(
    'classId',
  );
  @override
  late final GeneratedColumn<String> classId = GeneratedColumn<String>(
    'class_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _chapterIdMeta = const VerificationMeta(
    'chapterId',
  );
  @override
  late final GeneratedColumn<String> chapterId = GeneratedColumn<String>(
    'chapter_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _signalsMeta = const VerificationMeta(
    'signals',
  );
  @override
  late final GeneratedColumn<String> signals = GeneratedColumn<String>(
    'signals',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _summaryMeta = const VerificationMeta(
    'summary',
  );
  @override
  late final GeneratedColumn<String> summary = GeneratedColumn<String>(
    'summary',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant(''),
  );
  static const VerificationMeta _actionsMeta = const VerificationMeta(
    'actions',
  );
  @override
  late final GeneratedColumn<String> actions = GeneratedColumn<String>(
    'actions',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('[]'),
  );
  static const VerificationMeta _deckMeta = const VerificationMeta('deck');
  @override
  late final GeneratedColumn<String> deck = GeneratedColumn<String>(
    'deck',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('{}'),
  );
  static const VerificationMeta _sourceMeta = const VerificationMeta('source');
  @override
  late final GeneratedColumn<String> source = GeneratedColumn<String>(
    'source',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('rule'),
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    teacherId,
    classId,
    chapterId,
    signals,
    summary,
    actions,
    deck,
    source,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'teaching_insights';
  @override
  VerificationContext validateIntegrity(
    Insertable<TeachingInsightRecord> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('updated_at')) {
      context.handle(
        _updatedAtMeta,
        updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_updatedAtMeta);
    }
    if (data.containsKey('deleted_at')) {
      context.handle(
        _deletedAtMeta,
        deletedAt.isAcceptableOrUnknown(data['deleted_at']!, _deletedAtMeta),
      );
    }
    if (data.containsKey('school_id')) {
      context.handle(
        _schoolIdMeta,
        schoolId.isAcceptableOrUnknown(data['school_id']!, _schoolIdMeta),
      );
    } else if (isInserting) {
      context.missing(_schoolIdMeta);
    }
    if (data.containsKey('teacher_id')) {
      context.handle(
        _teacherIdMeta,
        teacherId.isAcceptableOrUnknown(data['teacher_id']!, _teacherIdMeta),
      );
    } else if (isInserting) {
      context.missing(_teacherIdMeta);
    }
    if (data.containsKey('class_id')) {
      context.handle(
        _classIdMeta,
        classId.isAcceptableOrUnknown(data['class_id']!, _classIdMeta),
      );
    } else if (isInserting) {
      context.missing(_classIdMeta);
    }
    if (data.containsKey('chapter_id')) {
      context.handle(
        _chapterIdMeta,
        chapterId.isAcceptableOrUnknown(data['chapter_id']!, _chapterIdMeta),
      );
    } else if (isInserting) {
      context.missing(_chapterIdMeta);
    }
    if (data.containsKey('signals')) {
      context.handle(
        _signalsMeta,
        signals.isAcceptableOrUnknown(data['signals']!, _signalsMeta),
      );
    }
    if (data.containsKey('summary')) {
      context.handle(
        _summaryMeta,
        summary.isAcceptableOrUnknown(data['summary']!, _summaryMeta),
      );
    }
    if (data.containsKey('actions')) {
      context.handle(
        _actionsMeta,
        actions.isAcceptableOrUnknown(data['actions']!, _actionsMeta),
      );
    }
    if (data.containsKey('deck')) {
      context.handle(
        _deckMeta,
        deck.isAcceptableOrUnknown(data['deck']!, _deckMeta),
      );
    }
    if (data.containsKey('source')) {
      context.handle(
        _sourceMeta,
        source.isAcceptableOrUnknown(data['source']!, _sourceMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  TeachingInsightRecord map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return TeachingInsightRecord(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      updatedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}updated_at'],
      )!,
      deletedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}deleted_at'],
      ),
      schoolId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}school_id'],
      )!,
      teacherId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}teacher_id'],
      )!,
      classId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}class_id'],
      )!,
      chapterId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}chapter_id'],
      )!,
      signals: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}signals'],
      )!,
      summary: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}summary'],
      )!,
      actions: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}actions'],
      )!,
      deck: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}deck'],
      )!,
      source: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}source'],
      )!,
    );
  }

  @override
  $TeachingInsightsTable createAlias(String alias) {
    return $TeachingInsightsTable(attachedDatabase, alias);
  }
}

class TeachingInsightRecord extends DataClass
    implements Insertable<TeachingInsightRecord> {
  final String id;
  final DateTime createdAt;
  final DateTime updatedAt;
  final DateTime? deletedAt;
  final String schoolId;
  final String teacherId;
  final String classId;
  final String chapterId;
  final String signals;
  final String summary;
  final String actions;
  final String deck;
  final String source;
  const TeachingInsightRecord({
    required this.id,
    required this.createdAt,
    required this.updatedAt,
    this.deletedAt,
    required this.schoolId,
    required this.teacherId,
    required this.classId,
    required this.chapterId,
    required this.signals,
    required this.summary,
    required this.actions,
    required this.deck,
    required this.source,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['updated_at'] = Variable<DateTime>(updatedAt);
    if (!nullToAbsent || deletedAt != null) {
      map['deleted_at'] = Variable<DateTime>(deletedAt);
    }
    map['school_id'] = Variable<String>(schoolId);
    map['teacher_id'] = Variable<String>(teacherId);
    map['class_id'] = Variable<String>(classId);
    map['chapter_id'] = Variable<String>(chapterId);
    map['signals'] = Variable<String>(signals);
    map['summary'] = Variable<String>(summary);
    map['actions'] = Variable<String>(actions);
    map['deck'] = Variable<String>(deck);
    map['source'] = Variable<String>(source);
    return map;
  }

  TeachingInsightsCompanion toCompanion(bool nullToAbsent) {
    return TeachingInsightsCompanion(
      id: Value(id),
      createdAt: Value(createdAt),
      updatedAt: Value(updatedAt),
      deletedAt: deletedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(deletedAt),
      schoolId: Value(schoolId),
      teacherId: Value(teacherId),
      classId: Value(classId),
      chapterId: Value(chapterId),
      signals: Value(signals),
      summary: Value(summary),
      actions: Value(actions),
      deck: Value(deck),
      source: Value(source),
    );
  }

  factory TeachingInsightRecord.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return TeachingInsightRecord(
      id: serializer.fromJson<String>(json['id']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime>(json['updatedAt']),
      deletedAt: serializer.fromJson<DateTime?>(json['deletedAt']),
      schoolId: serializer.fromJson<String>(json['schoolId']),
      teacherId: serializer.fromJson<String>(json['teacherId']),
      classId: serializer.fromJson<String>(json['classId']),
      chapterId: serializer.fromJson<String>(json['chapterId']),
      signals: serializer.fromJson<String>(json['signals']),
      summary: serializer.fromJson<String>(json['summary']),
      actions: serializer.fromJson<String>(json['actions']),
      deck: serializer.fromJson<String>(json['deck']),
      source: serializer.fromJson<String>(json['source']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'updatedAt': serializer.toJson<DateTime>(updatedAt),
      'deletedAt': serializer.toJson<DateTime?>(deletedAt),
      'schoolId': serializer.toJson<String>(schoolId),
      'teacherId': serializer.toJson<String>(teacherId),
      'classId': serializer.toJson<String>(classId),
      'chapterId': serializer.toJson<String>(chapterId),
      'signals': serializer.toJson<String>(signals),
      'summary': serializer.toJson<String>(summary),
      'actions': serializer.toJson<String>(actions),
      'deck': serializer.toJson<String>(deck),
      'source': serializer.toJson<String>(source),
    };
  }

  TeachingInsightRecord copyWith({
    String? id,
    DateTime? createdAt,
    DateTime? updatedAt,
    Value<DateTime?> deletedAt = const Value.absent(),
    String? schoolId,
    String? teacherId,
    String? classId,
    String? chapterId,
    String? signals,
    String? summary,
    String? actions,
    String? deck,
    String? source,
  }) => TeachingInsightRecord(
    id: id ?? this.id,
    createdAt: createdAt ?? this.createdAt,
    updatedAt: updatedAt ?? this.updatedAt,
    deletedAt: deletedAt.present ? deletedAt.value : this.deletedAt,
    schoolId: schoolId ?? this.schoolId,
    teacherId: teacherId ?? this.teacherId,
    classId: classId ?? this.classId,
    chapterId: chapterId ?? this.chapterId,
    signals: signals ?? this.signals,
    summary: summary ?? this.summary,
    actions: actions ?? this.actions,
    deck: deck ?? this.deck,
    source: source ?? this.source,
  );
  TeachingInsightRecord copyWithCompanion(TeachingInsightsCompanion data) {
    return TeachingInsightRecord(
      id: data.id.present ? data.id.value : this.id,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
      deletedAt: data.deletedAt.present ? data.deletedAt.value : this.deletedAt,
      schoolId: data.schoolId.present ? data.schoolId.value : this.schoolId,
      teacherId: data.teacherId.present ? data.teacherId.value : this.teacherId,
      classId: data.classId.present ? data.classId.value : this.classId,
      chapterId: data.chapterId.present ? data.chapterId.value : this.chapterId,
      signals: data.signals.present ? data.signals.value : this.signals,
      summary: data.summary.present ? data.summary.value : this.summary,
      actions: data.actions.present ? data.actions.value : this.actions,
      deck: data.deck.present ? data.deck.value : this.deck,
      source: data.source.present ? data.source.value : this.source,
    );
  }

  @override
  String toString() {
    return (StringBuffer('TeachingInsightRecord(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('classId: $classId, ')
          ..write('chapterId: $chapterId, ')
          ..write('signals: $signals, ')
          ..write('summary: $summary, ')
          ..write('actions: $actions, ')
          ..write('deck: $deck, ')
          ..write('source: $source')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    createdAt,
    updatedAt,
    deletedAt,
    schoolId,
    teacherId,
    classId,
    chapterId,
    signals,
    summary,
    actions,
    deck,
    source,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is TeachingInsightRecord &&
          other.id == this.id &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt &&
          other.deletedAt == this.deletedAt &&
          other.schoolId == this.schoolId &&
          other.teacherId == this.teacherId &&
          other.classId == this.classId &&
          other.chapterId == this.chapterId &&
          other.signals == this.signals &&
          other.summary == this.summary &&
          other.actions == this.actions &&
          other.deck == this.deck &&
          other.source == this.source);
}

class TeachingInsightsCompanion extends UpdateCompanion<TeachingInsightRecord> {
  final Value<String> id;
  final Value<DateTime> createdAt;
  final Value<DateTime> updatedAt;
  final Value<DateTime?> deletedAt;
  final Value<String> schoolId;
  final Value<String> teacherId;
  final Value<String> classId;
  final Value<String> chapterId;
  final Value<String> signals;
  final Value<String> summary;
  final Value<String> actions;
  final Value<String> deck;
  final Value<String> source;
  final Value<int> rowid;
  const TeachingInsightsCompanion({
    this.id = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
    this.deletedAt = const Value.absent(),
    this.schoolId = const Value.absent(),
    this.teacherId = const Value.absent(),
    this.classId = const Value.absent(),
    this.chapterId = const Value.absent(),
    this.signals = const Value.absent(),
    this.summary = const Value.absent(),
    this.actions = const Value.absent(),
    this.deck = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  TeachingInsightsCompanion.insert({
    required String id,
    required DateTime createdAt,
    required DateTime updatedAt,
    this.deletedAt = const Value.absent(),
    required String schoolId,
    required String teacherId,
    required String classId,
    required String chapterId,
    this.signals = const Value.absent(),
    this.summary = const Value.absent(),
    this.actions = const Value.absent(),
    this.deck = const Value.absent(),
    this.source = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       createdAt = Value(createdAt),
       updatedAt = Value(updatedAt),
       schoolId = Value(schoolId),
       teacherId = Value(teacherId),
       classId = Value(classId),
       chapterId = Value(chapterId);
  static Insertable<TeachingInsightRecord> custom({
    Expression<String>? id,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
    Expression<DateTime>? deletedAt,
    Expression<String>? schoolId,
    Expression<String>? teacherId,
    Expression<String>? classId,
    Expression<String>? chapterId,
    Expression<String>? signals,
    Expression<String>? summary,
    Expression<String>? actions,
    Expression<String>? deck,
    Expression<String>? source,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
      if (deletedAt != null) 'deleted_at': deletedAt,
      if (schoolId != null) 'school_id': schoolId,
      if (teacherId != null) 'teacher_id': teacherId,
      if (classId != null) 'class_id': classId,
      if (chapterId != null) 'chapter_id': chapterId,
      if (signals != null) 'signals': signals,
      if (summary != null) 'summary': summary,
      if (actions != null) 'actions': actions,
      if (deck != null) 'deck': deck,
      if (source != null) 'source': source,
      if (rowid != null) 'rowid': rowid,
    });
  }

  TeachingInsightsCompanion copyWith({
    Value<String>? id,
    Value<DateTime>? createdAt,
    Value<DateTime>? updatedAt,
    Value<DateTime?>? deletedAt,
    Value<String>? schoolId,
    Value<String>? teacherId,
    Value<String>? classId,
    Value<String>? chapterId,
    Value<String>? signals,
    Value<String>? summary,
    Value<String>? actions,
    Value<String>? deck,
    Value<String>? source,
    Value<int>? rowid,
  }) {
    return TeachingInsightsCompanion(
      id: id ?? this.id,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      deletedAt: deletedAt ?? this.deletedAt,
      schoolId: schoolId ?? this.schoolId,
      teacherId: teacherId ?? this.teacherId,
      classId: classId ?? this.classId,
      chapterId: chapterId ?? this.chapterId,
      signals: signals ?? this.signals,
      summary: summary ?? this.summary,
      actions: actions ?? this.actions,
      deck: deck ?? this.deck,
      source: source ?? this.source,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    if (deletedAt.present) {
      map['deleted_at'] = Variable<DateTime>(deletedAt.value);
    }
    if (schoolId.present) {
      map['school_id'] = Variable<String>(schoolId.value);
    }
    if (teacherId.present) {
      map['teacher_id'] = Variable<String>(teacherId.value);
    }
    if (classId.present) {
      map['class_id'] = Variable<String>(classId.value);
    }
    if (chapterId.present) {
      map['chapter_id'] = Variable<String>(chapterId.value);
    }
    if (signals.present) {
      map['signals'] = Variable<String>(signals.value);
    }
    if (summary.present) {
      map['summary'] = Variable<String>(summary.value);
    }
    if (actions.present) {
      map['actions'] = Variable<String>(actions.value);
    }
    if (deck.present) {
      map['deck'] = Variable<String>(deck.value);
    }
    if (source.present) {
      map['source'] = Variable<String>(source.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('TeachingInsightsCompanion(')
          ..write('id: $id, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt, ')
          ..write('deletedAt: $deletedAt, ')
          ..write('schoolId: $schoolId, ')
          ..write('teacherId: $teacherId, ')
          ..write('classId: $classId, ')
          ..write('chapterId: $chapterId, ')
          ..write('signals: $signals, ')
          ..write('summary: $summary, ')
          ..write('actions: $actions, ')
          ..write('deck: $deck, ')
          ..write('source: $source, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $SyncStateTable extends SyncState
    with TableInfo<$SyncStateTable, SyncStateData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SyncStateTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _tableMeta = const VerificationMeta('table');
  @override
  late final GeneratedColumn<String> table = GeneratedColumn<String>(
    'table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _watermarkMeta = const VerificationMeta(
    'watermark',
  );
  @override
  late final GeneratedColumn<DateTime> watermark = GeneratedColumn<DateTime>(
    'watermark',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _lastPullAtMeta = const VerificationMeta(
    'lastPullAt',
  );
  @override
  late final GeneratedColumn<DateTime> lastPullAt = GeneratedColumn<DateTime>(
    'last_pull_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [table, watermark, lastPullAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'sync_state';
  @override
  VerificationContext validateIntegrity(
    Insertable<SyncStateData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('table')) {
      context.handle(
        _tableMeta,
        table.isAcceptableOrUnknown(data['table']!, _tableMeta),
      );
    } else if (isInserting) {
      context.missing(_tableMeta);
    }
    if (data.containsKey('watermark')) {
      context.handle(
        _watermarkMeta,
        watermark.isAcceptableOrUnknown(data['watermark']!, _watermarkMeta),
      );
    }
    if (data.containsKey('last_pull_at')) {
      context.handle(
        _lastPullAtMeta,
        lastPullAt.isAcceptableOrUnknown(
          data['last_pull_at']!,
          _lastPullAtMeta,
        ),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {table};
  @override
  SyncStateData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SyncStateData(
      table: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table'],
      )!,
      watermark: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}watermark'],
      ),
      lastPullAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}last_pull_at'],
      ),
    );
  }

  @override
  $SyncStateTable createAlias(String alias) {
    return $SyncStateTable(attachedDatabase, alias);
  }
}

class SyncStateData extends DataClass implements Insertable<SyncStateData> {
  final String table;
  final DateTime? watermark;
  final DateTime? lastPullAt;
  const SyncStateData({required this.table, this.watermark, this.lastPullAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['table'] = Variable<String>(table);
    if (!nullToAbsent || watermark != null) {
      map['watermark'] = Variable<DateTime>(watermark);
    }
    if (!nullToAbsent || lastPullAt != null) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt);
    }
    return map;
  }

  SyncStateCompanion toCompanion(bool nullToAbsent) {
    return SyncStateCompanion(
      table: Value(table),
      watermark: watermark == null && nullToAbsent
          ? const Value.absent()
          : Value(watermark),
      lastPullAt: lastPullAt == null && nullToAbsent
          ? const Value.absent()
          : Value(lastPullAt),
    );
  }

  factory SyncStateData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SyncStateData(
      table: serializer.fromJson<String>(json['table']),
      watermark: serializer.fromJson<DateTime?>(json['watermark']),
      lastPullAt: serializer.fromJson<DateTime?>(json['lastPullAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'table': serializer.toJson<String>(table),
      'watermark': serializer.toJson<DateTime?>(watermark),
      'lastPullAt': serializer.toJson<DateTime?>(lastPullAt),
    };
  }

  SyncStateData copyWith({
    String? table,
    Value<DateTime?> watermark = const Value.absent(),
    Value<DateTime?> lastPullAt = const Value.absent(),
  }) => SyncStateData(
    table: table ?? this.table,
    watermark: watermark.present ? watermark.value : this.watermark,
    lastPullAt: lastPullAt.present ? lastPullAt.value : this.lastPullAt,
  );
  SyncStateData copyWithCompanion(SyncStateCompanion data) {
    return SyncStateData(
      table: data.table.present ? data.table.value : this.table,
      watermark: data.watermark.present ? data.watermark.value : this.watermark,
      lastPullAt: data.lastPullAt.present
          ? data.lastPullAt.value
          : this.lastPullAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateData(')
          ..write('table: $table, ')
          ..write('watermark: $watermark, ')
          ..write('lastPullAt: $lastPullAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(table, watermark, lastPullAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SyncStateData &&
          other.table == this.table &&
          other.watermark == this.watermark &&
          other.lastPullAt == this.lastPullAt);
}

class SyncStateCompanion extends UpdateCompanion<SyncStateData> {
  final Value<String> table;
  final Value<DateTime?> watermark;
  final Value<DateTime?> lastPullAt;
  final Value<int> rowid;
  const SyncStateCompanion({
    this.table = const Value.absent(),
    this.watermark = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  SyncStateCompanion.insert({
    required String table,
    this.watermark = const Value.absent(),
    this.lastPullAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : table = Value(table);
  static Insertable<SyncStateData> custom({
    Expression<String>? table,
    Expression<DateTime>? watermark,
    Expression<DateTime>? lastPullAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (table != null) 'table': table,
      if (watermark != null) 'watermark': watermark,
      if (lastPullAt != null) 'last_pull_at': lastPullAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  SyncStateCompanion copyWith({
    Value<String>? table,
    Value<DateTime?>? watermark,
    Value<DateTime?>? lastPullAt,
    Value<int>? rowid,
  }) {
    return SyncStateCompanion(
      table: table ?? this.table,
      watermark: watermark ?? this.watermark,
      lastPullAt: lastPullAt ?? this.lastPullAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (table.present) {
      map['table'] = Variable<String>(table.value);
    }
    if (watermark.present) {
      map['watermark'] = Variable<DateTime>(watermark.value);
    }
    if (lastPullAt.present) {
      map['last_pull_at'] = Variable<DateTime>(lastPullAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SyncStateCompanion(')
          ..write('table: $table, ')
          ..write('watermark: $watermark, ')
          ..write('lastPullAt: $lastPullAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $OutboxTable extends Outbox with TableInfo<$OutboxTable, OutboxData> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $OutboxTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _opMeta = const VerificationMeta('op');
  @override
  late final GeneratedColumn<String> op = GeneratedColumn<String>(
    'op',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableMeta = const VerificationMeta('table');
  @override
  late final GeneratedColumn<String> table = GeneratedColumn<String>(
    'table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _observedValueMeta = const VerificationMeta(
    'observedValue',
  );
  @override
  late final GeneratedColumn<String> observedValue = GeneratedColumn<String>(
    'observed_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _newValueMeta = const VerificationMeta(
    'newValue',
  );
  @override
  late final GeneratedColumn<String> newValue = GeneratedColumn<String>(
    'new_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _clientTsMeta = const VerificationMeta(
    'clientTs',
  );
  @override
  late final GeneratedColumn<DateTime> clientTs = GeneratedColumn<DateTime>(
    'client_ts',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    op,
    table,
    rowId,
    field,
    observedValue,
    newValue,
    payload,
    clientTs,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'outbox';
  @override
  VerificationContext validateIntegrity(
    Insertable<OutboxData> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('op')) {
      context.handle(_opMeta, op.isAcceptableOrUnknown(data['op']!, _opMeta));
    } else if (isInserting) {
      context.missing(_opMeta);
    }
    if (data.containsKey('table')) {
      context.handle(
        _tableMeta,
        table.isAcceptableOrUnknown(data['table']!, _tableMeta),
      );
    } else if (isInserting) {
      context.missing(_tableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    }
    if (data.containsKey('observed_value')) {
      context.handle(
        _observedValueMeta,
        observedValue.isAcceptableOrUnknown(
          data['observed_value']!,
          _observedValueMeta,
        ),
      );
    }
    if (data.containsKey('new_value')) {
      context.handle(
        _newValueMeta,
        newValue.isAcceptableOrUnknown(data['new_value']!, _newValueMeta),
      );
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    }
    if (data.containsKey('client_ts')) {
      context.handle(
        _clientTsMeta,
        clientTs.isAcceptableOrUnknown(data['client_ts']!, _clientTsMeta),
      );
    } else if (isInserting) {
      context.missing(_clientTsMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
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
  OutboxData map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return OutboxData(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      op: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}op'],
      )!,
      table: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      ),
      observedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_value'],
      ),
      newValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}new_value'],
      ),
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      ),
      clientTs: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}client_ts'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $OutboxTable createAlias(String alias) {
    return $OutboxTable(attachedDatabase, alias);
  }
}

class OutboxData extends DataClass implements Insertable<OutboxData> {
  final String id;
  final String op;
  final String table;
  final String rowId;
  final String? field;
  final String? observedValue;
  final String? newValue;
  final String? payload;
  final DateTime clientTs;
  final int attempts;
  final String? lastError;
  const OutboxData({
    required this.id,
    required this.op,
    required this.table,
    required this.rowId,
    this.field,
    this.observedValue,
    this.newValue,
    this.payload,
    required this.clientTs,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['op'] = Variable<String>(op);
    map['table'] = Variable<String>(table);
    map['row_id'] = Variable<String>(rowId);
    if (!nullToAbsent || field != null) {
      map['field'] = Variable<String>(field);
    }
    if (!nullToAbsent || observedValue != null) {
      map['observed_value'] = Variable<String>(observedValue);
    }
    if (!nullToAbsent || newValue != null) {
      map['new_value'] = Variable<String>(newValue);
    }
    if (!nullToAbsent || payload != null) {
      map['payload'] = Variable<String>(payload);
    }
    map['client_ts'] = Variable<DateTime>(clientTs);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  OutboxCompanion toCompanion(bool nullToAbsent) {
    return OutboxCompanion(
      id: Value(id),
      op: Value(op),
      table: Value(table),
      rowId: Value(rowId),
      field: field == null && nullToAbsent
          ? const Value.absent()
          : Value(field),
      observedValue: observedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(observedValue),
      newValue: newValue == null && nullToAbsent
          ? const Value.absent()
          : Value(newValue),
      payload: payload == null && nullToAbsent
          ? const Value.absent()
          : Value(payload),
      clientTs: Value(clientTs),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory OutboxData.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return OutboxData(
      id: serializer.fromJson<String>(json['id']),
      op: serializer.fromJson<String>(json['op']),
      table: serializer.fromJson<String>(json['table']),
      rowId: serializer.fromJson<String>(json['rowId']),
      field: serializer.fromJson<String?>(json['field']),
      observedValue: serializer.fromJson<String?>(json['observedValue']),
      newValue: serializer.fromJson<String?>(json['newValue']),
      payload: serializer.fromJson<String?>(json['payload']),
      clientTs: serializer.fromJson<DateTime>(json['clientTs']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'op': serializer.toJson<String>(op),
      'table': serializer.toJson<String>(table),
      'rowId': serializer.toJson<String>(rowId),
      'field': serializer.toJson<String?>(field),
      'observedValue': serializer.toJson<String?>(observedValue),
      'newValue': serializer.toJson<String?>(newValue),
      'payload': serializer.toJson<String?>(payload),
      'clientTs': serializer.toJson<DateTime>(clientTs),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  OutboxData copyWith({
    String? id,
    String? op,
    String? table,
    String? rowId,
    Value<String?> field = const Value.absent(),
    Value<String?> observedValue = const Value.absent(),
    Value<String?> newValue = const Value.absent(),
    Value<String?> payload = const Value.absent(),
    DateTime? clientTs,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => OutboxData(
    id: id ?? this.id,
    op: op ?? this.op,
    table: table ?? this.table,
    rowId: rowId ?? this.rowId,
    field: field.present ? field.value : this.field,
    observedValue: observedValue.present
        ? observedValue.value
        : this.observedValue,
    newValue: newValue.present ? newValue.value : this.newValue,
    payload: payload.present ? payload.value : this.payload,
    clientTs: clientTs ?? this.clientTs,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  OutboxData copyWithCompanion(OutboxCompanion data) {
    return OutboxData(
      id: data.id.present ? data.id.value : this.id,
      op: data.op.present ? data.op.value : this.op,
      table: data.table.present ? data.table.value : this.table,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      field: data.field.present ? data.field.value : this.field,
      observedValue: data.observedValue.present
          ? data.observedValue.value
          : this.observedValue,
      newValue: data.newValue.present ? data.newValue.value : this.newValue,
      payload: data.payload.present ? data.payload.value : this.payload,
      clientTs: data.clientTs.present ? data.clientTs.value : this.clientTs,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('OutboxData(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('table: $table, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('observedValue: $observedValue, ')
          ..write('newValue: $newValue, ')
          ..write('payload: $payload, ')
          ..write('clientTs: $clientTs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    op,
    table,
    rowId,
    field,
    observedValue,
    newValue,
    payload,
    clientTs,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is OutboxData &&
          other.id == this.id &&
          other.op == this.op &&
          other.table == this.table &&
          other.rowId == this.rowId &&
          other.field == this.field &&
          other.observedValue == this.observedValue &&
          other.newValue == this.newValue &&
          other.payload == this.payload &&
          other.clientTs == this.clientTs &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class OutboxCompanion extends UpdateCompanion<OutboxData> {
  final Value<String> id;
  final Value<String> op;
  final Value<String> table;
  final Value<String> rowId;
  final Value<String?> field;
  final Value<String?> observedValue;
  final Value<String?> newValue;
  final Value<String?> payload;
  final Value<DateTime> clientTs;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const OutboxCompanion({
    this.id = const Value.absent(),
    this.op = const Value.absent(),
    this.table = const Value.absent(),
    this.rowId = const Value.absent(),
    this.field = const Value.absent(),
    this.observedValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.payload = const Value.absent(),
    this.clientTs = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  OutboxCompanion.insert({
    required String id,
    required String op,
    required String table,
    required String rowId,
    this.field = const Value.absent(),
    this.observedValue = const Value.absent(),
    this.newValue = const Value.absent(),
    this.payload = const Value.absent(),
    required DateTime clientTs,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       op = Value(op),
       table = Value(table),
       rowId = Value(rowId),
       clientTs = Value(clientTs);
  static Insertable<OutboxData> custom({
    Expression<String>? id,
    Expression<String>? op,
    Expression<String>? table,
    Expression<String>? rowId,
    Expression<String>? field,
    Expression<String>? observedValue,
    Expression<String>? newValue,
    Expression<String>? payload,
    Expression<DateTime>? clientTs,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (op != null) 'op': op,
      if (table != null) 'table': table,
      if (rowId != null) 'row_id': rowId,
      if (field != null) 'field': field,
      if (observedValue != null) 'observed_value': observedValue,
      if (newValue != null) 'new_value': newValue,
      if (payload != null) 'payload': payload,
      if (clientTs != null) 'client_ts': clientTs,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  OutboxCompanion copyWith({
    Value<String>? id,
    Value<String>? op,
    Value<String>? table,
    Value<String>? rowId,
    Value<String?>? field,
    Value<String?>? observedValue,
    Value<String?>? newValue,
    Value<String?>? payload,
    Value<DateTime>? clientTs,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return OutboxCompanion(
      id: id ?? this.id,
      op: op ?? this.op,
      table: table ?? this.table,
      rowId: rowId ?? this.rowId,
      field: field ?? this.field,
      observedValue: observedValue ?? this.observedValue,
      newValue: newValue ?? this.newValue,
      payload: payload ?? this.payload,
      clientTs: clientTs ?? this.clientTs,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (op.present) {
      map['op'] = Variable<String>(op.value);
    }
    if (table.present) {
      map['table'] = Variable<String>(table.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (observedValue.present) {
      map['observed_value'] = Variable<String>(observedValue.value);
    }
    if (newValue.present) {
      map['new_value'] = Variable<String>(newValue.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (clientTs.present) {
      map['client_ts'] = Variable<DateTime>(clientTs.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('OutboxCompanion(')
          ..write('id: $id, ')
          ..write('op: $op, ')
          ..write('table: $table, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('observedValue: $observedValue, ')
          ..write('newValue: $newValue, ')
          ..write('payload: $payload, ')
          ..write('clientTs: $clientTs, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $PendingIntentsTable extends PendingIntents
    with TableInfo<$PendingIntentsTable, PendingIntent> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $PendingIntentsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _functionNameMeta = const VerificationMeta(
    'functionName',
  );
  @override
  late final GeneratedColumn<String> functionName = GeneratedColumn<String>(
    'function_name',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _payloadMeta = const VerificationMeta(
    'payload',
  );
  @override
  late final GeneratedColumn<String> payload = GeneratedColumn<String>(
    'payload',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _statusMeta = const VerificationMeta('status');
  @override
  late final GeneratedColumn<String> status = GeneratedColumn<String>(
    'status',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
    defaultValue: const Constant('pending'),
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
  static const VerificationMeta _attemptsMeta = const VerificationMeta(
    'attempts',
  );
  @override
  late final GeneratedColumn<int> attempts = GeneratedColumn<int>(
    'attempts',
    aliasedName,
    false,
    type: DriftSqlType.int,
    requiredDuringInsert: false,
    defaultValue: const Constant(0),
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
    functionName,
    payload,
    status,
    createdAt,
    attempts,
    lastError,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'pending_intents';
  @override
  VerificationContext validateIntegrity(
    Insertable<PendingIntent> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('function_name')) {
      context.handle(
        _functionNameMeta,
        functionName.isAcceptableOrUnknown(
          data['function_name']!,
          _functionNameMeta,
        ),
      );
    } else if (isInserting) {
      context.missing(_functionNameMeta);
    }
    if (data.containsKey('payload')) {
      context.handle(
        _payloadMeta,
        payload.isAcceptableOrUnknown(data['payload']!, _payloadMeta),
      );
    } else if (isInserting) {
      context.missing(_payloadMeta);
    }
    if (data.containsKey('status')) {
      context.handle(
        _statusMeta,
        status.isAcceptableOrUnknown(data['status']!, _statusMeta),
      );
    }
    if (data.containsKey('created_at')) {
      context.handle(
        _createdAtMeta,
        createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta),
      );
    } else if (isInserting) {
      context.missing(_createdAtMeta);
    }
    if (data.containsKey('attempts')) {
      context.handle(
        _attemptsMeta,
        attempts.isAcceptableOrUnknown(data['attempts']!, _attemptsMeta),
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
  PendingIntent map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return PendingIntent(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      functionName: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}function_name'],
      )!,
      payload: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}payload'],
      )!,
      status: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}status'],
      )!,
      createdAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}created_at'],
      )!,
      attempts: attachedDatabase.typeMapping.read(
        DriftSqlType.int,
        data['${effectivePrefix}attempts'],
      )!,
      lastError: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}last_error'],
      ),
    );
  }

  @override
  $PendingIntentsTable createAlias(String alias) {
    return $PendingIntentsTable(attachedDatabase, alias);
  }
}

class PendingIntent extends DataClass implements Insertable<PendingIntent> {
  final String id;
  final String functionName;
  final String payload;
  final String status;
  final DateTime createdAt;
  final int attempts;
  final String? lastError;
  const PendingIntent({
    required this.id,
    required this.functionName,
    required this.payload,
    required this.status,
    required this.createdAt,
    required this.attempts,
    this.lastError,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['function_name'] = Variable<String>(functionName);
    map['payload'] = Variable<String>(payload);
    map['status'] = Variable<String>(status);
    map['created_at'] = Variable<DateTime>(createdAt);
    map['attempts'] = Variable<int>(attempts);
    if (!nullToAbsent || lastError != null) {
      map['last_error'] = Variable<String>(lastError);
    }
    return map;
  }

  PendingIntentsCompanion toCompanion(bool nullToAbsent) {
    return PendingIntentsCompanion(
      id: Value(id),
      functionName: Value(functionName),
      payload: Value(payload),
      status: Value(status),
      createdAt: Value(createdAt),
      attempts: Value(attempts),
      lastError: lastError == null && nullToAbsent
          ? const Value.absent()
          : Value(lastError),
    );
  }

  factory PendingIntent.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return PendingIntent(
      id: serializer.fromJson<String>(json['id']),
      functionName: serializer.fromJson<String>(json['functionName']),
      payload: serializer.fromJson<String>(json['payload']),
      status: serializer.fromJson<String>(json['status']),
      createdAt: serializer.fromJson<DateTime>(json['createdAt']),
      attempts: serializer.fromJson<int>(json['attempts']),
      lastError: serializer.fromJson<String?>(json['lastError']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'functionName': serializer.toJson<String>(functionName),
      'payload': serializer.toJson<String>(payload),
      'status': serializer.toJson<String>(status),
      'createdAt': serializer.toJson<DateTime>(createdAt),
      'attempts': serializer.toJson<int>(attempts),
      'lastError': serializer.toJson<String?>(lastError),
    };
  }

  PendingIntent copyWith({
    String? id,
    String? functionName,
    String? payload,
    String? status,
    DateTime? createdAt,
    int? attempts,
    Value<String?> lastError = const Value.absent(),
  }) => PendingIntent(
    id: id ?? this.id,
    functionName: functionName ?? this.functionName,
    payload: payload ?? this.payload,
    status: status ?? this.status,
    createdAt: createdAt ?? this.createdAt,
    attempts: attempts ?? this.attempts,
    lastError: lastError.present ? lastError.value : this.lastError,
  );
  PendingIntent copyWithCompanion(PendingIntentsCompanion data) {
    return PendingIntent(
      id: data.id.present ? data.id.value : this.id,
      functionName: data.functionName.present
          ? data.functionName.value
          : this.functionName,
      payload: data.payload.present ? data.payload.value : this.payload,
      status: data.status.present ? data.status.value : this.status,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      attempts: data.attempts.present ? data.attempts.value : this.attempts,
      lastError: data.lastError.present ? data.lastError.value : this.lastError,
    );
  }

  @override
  String toString() {
    return (StringBuffer('PendingIntent(')
          ..write('id: $id, ')
          ..write('functionName: $functionName, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    functionName,
    payload,
    status,
    createdAt,
    attempts,
    lastError,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is PendingIntent &&
          other.id == this.id &&
          other.functionName == this.functionName &&
          other.payload == this.payload &&
          other.status == this.status &&
          other.createdAt == this.createdAt &&
          other.attempts == this.attempts &&
          other.lastError == this.lastError);
}

class PendingIntentsCompanion extends UpdateCompanion<PendingIntent> {
  final Value<String> id;
  final Value<String> functionName;
  final Value<String> payload;
  final Value<String> status;
  final Value<DateTime> createdAt;
  final Value<int> attempts;
  final Value<String?> lastError;
  final Value<int> rowid;
  const PendingIntentsCompanion({
    this.id = const Value.absent(),
    this.functionName = const Value.absent(),
    this.payload = const Value.absent(),
    this.status = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  PendingIntentsCompanion.insert({
    required String id,
    required String functionName,
    required String payload,
    this.status = const Value.absent(),
    required DateTime createdAt,
    this.attempts = const Value.absent(),
    this.lastError = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       functionName = Value(functionName),
       payload = Value(payload),
       createdAt = Value(createdAt);
  static Insertable<PendingIntent> custom({
    Expression<String>? id,
    Expression<String>? functionName,
    Expression<String>? payload,
    Expression<String>? status,
    Expression<DateTime>? createdAt,
    Expression<int>? attempts,
    Expression<String>? lastError,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (functionName != null) 'function_name': functionName,
      if (payload != null) 'payload': payload,
      if (status != null) 'status': status,
      if (createdAt != null) 'created_at': createdAt,
      if (attempts != null) 'attempts': attempts,
      if (lastError != null) 'last_error': lastError,
      if (rowid != null) 'rowid': rowid,
    });
  }

  PendingIntentsCompanion copyWith({
    Value<String>? id,
    Value<String>? functionName,
    Value<String>? payload,
    Value<String>? status,
    Value<DateTime>? createdAt,
    Value<int>? attempts,
    Value<String?>? lastError,
    Value<int>? rowid,
  }) {
    return PendingIntentsCompanion(
      id: id ?? this.id,
      functionName: functionName ?? this.functionName,
      payload: payload ?? this.payload,
      status: status ?? this.status,
      createdAt: createdAt ?? this.createdAt,
      attempts: attempts ?? this.attempts,
      lastError: lastError ?? this.lastError,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (functionName.present) {
      map['function_name'] = Variable<String>(functionName.value);
    }
    if (payload.present) {
      map['payload'] = Variable<String>(payload.value);
    }
    if (status.present) {
      map['status'] = Variable<String>(status.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (attempts.present) {
      map['attempts'] = Variable<int>(attempts.value);
    }
    if (lastError.present) {
      map['last_error'] = Variable<String>(lastError.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('PendingIntentsCompanion(')
          ..write('id: $id, ')
          ..write('functionName: $functionName, ')
          ..write('payload: $payload, ')
          ..write('status: $status, ')
          ..write('createdAt: $createdAt, ')
          ..write('attempts: $attempts, ')
          ..write('lastError: $lastError, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

class $LocalConflictsTable extends LocalConflicts
    with TableInfo<$LocalConflictsTable, LocalConflict> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $LocalConflictsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<String> id = GeneratedColumn<String>(
    'id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _tableMeta = const VerificationMeta('table');
  @override
  late final GeneratedColumn<String> table = GeneratedColumn<String>(
    'table',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _rowIdMeta = const VerificationMeta('rowId');
  @override
  late final GeneratedColumn<String> rowId = GeneratedColumn<String>(
    'row_id',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _fieldMeta = const VerificationMeta('field');
  @override
  late final GeneratedColumn<String> field = GeneratedColumn<String>(
    'field',
    aliasedName,
    false,
    type: DriftSqlType.string,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _observedValueMeta = const VerificationMeta(
    'observedValue',
  );
  @override
  late final GeneratedColumn<String> observedValue = GeneratedColumn<String>(
    'observed_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _attemptedValueMeta = const VerificationMeta(
    'attemptedValue',
  );
  @override
  late final GeneratedColumn<String> attemptedValue = GeneratedColumn<String>(
    'attempted_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _serverValueMeta = const VerificationMeta(
    'serverValue',
  );
  @override
  late final GeneratedColumn<String> serverValue = GeneratedColumn<String>(
    'server_value',
    aliasedName,
    true,
    type: DriftSqlType.string,
    requiredDuringInsert: false,
  );
  static const VerificationMeta _detectedAtMeta = const VerificationMeta(
    'detectedAt',
  );
  @override
  late final GeneratedColumn<DateTime> detectedAt = GeneratedColumn<DateTime>(
    'detected_at',
    aliasedName,
    false,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: true,
  );
  static const VerificationMeta _resolvedAtMeta = const VerificationMeta(
    'resolvedAt',
  );
  @override
  late final GeneratedColumn<DateTime> resolvedAt = GeneratedColumn<DateTime>(
    'resolved_at',
    aliasedName,
    true,
    type: DriftSqlType.dateTime,
    requiredDuringInsert: false,
  );
  @override
  List<GeneratedColumn> get $columns => [
    id,
    table,
    rowId,
    field,
    observedValue,
    attemptedValue,
    serverValue,
    detectedAt,
    resolvedAt,
  ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'local_conflicts';
  @override
  VerificationContext validateIntegrity(
    Insertable<LocalConflict> instance, {
    bool isInserting = false,
  }) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    } else if (isInserting) {
      context.missing(_idMeta);
    }
    if (data.containsKey('table')) {
      context.handle(
        _tableMeta,
        table.isAcceptableOrUnknown(data['table']!, _tableMeta),
      );
    } else if (isInserting) {
      context.missing(_tableMeta);
    }
    if (data.containsKey('row_id')) {
      context.handle(
        _rowIdMeta,
        rowId.isAcceptableOrUnknown(data['row_id']!, _rowIdMeta),
      );
    } else if (isInserting) {
      context.missing(_rowIdMeta);
    }
    if (data.containsKey('field')) {
      context.handle(
        _fieldMeta,
        field.isAcceptableOrUnknown(data['field']!, _fieldMeta),
      );
    } else if (isInserting) {
      context.missing(_fieldMeta);
    }
    if (data.containsKey('observed_value')) {
      context.handle(
        _observedValueMeta,
        observedValue.isAcceptableOrUnknown(
          data['observed_value']!,
          _observedValueMeta,
        ),
      );
    }
    if (data.containsKey('attempted_value')) {
      context.handle(
        _attemptedValueMeta,
        attemptedValue.isAcceptableOrUnknown(
          data['attempted_value']!,
          _attemptedValueMeta,
        ),
      );
    }
    if (data.containsKey('server_value')) {
      context.handle(
        _serverValueMeta,
        serverValue.isAcceptableOrUnknown(
          data['server_value']!,
          _serverValueMeta,
        ),
      );
    }
    if (data.containsKey('detected_at')) {
      context.handle(
        _detectedAtMeta,
        detectedAt.isAcceptableOrUnknown(data['detected_at']!, _detectedAtMeta),
      );
    } else if (isInserting) {
      context.missing(_detectedAtMeta);
    }
    if (data.containsKey('resolved_at')) {
      context.handle(
        _resolvedAtMeta,
        resolvedAt.isAcceptableOrUnknown(data['resolved_at']!, _resolvedAtMeta),
      );
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  LocalConflict map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return LocalConflict(
      id: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}id'],
      )!,
      table: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}table'],
      )!,
      rowId: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}row_id'],
      )!,
      field: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}field'],
      )!,
      observedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}observed_value'],
      ),
      attemptedValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}attempted_value'],
      ),
      serverValue: attachedDatabase.typeMapping.read(
        DriftSqlType.string,
        data['${effectivePrefix}server_value'],
      ),
      detectedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}detected_at'],
      )!,
      resolvedAt: attachedDatabase.typeMapping.read(
        DriftSqlType.dateTime,
        data['${effectivePrefix}resolved_at'],
      ),
    );
  }

  @override
  $LocalConflictsTable createAlias(String alias) {
    return $LocalConflictsTable(attachedDatabase, alias);
  }
}

class LocalConflict extends DataClass implements Insertable<LocalConflict> {
  final String id;
  final String table;
  final String rowId;
  final String field;
  final String? observedValue;
  final String? attemptedValue;
  final String? serverValue;
  final DateTime detectedAt;
  final DateTime? resolvedAt;
  const LocalConflict({
    required this.id,
    required this.table,
    required this.rowId,
    required this.field,
    this.observedValue,
    this.attemptedValue,
    this.serverValue,
    required this.detectedAt,
    this.resolvedAt,
  });
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<String>(id);
    map['table'] = Variable<String>(table);
    map['row_id'] = Variable<String>(rowId);
    map['field'] = Variable<String>(field);
    if (!nullToAbsent || observedValue != null) {
      map['observed_value'] = Variable<String>(observedValue);
    }
    if (!nullToAbsent || attemptedValue != null) {
      map['attempted_value'] = Variable<String>(attemptedValue);
    }
    if (!nullToAbsent || serverValue != null) {
      map['server_value'] = Variable<String>(serverValue);
    }
    map['detected_at'] = Variable<DateTime>(detectedAt);
    if (!nullToAbsent || resolvedAt != null) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt);
    }
    return map;
  }

  LocalConflictsCompanion toCompanion(bool nullToAbsent) {
    return LocalConflictsCompanion(
      id: Value(id),
      table: Value(table),
      rowId: Value(rowId),
      field: Value(field),
      observedValue: observedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(observedValue),
      attemptedValue: attemptedValue == null && nullToAbsent
          ? const Value.absent()
          : Value(attemptedValue),
      serverValue: serverValue == null && nullToAbsent
          ? const Value.absent()
          : Value(serverValue),
      detectedAt: Value(detectedAt),
      resolvedAt: resolvedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(resolvedAt),
    );
  }

  factory LocalConflict.fromJson(
    Map<String, dynamic> json, {
    ValueSerializer? serializer,
  }) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return LocalConflict(
      id: serializer.fromJson<String>(json['id']),
      table: serializer.fromJson<String>(json['table']),
      rowId: serializer.fromJson<String>(json['rowId']),
      field: serializer.fromJson<String>(json['field']),
      observedValue: serializer.fromJson<String?>(json['observedValue']),
      attemptedValue: serializer.fromJson<String?>(json['attemptedValue']),
      serverValue: serializer.fromJson<String?>(json['serverValue']),
      detectedAt: serializer.fromJson<DateTime>(json['detectedAt']),
      resolvedAt: serializer.fromJson<DateTime?>(json['resolvedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<String>(id),
      'table': serializer.toJson<String>(table),
      'rowId': serializer.toJson<String>(rowId),
      'field': serializer.toJson<String>(field),
      'observedValue': serializer.toJson<String?>(observedValue),
      'attemptedValue': serializer.toJson<String?>(attemptedValue),
      'serverValue': serializer.toJson<String?>(serverValue),
      'detectedAt': serializer.toJson<DateTime>(detectedAt),
      'resolvedAt': serializer.toJson<DateTime?>(resolvedAt),
    };
  }

  LocalConflict copyWith({
    String? id,
    String? table,
    String? rowId,
    String? field,
    Value<String?> observedValue = const Value.absent(),
    Value<String?> attemptedValue = const Value.absent(),
    Value<String?> serverValue = const Value.absent(),
    DateTime? detectedAt,
    Value<DateTime?> resolvedAt = const Value.absent(),
  }) => LocalConflict(
    id: id ?? this.id,
    table: table ?? this.table,
    rowId: rowId ?? this.rowId,
    field: field ?? this.field,
    observedValue: observedValue.present
        ? observedValue.value
        : this.observedValue,
    attemptedValue: attemptedValue.present
        ? attemptedValue.value
        : this.attemptedValue,
    serverValue: serverValue.present ? serverValue.value : this.serverValue,
    detectedAt: detectedAt ?? this.detectedAt,
    resolvedAt: resolvedAt.present ? resolvedAt.value : this.resolvedAt,
  );
  LocalConflict copyWithCompanion(LocalConflictsCompanion data) {
    return LocalConflict(
      id: data.id.present ? data.id.value : this.id,
      table: data.table.present ? data.table.value : this.table,
      rowId: data.rowId.present ? data.rowId.value : this.rowId,
      field: data.field.present ? data.field.value : this.field,
      observedValue: data.observedValue.present
          ? data.observedValue.value
          : this.observedValue,
      attemptedValue: data.attemptedValue.present
          ? data.attemptedValue.value
          : this.attemptedValue,
      serverValue: data.serverValue.present
          ? data.serverValue.value
          : this.serverValue,
      detectedAt: data.detectedAt.present
          ? data.detectedAt.value
          : this.detectedAt,
      resolvedAt: data.resolvedAt.present
          ? data.resolvedAt.value
          : this.resolvedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflict(')
          ..write('id: $id, ')
          ..write('table: $table, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('observedValue: $observedValue, ')
          ..write('attemptedValue: $attemptedValue, ')
          ..write('serverValue: $serverValue, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
    id,
    table,
    rowId,
    field,
    observedValue,
    attemptedValue,
    serverValue,
    detectedAt,
    resolvedAt,
  );
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is LocalConflict &&
          other.id == this.id &&
          other.table == this.table &&
          other.rowId == this.rowId &&
          other.field == this.field &&
          other.observedValue == this.observedValue &&
          other.attemptedValue == this.attemptedValue &&
          other.serverValue == this.serverValue &&
          other.detectedAt == this.detectedAt &&
          other.resolvedAt == this.resolvedAt);
}

class LocalConflictsCompanion extends UpdateCompanion<LocalConflict> {
  final Value<String> id;
  final Value<String> table;
  final Value<String> rowId;
  final Value<String> field;
  final Value<String?> observedValue;
  final Value<String?> attemptedValue;
  final Value<String?> serverValue;
  final Value<DateTime> detectedAt;
  final Value<DateTime?> resolvedAt;
  final Value<int> rowid;
  const LocalConflictsCompanion({
    this.id = const Value.absent(),
    this.table = const Value.absent(),
    this.rowId = const Value.absent(),
    this.field = const Value.absent(),
    this.observedValue = const Value.absent(),
    this.attemptedValue = const Value.absent(),
    this.serverValue = const Value.absent(),
    this.detectedAt = const Value.absent(),
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  });
  LocalConflictsCompanion.insert({
    required String id,
    required String table,
    required String rowId,
    required String field,
    this.observedValue = const Value.absent(),
    this.attemptedValue = const Value.absent(),
    this.serverValue = const Value.absent(),
    required DateTime detectedAt,
    this.resolvedAt = const Value.absent(),
    this.rowid = const Value.absent(),
  }) : id = Value(id),
       table = Value(table),
       rowId = Value(rowId),
       field = Value(field),
       detectedAt = Value(detectedAt);
  static Insertable<LocalConflict> custom({
    Expression<String>? id,
    Expression<String>? table,
    Expression<String>? rowId,
    Expression<String>? field,
    Expression<String>? observedValue,
    Expression<String>? attemptedValue,
    Expression<String>? serverValue,
    Expression<DateTime>? detectedAt,
    Expression<DateTime>? resolvedAt,
    Expression<int>? rowid,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (table != null) 'table': table,
      if (rowId != null) 'row_id': rowId,
      if (field != null) 'field': field,
      if (observedValue != null) 'observed_value': observedValue,
      if (attemptedValue != null) 'attempted_value': attemptedValue,
      if (serverValue != null) 'server_value': serverValue,
      if (detectedAt != null) 'detected_at': detectedAt,
      if (resolvedAt != null) 'resolved_at': resolvedAt,
      if (rowid != null) 'rowid': rowid,
    });
  }

  LocalConflictsCompanion copyWith({
    Value<String>? id,
    Value<String>? table,
    Value<String>? rowId,
    Value<String>? field,
    Value<String?>? observedValue,
    Value<String?>? attemptedValue,
    Value<String?>? serverValue,
    Value<DateTime>? detectedAt,
    Value<DateTime?>? resolvedAt,
    Value<int>? rowid,
  }) {
    return LocalConflictsCompanion(
      id: id ?? this.id,
      table: table ?? this.table,
      rowId: rowId ?? this.rowId,
      field: field ?? this.field,
      observedValue: observedValue ?? this.observedValue,
      attemptedValue: attemptedValue ?? this.attemptedValue,
      serverValue: serverValue ?? this.serverValue,
      detectedAt: detectedAt ?? this.detectedAt,
      resolvedAt: resolvedAt ?? this.resolvedAt,
      rowid: rowid ?? this.rowid,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<String>(id.value);
    }
    if (table.present) {
      map['table'] = Variable<String>(table.value);
    }
    if (rowId.present) {
      map['row_id'] = Variable<String>(rowId.value);
    }
    if (field.present) {
      map['field'] = Variable<String>(field.value);
    }
    if (observedValue.present) {
      map['observed_value'] = Variable<String>(observedValue.value);
    }
    if (attemptedValue.present) {
      map['attempted_value'] = Variable<String>(attemptedValue.value);
    }
    if (serverValue.present) {
      map['server_value'] = Variable<String>(serverValue.value);
    }
    if (detectedAt.present) {
      map['detected_at'] = Variable<DateTime>(detectedAt.value);
    }
    if (resolvedAt.present) {
      map['resolved_at'] = Variable<DateTime>(resolvedAt.value);
    }
    if (rowid.present) {
      map['rowid'] = Variable<int>(rowid.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('LocalConflictsCompanion(')
          ..write('id: $id, ')
          ..write('table: $table, ')
          ..write('rowId: $rowId, ')
          ..write('field: $field, ')
          ..write('observedValue: $observedValue, ')
          ..write('attemptedValue: $attemptedValue, ')
          ..write('serverValue: $serverValue, ')
          ..write('detectedAt: $detectedAt, ')
          ..write('resolvedAt: $resolvedAt, ')
          ..write('rowid: $rowid')
          ..write(')'))
        .toString();
  }
}

abstract class _$SyncEduDatabase extends GeneratedDatabase {
  _$SyncEduDatabase(QueryExecutor e) : super(e);
  $SyncEduDatabaseManager get managers => $SyncEduDatabaseManager(this);
  late final $SchoolsTable schools = $SchoolsTable(this);
  late final $ProfilesTable profiles = $ProfilesTable(this);
  late final $StudentsTable students = $StudentsTable(this);
  late final $SubjectsTable subjects = $SubjectsTable(this);
  late final $ChaptersTable chapters = $ChaptersTable(this);
  late final $ClassesTable classes = $ClassesTable(this);
  late final $ClassSubjectsTable classSubjects = $ClassSubjectsTable(this);
  late final $ClassChapterSchedTable classChapterSched =
      $ClassChapterSchedTable(this);
  late final $MicroSkillsTable microSkills = $MicroSkillsTable(this);
  late final $MicroSkillExplanationsTable microSkillExplanations =
      $MicroSkillExplanationsTable(this);
  late final $QuestionsTable questions = $QuestionsTable(this);
  late final $AttemptsTable attempts = $AttemptsTable(this);
  late final $AttemptItemsTable attemptItems = $AttemptItemsTable(this);
  late final $WeaknessesTable weaknesses = $WeaknessesTable(this);
  late final $MaterialsTable materials = $MaterialsTable(this);
  late final $TeacherObservationsTable teacherObservations =
      $TeacherObservationsTable(this);
  late final $GeneratedContentTable generatedContent = $GeneratedContentTable(
    this,
  );
  late final $PreAdmissionResultsTable preAdmissionResults =
      $PreAdmissionResultsTable(this);
  late final $ReflectionCampaignsTable reflectionCampaigns =
      $ReflectionCampaignsTable(this);
  late final $YearEndReflectionsTable yearEndReflections =
      $YearEndReflectionsTable(this);
  late final $FitAnalysesTable fitAnalyses = $FitAnalysesTable(this);
  late final $PlacementSuggestionsTable placementSuggestions =
      $PlacementSuggestionsTable(this);
  late final $ExamPapersTable examPapers = $ExamPapersTable(this);
  late final $TeachingInsightsTable teachingInsights = $TeachingInsightsTable(
    this,
  );
  late final $SyncStateTable syncState = $SyncStateTable(this);
  late final $OutboxTable outbox = $OutboxTable(this);
  late final $PendingIntentsTable pendingIntents = $PendingIntentsTable(this);
  late final $LocalConflictsTable localConflicts = $LocalConflictsTable(this);
  late final Index weaknessesStudentSkillSource = Index(
    'weaknesses_student_skill_source',
    'CREATE UNIQUE INDEX weaknesses_student_skill_source ON weaknesses (student_id, micro_skill_id, source)',
  );
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [
    schools,
    profiles,
    students,
    subjects,
    chapters,
    classes,
    classSubjects,
    classChapterSched,
    microSkills,
    microSkillExplanations,
    questions,
    attempts,
    attemptItems,
    weaknesses,
    materials,
    teacherObservations,
    generatedContent,
    preAdmissionResults,
    reflectionCampaigns,
    yearEndReflections,
    fitAnalyses,
    placementSuggestions,
    examPapers,
    teachingInsights,
    syncState,
    outbox,
    pendingIntents,
    localConflicts,
    weaknessesStudentSkillSource,
  ];
}

typedef $$SchoolsTableCreateCompanionBuilder =
    SchoolsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String name,
      required String educationLevel,
      Value<String> contentLanguage,
      Value<int> maxOfflineDays,
      Value<int> rowid,
    });
typedef $$SchoolsTableUpdateCompanionBuilder =
    SchoolsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> name,
      Value<String> educationLevel,
      Value<String> contentLanguage,
      Value<int> maxOfflineDays,
      Value<int> rowid,
    });

class $$SchoolsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $SchoolsTable> {
  $$SchoolsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get maxOfflineDays => $composableBuilder(
    column: $table.maxOfflineDays,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SchoolsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $SchoolsTable> {
  $$SchoolsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get maxOfflineDays => $composableBuilder(
    column: $table.maxOfflineDays,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SchoolsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $SchoolsTable> {
  $$SchoolsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<String> get educationLevel => $composableBuilder(
    column: $table.educationLevel,
    builder: (column) => column,
  );

  GeneratedColumn<String> get contentLanguage => $composableBuilder(
    column: $table.contentLanguage,
    builder: (column) => column,
  );

  GeneratedColumn<int> get maxOfflineDays => $composableBuilder(
    column: $table.maxOfflineDays,
    builder: (column) => column,
  );
}

class $$SchoolsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $SchoolsTable,
          School,
          $$SchoolsTableFilterComposer,
          $$SchoolsTableOrderingComposer,
          $$SchoolsTableAnnotationComposer,
          $$SchoolsTableCreateCompanionBuilder,
          $$SchoolsTableUpdateCompanionBuilder,
          (School, BaseReferences<_$SyncEduDatabase, $SchoolsTable, School>),
          School,
          PrefetchHooks Function()
        > {
  $$SchoolsTableTableManager(_$SyncEduDatabase db, $SchoolsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SchoolsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SchoolsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SchoolsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<String> educationLevel = const Value.absent(),
                Value<String> contentLanguage = const Value.absent(),
                Value<int> maxOfflineDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                educationLevel: educationLevel,
                contentLanguage: contentLanguage,
                maxOfflineDays: maxOfflineDays,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String name,
                required String educationLevel,
                Value<String> contentLanguage = const Value.absent(),
                Value<int> maxOfflineDays = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SchoolsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                name: name,
                educationLevel: educationLevel,
                contentLanguage: contentLanguage,
                maxOfflineDays: maxOfflineDays,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SchoolsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $SchoolsTable,
      School,
      $$SchoolsTableFilterComposer,
      $$SchoolsTableOrderingComposer,
      $$SchoolsTableAnnotationComposer,
      $$SchoolsTableCreateCompanionBuilder,
      $$SchoolsTableUpdateCompanionBuilder,
      (School, BaseReferences<_$SyncEduDatabase, $SchoolsTable, School>),
      School,
      PrefetchHooks Function()
    >;
typedef $$ProfilesTableCreateCompanionBuilder =
    ProfilesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String role,
      required String fullName,
      required String email,
      Value<int> rowid,
    });
typedef $$ProfilesTableUpdateCompanionBuilder =
    ProfilesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> role,
      Value<String> fullName,
      Value<String> email,
      Value<int> rowid,
    });

class $$ProfilesTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ProfilesTable> {
  $$ProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ProfilesTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ProfilesTable> {
  $$ProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get role => $composableBuilder(
    column: $table.role,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get fullName => $composableBuilder(
    column: $table.fullName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get email => $composableBuilder(
    column: $table.email,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ProfilesTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ProfilesTable> {
  $$ProfilesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get role =>
      $composableBuilder(column: $table.role, builder: (column) => column);

  GeneratedColumn<String> get fullName =>
      $composableBuilder(column: $table.fullName, builder: (column) => column);

  GeneratedColumn<String> get email =>
      $composableBuilder(column: $table.email, builder: (column) => column);
}

class $$ProfilesTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ProfilesTable,
          Profile,
          $$ProfilesTableFilterComposer,
          $$ProfilesTableOrderingComposer,
          $$ProfilesTableAnnotationComposer,
          $$ProfilesTableCreateCompanionBuilder,
          $$ProfilesTableUpdateCompanionBuilder,
          (Profile, BaseReferences<_$SyncEduDatabase, $ProfilesTable, Profile>),
          Profile,
          PrefetchHooks Function()
        > {
  $$ProfilesTableTableManager(_$SyncEduDatabase db, $ProfilesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> role = const Value.absent(),
                Value<String> fullName = const Value.absent(),
                Value<String> email = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                role: role,
                fullName: fullName,
                email: email,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String role,
                required String fullName,
                required String email,
                Value<int> rowid = const Value.absent(),
              }) => ProfilesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                role: role,
                fullName: fullName,
                email: email,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ProfilesTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ProfilesTable,
      Profile,
      $$ProfilesTableFilterComposer,
      $$ProfilesTableOrderingComposer,
      $$ProfilesTableAnnotationComposer,
      $$ProfilesTableCreateCompanionBuilder,
      $$ProfilesTableUpdateCompanionBuilder,
      (Profile, BaseReferences<_$SyncEduDatabase, $ProfilesTable, Profile>),
      Profile,
      PrefetchHooks Function()
    >;
typedef $$StudentsTableCreateCompanionBuilder =
    StudentsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String profileId,
      Value<String?> classId,
      Value<String> specialNeeds,
      Value<String?> specialNeedsNote,
      Value<DateTime?> preAdmissionCompletedAt,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$StudentsTableUpdateCompanionBuilder =
    StudentsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> profileId,
      Value<String?> classId,
      Value<String> specialNeeds,
      Value<String?> specialNeedsNote,
      Value<DateTime?> preAdmissionCompletedAt,
      Value<int> version,
      Value<int> rowid,
    });

class $$StudentsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $StudentsTable> {
  $$StudentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialNeeds => $composableBuilder(
    column: $table.specialNeeds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get specialNeedsNote => $composableBuilder(
    column: $table.specialNeedsNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get preAdmissionCompletedAt => $composableBuilder(
    column: $table.preAdmissionCompletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$StudentsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $StudentsTable> {
  $$StudentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get profileId => $composableBuilder(
    column: $table.profileId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialNeeds => $composableBuilder(
    column: $table.specialNeeds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get specialNeedsNote => $composableBuilder(
    column: $table.specialNeedsNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get preAdmissionCompletedAt => $composableBuilder(
    column: $table.preAdmissionCompletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$StudentsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $StudentsTable> {
  $$StudentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get profileId =>
      $composableBuilder(column: $table.profileId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get specialNeeds => $composableBuilder(
    column: $table.specialNeeds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get specialNeedsNote => $composableBuilder(
    column: $table.specialNeedsNote,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get preAdmissionCompletedAt => $composableBuilder(
    column: $table.preAdmissionCompletedAt,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$StudentsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $StudentsTable,
          Student,
          $$StudentsTableFilterComposer,
          $$StudentsTableOrderingComposer,
          $$StudentsTableAnnotationComposer,
          $$StudentsTableCreateCompanionBuilder,
          $$StudentsTableUpdateCompanionBuilder,
          (Student, BaseReferences<_$SyncEduDatabase, $StudentsTable, Student>),
          Student,
          PrefetchHooks Function()
        > {
  $$StudentsTableTableManager(_$SyncEduDatabase db, $StudentsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$StudentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$StudentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$StudentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> profileId = const Value.absent(),
                Value<String?> classId = const Value.absent(),
                Value<String> specialNeeds = const Value.absent(),
                Value<String?> specialNeedsNote = const Value.absent(),
                Value<DateTime?> preAdmissionCompletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                profileId: profileId,
                classId: classId,
                specialNeeds: specialNeeds,
                specialNeedsNote: specialNeedsNote,
                preAdmissionCompletedAt: preAdmissionCompletedAt,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String profileId,
                Value<String?> classId = const Value.absent(),
                Value<String> specialNeeds = const Value.absent(),
                Value<String?> specialNeedsNote = const Value.absent(),
                Value<DateTime?> preAdmissionCompletedAt = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => StudentsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                profileId: profileId,
                classId: classId,
                specialNeeds: specialNeeds,
                specialNeedsNote: specialNeedsNote,
                preAdmissionCompletedAt: preAdmissionCompletedAt,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$StudentsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $StudentsTable,
      Student,
      $$StudentsTableFilterComposer,
      $$StudentsTableOrderingComposer,
      $$StudentsTableAnnotationComposer,
      $$StudentsTableCreateCompanionBuilder,
      $$StudentsTableUpdateCompanionBuilder,
      (Student, BaseReferences<_$SyncEduDatabase, $StudentsTable, Student>),
      Student,
      PrefetchHooks Function()
    >;
typedef $$SubjectsTableCreateCompanionBuilder =
    SubjectsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String name,
      Value<int> chapterCount,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$SubjectsTableUpdateCompanionBuilder =
    SubjectsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> name,
      Value<int> chapterCount,
      Value<int> version,
      Value<int> rowid,
    });

class $$SubjectsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $SubjectsTable> {
  $$SubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SubjectsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $SubjectsTable> {
  $$SubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SubjectsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $SubjectsTable> {
  $$SubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get chapterCount => $composableBuilder(
    column: $table.chapterCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$SubjectsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $SubjectsTable,
          Subject,
          $$SubjectsTableFilterComposer,
          $$SubjectsTableOrderingComposer,
          $$SubjectsTableAnnotationComposer,
          $$SubjectsTableCreateCompanionBuilder,
          $$SubjectsTableUpdateCompanionBuilder,
          (Subject, BaseReferences<_$SyncEduDatabase, $SubjectsTable, Subject>),
          Subject,
          PrefetchHooks Function()
        > {
  $$SubjectsTableTableManager(_$SyncEduDatabase db, $SubjectsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> chapterCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                name: name,
                chapterCount: chapterCount,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String name,
                Value<int> chapterCount = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SubjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                name: name,
                chapterCount: chapterCount,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $SubjectsTable,
      Subject,
      $$SubjectsTableFilterComposer,
      $$SubjectsTableOrderingComposer,
      $$SubjectsTableAnnotationComposer,
      $$SubjectsTableCreateCompanionBuilder,
      $$SubjectsTableUpdateCompanionBuilder,
      (Subject, BaseReferences<_$SyncEduDatabase, $SubjectsTable, Subject>),
      Subject,
      PrefetchHooks Function()
    >;
typedef $$ChaptersTableCreateCompanionBuilder =
    ChaptersCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String subjectId,
      required int ordinal,
      required String title,
      Value<DateTime?> microSkillsLockedAt,
      Value<int> rowid,
    });
typedef $$ChaptersTableUpdateCompanionBuilder =
    ChaptersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> subjectId,
      Value<int> ordinal,
      Value<String> title,
      Value<DateTime?> microSkillsLockedAt,
      Value<int> rowid,
    });

class $$ChaptersTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ChaptersTable> {
  $$ChaptersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get microSkillsLockedAt => $composableBuilder(
    column: $table.microSkillsLockedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ChaptersTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ChaptersTable> {
  $$ChaptersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get title => $composableBuilder(
    column: $table.title,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get microSkillsLockedAt => $composableBuilder(
    column: $table.microSkillsLockedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ChaptersTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ChaptersTable> {
  $$ChaptersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);

  GeneratedColumn<String> get title =>
      $composableBuilder(column: $table.title, builder: (column) => column);

  GeneratedColumn<DateTime> get microSkillsLockedAt => $composableBuilder(
    column: $table.microSkillsLockedAt,
    builder: (column) => column,
  );
}

class $$ChaptersTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ChaptersTable,
          Chapter,
          $$ChaptersTableFilterComposer,
          $$ChaptersTableOrderingComposer,
          $$ChaptersTableAnnotationComposer,
          $$ChaptersTableCreateCompanionBuilder,
          $$ChaptersTableUpdateCompanionBuilder,
          (Chapter, BaseReferences<_$SyncEduDatabase, $ChaptersTable, Chapter>),
          Chapter,
          PrefetchHooks Function()
        > {
  $$ChaptersTableTableManager(_$SyncEduDatabase db, $ChaptersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ChaptersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ChaptersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ChaptersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<String> title = const Value.absent(),
                Value<DateTime?> microSkillsLockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                subjectId: subjectId,
                ordinal: ordinal,
                title: title,
                microSkillsLockedAt: microSkillsLockedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String subjectId,
                required int ordinal,
                required String title,
                Value<DateTime?> microSkillsLockedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ChaptersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                subjectId: subjectId,
                ordinal: ordinal,
                title: title,
                microSkillsLockedAt: microSkillsLockedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ChaptersTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ChaptersTable,
      Chapter,
      $$ChaptersTableFilterComposer,
      $$ChaptersTableOrderingComposer,
      $$ChaptersTableAnnotationComposer,
      $$ChaptersTableCreateCompanionBuilder,
      $$ChaptersTableUpdateCompanionBuilder,
      (Chapter, BaseReferences<_$SyncEduDatabase, $ChaptersTable, Chapter>),
      Chapter,
      PrefetchHooks Function()
    >;
typedef $$ClassesTableCreateCompanionBuilder =
    ClassesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String name,
      required int yearLevel,
      Value<String?> targetLearningStyle,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ClassesTableUpdateCompanionBuilder =
    ClassesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> name,
      Value<int> yearLevel,
      Value<String?> targetLearningStyle,
      Value<int> version,
      Value<int> rowid,
    });

class $$ClassesTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ClassesTable> {
  $$ClassesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get yearLevel => $composableBuilder(
    column: $table.yearLevel,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get targetLearningStyle => $composableBuilder(
    column: $table.targetLearningStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassesTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ClassesTable> {
  $$ClassesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get name => $composableBuilder(
    column: $table.name,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get yearLevel => $composableBuilder(
    column: $table.yearLevel,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get targetLearningStyle => $composableBuilder(
    column: $table.targetLearningStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassesTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ClassesTable> {
  $$ClassesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get name =>
      $composableBuilder(column: $table.name, builder: (column) => column);

  GeneratedColumn<int> get yearLevel =>
      $composableBuilder(column: $table.yearLevel, builder: (column) => column);

  GeneratedColumn<String> get targetLearningStyle => $composableBuilder(
    column: $table.targetLearningStyle,
    builder: (column) => column,
  );

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$ClassesTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ClassesTable,
          ClassesData,
          $$ClassesTableFilterComposer,
          $$ClassesTableOrderingComposer,
          $$ClassesTableAnnotationComposer,
          $$ClassesTableCreateCompanionBuilder,
          $$ClassesTableUpdateCompanionBuilder,
          (
            ClassesData,
            BaseReferences<_$SyncEduDatabase, $ClassesTable, ClassesData>,
          ),
          ClassesData,
          PrefetchHooks Function()
        > {
  $$ClassesTableTableManager(_$SyncEduDatabase db, $ClassesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> name = const Value.absent(),
                Value<int> yearLevel = const Value.absent(),
                Value<String?> targetLearningStyle = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                name: name,
                yearLevel: yearLevel,
                targetLearningStyle: targetLearningStyle,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String name,
                required int yearLevel,
                Value<String?> targetLearningStyle = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                name: name,
                yearLevel: yearLevel,
                targetLearningStyle: targetLearningStyle,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassesTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ClassesTable,
      ClassesData,
      $$ClassesTableFilterComposer,
      $$ClassesTableOrderingComposer,
      $$ClassesTableAnnotationComposer,
      $$ClassesTableCreateCompanionBuilder,
      $$ClassesTableUpdateCompanionBuilder,
      (
        ClassesData,
        BaseReferences<_$SyncEduDatabase, $ClassesTable, ClassesData>,
      ),
      ClassesData,
      PrefetchHooks Function()
    >;
typedef $$ClassSubjectsTableCreateCompanionBuilder =
    ClassSubjectsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String classId,
      required String subjectId,
      required String teacherId,
      Value<int> rowid,
    });
typedef $$ClassSubjectsTableUpdateCompanionBuilder =
    ClassSubjectsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> classId,
      Value<String> subjectId,
      Value<String> teacherId,
      Value<int> rowid,
    });

class $$ClassSubjectsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ClassSubjectsTable> {
  $$ClassSubjectsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassSubjectsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ClassSubjectsTable> {
  $$ClassSubjectsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get subjectId => $composableBuilder(
    column: $table.subjectId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassSubjectsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ClassSubjectsTable> {
  $$ClassSubjectsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get subjectId =>
      $composableBuilder(column: $table.subjectId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);
}

class $$ClassSubjectsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ClassSubjectsTable,
          ClassSubject,
          $$ClassSubjectsTableFilterComposer,
          $$ClassSubjectsTableOrderingComposer,
          $$ClassSubjectsTableAnnotationComposer,
          $$ClassSubjectsTableCreateCompanionBuilder,
          $$ClassSubjectsTableUpdateCompanionBuilder,
          (
            ClassSubject,
            BaseReferences<
              _$SyncEduDatabase,
              $ClassSubjectsTable,
              ClassSubject
            >,
          ),
          ClassSubject,
          PrefetchHooks Function()
        > {
  $$ClassSubjectsTableTableManager(
    _$SyncEduDatabase db,
    $ClassSubjectsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassSubjectsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassSubjectsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassSubjectsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> subjectId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassSubjectsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                classId: classId,
                subjectId: subjectId,
                teacherId: teacherId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String classId,
                required String subjectId,
                required String teacherId,
                Value<int> rowid = const Value.absent(),
              }) => ClassSubjectsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                classId: classId,
                subjectId: subjectId,
                teacherId: teacherId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassSubjectsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ClassSubjectsTable,
      ClassSubject,
      $$ClassSubjectsTableFilterComposer,
      $$ClassSubjectsTableOrderingComposer,
      $$ClassSubjectsTableAnnotationComposer,
      $$ClassSubjectsTableCreateCompanionBuilder,
      $$ClassSubjectsTableUpdateCompanionBuilder,
      (
        ClassSubject,
        BaseReferences<_$SyncEduDatabase, $ClassSubjectsTable, ClassSubject>,
      ),
      ClassSubject,
      PrefetchHooks Function()
    >;
typedef $$ClassChapterSchedTableCreateCompanionBuilder =
    ClassChapterSchedCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String classId,
      required String chapterId,
      Value<DateTime?> taughtOn,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$ClassChapterSchedTableUpdateCompanionBuilder =
    ClassChapterSchedCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> classId,
      Value<String> chapterId,
      Value<DateTime?> taughtOn,
      Value<int> version,
      Value<int> rowid,
    });

class $$ClassChapterSchedTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ClassChapterSchedTable> {
  $$ClassChapterSchedTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get taughtOn => $composableBuilder(
    column: $table.taughtOn,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ClassChapterSchedTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ClassChapterSchedTable> {
  $$ClassChapterSchedTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get taughtOn => $composableBuilder(
    column: $table.taughtOn,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ClassChapterSchedTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ClassChapterSchedTable> {
  $$ClassChapterSchedTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<DateTime> get taughtOn =>
      $composableBuilder(column: $table.taughtOn, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$ClassChapterSchedTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ClassChapterSchedTable,
          ClassChapterSchedData,
          $$ClassChapterSchedTableFilterComposer,
          $$ClassChapterSchedTableOrderingComposer,
          $$ClassChapterSchedTableAnnotationComposer,
          $$ClassChapterSchedTableCreateCompanionBuilder,
          $$ClassChapterSchedTableUpdateCompanionBuilder,
          (
            ClassChapterSchedData,
            BaseReferences<
              _$SyncEduDatabase,
              $ClassChapterSchedTable,
              ClassChapterSchedData
            >,
          ),
          ClassChapterSchedData,
          PrefetchHooks Function()
        > {
  $$ClassChapterSchedTableTableManager(
    _$SyncEduDatabase db,
    $ClassChapterSchedTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ClassChapterSchedTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ClassChapterSchedTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ClassChapterSchedTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<DateTime?> taughtOn = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassChapterSchedCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                classId: classId,
                chapterId: chapterId,
                taughtOn: taughtOn,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String classId,
                required String chapterId,
                Value<DateTime?> taughtOn = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ClassChapterSchedCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                classId: classId,
                chapterId: chapterId,
                taughtOn: taughtOn,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ClassChapterSchedTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ClassChapterSchedTable,
      ClassChapterSchedData,
      $$ClassChapterSchedTableFilterComposer,
      $$ClassChapterSchedTableOrderingComposer,
      $$ClassChapterSchedTableAnnotationComposer,
      $$ClassChapterSchedTableCreateCompanionBuilder,
      $$ClassChapterSchedTableUpdateCompanionBuilder,
      (
        ClassChapterSchedData,
        BaseReferences<
          _$SyncEduDatabase,
          $ClassChapterSchedTable,
          ClassChapterSchedData
        >,
      ),
      ClassChapterSchedData,
      PrefetchHooks Function()
    >;
typedef $$MicroSkillsTableCreateCompanionBuilder =
    MicroSkillsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String chapterId,
      required String slug,
      required String label,
      Value<String?> description,
      required int ordinal,
      Value<int> rowid,
    });
typedef $$MicroSkillsTableUpdateCompanionBuilder =
    MicroSkillsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> chapterId,
      Value<String> slug,
      Value<String> label,
      Value<String?> description,
      Value<int> ordinal,
      Value<int> rowid,
    });

class $$MicroSkillsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillsTable> {
  $$MicroSkillsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MicroSkillsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillsTable> {
  $$MicroSkillsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get slug => $composableBuilder(
    column: $table.slug,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get label => $composableBuilder(
    column: $table.label,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MicroSkillsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillsTable> {
  $$MicroSkillsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get slug =>
      $composableBuilder(column: $table.slug, builder: (column) => column);

  GeneratedColumn<String> get label =>
      $composableBuilder(column: $table.label, builder: (column) => column);

  GeneratedColumn<String> get description => $composableBuilder(
    column: $table.description,
    builder: (column) => column,
  );

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);
}

class $$MicroSkillsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $MicroSkillsTable,
          MicroSkill,
          $$MicroSkillsTableFilterComposer,
          $$MicroSkillsTableOrderingComposer,
          $$MicroSkillsTableAnnotationComposer,
          $$MicroSkillsTableCreateCompanionBuilder,
          $$MicroSkillsTableUpdateCompanionBuilder,
          (
            MicroSkill,
            BaseReferences<_$SyncEduDatabase, $MicroSkillsTable, MicroSkill>,
          ),
          MicroSkill,
          PrefetchHooks Function()
        > {
  $$MicroSkillsTableTableManager(_$SyncEduDatabase db, $MicroSkillsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MicroSkillsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MicroSkillsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MicroSkillsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> slug = const Value.absent(),
                Value<String> label = const Value.absent(),
                Value<String?> description = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MicroSkillsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                slug: slug,
                label: label,
                description: description,
                ordinal: ordinal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String chapterId,
                required String slug,
                required String label,
                Value<String?> description = const Value.absent(),
                required int ordinal,
                Value<int> rowid = const Value.absent(),
              }) => MicroSkillsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                slug: slug,
                label: label,
                description: description,
                ordinal: ordinal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MicroSkillsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $MicroSkillsTable,
      MicroSkill,
      $$MicroSkillsTableFilterComposer,
      $$MicroSkillsTableOrderingComposer,
      $$MicroSkillsTableAnnotationComposer,
      $$MicroSkillsTableCreateCompanionBuilder,
      $$MicroSkillsTableUpdateCompanionBuilder,
      (
        MicroSkill,
        BaseReferences<_$SyncEduDatabase, $MicroSkillsTable, MicroSkill>,
      ),
      MicroSkill,
      PrefetchHooks Function()
    >;
typedef $$MicroSkillExplanationsTableCreateCompanionBuilder =
    MicroSkillExplanationsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String microSkillId,
      required String body,
      Value<int> rowid,
    });
typedef $$MicroSkillExplanationsTableUpdateCompanionBuilder =
    MicroSkillExplanationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> microSkillId,
      Value<String> body,
      Value<int> rowid,
    });

class $$MicroSkillExplanationsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillExplanationsTable> {
  $$MicroSkillExplanationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MicroSkillExplanationsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillExplanationsTable> {
  $$MicroSkillExplanationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MicroSkillExplanationsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $MicroSkillExplanationsTable> {
  $$MicroSkillExplanationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$MicroSkillExplanationsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $MicroSkillExplanationsTable,
          MicroSkillExplanation,
          $$MicroSkillExplanationsTableFilterComposer,
          $$MicroSkillExplanationsTableOrderingComposer,
          $$MicroSkillExplanationsTableAnnotationComposer,
          $$MicroSkillExplanationsTableCreateCompanionBuilder,
          $$MicroSkillExplanationsTableUpdateCompanionBuilder,
          (
            MicroSkillExplanation,
            BaseReferences<
              _$SyncEduDatabase,
              $MicroSkillExplanationsTable,
              MicroSkillExplanation
            >,
          ),
          MicroSkillExplanation,
          PrefetchHooks Function()
        > {
  $$MicroSkillExplanationsTableTableManager(
    _$SyncEduDatabase db,
    $MicroSkillExplanationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MicroSkillExplanationsTableFilterComposer(
                $db: db,
                $table: table,
              ),
          createOrderingComposer: () =>
              $$MicroSkillExplanationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$MicroSkillExplanationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> microSkillId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MicroSkillExplanationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                microSkillId: microSkillId,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String microSkillId,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => MicroSkillExplanationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                microSkillId: microSkillId,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MicroSkillExplanationsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $MicroSkillExplanationsTable,
      MicroSkillExplanation,
      $$MicroSkillExplanationsTableFilterComposer,
      $$MicroSkillExplanationsTableOrderingComposer,
      $$MicroSkillExplanationsTableAnnotationComposer,
      $$MicroSkillExplanationsTableCreateCompanionBuilder,
      $$MicroSkillExplanationsTableUpdateCompanionBuilder,
      (
        MicroSkillExplanation,
        BaseReferences<
          _$SyncEduDatabase,
          $MicroSkillExplanationsTable,
          MicroSkillExplanation
        >,
      ),
      MicroSkillExplanation,
      PrefetchHooks Function()
    >;
typedef $$QuestionsTableCreateCompanionBuilder =
    QuestionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String chapterId,
      required String microSkillId,
      required int difficulty,
      required String stem,
      required String options,
      required int correctIndex,
      Value<String?> rationale,
      Value<String> provenance,
      Value<String?> forStudentId,
      Value<String?> materialId,
      Value<int> rowid,
    });
typedef $$QuestionsTableUpdateCompanionBuilder =
    QuestionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> chapterId,
      Value<String> microSkillId,
      Value<int> difficulty,
      Value<String> stem,
      Value<String> options,
      Value<int> correctIndex,
      Value<String?> rationale,
      Value<String> provenance,
      Value<String?> forStudentId,
      Value<String?> materialId,
      Value<int> rowid,
    });

class $$QuestionsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $QuestionsTable> {
  $$QuestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get forStudentId => $composableBuilder(
    column: $table.forStudentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnFilters(column),
  );
}

class $$QuestionsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $QuestionsTable> {
  $$QuestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get stem => $composableBuilder(
    column: $table.stem,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get options => $composableBuilder(
    column: $table.options,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get forStudentId => $composableBuilder(
    column: $table.forStudentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$QuestionsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $QuestionsTable> {
  $$QuestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get difficulty => $composableBuilder(
    column: $table.difficulty,
    builder: (column) => column,
  );

  GeneratedColumn<String> get stem =>
      $composableBuilder(column: $table.stem, builder: (column) => column);

  GeneratedColumn<String> get options =>
      $composableBuilder(column: $table.options, builder: (column) => column);

  GeneratedColumn<int> get correctIndex => $composableBuilder(
    column: $table.correctIndex,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rationale =>
      $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<String> get provenance => $composableBuilder(
    column: $table.provenance,
    builder: (column) => column,
  );

  GeneratedColumn<String> get forStudentId => $composableBuilder(
    column: $table.forStudentId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get materialId => $composableBuilder(
    column: $table.materialId,
    builder: (column) => column,
  );
}

class $$QuestionsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $QuestionsTable,
          Question,
          $$QuestionsTableFilterComposer,
          $$QuestionsTableOrderingComposer,
          $$QuestionsTableAnnotationComposer,
          $$QuestionsTableCreateCompanionBuilder,
          $$QuestionsTableUpdateCompanionBuilder,
          (
            Question,
            BaseReferences<_$SyncEduDatabase, $QuestionsTable, Question>,
          ),
          Question,
          PrefetchHooks Function()
        > {
  $$QuestionsTableTableManager(_$SyncEduDatabase db, $QuestionsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$QuestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$QuestionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$QuestionsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> microSkillId = const Value.absent(),
                Value<int> difficulty = const Value.absent(),
                Value<String> stem = const Value.absent(),
                Value<String> options = const Value.absent(),
                Value<int> correctIndex = const Value.absent(),
                Value<String?> rationale = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String?> forStudentId = const Value.absent(),
                Value<String?> materialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                microSkillId: microSkillId,
                difficulty: difficulty,
                stem: stem,
                options: options,
                correctIndex: correctIndex,
                rationale: rationale,
                provenance: provenance,
                forStudentId: forStudentId,
                materialId: materialId,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String chapterId,
                required String microSkillId,
                required int difficulty,
                required String stem,
                required String options,
                required int correctIndex,
                Value<String?> rationale = const Value.absent(),
                Value<String> provenance = const Value.absent(),
                Value<String?> forStudentId = const Value.absent(),
                Value<String?> materialId = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => QuestionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                microSkillId: microSkillId,
                difficulty: difficulty,
                stem: stem,
                options: options,
                correctIndex: correctIndex,
                rationale: rationale,
                provenance: provenance,
                forStudentId: forStudentId,
                materialId: materialId,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$QuestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $QuestionsTable,
      Question,
      $$QuestionsTableFilterComposer,
      $$QuestionsTableOrderingComposer,
      $$QuestionsTableAnnotationComposer,
      $$QuestionsTableCreateCompanionBuilder,
      $$QuestionsTableUpdateCompanionBuilder,
      (Question, BaseReferences<_$SyncEduDatabase, $QuestionsTable, Question>),
      Question,
      PrefetchHooks Function()
    >;
typedef $$AttemptsTableCreateCompanionBuilder =
    AttemptsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      Value<String> chapterIds,
      required String mode,
      Value<int> attemptNumber,
      Value<String?> parentAttemptId,
      required int questionCount,
      Value<int> score,
      Value<DateTime?> startedAt,
      Value<DateTime?> submittedAt,
      Value<int> rowid,
    });
typedef $$AttemptsTableUpdateCompanionBuilder =
    AttemptsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> chapterIds,
      Value<String> mode,
      Value<int> attemptNumber,
      Value<String?> parentAttemptId,
      Value<int> questionCount,
      Value<int> score,
      Value<DateTime?> startedAt,
      Value<DateTime?> submittedAt,
      Value<int> rowid,
    });

class $$AttemptsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $AttemptsTable> {
  $$AttemptsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterIds => $composableBuilder(
    column: $table.chapterIds,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get parentAttemptId => $composableBuilder(
    column: $table.parentAttemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $AttemptsTable> {
  $$AttemptsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterIds => $composableBuilder(
    column: $table.chapterIds,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mode => $composableBuilder(
    column: $table.mode,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get parentAttemptId => $composableBuilder(
    column: $table.parentAttemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get score => $composableBuilder(
    column: $table.score,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get startedAt => $composableBuilder(
    column: $table.startedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $AttemptsTable> {
  $$AttemptsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get chapterIds => $composableBuilder(
    column: $table.chapterIds,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mode =>
      $composableBuilder(column: $table.mode, builder: (column) => column);

  GeneratedColumn<int> get attemptNumber => $composableBuilder(
    column: $table.attemptNumber,
    builder: (column) => column,
  );

  GeneratedColumn<String> get parentAttemptId => $composableBuilder(
    column: $table.parentAttemptId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get questionCount => $composableBuilder(
    column: $table.questionCount,
    builder: (column) => column,
  );

  GeneratedColumn<int> get score =>
      $composableBuilder(column: $table.score, builder: (column) => column);

  GeneratedColumn<DateTime> get startedAt =>
      $composableBuilder(column: $table.startedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get submittedAt => $composableBuilder(
    column: $table.submittedAt,
    builder: (column) => column,
  );
}

class $$AttemptsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $AttemptsTable,
          Attempt,
          $$AttemptsTableFilterComposer,
          $$AttemptsTableOrderingComposer,
          $$AttemptsTableAnnotationComposer,
          $$AttemptsTableCreateCompanionBuilder,
          $$AttemptsTableUpdateCompanionBuilder,
          (Attempt, BaseReferences<_$SyncEduDatabase, $AttemptsTable, Attempt>),
          Attempt,
          PrefetchHooks Function()
        > {
  $$AttemptsTableTableManager(_$SyncEduDatabase db, $AttemptsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> chapterIds = const Value.absent(),
                Value<String> mode = const Value.absent(),
                Value<int> attemptNumber = const Value.absent(),
                Value<String?> parentAttemptId = const Value.absent(),
                Value<int> questionCount = const Value.absent(),
                Value<int> score = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                chapterIds: chapterIds,
                mode: mode,
                attemptNumber: attemptNumber,
                parentAttemptId: parentAttemptId,
                questionCount: questionCount,
                score: score,
                startedAt: startedAt,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                Value<String> chapterIds = const Value.absent(),
                required String mode,
                Value<int> attemptNumber = const Value.absent(),
                Value<String?> parentAttemptId = const Value.absent(),
                required int questionCount,
                Value<int> score = const Value.absent(),
                Value<DateTime?> startedAt = const Value.absent(),
                Value<DateTime?> submittedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                chapterIds: chapterIds,
                mode: mode,
                attemptNumber: attemptNumber,
                parentAttemptId: parentAttemptId,
                questionCount: questionCount,
                score: score,
                startedAt: startedAt,
                submittedAt: submittedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttemptsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $AttemptsTable,
      Attempt,
      $$AttemptsTableFilterComposer,
      $$AttemptsTableOrderingComposer,
      $$AttemptsTableAnnotationComposer,
      $$AttemptsTableCreateCompanionBuilder,
      $$AttemptsTableUpdateCompanionBuilder,
      (Attempt, BaseReferences<_$SyncEduDatabase, $AttemptsTable, Attempt>),
      Attempt,
      PrefetchHooks Function()
    >;
typedef $$AttemptItemsTableCreateCompanionBuilder =
    AttemptItemsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String attemptId,
      Value<String?> questionId,
      required String microSkillId,
      Value<int?> selectedIndex,
      required bool isCorrect,
      required int ordinal,
      Value<int> rowid,
    });
typedef $$AttemptItemsTableUpdateCompanionBuilder =
    AttemptItemsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> attemptId,
      Value<String?> questionId,
      Value<String> microSkillId,
      Value<int?> selectedIndex,
      Value<bool> isCorrect,
      Value<int> ordinal,
      Value<int> rowid,
    });

class $$AttemptItemsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $AttemptItemsTable> {
  $$AttemptItemsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnFilters(column),
  );
}

class $$AttemptItemsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $AttemptItemsTable> {
  $$AttemptItemsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptId => $composableBuilder(
    column: $table.attemptId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<bool> get isCorrect => $composableBuilder(
    column: $table.isCorrect,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get ordinal => $composableBuilder(
    column: $table.ordinal,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$AttemptItemsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $AttemptItemsTable> {
  $$AttemptItemsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get attemptId =>
      $composableBuilder(column: $table.attemptId, builder: (column) => column);

  GeneratedColumn<String> get questionId => $composableBuilder(
    column: $table.questionId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => column,
  );

  GeneratedColumn<int> get selectedIndex => $composableBuilder(
    column: $table.selectedIndex,
    builder: (column) => column,
  );

  GeneratedColumn<bool> get isCorrect =>
      $composableBuilder(column: $table.isCorrect, builder: (column) => column);

  GeneratedColumn<int> get ordinal =>
      $composableBuilder(column: $table.ordinal, builder: (column) => column);
}

class $$AttemptItemsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $AttemptItemsTable,
          AttemptItem,
          $$AttemptItemsTableFilterComposer,
          $$AttemptItemsTableOrderingComposer,
          $$AttemptItemsTableAnnotationComposer,
          $$AttemptItemsTableCreateCompanionBuilder,
          $$AttemptItemsTableUpdateCompanionBuilder,
          (
            AttemptItem,
            BaseReferences<_$SyncEduDatabase, $AttemptItemsTable, AttemptItem>,
          ),
          AttemptItem,
          PrefetchHooks Function()
        > {
  $$AttemptItemsTableTableManager(
    _$SyncEduDatabase db,
    $AttemptItemsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$AttemptItemsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$AttemptItemsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$AttemptItemsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> attemptId = const Value.absent(),
                Value<String?> questionId = const Value.absent(),
                Value<String> microSkillId = const Value.absent(),
                Value<int?> selectedIndex = const Value.absent(),
                Value<bool> isCorrect = const Value.absent(),
                Value<int> ordinal = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => AttemptItemsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                attemptId: attemptId,
                questionId: questionId,
                microSkillId: microSkillId,
                selectedIndex: selectedIndex,
                isCorrect: isCorrect,
                ordinal: ordinal,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String attemptId,
                Value<String?> questionId = const Value.absent(),
                required String microSkillId,
                Value<int?> selectedIndex = const Value.absent(),
                required bool isCorrect,
                required int ordinal,
                Value<int> rowid = const Value.absent(),
              }) => AttemptItemsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                attemptId: attemptId,
                questionId: questionId,
                microSkillId: microSkillId,
                selectedIndex: selectedIndex,
                isCorrect: isCorrect,
                ordinal: ordinal,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$AttemptItemsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $AttemptItemsTable,
      AttemptItem,
      $$AttemptItemsTableFilterComposer,
      $$AttemptItemsTableOrderingComposer,
      $$AttemptItemsTableAnnotationComposer,
      $$AttemptItemsTableCreateCompanionBuilder,
      $$AttemptItemsTableUpdateCompanionBuilder,
      (
        AttemptItem,
        BaseReferences<_$SyncEduDatabase, $AttemptItemsTable, AttemptItem>,
      ),
      AttemptItem,
      PrefetchHooks Function()
    >;
typedef $$WeaknessesTableCreateCompanionBuilder =
    WeaknessesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      required String microSkillId,
      required double weight,
      required String source,
      Value<int> rowid,
    });
typedef $$WeaknessesTableUpdateCompanionBuilder =
    WeaknessesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> microSkillId,
      Value<double> weight,
      Value<String> source,
      Value<int> rowid,
    });

class $$WeaknessesTableFilterComposer
    extends Composer<_$SyncEduDatabase, $WeaknessesTable> {
  $$WeaknessesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$WeaknessesTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $WeaknessesTable> {
  $$WeaknessesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get weight => $composableBuilder(
    column: $table.weight,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$WeaknessesTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $WeaknessesTable> {
  $$WeaknessesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get microSkillId => $composableBuilder(
    column: $table.microSkillId,
    builder: (column) => column,
  );

  GeneratedColumn<double> get weight =>
      $composableBuilder(column: $table.weight, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$WeaknessesTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $WeaknessesTable,
          WeaknessesData,
          $$WeaknessesTableFilterComposer,
          $$WeaknessesTableOrderingComposer,
          $$WeaknessesTableAnnotationComposer,
          $$WeaknessesTableCreateCompanionBuilder,
          $$WeaknessesTableUpdateCompanionBuilder,
          (
            WeaknessesData,
            BaseReferences<_$SyncEduDatabase, $WeaknessesTable, WeaknessesData>,
          ),
          WeaknessesData,
          PrefetchHooks Function()
        > {
  $$WeaknessesTableTableManager(_$SyncEduDatabase db, $WeaknessesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$WeaknessesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$WeaknessesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$WeaknessesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> microSkillId = const Value.absent(),
                Value<double> weight = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => WeaknessesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                microSkillId: microSkillId,
                weight: weight,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                required String microSkillId,
                required double weight,
                required String source,
                Value<int> rowid = const Value.absent(),
              }) => WeaknessesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                microSkillId: microSkillId,
                weight: weight,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$WeaknessesTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $WeaknessesTable,
      WeaknessesData,
      $$WeaknessesTableFilterComposer,
      $$WeaknessesTableOrderingComposer,
      $$WeaknessesTableAnnotationComposer,
      $$WeaknessesTableCreateCompanionBuilder,
      $$WeaknessesTableUpdateCompanionBuilder,
      (
        WeaknessesData,
        BaseReferences<_$SyncEduDatabase, $WeaknessesTable, WeaknessesData>,
      ),
      WeaknessesData,
      PrefetchHooks Function()
    >;
typedef $$MaterialsTableCreateCompanionBuilder =
    MaterialsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String chapterId,
      Value<String?> storagePath,
      required String mime,
      Value<String> ingestionStatus,
      Value<int> rowid,
    });
typedef $$MaterialsTableUpdateCompanionBuilder =
    MaterialsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> chapterId,
      Value<String?> storagePath,
      Value<String> mime,
      Value<String> ingestionStatus,
      Value<int> rowid,
    });

class $$MaterialsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $MaterialsTable> {
  $$MaterialsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get ingestionStatus => $composableBuilder(
    column: $table.ingestionStatus,
    builder: (column) => ColumnFilters(column),
  );
}

class $$MaterialsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $MaterialsTable> {
  $$MaterialsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get mime => $composableBuilder(
    column: $table.mime,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get ingestionStatus => $composableBuilder(
    column: $table.ingestionStatus,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$MaterialsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $MaterialsTable> {
  $$MaterialsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get mime =>
      $composableBuilder(column: $table.mime, builder: (column) => column);

  GeneratedColumn<String> get ingestionStatus => $composableBuilder(
    column: $table.ingestionStatus,
    builder: (column) => column,
  );
}

class $$MaterialsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $MaterialsTable,
          Material,
          $$MaterialsTableFilterComposer,
          $$MaterialsTableOrderingComposer,
          $$MaterialsTableAnnotationComposer,
          $$MaterialsTableCreateCompanionBuilder,
          $$MaterialsTableUpdateCompanionBuilder,
          (
            Material,
            BaseReferences<_$SyncEduDatabase, $MaterialsTable, Material>,
          ),
          Material,
          PrefetchHooks Function()
        > {
  $$MaterialsTableTableManager(_$SyncEduDatabase db, $MaterialsTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$MaterialsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$MaterialsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$MaterialsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String?> storagePath = const Value.absent(),
                Value<String> mime = const Value.absent(),
                Value<String> ingestionStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                storagePath: storagePath,
                mime: mime,
                ingestionStatus: ingestionStatus,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String chapterId,
                Value<String?> storagePath = const Value.absent(),
                required String mime,
                Value<String> ingestionStatus = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => MaterialsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                storagePath: storagePath,
                mime: mime,
                ingestionStatus: ingestionStatus,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$MaterialsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $MaterialsTable,
      Material,
      $$MaterialsTableFilterComposer,
      $$MaterialsTableOrderingComposer,
      $$MaterialsTableAnnotationComposer,
      $$MaterialsTableCreateCompanionBuilder,
      $$MaterialsTableUpdateCompanionBuilder,
      (Material, BaseReferences<_$SyncEduDatabase, $MaterialsTable, Material>),
      Material,
      PrefetchHooks Function()
    >;
typedef $$TeacherObservationsTableCreateCompanionBuilder =
    TeacherObservationsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      required String teacherId,
      required String body,
      Value<int> rowid,
    });
typedef $$TeacherObservationsTableUpdateCompanionBuilder =
    TeacherObservationsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> teacherId,
      Value<String> body,
      Value<int> rowid,
    });

class $$TeacherObservationsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $TeacherObservationsTable> {
  $$TeacherObservationsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeacherObservationsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $TeacherObservationsTable> {
  $$TeacherObservationsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get body => $composableBuilder(
    column: $table.body,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeacherObservationsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $TeacherObservationsTable> {
  $$TeacherObservationsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get body =>
      $composableBuilder(column: $table.body, builder: (column) => column);
}

class $$TeacherObservationsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $TeacherObservationsTable,
          TeacherObservation,
          $$TeacherObservationsTableFilterComposer,
          $$TeacherObservationsTableOrderingComposer,
          $$TeacherObservationsTableAnnotationComposer,
          $$TeacherObservationsTableCreateCompanionBuilder,
          $$TeacherObservationsTableUpdateCompanionBuilder,
          (
            TeacherObservation,
            BaseReferences<
              _$SyncEduDatabase,
              $TeacherObservationsTable,
              TeacherObservation
            >,
          ),
          TeacherObservation,
          PrefetchHooks Function()
        > {
  $$TeacherObservationsTableTableManager(
    _$SyncEduDatabase db,
    $TeacherObservationsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeacherObservationsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeacherObservationsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$TeacherObservationsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> body = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeacherObservationsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                teacherId: teacherId,
                body: body,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                required String teacherId,
                required String body,
                Value<int> rowid = const Value.absent(),
              }) => TeacherObservationsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                teacherId: teacherId,
                body: body,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeacherObservationsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $TeacherObservationsTable,
      TeacherObservation,
      $$TeacherObservationsTableFilterComposer,
      $$TeacherObservationsTableOrderingComposer,
      $$TeacherObservationsTableAnnotationComposer,
      $$TeacherObservationsTableCreateCompanionBuilder,
      $$TeacherObservationsTableUpdateCompanionBuilder,
      (
        TeacherObservation,
        BaseReferences<
          _$SyncEduDatabase,
          $TeacherObservationsTable,
          TeacherObservation
        >,
      ),
      TeacherObservation,
      PrefetchHooks Function()
    >;
typedef $$GeneratedContentTableCreateCompanionBuilder =
    GeneratedContentCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String chapterId,
      Value<String?> studentId,
      required String kind,
      Value<String> payload,
      Value<int> rowid,
    });
typedef $$GeneratedContentTableUpdateCompanionBuilder =
    GeneratedContentCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> chapterId,
      Value<String?> studentId,
      Value<String> kind,
      Value<String> payload,
      Value<int> rowid,
    });

class $$GeneratedContentTableFilterComposer
    extends Composer<_$SyncEduDatabase, $GeneratedContentTable> {
  $$GeneratedContentTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );
}

class $$GeneratedContentTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $GeneratedContentTable> {
  $$GeneratedContentTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get kind => $composableBuilder(
    column: $table.kind,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$GeneratedContentTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $GeneratedContentTable> {
  $$GeneratedContentTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get kind =>
      $composableBuilder(column: $table.kind, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);
}

class $$GeneratedContentTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $GeneratedContentTable,
          GeneratedContentData,
          $$GeneratedContentTableFilterComposer,
          $$GeneratedContentTableOrderingComposer,
          $$GeneratedContentTableAnnotationComposer,
          $$GeneratedContentTableCreateCompanionBuilder,
          $$GeneratedContentTableUpdateCompanionBuilder,
          (
            GeneratedContentData,
            BaseReferences<
              _$SyncEduDatabase,
              $GeneratedContentTable,
              GeneratedContentData
            >,
          ),
          GeneratedContentData,
          PrefetchHooks Function()
        > {
  $$GeneratedContentTableTableManager(
    _$SyncEduDatabase db,
    $GeneratedContentTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$GeneratedContentTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$GeneratedContentTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$GeneratedContentTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String?> studentId = const Value.absent(),
                Value<String> kind = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeneratedContentCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                studentId: studentId,
                kind: kind,
                payload: payload,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String chapterId,
                Value<String?> studentId = const Value.absent(),
                required String kind,
                Value<String> payload = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => GeneratedContentCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                chapterId: chapterId,
                studentId: studentId,
                kind: kind,
                payload: payload,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$GeneratedContentTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $GeneratedContentTable,
      GeneratedContentData,
      $$GeneratedContentTableFilterComposer,
      $$GeneratedContentTableOrderingComposer,
      $$GeneratedContentTableAnnotationComposer,
      $$GeneratedContentTableCreateCompanionBuilder,
      $$GeneratedContentTableUpdateCompanionBuilder,
      (
        GeneratedContentData,
        BaseReferences<
          _$SyncEduDatabase,
          $GeneratedContentTable,
          GeneratedContentData
        >,
      ),
      GeneratedContentData,
      PrefetchHooks Function()
    >;
typedef $$PreAdmissionResultsTableCreateCompanionBuilder =
    PreAdmissionResultsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      Value<String> vark,
      Value<int> structured,
      Value<int> exploratory,
      Value<int> introvert,
      Value<int> extrovert,
      Value<int> impulsivity,
      Value<int> reflectivity,
      required String dominantStyle,
      Value<String> answers,
      Value<int> rowid,
    });
typedef $$PreAdmissionResultsTableUpdateCompanionBuilder =
    PreAdmissionResultsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> vark,
      Value<int> structured,
      Value<int> exploratory,
      Value<int> introvert,
      Value<int> extrovert,
      Value<int> impulsivity,
      Value<int> reflectivity,
      Value<String> dominantStyle,
      Value<String> answers,
      Value<int> rowid,
    });

class $$PreAdmissionResultsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $PreAdmissionResultsTable> {
  $$PreAdmissionResultsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get vark => $composableBuilder(
    column: $table.vark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get structured => $composableBuilder(
    column: $table.structured,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get exploratory => $composableBuilder(
    column: $table.exploratory,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get introvert => $composableBuilder(
    column: $table.introvert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get extrovert => $composableBuilder(
    column: $table.extrovert,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get impulsivity => $composableBuilder(
    column: $table.impulsivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get reflectivity => $composableBuilder(
    column: $table.reflectivity,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get dominantStyle => $composableBuilder(
    column: $table.dominantStyle,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PreAdmissionResultsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $PreAdmissionResultsTable> {
  $$PreAdmissionResultsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get vark => $composableBuilder(
    column: $table.vark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get structured => $composableBuilder(
    column: $table.structured,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get exploratory => $composableBuilder(
    column: $table.exploratory,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get introvert => $composableBuilder(
    column: $table.introvert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get extrovert => $composableBuilder(
    column: $table.extrovert,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get impulsivity => $composableBuilder(
    column: $table.impulsivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get reflectivity => $composableBuilder(
    column: $table.reflectivity,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get dominantStyle => $composableBuilder(
    column: $table.dominantStyle,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get answers => $composableBuilder(
    column: $table.answers,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PreAdmissionResultsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $PreAdmissionResultsTable> {
  $$PreAdmissionResultsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get vark =>
      $composableBuilder(column: $table.vark, builder: (column) => column);

  GeneratedColumn<int> get structured => $composableBuilder(
    column: $table.structured,
    builder: (column) => column,
  );

  GeneratedColumn<int> get exploratory => $composableBuilder(
    column: $table.exploratory,
    builder: (column) => column,
  );

  GeneratedColumn<int> get introvert =>
      $composableBuilder(column: $table.introvert, builder: (column) => column);

  GeneratedColumn<int> get extrovert =>
      $composableBuilder(column: $table.extrovert, builder: (column) => column);

  GeneratedColumn<int> get impulsivity => $composableBuilder(
    column: $table.impulsivity,
    builder: (column) => column,
  );

  GeneratedColumn<int> get reflectivity => $composableBuilder(
    column: $table.reflectivity,
    builder: (column) => column,
  );

  GeneratedColumn<String> get dominantStyle => $composableBuilder(
    column: $table.dominantStyle,
    builder: (column) => column,
  );

  GeneratedColumn<String> get answers =>
      $composableBuilder(column: $table.answers, builder: (column) => column);
}

class $$PreAdmissionResultsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $PreAdmissionResultsTable,
          PreAdmissionResult,
          $$PreAdmissionResultsTableFilterComposer,
          $$PreAdmissionResultsTableOrderingComposer,
          $$PreAdmissionResultsTableAnnotationComposer,
          $$PreAdmissionResultsTableCreateCompanionBuilder,
          $$PreAdmissionResultsTableUpdateCompanionBuilder,
          (
            PreAdmissionResult,
            BaseReferences<
              _$SyncEduDatabase,
              $PreAdmissionResultsTable,
              PreAdmissionResult
            >,
          ),
          PreAdmissionResult,
          PrefetchHooks Function()
        > {
  $$PreAdmissionResultsTableTableManager(
    _$SyncEduDatabase db,
    $PreAdmissionResultsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PreAdmissionResultsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PreAdmissionResultsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PreAdmissionResultsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> vark = const Value.absent(),
                Value<int> structured = const Value.absent(),
                Value<int> exploratory = const Value.absent(),
                Value<int> introvert = const Value.absent(),
                Value<int> extrovert = const Value.absent(),
                Value<int> impulsivity = const Value.absent(),
                Value<int> reflectivity = const Value.absent(),
                Value<String> dominantStyle = const Value.absent(),
                Value<String> answers = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreAdmissionResultsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                vark: vark,
                structured: structured,
                exploratory: exploratory,
                introvert: introvert,
                extrovert: extrovert,
                impulsivity: impulsivity,
                reflectivity: reflectivity,
                dominantStyle: dominantStyle,
                answers: answers,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                Value<String> vark = const Value.absent(),
                Value<int> structured = const Value.absent(),
                Value<int> exploratory = const Value.absent(),
                Value<int> introvert = const Value.absent(),
                Value<int> extrovert = const Value.absent(),
                Value<int> impulsivity = const Value.absent(),
                Value<int> reflectivity = const Value.absent(),
                required String dominantStyle,
                Value<String> answers = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PreAdmissionResultsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                vark: vark,
                structured: structured,
                exploratory: exploratory,
                introvert: introvert,
                extrovert: extrovert,
                impulsivity: impulsivity,
                reflectivity: reflectivity,
                dominantStyle: dominantStyle,
                answers: answers,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PreAdmissionResultsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $PreAdmissionResultsTable,
      PreAdmissionResult,
      $$PreAdmissionResultsTableFilterComposer,
      $$PreAdmissionResultsTableOrderingComposer,
      $$PreAdmissionResultsTableAnnotationComposer,
      $$PreAdmissionResultsTableCreateCompanionBuilder,
      $$PreAdmissionResultsTableUpdateCompanionBuilder,
      (
        PreAdmissionResult,
        BaseReferences<
          _$SyncEduDatabase,
          $PreAdmissionResultsTable,
          PreAdmissionResult
        >,
      ),
      PreAdmissionResult,
      PrefetchHooks Function()
    >;
typedef $$ReflectionCampaignsTableCreateCompanionBuilder =
    ReflectionCampaignsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String academicYear,
      required DateTime openedAt,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });
typedef $$ReflectionCampaignsTableUpdateCompanionBuilder =
    ReflectionCampaignsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> academicYear,
      Value<DateTime> openedAt,
      Value<DateTime?> closedAt,
      Value<int> rowid,
    });

class $$ReflectionCampaignsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ReflectionCampaignsTable> {
  $$ReflectionCampaignsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ReflectionCampaignsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ReflectionCampaignsTable> {
  $$ReflectionCampaignsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get openedAt => $composableBuilder(
    column: $table.openedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get closedAt => $composableBuilder(
    column: $table.closedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ReflectionCampaignsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ReflectionCampaignsTable> {
  $$ReflectionCampaignsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get openedAt =>
      $composableBuilder(column: $table.openedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get closedAt =>
      $composableBuilder(column: $table.closedAt, builder: (column) => column);
}

class $$ReflectionCampaignsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ReflectionCampaignsTable,
          ReflectionCampaign,
          $$ReflectionCampaignsTableFilterComposer,
          $$ReflectionCampaignsTableOrderingComposer,
          $$ReflectionCampaignsTableAnnotationComposer,
          $$ReflectionCampaignsTableCreateCompanionBuilder,
          $$ReflectionCampaignsTableUpdateCompanionBuilder,
          (
            ReflectionCampaign,
            BaseReferences<
              _$SyncEduDatabase,
              $ReflectionCampaignsTable,
              ReflectionCampaign
            >,
          ),
          ReflectionCampaign,
          PrefetchHooks Function()
        > {
  $$ReflectionCampaignsTableTableManager(
    _$SyncEduDatabase db,
    $ReflectionCampaignsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ReflectionCampaignsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ReflectionCampaignsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$ReflectionCampaignsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> academicYear = const Value.absent(),
                Value<DateTime> openedAt = const Value.absent(),
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionCampaignsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                academicYear: academicYear,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String academicYear,
                required DateTime openedAt,
                Value<DateTime?> closedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ReflectionCampaignsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                academicYear: academicYear,
                openedAt: openedAt,
                closedAt: closedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ReflectionCampaignsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ReflectionCampaignsTable,
      ReflectionCampaign,
      $$ReflectionCampaignsTableFilterComposer,
      $$ReflectionCampaignsTableOrderingComposer,
      $$ReflectionCampaignsTableAnnotationComposer,
      $$ReflectionCampaignsTableCreateCompanionBuilder,
      $$ReflectionCampaignsTableUpdateCompanionBuilder,
      (
        ReflectionCampaign,
        BaseReferences<
          _$SyncEduDatabase,
          $ReflectionCampaignsTable,
          ReflectionCampaign
        >,
      ),
      ReflectionCampaign,
      PrefetchHooks Function()
    >;
typedef $$YearEndReflectionsTableCreateCompanionBuilder =
    YearEndReflectionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      Value<String?> campaignId,
      required String academicYear,
      Value<String> responses,
      Value<double?> studentPct,
      Value<int> rowid,
    });
typedef $$YearEndReflectionsTableUpdateCompanionBuilder =
    YearEndReflectionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String?> campaignId,
      Value<String> academicYear,
      Value<String> responses,
      Value<double?> studentPct,
      Value<int> rowid,
    });

class $$YearEndReflectionsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $YearEndReflectionsTable> {
  $$YearEndReflectionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get responses => $composableBuilder(
    column: $table.responses,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => ColumnFilters(column),
  );
}

class $$YearEndReflectionsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $YearEndReflectionsTable> {
  $$YearEndReflectionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get responses => $composableBuilder(
    column: $table.responses,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$YearEndReflectionsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $YearEndReflectionsTable> {
  $$YearEndReflectionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get campaignId => $composableBuilder(
    column: $table.campaignId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get academicYear => $composableBuilder(
    column: $table.academicYear,
    builder: (column) => column,
  );

  GeneratedColumn<String> get responses =>
      $composableBuilder(column: $table.responses, builder: (column) => column);

  GeneratedColumn<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => column,
  );
}

class $$YearEndReflectionsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $YearEndReflectionsTable,
          YearEndReflection,
          $$YearEndReflectionsTableFilterComposer,
          $$YearEndReflectionsTableOrderingComposer,
          $$YearEndReflectionsTableAnnotationComposer,
          $$YearEndReflectionsTableCreateCompanionBuilder,
          $$YearEndReflectionsTableUpdateCompanionBuilder,
          (
            YearEndReflection,
            BaseReferences<
              _$SyncEduDatabase,
              $YearEndReflectionsTable,
              YearEndReflection
            >,
          ),
          YearEndReflection,
          PrefetchHooks Function()
        > {
  $$YearEndReflectionsTableTableManager(
    _$SyncEduDatabase db,
    $YearEndReflectionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$YearEndReflectionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$YearEndReflectionsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$YearEndReflectionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> campaignId = const Value.absent(),
                Value<String> academicYear = const Value.absent(),
                Value<String> responses = const Value.absent(),
                Value<double?> studentPct = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YearEndReflectionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                campaignId: campaignId,
                academicYear: academicYear,
                responses: responses,
                studentPct: studentPct,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                Value<String?> campaignId = const Value.absent(),
                required String academicYear,
                Value<String> responses = const Value.absent(),
                Value<double?> studentPct = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => YearEndReflectionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                campaignId: campaignId,
                academicYear: academicYear,
                responses: responses,
                studentPct: studentPct,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$YearEndReflectionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $YearEndReflectionsTable,
      YearEndReflection,
      $$YearEndReflectionsTableFilterComposer,
      $$YearEndReflectionsTableOrderingComposer,
      $$YearEndReflectionsTableAnnotationComposer,
      $$YearEndReflectionsTableCreateCompanionBuilder,
      $$YearEndReflectionsTableUpdateCompanionBuilder,
      (
        YearEndReflection,
        BaseReferences<
          _$SyncEduDatabase,
          $YearEndReflectionsTable,
          YearEndReflection
        >,
      ),
      YearEndReflection,
      PrefetchHooks Function()
    >;
typedef $$FitAnalysesTableCreateCompanionBuilder =
    FitAnalysesCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      Value<double?> academicPct,
      Value<double?> studentPct,
      Value<double?> teacherPct,
      Value<double?> fitScore,
      Value<String?> verdict,
      Value<String?> recommendation,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$FitAnalysesTableUpdateCompanionBuilder =
    FitAnalysesCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<double?> academicPct,
      Value<double?> studentPct,
      Value<double?> teacherPct,
      Value<double?> fitScore,
      Value<String?> verdict,
      Value<String?> recommendation,
      Value<String> source,
      Value<int> rowid,
    });

class $$FitAnalysesTableFilterComposer
    extends Composer<_$SyncEduDatabase, $FitAnalysesTable> {
  $$FitAnalysesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get academicPct => $composableBuilder(
    column: $table.academicPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get teacherPct => $composableBuilder(
    column: $table.teacherPct,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<double> get fitScore => $composableBuilder(
    column: $table.fitScore,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$FitAnalysesTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $FitAnalysesTable> {
  $$FitAnalysesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get academicPct => $composableBuilder(
    column: $table.academicPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get teacherPct => $composableBuilder(
    column: $table.teacherPct,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<double> get fitScore => $composableBuilder(
    column: $table.fitScore,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get verdict => $composableBuilder(
    column: $table.verdict,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$FitAnalysesTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $FitAnalysesTable> {
  $$FitAnalysesTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<double> get academicPct => $composableBuilder(
    column: $table.academicPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get studentPct => $composableBuilder(
    column: $table.studentPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get teacherPct => $composableBuilder(
    column: $table.teacherPct,
    builder: (column) => column,
  );

  GeneratedColumn<double> get fitScore =>
      $composableBuilder(column: $table.fitScore, builder: (column) => column);

  GeneratedColumn<String> get verdict =>
      $composableBuilder(column: $table.verdict, builder: (column) => column);

  GeneratedColumn<String> get recommendation => $composableBuilder(
    column: $table.recommendation,
    builder: (column) => column,
  );

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$FitAnalysesTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $FitAnalysesTable,
          FitAnalyse,
          $$FitAnalysesTableFilterComposer,
          $$FitAnalysesTableOrderingComposer,
          $$FitAnalysesTableAnnotationComposer,
          $$FitAnalysesTableCreateCompanionBuilder,
          $$FitAnalysesTableUpdateCompanionBuilder,
          (
            FitAnalyse,
            BaseReferences<_$SyncEduDatabase, $FitAnalysesTable, FitAnalyse>,
          ),
          FitAnalyse,
          PrefetchHooks Function()
        > {
  $$FitAnalysesTableTableManager(_$SyncEduDatabase db, $FitAnalysesTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$FitAnalysesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$FitAnalysesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$FitAnalysesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<double?> academicPct = const Value.absent(),
                Value<double?> studentPct = const Value.absent(),
                Value<double?> teacherPct = const Value.absent(),
                Value<double?> fitScore = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<String?> recommendation = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FitAnalysesCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                academicPct: academicPct,
                studentPct: studentPct,
                teacherPct: teacherPct,
                fitScore: fitScore,
                verdict: verdict,
                recommendation: recommendation,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                Value<double?> academicPct = const Value.absent(),
                Value<double?> studentPct = const Value.absent(),
                Value<double?> teacherPct = const Value.absent(),
                Value<double?> fitScore = const Value.absent(),
                Value<String?> verdict = const Value.absent(),
                Value<String?> recommendation = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => FitAnalysesCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                academicPct: academicPct,
                studentPct: studentPct,
                teacherPct: teacherPct,
                fitScore: fitScore,
                verdict: verdict,
                recommendation: recommendation,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$FitAnalysesTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $FitAnalysesTable,
      FitAnalyse,
      $$FitAnalysesTableFilterComposer,
      $$FitAnalysesTableOrderingComposer,
      $$FitAnalysesTableAnnotationComposer,
      $$FitAnalysesTableCreateCompanionBuilder,
      $$FitAnalysesTableUpdateCompanionBuilder,
      (
        FitAnalyse,
        BaseReferences<_$SyncEduDatabase, $FitAnalysesTable, FitAnalyse>,
      ),
      FitAnalyse,
      PrefetchHooks Function()
    >;
typedef $$PlacementSuggestionsTableCreateCompanionBuilder =
    PlacementSuggestionsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      Value<String?> suggestedClassId,
      Value<String> rationale,
      Value<String> status,
      Value<int> version,
      Value<int> rowid,
    });
typedef $$PlacementSuggestionsTableUpdateCompanionBuilder =
    PlacementSuggestionsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String?> suggestedClassId,
      Value<String> rationale,
      Value<String> status,
      Value<int> version,
      Value<int> rowid,
    });

class $$PlacementSuggestionsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $PlacementSuggestionsTable> {
  $$PlacementSuggestionsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get suggestedClassId => $composableBuilder(
    column: $table.suggestedClassId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PlacementSuggestionsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $PlacementSuggestionsTable> {
  $$PlacementSuggestionsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get suggestedClassId => $composableBuilder(
    column: $table.suggestedClassId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rationale => $composableBuilder(
    column: $table.rationale,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get version => $composableBuilder(
    column: $table.version,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PlacementSuggestionsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $PlacementSuggestionsTable> {
  $$PlacementSuggestionsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get suggestedClassId => $composableBuilder(
    column: $table.suggestedClassId,
    builder: (column) => column,
  );

  GeneratedColumn<String> get rationale =>
      $composableBuilder(column: $table.rationale, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<int> get version =>
      $composableBuilder(column: $table.version, builder: (column) => column);
}

class $$PlacementSuggestionsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $PlacementSuggestionsTable,
          PlacementSuggestion,
          $$PlacementSuggestionsTableFilterComposer,
          $$PlacementSuggestionsTableOrderingComposer,
          $$PlacementSuggestionsTableAnnotationComposer,
          $$PlacementSuggestionsTableCreateCompanionBuilder,
          $$PlacementSuggestionsTableUpdateCompanionBuilder,
          (
            PlacementSuggestion,
            BaseReferences<
              _$SyncEduDatabase,
              $PlacementSuggestionsTable,
              PlacementSuggestion
            >,
          ),
          PlacementSuggestion,
          PrefetchHooks Function()
        > {
  $$PlacementSuggestionsTableTableManager(
    _$SyncEduDatabase db,
    $PlacementSuggestionsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PlacementSuggestionsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PlacementSuggestionsTableOrderingComposer(
                $db: db,
                $table: table,
              ),
          createComputedFieldComposer: () =>
              $$PlacementSuggestionsTableAnnotationComposer(
                $db: db,
                $table: table,
              ),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String?> suggestedClassId = const Value.absent(),
                Value<String> rationale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacementSuggestionsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                suggestedClassId: suggestedClassId,
                rationale: rationale,
                status: status,
                version: version,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                Value<String?> suggestedClassId = const Value.absent(),
                Value<String> rationale = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<int> version = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PlacementSuggestionsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                suggestedClassId: suggestedClassId,
                rationale: rationale,
                status: status,
                version: version,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PlacementSuggestionsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $PlacementSuggestionsTable,
      PlacementSuggestion,
      $$PlacementSuggestionsTableFilterComposer,
      $$PlacementSuggestionsTableOrderingComposer,
      $$PlacementSuggestionsTableAnnotationComposer,
      $$PlacementSuggestionsTableCreateCompanionBuilder,
      $$PlacementSuggestionsTableUpdateCompanionBuilder,
      (
        PlacementSuggestion,
        BaseReferences<
          _$SyncEduDatabase,
          $PlacementSuggestionsTable,
          PlacementSuggestion
        >,
      ),
      PlacementSuggestion,
      PrefetchHooks Function()
    >;
typedef $$ExamPapersTableCreateCompanionBuilder =
    ExamPapersCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String studentId,
      required String chapterId,
      required String storagePath,
      Value<String> analysisStatus,
      Value<String?> analysisNote,
      required String uploadedBy,
      Value<int> rowid,
    });
typedef $$ExamPapersTableUpdateCompanionBuilder =
    ExamPapersCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> studentId,
      Value<String> chapterId,
      Value<String> storagePath,
      Value<String> analysisStatus,
      Value<String?> analysisNote,
      Value<String> uploadedBy,
      Value<int> rowid,
    });

class $$ExamPapersTableFilterComposer
    extends Composer<_$SyncEduDatabase, $ExamPapersTable> {
  $$ExamPapersTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisStatus => $composableBuilder(
    column: $table.analysisStatus,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get analysisNote => $composableBuilder(
    column: $table.analysisNote,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get uploadedBy => $composableBuilder(
    column: $table.uploadedBy,
    builder: (column) => ColumnFilters(column),
  );
}

class $$ExamPapersTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $ExamPapersTable> {
  $$ExamPapersTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get studentId => $composableBuilder(
    column: $table.studentId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisStatus => $composableBuilder(
    column: $table.analysisStatus,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get analysisNote => $composableBuilder(
    column: $table.analysisNote,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get uploadedBy => $composableBuilder(
    column: $table.uploadedBy,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$ExamPapersTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $ExamPapersTable> {
  $$ExamPapersTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get studentId =>
      $composableBuilder(column: $table.studentId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get storagePath => $composableBuilder(
    column: $table.storagePath,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisStatus => $composableBuilder(
    column: $table.analysisStatus,
    builder: (column) => column,
  );

  GeneratedColumn<String> get analysisNote => $composableBuilder(
    column: $table.analysisNote,
    builder: (column) => column,
  );

  GeneratedColumn<String> get uploadedBy => $composableBuilder(
    column: $table.uploadedBy,
    builder: (column) => column,
  );
}

class $$ExamPapersTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $ExamPapersTable,
          ExamPaper,
          $$ExamPapersTableFilterComposer,
          $$ExamPapersTableOrderingComposer,
          $$ExamPapersTableAnnotationComposer,
          $$ExamPapersTableCreateCompanionBuilder,
          $$ExamPapersTableUpdateCompanionBuilder,
          (
            ExamPaper,
            BaseReferences<_$SyncEduDatabase, $ExamPapersTable, ExamPaper>,
          ),
          ExamPaper,
          PrefetchHooks Function()
        > {
  $$ExamPapersTableTableManager(_$SyncEduDatabase db, $ExamPapersTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ExamPapersTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ExamPapersTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ExamPapersTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> studentId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> storagePath = const Value.absent(),
                Value<String> analysisStatus = const Value.absent(),
                Value<String?> analysisNote = const Value.absent(),
                Value<String> uploadedBy = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => ExamPapersCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                chapterId: chapterId,
                storagePath: storagePath,
                analysisStatus: analysisStatus,
                analysisNote: analysisNote,
                uploadedBy: uploadedBy,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String studentId,
                required String chapterId,
                required String storagePath,
                Value<String> analysisStatus = const Value.absent(),
                Value<String?> analysisNote = const Value.absent(),
                required String uploadedBy,
                Value<int> rowid = const Value.absent(),
              }) => ExamPapersCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                studentId: studentId,
                chapterId: chapterId,
                storagePath: storagePath,
                analysisStatus: analysisStatus,
                analysisNote: analysisNote,
                uploadedBy: uploadedBy,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$ExamPapersTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $ExamPapersTable,
      ExamPaper,
      $$ExamPapersTableFilterComposer,
      $$ExamPapersTableOrderingComposer,
      $$ExamPapersTableAnnotationComposer,
      $$ExamPapersTableCreateCompanionBuilder,
      $$ExamPapersTableUpdateCompanionBuilder,
      (
        ExamPaper,
        BaseReferences<_$SyncEduDatabase, $ExamPapersTable, ExamPaper>,
      ),
      ExamPaper,
      PrefetchHooks Function()
    >;
typedef $$TeachingInsightsTableCreateCompanionBuilder =
    TeachingInsightsCompanion Function({
      required String id,
      required DateTime createdAt,
      required DateTime updatedAt,
      Value<DateTime?> deletedAt,
      required String schoolId,
      required String teacherId,
      required String classId,
      required String chapterId,
      Value<String> signals,
      Value<String> summary,
      Value<String> actions,
      Value<String> deck,
      Value<String> source,
      Value<int> rowid,
    });
typedef $$TeachingInsightsTableUpdateCompanionBuilder =
    TeachingInsightsCompanion Function({
      Value<String> id,
      Value<DateTime> createdAt,
      Value<DateTime> updatedAt,
      Value<DateTime?> deletedAt,
      Value<String> schoolId,
      Value<String> teacherId,
      Value<String> classId,
      Value<String> chapterId,
      Value<String> signals,
      Value<String> summary,
      Value<String> actions,
      Value<String> deck,
      Value<String> source,
      Value<int> rowid,
    });

class $$TeachingInsightsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $TeachingInsightsTable> {
  $$TeachingInsightsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get signals => $composableBuilder(
    column: $table.signals,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get deck => $composableBuilder(
    column: $table.deck,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnFilters(column),
  );
}

class $$TeachingInsightsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $TeachingInsightsTable> {
  $$TeachingInsightsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
    column: $table.updatedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get deletedAt => $composableBuilder(
    column: $table.deletedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get schoolId => $composableBuilder(
    column: $table.schoolId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get teacherId => $composableBuilder(
    column: $table.teacherId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get classId => $composableBuilder(
    column: $table.classId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get chapterId => $composableBuilder(
    column: $table.chapterId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get signals => $composableBuilder(
    column: $table.signals,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get summary => $composableBuilder(
    column: $table.summary,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get actions => $composableBuilder(
    column: $table.actions,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get deck => $composableBuilder(
    column: $table.deck,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get source => $composableBuilder(
    column: $table.source,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$TeachingInsightsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $TeachingInsightsTable> {
  $$TeachingInsightsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);

  GeneratedColumn<DateTime> get deletedAt =>
      $composableBuilder(column: $table.deletedAt, builder: (column) => column);

  GeneratedColumn<String> get schoolId =>
      $composableBuilder(column: $table.schoolId, builder: (column) => column);

  GeneratedColumn<String> get teacherId =>
      $composableBuilder(column: $table.teacherId, builder: (column) => column);

  GeneratedColumn<String> get classId =>
      $composableBuilder(column: $table.classId, builder: (column) => column);

  GeneratedColumn<String> get chapterId =>
      $composableBuilder(column: $table.chapterId, builder: (column) => column);

  GeneratedColumn<String> get signals =>
      $composableBuilder(column: $table.signals, builder: (column) => column);

  GeneratedColumn<String> get summary =>
      $composableBuilder(column: $table.summary, builder: (column) => column);

  GeneratedColumn<String> get actions =>
      $composableBuilder(column: $table.actions, builder: (column) => column);

  GeneratedColumn<String> get deck =>
      $composableBuilder(column: $table.deck, builder: (column) => column);

  GeneratedColumn<String> get source =>
      $composableBuilder(column: $table.source, builder: (column) => column);
}

class $$TeachingInsightsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $TeachingInsightsTable,
          TeachingInsightRecord,
          $$TeachingInsightsTableFilterComposer,
          $$TeachingInsightsTableOrderingComposer,
          $$TeachingInsightsTableAnnotationComposer,
          $$TeachingInsightsTableCreateCompanionBuilder,
          $$TeachingInsightsTableUpdateCompanionBuilder,
          (
            TeachingInsightRecord,
            BaseReferences<
              _$SyncEduDatabase,
              $TeachingInsightsTable,
              TeachingInsightRecord
            >,
          ),
          TeachingInsightRecord,
          PrefetchHooks Function()
        > {
  $$TeachingInsightsTableTableManager(
    _$SyncEduDatabase db,
    $TeachingInsightsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$TeachingInsightsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$TeachingInsightsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$TeachingInsightsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<DateTime> updatedAt = const Value.absent(),
                Value<DateTime?> deletedAt = const Value.absent(),
                Value<String> schoolId = const Value.absent(),
                Value<String> teacherId = const Value.absent(),
                Value<String> classId = const Value.absent(),
                Value<String> chapterId = const Value.absent(),
                Value<String> signals = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<String> deck = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeachingInsightsCompanion(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                teacherId: teacherId,
                classId: classId,
                chapterId: chapterId,
                signals: signals,
                summary: summary,
                actions: actions,
                deck: deck,
                source: source,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required DateTime createdAt,
                required DateTime updatedAt,
                Value<DateTime?> deletedAt = const Value.absent(),
                required String schoolId,
                required String teacherId,
                required String classId,
                required String chapterId,
                Value<String> signals = const Value.absent(),
                Value<String> summary = const Value.absent(),
                Value<String> actions = const Value.absent(),
                Value<String> deck = const Value.absent(),
                Value<String> source = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => TeachingInsightsCompanion.insert(
                id: id,
                createdAt: createdAt,
                updatedAt: updatedAt,
                deletedAt: deletedAt,
                schoolId: schoolId,
                teacherId: teacherId,
                classId: classId,
                chapterId: chapterId,
                signals: signals,
                summary: summary,
                actions: actions,
                deck: deck,
                source: source,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$TeachingInsightsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $TeachingInsightsTable,
      TeachingInsightRecord,
      $$TeachingInsightsTableFilterComposer,
      $$TeachingInsightsTableOrderingComposer,
      $$TeachingInsightsTableAnnotationComposer,
      $$TeachingInsightsTableCreateCompanionBuilder,
      $$TeachingInsightsTableUpdateCompanionBuilder,
      (
        TeachingInsightRecord,
        BaseReferences<
          _$SyncEduDatabase,
          $TeachingInsightsTable,
          TeachingInsightRecord
        >,
      ),
      TeachingInsightRecord,
      PrefetchHooks Function()
    >;
typedef $$SyncStateTableCreateCompanionBuilder =
    SyncStateCompanion Function({
      required String table,
      Value<DateTime?> watermark,
      Value<DateTime?> lastPullAt,
      Value<int> rowid,
    });
typedef $$SyncStateTableUpdateCompanionBuilder =
    SyncStateCompanion Function({
      Value<String> table,
      Value<DateTime?> watermark,
      Value<DateTime?> lastPullAt,
      Value<int> rowid,
    });

class $$SyncStateTableFilterComposer
    extends Composer<_$SyncEduDatabase, $SyncStateTable> {
  $$SyncStateTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$SyncStateTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $SyncStateTable> {
  $$SyncStateTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get watermark => $composableBuilder(
    column: $table.watermark,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$SyncStateTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $SyncStateTable> {
  $$SyncStateTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get table =>
      $composableBuilder(column: $table.table, builder: (column) => column);

  GeneratedColumn<DateTime> get watermark =>
      $composableBuilder(column: $table.watermark, builder: (column) => column);

  GeneratedColumn<DateTime> get lastPullAt => $composableBuilder(
    column: $table.lastPullAt,
    builder: (column) => column,
  );
}

class $$SyncStateTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $SyncStateTable,
          SyncStateData,
          $$SyncStateTableFilterComposer,
          $$SyncStateTableOrderingComposer,
          $$SyncStateTableAnnotationComposer,
          $$SyncStateTableCreateCompanionBuilder,
          $$SyncStateTableUpdateCompanionBuilder,
          (
            SyncStateData,
            BaseReferences<_$SyncEduDatabase, $SyncStateTable, SyncStateData>,
          ),
          SyncStateData,
          PrefetchHooks Function()
        > {
  $$SyncStateTableTableManager(_$SyncEduDatabase db, $SyncStateTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SyncStateTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SyncStateTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SyncStateTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> table = const Value.absent(),
                Value<DateTime?> watermark = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion(
                table: table,
                watermark: watermark,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String table,
                Value<DateTime?> watermark = const Value.absent(),
                Value<DateTime?> lastPullAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => SyncStateCompanion.insert(
                table: table,
                watermark: watermark,
                lastPullAt: lastPullAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$SyncStateTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $SyncStateTable,
      SyncStateData,
      $$SyncStateTableFilterComposer,
      $$SyncStateTableOrderingComposer,
      $$SyncStateTableAnnotationComposer,
      $$SyncStateTableCreateCompanionBuilder,
      $$SyncStateTableUpdateCompanionBuilder,
      (
        SyncStateData,
        BaseReferences<_$SyncEduDatabase, $SyncStateTable, SyncStateData>,
      ),
      SyncStateData,
      PrefetchHooks Function()
    >;
typedef $$OutboxTableCreateCompanionBuilder =
    OutboxCompanion Function({
      required String id,
      required String op,
      required String table,
      required String rowId,
      Value<String?> field,
      Value<String?> observedValue,
      Value<String?> newValue,
      Value<String?> payload,
      required DateTime clientTs,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$OutboxTableUpdateCompanionBuilder =
    OutboxCompanion Function({
      Value<String> id,
      Value<String> op,
      Value<String> table,
      Value<String> rowId,
      Value<String?> field,
      Value<String?> observedValue,
      Value<String?> newValue,
      Value<String?> payload,
      Value<DateTime> clientTs,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$OutboxTableFilterComposer
    extends Composer<_$SyncEduDatabase, $OutboxTable> {
  $$OutboxTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$OutboxTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $OutboxTable> {
  $$OutboxTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get op => $composableBuilder(
    column: $table.op,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get newValue => $composableBuilder(
    column: $table.newValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get clientTs => $composableBuilder(
    column: $table.clientTs,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$OutboxTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $OutboxTable> {
  $$OutboxTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get op =>
      $composableBuilder(column: $table.op, builder: (column) => column);

  GeneratedColumn<String> get table =>
      $composableBuilder(column: $table.table, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get newValue =>
      $composableBuilder(column: $table.newValue, builder: (column) => column);

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<DateTime> get clientTs =>
      $composableBuilder(column: $table.clientTs, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$OutboxTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $OutboxTable,
          OutboxData,
          $$OutboxTableFilterComposer,
          $$OutboxTableOrderingComposer,
          $$OutboxTableAnnotationComposer,
          $$OutboxTableCreateCompanionBuilder,
          $$OutboxTableUpdateCompanionBuilder,
          (
            OutboxData,
            BaseReferences<_$SyncEduDatabase, $OutboxTable, OutboxData>,
          ),
          OutboxData,
          PrefetchHooks Function()
        > {
  $$OutboxTableTableManager(_$SyncEduDatabase db, $OutboxTable table)
    : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$OutboxTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$OutboxTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$OutboxTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> op = const Value.absent(),
                Value<String> table = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String?> field = const Value.absent(),
                Value<String?> observedValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                Value<DateTime> clientTs = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion(
                id: id,
                op: op,
                table: table,
                rowId: rowId,
                field: field,
                observedValue: observedValue,
                newValue: newValue,
                payload: payload,
                clientTs: clientTs,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String op,
                required String table,
                required String rowId,
                Value<String?> field = const Value.absent(),
                Value<String?> observedValue = const Value.absent(),
                Value<String?> newValue = const Value.absent(),
                Value<String?> payload = const Value.absent(),
                required DateTime clientTs,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => OutboxCompanion.insert(
                id: id,
                op: op,
                table: table,
                rowId: rowId,
                field: field,
                observedValue: observedValue,
                newValue: newValue,
                payload: payload,
                clientTs: clientTs,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$OutboxTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $OutboxTable,
      OutboxData,
      $$OutboxTableFilterComposer,
      $$OutboxTableOrderingComposer,
      $$OutboxTableAnnotationComposer,
      $$OutboxTableCreateCompanionBuilder,
      $$OutboxTableUpdateCompanionBuilder,
      (OutboxData, BaseReferences<_$SyncEduDatabase, $OutboxTable, OutboxData>),
      OutboxData,
      PrefetchHooks Function()
    >;
typedef $$PendingIntentsTableCreateCompanionBuilder =
    PendingIntentsCompanion Function({
      required String id,
      required String functionName,
      required String payload,
      Value<String> status,
      required DateTime createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });
typedef $$PendingIntentsTableUpdateCompanionBuilder =
    PendingIntentsCompanion Function({
      Value<String> id,
      Value<String> functionName,
      Value<String> payload,
      Value<String> status,
      Value<DateTime> createdAt,
      Value<int> attempts,
      Value<String?> lastError,
      Value<int> rowid,
    });

class $$PendingIntentsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $PendingIntentsTable> {
  $$PendingIntentsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnFilters(column),
  );
}

class $$PendingIntentsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $PendingIntentsTable> {
  $$PendingIntentsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get payload => $composableBuilder(
    column: $table.payload,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get status => $composableBuilder(
    column: $table.status,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
    column: $table.createdAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<int> get attempts => $composableBuilder(
    column: $table.attempts,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get lastError => $composableBuilder(
    column: $table.lastError,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$PendingIntentsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $PendingIntentsTable> {
  $$PendingIntentsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get functionName => $composableBuilder(
    column: $table.functionName,
    builder: (column) => column,
  );

  GeneratedColumn<String> get payload =>
      $composableBuilder(column: $table.payload, builder: (column) => column);

  GeneratedColumn<String> get status =>
      $composableBuilder(column: $table.status, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<int> get attempts =>
      $composableBuilder(column: $table.attempts, builder: (column) => column);

  GeneratedColumn<String> get lastError =>
      $composableBuilder(column: $table.lastError, builder: (column) => column);
}

class $$PendingIntentsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $PendingIntentsTable,
          PendingIntent,
          $$PendingIntentsTableFilterComposer,
          $$PendingIntentsTableOrderingComposer,
          $$PendingIntentsTableAnnotationComposer,
          $$PendingIntentsTableCreateCompanionBuilder,
          $$PendingIntentsTableUpdateCompanionBuilder,
          (
            PendingIntent,
            BaseReferences<
              _$SyncEduDatabase,
              $PendingIntentsTable,
              PendingIntent
            >,
          ),
          PendingIntent,
          PrefetchHooks Function()
        > {
  $$PendingIntentsTableTableManager(
    _$SyncEduDatabase db,
    $PendingIntentsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$PendingIntentsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$PendingIntentsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$PendingIntentsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> functionName = const Value.absent(),
                Value<String> payload = const Value.absent(),
                Value<String> status = const Value.absent(),
                Value<DateTime> createdAt = const Value.absent(),
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingIntentsCompanion(
                id: id,
                functionName: functionName,
                payload: payload,
                status: status,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String functionName,
                required String payload,
                Value<String> status = const Value.absent(),
                required DateTime createdAt,
                Value<int> attempts = const Value.absent(),
                Value<String?> lastError = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => PendingIntentsCompanion.insert(
                id: id,
                functionName: functionName,
                payload: payload,
                status: status,
                createdAt: createdAt,
                attempts: attempts,
                lastError: lastError,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$PendingIntentsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $PendingIntentsTable,
      PendingIntent,
      $$PendingIntentsTableFilterComposer,
      $$PendingIntentsTableOrderingComposer,
      $$PendingIntentsTableAnnotationComposer,
      $$PendingIntentsTableCreateCompanionBuilder,
      $$PendingIntentsTableUpdateCompanionBuilder,
      (
        PendingIntent,
        BaseReferences<_$SyncEduDatabase, $PendingIntentsTable, PendingIntent>,
      ),
      PendingIntent,
      PrefetchHooks Function()
    >;
typedef $$LocalConflictsTableCreateCompanionBuilder =
    LocalConflictsCompanion Function({
      required String id,
      required String table,
      required String rowId,
      required String field,
      Value<String?> observedValue,
      Value<String?> attemptedValue,
      Value<String?> serverValue,
      required DateTime detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });
typedef $$LocalConflictsTableUpdateCompanionBuilder =
    LocalConflictsCompanion Function({
      Value<String> id,
      Value<String> table,
      Value<String> rowId,
      Value<String> field,
      Value<String?> observedValue,
      Value<String?> attemptedValue,
      Value<String?> serverValue,
      Value<DateTime> detectedAt,
      Value<DateTime?> resolvedAt,
      Value<int> rowid,
    });

class $$LocalConflictsTableFilterComposer
    extends Composer<_$SyncEduDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get attemptedValue => $composableBuilder(
    column: $table.attemptedValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<String> get serverValue => $composableBuilder(
    column: $table.serverValue,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnFilters(column),
  );

  ColumnFilters<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnFilters(column),
  );
}

class $$LocalConflictsTableOrderingComposer
    extends Composer<_$SyncEduDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<String> get id => $composableBuilder(
    column: $table.id,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get table => $composableBuilder(
    column: $table.table,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get rowId => $composableBuilder(
    column: $table.rowId,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get field => $composableBuilder(
    column: $table.field,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get attemptedValue => $composableBuilder(
    column: $table.attemptedValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<String> get serverValue => $composableBuilder(
    column: $table.serverValue,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => ColumnOrderings(column),
  );

  ColumnOrderings<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => ColumnOrderings(column),
  );
}

class $$LocalConflictsTableAnnotationComposer
    extends Composer<_$SyncEduDatabase, $LocalConflictsTable> {
  $$LocalConflictsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<String> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get table =>
      $composableBuilder(column: $table.table, builder: (column) => column);

  GeneratedColumn<String> get rowId =>
      $composableBuilder(column: $table.rowId, builder: (column) => column);

  GeneratedColumn<String> get field =>
      $composableBuilder(column: $table.field, builder: (column) => column);

  GeneratedColumn<String> get observedValue => $composableBuilder(
    column: $table.observedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get attemptedValue => $composableBuilder(
    column: $table.attemptedValue,
    builder: (column) => column,
  );

  GeneratedColumn<String> get serverValue => $composableBuilder(
    column: $table.serverValue,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get detectedAt => $composableBuilder(
    column: $table.detectedAt,
    builder: (column) => column,
  );

  GeneratedColumn<DateTime> get resolvedAt => $composableBuilder(
    column: $table.resolvedAt,
    builder: (column) => column,
  );
}

class $$LocalConflictsTableTableManager
    extends
        RootTableManager<
          _$SyncEduDatabase,
          $LocalConflictsTable,
          LocalConflict,
          $$LocalConflictsTableFilterComposer,
          $$LocalConflictsTableOrderingComposer,
          $$LocalConflictsTableAnnotationComposer,
          $$LocalConflictsTableCreateCompanionBuilder,
          $$LocalConflictsTableUpdateCompanionBuilder,
          (
            LocalConflict,
            BaseReferences<
              _$SyncEduDatabase,
              $LocalConflictsTable,
              LocalConflict
            >,
          ),
          LocalConflict,
          PrefetchHooks Function()
        > {
  $$LocalConflictsTableTableManager(
    _$SyncEduDatabase db,
    $LocalConflictsTable table,
  ) : super(
        TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$LocalConflictsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$LocalConflictsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$LocalConflictsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback:
              ({
                Value<String> id = const Value.absent(),
                Value<String> table = const Value.absent(),
                Value<String> rowId = const Value.absent(),
                Value<String> field = const Value.absent(),
                Value<String?> observedValue = const Value.absent(),
                Value<String?> attemptedValue = const Value.absent(),
                Value<String?> serverValue = const Value.absent(),
                Value<DateTime> detectedAt = const Value.absent(),
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictsCompanion(
                id: id,
                table: table,
                rowId: rowId,
                field: field,
                observedValue: observedValue,
                attemptedValue: attemptedValue,
                serverValue: serverValue,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          createCompanionCallback:
              ({
                required String id,
                required String table,
                required String rowId,
                required String field,
                Value<String?> observedValue = const Value.absent(),
                Value<String?> attemptedValue = const Value.absent(),
                Value<String?> serverValue = const Value.absent(),
                required DateTime detectedAt,
                Value<DateTime?> resolvedAt = const Value.absent(),
                Value<int> rowid = const Value.absent(),
              }) => LocalConflictsCompanion.insert(
                id: id,
                table: table,
                rowId: rowId,
                field: field,
                observedValue: observedValue,
                attemptedValue: attemptedValue,
                serverValue: serverValue,
                detectedAt: detectedAt,
                resolvedAt: resolvedAt,
                rowid: rowid,
              ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ),
      );
}

typedef $$LocalConflictsTableProcessedTableManager =
    ProcessedTableManager<
      _$SyncEduDatabase,
      $LocalConflictsTable,
      LocalConflict,
      $$LocalConflictsTableFilterComposer,
      $$LocalConflictsTableOrderingComposer,
      $$LocalConflictsTableAnnotationComposer,
      $$LocalConflictsTableCreateCompanionBuilder,
      $$LocalConflictsTableUpdateCompanionBuilder,
      (
        LocalConflict,
        BaseReferences<_$SyncEduDatabase, $LocalConflictsTable, LocalConflict>,
      ),
      LocalConflict,
      PrefetchHooks Function()
    >;

class $SyncEduDatabaseManager {
  final _$SyncEduDatabase _db;
  $SyncEduDatabaseManager(this._db);
  $$SchoolsTableTableManager get schools =>
      $$SchoolsTableTableManager(_db, _db.schools);
  $$ProfilesTableTableManager get profiles =>
      $$ProfilesTableTableManager(_db, _db.profiles);
  $$StudentsTableTableManager get students =>
      $$StudentsTableTableManager(_db, _db.students);
  $$SubjectsTableTableManager get subjects =>
      $$SubjectsTableTableManager(_db, _db.subjects);
  $$ChaptersTableTableManager get chapters =>
      $$ChaptersTableTableManager(_db, _db.chapters);
  $$ClassesTableTableManager get classes =>
      $$ClassesTableTableManager(_db, _db.classes);
  $$ClassSubjectsTableTableManager get classSubjects =>
      $$ClassSubjectsTableTableManager(_db, _db.classSubjects);
  $$ClassChapterSchedTableTableManager get classChapterSched =>
      $$ClassChapterSchedTableTableManager(_db, _db.classChapterSched);
  $$MicroSkillsTableTableManager get microSkills =>
      $$MicroSkillsTableTableManager(_db, _db.microSkills);
  $$MicroSkillExplanationsTableTableManager get microSkillExplanations =>
      $$MicroSkillExplanationsTableTableManager(
        _db,
        _db.microSkillExplanations,
      );
  $$QuestionsTableTableManager get questions =>
      $$QuestionsTableTableManager(_db, _db.questions);
  $$AttemptsTableTableManager get attempts =>
      $$AttemptsTableTableManager(_db, _db.attempts);
  $$AttemptItemsTableTableManager get attemptItems =>
      $$AttemptItemsTableTableManager(_db, _db.attemptItems);
  $$WeaknessesTableTableManager get weaknesses =>
      $$WeaknessesTableTableManager(_db, _db.weaknesses);
  $$MaterialsTableTableManager get materials =>
      $$MaterialsTableTableManager(_db, _db.materials);
  $$TeacherObservationsTableTableManager get teacherObservations =>
      $$TeacherObservationsTableTableManager(_db, _db.teacherObservations);
  $$GeneratedContentTableTableManager get generatedContent =>
      $$GeneratedContentTableTableManager(_db, _db.generatedContent);
  $$PreAdmissionResultsTableTableManager get preAdmissionResults =>
      $$PreAdmissionResultsTableTableManager(_db, _db.preAdmissionResults);
  $$ReflectionCampaignsTableTableManager get reflectionCampaigns =>
      $$ReflectionCampaignsTableTableManager(_db, _db.reflectionCampaigns);
  $$YearEndReflectionsTableTableManager get yearEndReflections =>
      $$YearEndReflectionsTableTableManager(_db, _db.yearEndReflections);
  $$FitAnalysesTableTableManager get fitAnalyses =>
      $$FitAnalysesTableTableManager(_db, _db.fitAnalyses);
  $$PlacementSuggestionsTableTableManager get placementSuggestions =>
      $$PlacementSuggestionsTableTableManager(_db, _db.placementSuggestions);
  $$ExamPapersTableTableManager get examPapers =>
      $$ExamPapersTableTableManager(_db, _db.examPapers);
  $$TeachingInsightsTableTableManager get teachingInsights =>
      $$TeachingInsightsTableTableManager(_db, _db.teachingInsights);
  $$SyncStateTableTableManager get syncState =>
      $$SyncStateTableTableManager(_db, _db.syncState);
  $$OutboxTableTableManager get outbox =>
      $$OutboxTableTableManager(_db, _db.outbox);
  $$PendingIntentsTableTableManager get pendingIntents =>
      $$PendingIntentsTableTableManager(_db, _db.pendingIntents);
  $$LocalConflictsTableTableManager get localConflicts =>
      $$LocalConflictsTableTableManager(_db, _db.localConflicts);
}
