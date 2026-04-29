// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'database.dart';

// ignore_for_file: type=lint
class $SshKeysTable extends SshKeys with TableInfo<$SshKeysTable, SshKey> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SshKeysTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _contentMeta =
      const VerificationMeta('content');
  @override
  late final GeneratedColumn<String> content = GeneratedColumn<String>(
      'content', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _algorithmMeta =
      const VerificationMeta('algorithm');
  @override
  late final GeneratedColumn<int> algorithm = GeneratedColumn<int>(
      'algorithm', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns =>
      [id, name, content, password, salt, algorithm, createdAt];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_keys';
  @override
  VerificationContext validateIntegrity(Insertable<SshKey> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    }
    if (data.containsKey('content')) {
      context.handle(_contentMeta,
          content.isAcceptableOrUnknown(data['content']!, _contentMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    }
    if (data.containsKey('algorithm')) {
      context.handle(_algorithmMeta,
          algorithm.isAcceptableOrUnknown(data['algorithm']!, _algorithmMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SshKey map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshKey(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name']),
      content: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}content']),
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt']),
      algorithm: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}algorithm']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $SshKeysTable createAlias(String alias) {
    return $SshKeysTable(attachedDatabase, alias);
  }
}

class SshKey extends DataClass implements Insertable<SshKey> {
  /// Primary key - auto increment
  final int id;

  /// Display name for the key
  final String? name;

  /// Encrypted PEM key content
  final String? content;

  /// Password for the key (if encrypted)
  final String? password;

  /// Salt used for encryption
  final String? salt;

  /// Algorithm type (1=rsa, 2=dsa, 3=ecdsa, 4=ed25519)
  final int? algorithm;

  /// Creation timestamp
  final DateTime? createdAt;
  const SshKey(
      {required this.id,
      this.name,
      this.content,
      this.password,
      this.salt,
      this.algorithm,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || name != null) {
      map['name'] = Variable<String>(name);
    }
    if (!nullToAbsent || content != null) {
      map['content'] = Variable<String>(content);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<String>(salt);
    }
    if (!nullToAbsent || algorithm != null) {
      map['algorithm'] = Variable<int>(algorithm);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  SshKeysCompanion toCompanion(bool nullToAbsent) {
    return SshKeysCompanion(
      id: Value(id),
      name: name == null && nullToAbsent ? const Value.absent() : Value(name),
      content: content == null && nullToAbsent
          ? const Value.absent()
          : Value(content),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      algorithm: algorithm == null && nullToAbsent
          ? const Value.absent()
          : Value(algorithm),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory SshKey.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshKey(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String?>(json['name']),
      content: serializer.fromJson<String?>(json['content']),
      password: serializer.fromJson<String?>(json['password']),
      salt: serializer.fromJson<String?>(json['salt']),
      algorithm: serializer.fromJson<int?>(json['algorithm']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String?>(name),
      'content': serializer.toJson<String?>(content),
      'password': serializer.toJson<String?>(password),
      'salt': serializer.toJson<String?>(salt),
      'algorithm': serializer.toJson<int?>(algorithm),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  SshKey copyWith(
          {int? id,
          Value<String?> name = const Value.absent(),
          Value<String?> content = const Value.absent(),
          Value<String?> password = const Value.absent(),
          Value<String?> salt = const Value.absent(),
          Value<int?> algorithm = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      SshKey(
        id: id ?? this.id,
        name: name.present ? name.value : this.name,
        content: content.present ? content.value : this.content,
        password: password.present ? password.value : this.password,
        salt: salt.present ? salt.value : this.salt,
        algorithm: algorithm.present ? algorithm.value : this.algorithm,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  SshKey copyWithCompanion(SshKeysCompanion data) {
    return SshKey(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      content: data.content.present ? data.content.value : this.content,
      password: data.password.present ? data.password.value : this.password,
      salt: data.salt.present ? data.salt.value : this.salt,
      algorithm: data.algorithm.present ? data.algorithm.value : this.algorithm,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshKey(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('password: $password, ')
          ..write('salt: $salt, ')
          ..write('algorithm: $algorithm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode =>
      Object.hash(id, name, content, password, salt, algorithm, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshKey &&
          other.id == this.id &&
          other.name == this.name &&
          other.content == this.content &&
          other.password == this.password &&
          other.salt == this.salt &&
          other.algorithm == this.algorithm &&
          other.createdAt == this.createdAt);
}

class SshKeysCompanion extends UpdateCompanion<SshKey> {
  final Value<int> id;
  final Value<String?> name;
  final Value<String?> content;
  final Value<String?> password;
  final Value<String?> salt;
  final Value<int?> algorithm;
  final Value<DateTime?> createdAt;
  const SshKeysCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.password = const Value.absent(),
    this.salt = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SshKeysCompanion.insert({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.content = const Value.absent(),
    this.password = const Value.absent(),
    this.salt = const Value.absent(),
    this.algorithm = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<SshKey> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<String>? content,
    Expression<String>? password,
    Expression<String>? salt,
    Expression<int>? algorithm,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (content != null) 'content': content,
      if (password != null) 'password': password,
      if (salt != null) 'salt': salt,
      if (algorithm != null) 'algorithm': algorithm,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SshKeysCompanion copyWith(
      {Value<int>? id,
      Value<String?>? name,
      Value<String?>? content,
      Value<String?>? password,
      Value<String?>? salt,
      Value<int?>? algorithm,
      Value<DateTime?>? createdAt}) {
    return SshKeysCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      content: content ?? this.content,
      password: password ?? this.password,
      salt: salt ?? this.salt,
      algorithm: algorithm ?? this.algorithm,
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
    if (content.present) {
      map['content'] = Variable<String>(content.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (algorithm.present) {
      map['algorithm'] = Variable<int>(algorithm.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshKeysCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('content: $content, ')
          ..write('password: $password, ')
          ..write('salt: $salt, ')
          ..write('algorithm: $algorithm, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $SshHostsTable extends SshHosts with TableInfo<$SshHostsTable, SshHost> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $SshHostsTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _hostMeta = const VerificationMeta('host');
  @override
  late final GeneratedColumn<String> host = GeneratedColumn<String>(
      'host', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _hostnameMeta =
      const VerificationMeta('hostname');
  @override
  late final GeneratedColumn<String> hostname = GeneratedColumn<String>(
      'hostname', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _portMeta = const VerificationMeta('port');
  @override
  late final GeneratedColumn<int> port = GeneratedColumn<int>(
      'port', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _usernameMeta =
      const VerificationMeta('username');
  @override
  late final GeneratedColumn<String> username = GeneratedColumn<String>(
      'username', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _passwordMeta =
      const VerificationMeta('password');
  @override
  late final GeneratedColumn<String> password = GeneratedColumn<String>(
      'password', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _saltMeta = const VerificationMeta('salt');
  @override
  late final GeneratedColumn<String> salt = GeneratedColumn<String>(
      'salt', aliasedName, true,
      type: DriftSqlType.string, requiredDuringInsert: false);
  static const VerificationMeta _identityKeyIdMeta =
      const VerificationMeta('identityKeyId');
  @override
  late final GeneratedColumn<int> identityKeyId = GeneratedColumn<int>(
      'identity_key_id', aliasedName, true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('REFERENCES ssh_keys (id)'));
  static const VerificationMeta _identityTypeMeta =
      const VerificationMeta('identityType');
  @override
  late final GeneratedColumn<int> identityType = GeneratedColumn<int>(
      'identity_type', aliasedName, true,
      type: DriftSqlType.int, requiredDuringInsert: false);
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        host,
        hostname,
        port,
        username,
        password,
        salt,
        identityKeyId,
        identityType,
        createdAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'ssh_hosts';
  @override
  VerificationContext validateIntegrity(Insertable<SshHost> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('host')) {
      context.handle(
          _hostMeta, host.isAcceptableOrUnknown(data['host']!, _hostMeta));
    }
    if (data.containsKey('hostname')) {
      context.handle(_hostnameMeta,
          hostname.isAcceptableOrUnknown(data['hostname']!, _hostnameMeta));
    }
    if (data.containsKey('port')) {
      context.handle(
          _portMeta, port.isAcceptableOrUnknown(data['port']!, _portMeta));
    }
    if (data.containsKey('username')) {
      context.handle(_usernameMeta,
          username.isAcceptableOrUnknown(data['username']!, _usernameMeta));
    }
    if (data.containsKey('password')) {
      context.handle(_passwordMeta,
          password.isAcceptableOrUnknown(data['password']!, _passwordMeta));
    }
    if (data.containsKey('salt')) {
      context.handle(
          _saltMeta, salt.isAcceptableOrUnknown(data['salt']!, _saltMeta));
    }
    if (data.containsKey('identity_key_id')) {
      context.handle(
          _identityKeyIdMeta,
          identityKeyId.isAcceptableOrUnknown(
              data['identity_key_id']!, _identityKeyIdMeta));
    }
    if (data.containsKey('identity_type')) {
      context.handle(
          _identityTypeMeta,
          identityType.isAcceptableOrUnknown(
              data['identity_type']!, _identityTypeMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  SshHost map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return SshHost(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      host: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}host']),
      hostname: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}hostname']),
      port: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}port']),
      username: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}username']),
      password: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}password']),
      salt: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}salt']),
      identityKeyId: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}identity_key_id']),
      identityType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}identity_type']),
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
    );
  }

  @override
  $SshHostsTable createAlias(String alias) {
    return $SshHostsTable(attachedDatabase, alias);
  }
}

class SshHost extends DataClass implements Insertable<SshHost> {
  /// Primary key - auto increment
  final int id;

  /// Display name for the host
  final String? host;

  /// IP address or domain name
  final String? hostname;

  /// SSH port (default: 22)
  final int? port;

  /// Username for authentication
  final String? username;

  /// Encrypted password
  final String? password;

  /// Salt used for password encryption
  final String? salt;

  /// Foreign key reference to SshKeys table
  final int? identityKeyId;

  /// Identity type (1=password, 2=key)
  final int? identityType;

  /// Creation timestamp
  final DateTime? createdAt;
  const SshHost(
      {required this.id,
      this.host,
      this.hostname,
      this.port,
      this.username,
      this.password,
      this.salt,
      this.identityKeyId,
      this.identityType,
      this.createdAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    if (!nullToAbsent || host != null) {
      map['host'] = Variable<String>(host);
    }
    if (!nullToAbsent || hostname != null) {
      map['hostname'] = Variable<String>(hostname);
    }
    if (!nullToAbsent || port != null) {
      map['port'] = Variable<int>(port);
    }
    if (!nullToAbsent || username != null) {
      map['username'] = Variable<String>(username);
    }
    if (!nullToAbsent || password != null) {
      map['password'] = Variable<String>(password);
    }
    if (!nullToAbsent || salt != null) {
      map['salt'] = Variable<String>(salt);
    }
    if (!nullToAbsent || identityKeyId != null) {
      map['identity_key_id'] = Variable<int>(identityKeyId);
    }
    if (!nullToAbsent || identityType != null) {
      map['identity_type'] = Variable<int>(identityType);
    }
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    return map;
  }

  SshHostsCompanion toCompanion(bool nullToAbsent) {
    return SshHostsCompanion(
      id: Value(id),
      host: host == null && nullToAbsent ? const Value.absent() : Value(host),
      hostname: hostname == null && nullToAbsent
          ? const Value.absent()
          : Value(hostname),
      port: port == null && nullToAbsent ? const Value.absent() : Value(port),
      username: username == null && nullToAbsent
          ? const Value.absent()
          : Value(username),
      password: password == null && nullToAbsent
          ? const Value.absent()
          : Value(password),
      salt: salt == null && nullToAbsent ? const Value.absent() : Value(salt),
      identityKeyId: identityKeyId == null && nullToAbsent
          ? const Value.absent()
          : Value(identityKeyId),
      identityType: identityType == null && nullToAbsent
          ? const Value.absent()
          : Value(identityType),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
    );
  }

  factory SshHost.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return SshHost(
      id: serializer.fromJson<int>(json['id']),
      host: serializer.fromJson<String?>(json['host']),
      hostname: serializer.fromJson<String?>(json['hostname']),
      port: serializer.fromJson<int?>(json['port']),
      username: serializer.fromJson<String?>(json['username']),
      password: serializer.fromJson<String?>(json['password']),
      salt: serializer.fromJson<String?>(json['salt']),
      identityKeyId: serializer.fromJson<int?>(json['identityKeyId']),
      identityType: serializer.fromJson<int?>(json['identityType']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'host': serializer.toJson<String?>(host),
      'hostname': serializer.toJson<String?>(hostname),
      'port': serializer.toJson<int?>(port),
      'username': serializer.toJson<String?>(username),
      'password': serializer.toJson<String?>(password),
      'salt': serializer.toJson<String?>(salt),
      'identityKeyId': serializer.toJson<int?>(identityKeyId),
      'identityType': serializer.toJson<int?>(identityType),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
    };
  }

  SshHost copyWith(
          {int? id,
          Value<String?> host = const Value.absent(),
          Value<String?> hostname = const Value.absent(),
          Value<int?> port = const Value.absent(),
          Value<String?> username = const Value.absent(),
          Value<String?> password = const Value.absent(),
          Value<String?> salt = const Value.absent(),
          Value<int?> identityKeyId = const Value.absent(),
          Value<int?> identityType = const Value.absent(),
          Value<DateTime?> createdAt = const Value.absent()}) =>
      SshHost(
        id: id ?? this.id,
        host: host.present ? host.value : this.host,
        hostname: hostname.present ? hostname.value : this.hostname,
        port: port.present ? port.value : this.port,
        username: username.present ? username.value : this.username,
        password: password.present ? password.value : this.password,
        salt: salt.present ? salt.value : this.salt,
        identityKeyId:
            identityKeyId.present ? identityKeyId.value : this.identityKeyId,
        identityType:
            identityType.present ? identityType.value : this.identityType,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
      );
  SshHost copyWithCompanion(SshHostsCompanion data) {
    return SshHost(
      id: data.id.present ? data.id.value : this.id,
      host: data.host.present ? data.host.value : this.host,
      hostname: data.hostname.present ? data.hostname.value : this.hostname,
      port: data.port.present ? data.port.value : this.port,
      username: data.username.present ? data.username.value : this.username,
      password: data.password.present ? data.password.value : this.password,
      salt: data.salt.present ? data.salt.value : this.salt,
      identityKeyId: data.identityKeyId.present
          ? data.identityKeyId.value
          : this.identityKeyId,
      identityType: data.identityType.present
          ? data.identityType.value
          : this.identityType,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('SshHost(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('salt: $salt, ')
          ..write('identityKeyId: $identityKeyId, ')
          ..write('identityType: $identityType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(id, host, hostname, port, username, password,
      salt, identityKeyId, identityType, createdAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is SshHost &&
          other.id == this.id &&
          other.host == this.host &&
          other.hostname == this.hostname &&
          other.port == this.port &&
          other.username == this.username &&
          other.password == this.password &&
          other.salt == this.salt &&
          other.identityKeyId == this.identityKeyId &&
          other.identityType == this.identityType &&
          other.createdAt == this.createdAt);
}

class SshHostsCompanion extends UpdateCompanion<SshHost> {
  final Value<int> id;
  final Value<String?> host;
  final Value<String?> hostname;
  final Value<int?> port;
  final Value<String?> username;
  final Value<String?> password;
  final Value<String?> salt;
  final Value<int?> identityKeyId;
  final Value<int?> identityType;
  final Value<DateTime?> createdAt;
  const SshHostsCompanion({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.hostname = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.salt = const Value.absent(),
    this.identityKeyId = const Value.absent(),
    this.identityType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  SshHostsCompanion.insert({
    this.id = const Value.absent(),
    this.host = const Value.absent(),
    this.hostname = const Value.absent(),
    this.port = const Value.absent(),
    this.username = const Value.absent(),
    this.password = const Value.absent(),
    this.salt = const Value.absent(),
    this.identityKeyId = const Value.absent(),
    this.identityType = const Value.absent(),
    this.createdAt = const Value.absent(),
  });
  static Insertable<SshHost> custom({
    Expression<int>? id,
    Expression<String>? host,
    Expression<String>? hostname,
    Expression<int>? port,
    Expression<String>? username,
    Expression<String>? password,
    Expression<String>? salt,
    Expression<int>? identityKeyId,
    Expression<int>? identityType,
    Expression<DateTime>? createdAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (host != null) 'host': host,
      if (hostname != null) 'hostname': hostname,
      if (port != null) 'port': port,
      if (username != null) 'username': username,
      if (password != null) 'password': password,
      if (salt != null) 'salt': salt,
      if (identityKeyId != null) 'identity_key_id': identityKeyId,
      if (identityType != null) 'identity_type': identityType,
      if (createdAt != null) 'created_at': createdAt,
    });
  }

  SshHostsCompanion copyWith(
      {Value<int>? id,
      Value<String?>? host,
      Value<String?>? hostname,
      Value<int?>? port,
      Value<String?>? username,
      Value<String?>? password,
      Value<String?>? salt,
      Value<int?>? identityKeyId,
      Value<int?>? identityType,
      Value<DateTime?>? createdAt}) {
    return SshHostsCompanion(
      id: id ?? this.id,
      host: host ?? this.host,
      hostname: hostname ?? this.hostname,
      port: port ?? this.port,
      username: username ?? this.username,
      password: password ?? this.password,
      salt: salt ?? this.salt,
      identityKeyId: identityKeyId ?? this.identityKeyId,
      identityType: identityType ?? this.identityType,
      createdAt: createdAt ?? this.createdAt,
    );
  }

  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    if (id.present) {
      map['id'] = Variable<int>(id.value);
    }
    if (host.present) {
      map['host'] = Variable<String>(host.value);
    }
    if (hostname.present) {
      map['hostname'] = Variable<String>(hostname.value);
    }
    if (port.present) {
      map['port'] = Variable<int>(port.value);
    }
    if (username.present) {
      map['username'] = Variable<String>(username.value);
    }
    if (password.present) {
      map['password'] = Variable<String>(password.value);
    }
    if (salt.present) {
      map['salt'] = Variable<String>(salt.value);
    }
    if (identityKeyId.present) {
      map['identity_key_id'] = Variable<int>(identityKeyId.value);
    }
    if (identityType.present) {
      map['identity_type'] = Variable<int>(identityType.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('SshHostsCompanion(')
          ..write('id: $id, ')
          ..write('host: $host, ')
          ..write('hostname: $hostname, ')
          ..write('port: $port, ')
          ..write('username: $username, ')
          ..write('password: $password, ')
          ..write('salt: $salt, ')
          ..write('identityKeyId: $identityKeyId, ')
          ..write('identityType: $identityType, ')
          ..write('createdAt: $createdAt')
          ..write(')'))
        .toString();
  }
}

class $ShellProfilesTable extends ShellProfiles
    with TableInfo<$ShellProfilesTable, ShellProfile> {
  @override
  final GeneratedDatabase attachedDatabase;
  final String? _alias;
  $ShellProfilesTable(this.attachedDatabase, [this._alias]);
  static const VerificationMeta _idMeta = const VerificationMeta('id');
  @override
  late final GeneratedColumn<int> id = GeneratedColumn<int>(
      'id', aliasedName, false,
      hasAutoIncrement: true,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('PRIMARY KEY AUTOINCREMENT'));
  static const VerificationMeta _nameMeta = const VerificationMeta('name');
  @override
  late final GeneratedColumn<String> name = GeneratedColumn<String>(
      'name', aliasedName, false,
      type: DriftSqlType.string, requiredDuringInsert: true);
  static const VerificationMeta _shellTypeMeta =
      const VerificationMeta('shellType');
  @override
  late final GeneratedColumn<int> shellType = GeneratedColumn<int>(
      'shell_type', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(1));
  static const VerificationMeta _environmentVariablesMeta =
      const VerificationMeta('environmentVariables');
  @override
  late final GeneratedColumn<String> environmentVariables =
      GeneratedColumn<String>('environment_variables', aliasedName, false,
          type: DriftSqlType.string,
          requiredDuringInsert: false,
          defaultValue: const Constant('{}'));
  static const VerificationMeta _aliasesMeta =
      const VerificationMeta('aliases');
  @override
  late final GeneratedColumn<String> aliases = GeneratedColumn<String>(
      'aliases', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('{}'));
  static const VerificationMeta _fontFamilyMeta =
      const VerificationMeta('fontFamily');
  @override
  late final GeneratedColumn<String> fontFamily = GeneratedColumn<String>(
      'font_family', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('monospace'));
  static const VerificationMeta _fontSizeMeta =
      const VerificationMeta('fontSize');
  @override
  late final GeneratedColumn<double> fontSize = GeneratedColumn<double>(
      'font_size', aliasedName, false,
      type: DriftSqlType.double,
      requiredDuringInsert: false,
      defaultValue: const Constant(14.0));
  static const VerificationMeta _colorThemeMeta =
      const VerificationMeta('colorTheme');
  @override
  late final GeneratedColumn<String> colorTheme = GeneratedColumn<String>(
      'color_theme', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant('default'));
  static const VerificationMeta _workingDirectoryMeta =
      const VerificationMeta('workingDirectory');
  @override
  late final GeneratedColumn<String> workingDirectory = GeneratedColumn<String>(
      'working_directory', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _startupCommandMeta =
      const VerificationMeta('startupCommand');
  @override
  late final GeneratedColumn<String> startupCommand = GeneratedColumn<String>(
      'startup_command', aliasedName, false,
      type: DriftSqlType.string,
      requiredDuringInsert: false,
      defaultValue: const Constant(''));
  static const VerificationMeta _cursorStyleMeta =
      const VerificationMeta('cursorStyle');
  @override
  late final GeneratedColumn<int> cursorStyle = GeneratedColumn<int>(
      'cursor_style', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(0));
  static const VerificationMeta _scrollbackLinesMeta =
      const VerificationMeta('scrollbackLines');
  @override
  late final GeneratedColumn<int> scrollbackLines = GeneratedColumn<int>(
      'scrollback_lines', aliasedName, false,
      type: DriftSqlType.int,
      requiredDuringInsert: false,
      defaultValue: const Constant(10000));
  static const VerificationMeta _isDefaultMeta =
      const VerificationMeta('isDefault');
  @override
  late final GeneratedColumn<bool> isDefault = GeneratedColumn<bool>(
      'is_default', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints:
          GeneratedColumn.constraintIsAlways('CHECK ("is_default" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _inheritCurrentStateMeta =
      const VerificationMeta('inheritCurrentState');
  @override
  late final GeneratedColumn<bool> inheritCurrentState = GeneratedColumn<bool>(
      'inherit_current_state', aliasedName, false,
      type: DriftSqlType.bool,
      requiredDuringInsert: false,
      defaultConstraints: GeneratedColumn.constraintIsAlways(
          'CHECK ("inherit_current_state" IN (0, 1))'),
      defaultValue: const Constant(false));
  static const VerificationMeta _createdAtMeta =
      const VerificationMeta('createdAt');
  @override
  late final GeneratedColumn<DateTime> createdAt = GeneratedColumn<DateTime>(
      'created_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  static const VerificationMeta _updatedAtMeta =
      const VerificationMeta('updatedAt');
  @override
  late final GeneratedColumn<DateTime> updatedAt = GeneratedColumn<DateTime>(
      'updated_at', aliasedName, true,
      type: DriftSqlType.dateTime, requiredDuringInsert: false);
  @override
  List<GeneratedColumn> get $columns => [
        id,
        name,
        shellType,
        environmentVariables,
        aliases,
        fontFamily,
        fontSize,
        colorTheme,
        workingDirectory,
        startupCommand,
        cursorStyle,
        scrollbackLines,
        isDefault,
        inheritCurrentState,
        createdAt,
        updatedAt
      ];
  @override
  String get aliasedName => _alias ?? actualTableName;
  @override
  String get actualTableName => $name;
  static const String $name = 'shell_profiles';
  @override
  VerificationContext validateIntegrity(Insertable<ShellProfile> instance,
      {bool isInserting = false}) {
    final context = VerificationContext();
    final data = instance.toColumns(true);
    if (data.containsKey('id')) {
      context.handle(_idMeta, id.isAcceptableOrUnknown(data['id']!, _idMeta));
    }
    if (data.containsKey('name')) {
      context.handle(
          _nameMeta, name.isAcceptableOrUnknown(data['name']!, _nameMeta));
    } else if (isInserting) {
      context.missing(_nameMeta);
    }
    if (data.containsKey('shell_type')) {
      context.handle(_shellTypeMeta,
          shellType.isAcceptableOrUnknown(data['shell_type']!, _shellTypeMeta));
    }
    if (data.containsKey('environment_variables')) {
      context.handle(
          _environmentVariablesMeta,
          environmentVariables.isAcceptableOrUnknown(
              data['environment_variables']!, _environmentVariablesMeta));
    }
    if (data.containsKey('aliases')) {
      context.handle(_aliasesMeta,
          aliases.isAcceptableOrUnknown(data['aliases']!, _aliasesMeta));
    }
    if (data.containsKey('font_family')) {
      context.handle(
          _fontFamilyMeta,
          fontFamily.isAcceptableOrUnknown(
              data['font_family']!, _fontFamilyMeta));
    }
    if (data.containsKey('font_size')) {
      context.handle(_fontSizeMeta,
          fontSize.isAcceptableOrUnknown(data['font_size']!, _fontSizeMeta));
    }
    if (data.containsKey('color_theme')) {
      context.handle(
          _colorThemeMeta,
          colorTheme.isAcceptableOrUnknown(
              data['color_theme']!, _colorThemeMeta));
    }
    if (data.containsKey('working_directory')) {
      context.handle(
          _workingDirectoryMeta,
          workingDirectory.isAcceptableOrUnknown(
              data['working_directory']!, _workingDirectoryMeta));
    }
    if (data.containsKey('startup_command')) {
      context.handle(
          _startupCommandMeta,
          startupCommand.isAcceptableOrUnknown(
              data['startup_command']!, _startupCommandMeta));
    }
    if (data.containsKey('cursor_style')) {
      context.handle(
          _cursorStyleMeta,
          cursorStyle.isAcceptableOrUnknown(
              data['cursor_style']!, _cursorStyleMeta));
    }
    if (data.containsKey('scrollback_lines')) {
      context.handle(
          _scrollbackLinesMeta,
          scrollbackLines.isAcceptableOrUnknown(
              data['scrollback_lines']!, _scrollbackLinesMeta));
    }
    if (data.containsKey('is_default')) {
      context.handle(_isDefaultMeta,
          isDefault.isAcceptableOrUnknown(data['is_default']!, _isDefaultMeta));
    }
    if (data.containsKey('inherit_current_state')) {
      context.handle(
          _inheritCurrentStateMeta,
          inheritCurrentState.isAcceptableOrUnknown(
              data['inherit_current_state']!, _inheritCurrentStateMeta));
    }
    if (data.containsKey('created_at')) {
      context.handle(_createdAtMeta,
          createdAt.isAcceptableOrUnknown(data['created_at']!, _createdAtMeta));
    }
    if (data.containsKey('updated_at')) {
      context.handle(_updatedAtMeta,
          updatedAt.isAcceptableOrUnknown(data['updated_at']!, _updatedAtMeta));
    }
    return context;
  }

  @override
  Set<GeneratedColumn> get $primaryKey => {id};
  @override
  ShellProfile map(Map<String, dynamic> data, {String? tablePrefix}) {
    final effectivePrefix = tablePrefix != null ? '$tablePrefix.' : '';
    return ShellProfile(
      id: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}id'])!,
      name: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}name'])!,
      shellType: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}shell_type'])!,
      environmentVariables: attachedDatabase.typeMapping.read(
          DriftSqlType.string,
          data['${effectivePrefix}environment_variables'])!,
      aliases: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}aliases'])!,
      fontFamily: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}font_family'])!,
      fontSize: attachedDatabase.typeMapping
          .read(DriftSqlType.double, data['${effectivePrefix}font_size'])!,
      colorTheme: attachedDatabase.typeMapping
          .read(DriftSqlType.string, data['${effectivePrefix}color_theme'])!,
      workingDirectory: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}working_directory'])!,
      startupCommand: attachedDatabase.typeMapping.read(
          DriftSqlType.string, data['${effectivePrefix}startup_command'])!,
      cursorStyle: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}cursor_style'])!,
      scrollbackLines: attachedDatabase.typeMapping
          .read(DriftSqlType.int, data['${effectivePrefix}scrollback_lines'])!,
      isDefault: attachedDatabase.typeMapping
          .read(DriftSqlType.bool, data['${effectivePrefix}is_default'])!,
      inheritCurrentState: attachedDatabase.typeMapping.read(
          DriftSqlType.bool, data['${effectivePrefix}inherit_current_state'])!,
      createdAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}created_at']),
      updatedAt: attachedDatabase.typeMapping
          .read(DriftSqlType.dateTime, data['${effectivePrefix}updated_at']),
    );
  }

  @override
  $ShellProfilesTable createAlias(String alias) {
    return $ShellProfilesTable(attachedDatabase, alias);
  }
}

class ShellProfile extends DataClass implements Insertable<ShellProfile> {
  /// Primary key - auto increment
  final int id;

  /// Display name for the profile
  final String name;

  /// Shell type (1=sh, 2=bash, 3=zsh, 4=fish)
  final int shellType;

  /// Environment variables as JSON string (key-value pairs)
  /// Example: {"TERM": "xterm-256color", "LANG": "en_US.UTF-8"}
  final String environmentVariables;

  /// Alias definitions as JSON string (name-command pairs)
  /// Example: {"ll": "ls -la", "gs": "git status"}
  final String aliases;

  /// Font family for terminal display
  final String fontFamily;

  /// Font size for terminal display (in logical pixels)
  final double fontSize;

  /// Color theme name (references terminal theme)
  final String colorTheme;

  /// Working directory to start the shell in (empty = system default)
  final String workingDirectory;

  /// Command to run automatically when the shell opens (e.g., tmux)
  final String startupCommand;

  /// Cursor style (0=block, 1=underline, 2=verticalBar)
  final int cursorStyle;

  /// Number of lines to keep in scroll history
  final int scrollbackLines;

  /// Whether this is the default profile for new sessions
  final bool isDefault;

  /// Whether new shells from this profile inherit state from the active tab.
  final bool inheritCurrentState;

  /// Creation timestamp
  final DateTime? createdAt;

  /// Last update timestamp
  final DateTime? updatedAt;
  const ShellProfile(
      {required this.id,
      required this.name,
      required this.shellType,
      required this.environmentVariables,
      required this.aliases,
      required this.fontFamily,
      required this.fontSize,
      required this.colorTheme,
      required this.workingDirectory,
      required this.startupCommand,
      required this.cursorStyle,
      required this.scrollbackLines,
      required this.isDefault,
      required this.inheritCurrentState,
      this.createdAt,
      this.updatedAt});
  @override
  Map<String, Expression> toColumns(bool nullToAbsent) {
    final map = <String, Expression>{};
    map['id'] = Variable<int>(id);
    map['name'] = Variable<String>(name);
    map['shell_type'] = Variable<int>(shellType);
    map['environment_variables'] = Variable<String>(environmentVariables);
    map['aliases'] = Variable<String>(aliases);
    map['font_family'] = Variable<String>(fontFamily);
    map['font_size'] = Variable<double>(fontSize);
    map['color_theme'] = Variable<String>(colorTheme);
    map['working_directory'] = Variable<String>(workingDirectory);
    map['startup_command'] = Variable<String>(startupCommand);
    map['cursor_style'] = Variable<int>(cursorStyle);
    map['scrollback_lines'] = Variable<int>(scrollbackLines);
    map['is_default'] = Variable<bool>(isDefault);
    map['inherit_current_state'] = Variable<bool>(inheritCurrentState);
    if (!nullToAbsent || createdAt != null) {
      map['created_at'] = Variable<DateTime>(createdAt);
    }
    if (!nullToAbsent || updatedAt != null) {
      map['updated_at'] = Variable<DateTime>(updatedAt);
    }
    return map;
  }

  ShellProfilesCompanion toCompanion(bool nullToAbsent) {
    return ShellProfilesCompanion(
      id: Value(id),
      name: Value(name),
      shellType: Value(shellType),
      environmentVariables: Value(environmentVariables),
      aliases: Value(aliases),
      fontFamily: Value(fontFamily),
      fontSize: Value(fontSize),
      colorTheme: Value(colorTheme),
      workingDirectory: Value(workingDirectory),
      startupCommand: Value(startupCommand),
      cursorStyle: Value(cursorStyle),
      scrollbackLines: Value(scrollbackLines),
      isDefault: Value(isDefault),
      inheritCurrentState: Value(inheritCurrentState),
      createdAt: createdAt == null && nullToAbsent
          ? const Value.absent()
          : Value(createdAt),
      updatedAt: updatedAt == null && nullToAbsent
          ? const Value.absent()
          : Value(updatedAt),
    );
  }

  factory ShellProfile.fromJson(Map<String, dynamic> json,
      {ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return ShellProfile(
      id: serializer.fromJson<int>(json['id']),
      name: serializer.fromJson<String>(json['name']),
      shellType: serializer.fromJson<int>(json['shellType']),
      environmentVariables:
          serializer.fromJson<String>(json['environmentVariables']),
      aliases: serializer.fromJson<String>(json['aliases']),
      fontFamily: serializer.fromJson<String>(json['fontFamily']),
      fontSize: serializer.fromJson<double>(json['fontSize']),
      colorTheme: serializer.fromJson<String>(json['colorTheme']),
      workingDirectory: serializer.fromJson<String>(json['workingDirectory']),
      startupCommand: serializer.fromJson<String>(json['startupCommand']),
      cursorStyle: serializer.fromJson<int>(json['cursorStyle']),
      scrollbackLines: serializer.fromJson<int>(json['scrollbackLines']),
      isDefault: serializer.fromJson<bool>(json['isDefault']),
      inheritCurrentState:
          serializer.fromJson<bool>(json['inheritCurrentState']),
      createdAt: serializer.fromJson<DateTime?>(json['createdAt']),
      updatedAt: serializer.fromJson<DateTime?>(json['updatedAt']),
    );
  }
  @override
  Map<String, dynamic> toJson({ValueSerializer? serializer}) {
    serializer ??= driftRuntimeOptions.defaultSerializer;
    return <String, dynamic>{
      'id': serializer.toJson<int>(id),
      'name': serializer.toJson<String>(name),
      'shellType': serializer.toJson<int>(shellType),
      'environmentVariables': serializer.toJson<String>(environmentVariables),
      'aliases': serializer.toJson<String>(aliases),
      'fontFamily': serializer.toJson<String>(fontFamily),
      'fontSize': serializer.toJson<double>(fontSize),
      'colorTheme': serializer.toJson<String>(colorTheme),
      'workingDirectory': serializer.toJson<String>(workingDirectory),
      'startupCommand': serializer.toJson<String>(startupCommand),
      'cursorStyle': serializer.toJson<int>(cursorStyle),
      'scrollbackLines': serializer.toJson<int>(scrollbackLines),
      'isDefault': serializer.toJson<bool>(isDefault),
      'inheritCurrentState': serializer.toJson<bool>(inheritCurrentState),
      'createdAt': serializer.toJson<DateTime?>(createdAt),
      'updatedAt': serializer.toJson<DateTime?>(updatedAt),
    };
  }

  ShellProfile copyWith(
          {int? id,
          String? name,
          int? shellType,
          String? environmentVariables,
          String? aliases,
          String? fontFamily,
          double? fontSize,
          String? colorTheme,
          String? workingDirectory,
          String? startupCommand,
          int? cursorStyle,
          int? scrollbackLines,
          bool? isDefault,
          bool? inheritCurrentState,
          Value<DateTime?> createdAt = const Value.absent(),
          Value<DateTime?> updatedAt = const Value.absent()}) =>
      ShellProfile(
        id: id ?? this.id,
        name: name ?? this.name,
        shellType: shellType ?? this.shellType,
        environmentVariables: environmentVariables ?? this.environmentVariables,
        aliases: aliases ?? this.aliases,
        fontFamily: fontFamily ?? this.fontFamily,
        fontSize: fontSize ?? this.fontSize,
        colorTheme: colorTheme ?? this.colorTheme,
        workingDirectory: workingDirectory ?? this.workingDirectory,
        startupCommand: startupCommand ?? this.startupCommand,
        cursorStyle: cursorStyle ?? this.cursorStyle,
        scrollbackLines: scrollbackLines ?? this.scrollbackLines,
        isDefault: isDefault ?? this.isDefault,
        inheritCurrentState: inheritCurrentState ?? this.inheritCurrentState,
        createdAt: createdAt.present ? createdAt.value : this.createdAt,
        updatedAt: updatedAt.present ? updatedAt.value : this.updatedAt,
      );
  ShellProfile copyWithCompanion(ShellProfilesCompanion data) {
    return ShellProfile(
      id: data.id.present ? data.id.value : this.id,
      name: data.name.present ? data.name.value : this.name,
      shellType: data.shellType.present ? data.shellType.value : this.shellType,
      environmentVariables: data.environmentVariables.present
          ? data.environmentVariables.value
          : this.environmentVariables,
      aliases: data.aliases.present ? data.aliases.value : this.aliases,
      fontFamily:
          data.fontFamily.present ? data.fontFamily.value : this.fontFamily,
      fontSize: data.fontSize.present ? data.fontSize.value : this.fontSize,
      colorTheme:
          data.colorTheme.present ? data.colorTheme.value : this.colorTheme,
      workingDirectory: data.workingDirectory.present
          ? data.workingDirectory.value
          : this.workingDirectory,
      startupCommand: data.startupCommand.present
          ? data.startupCommand.value
          : this.startupCommand,
      cursorStyle:
          data.cursorStyle.present ? data.cursorStyle.value : this.cursorStyle,
      scrollbackLines: data.scrollbackLines.present
          ? data.scrollbackLines.value
          : this.scrollbackLines,
      isDefault: data.isDefault.present ? data.isDefault.value : this.isDefault,
      inheritCurrentState: data.inheritCurrentState.present
          ? data.inheritCurrentState.value
          : this.inheritCurrentState,
      createdAt: data.createdAt.present ? data.createdAt.value : this.createdAt,
      updatedAt: data.updatedAt.present ? data.updatedAt.value : this.updatedAt,
    );
  }

  @override
  String toString() {
    return (StringBuffer('ShellProfile(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shellType: $shellType, ')
          ..write('environmentVariables: $environmentVariables, ')
          ..write('aliases: $aliases, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('fontSize: $fontSize, ')
          ..write('colorTheme: $colorTheme, ')
          ..write('workingDirectory: $workingDirectory, ')
          ..write('startupCommand: $startupCommand, ')
          ..write('cursorStyle: $cursorStyle, ')
          ..write('scrollbackLines: $scrollbackLines, ')
          ..write('isDefault: $isDefault, ')
          ..write('inheritCurrentState: $inheritCurrentState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }

  @override
  int get hashCode => Object.hash(
      id,
      name,
      shellType,
      environmentVariables,
      aliases,
      fontFamily,
      fontSize,
      colorTheme,
      workingDirectory,
      startupCommand,
      cursorStyle,
      scrollbackLines,
      isDefault,
      inheritCurrentState,
      createdAt,
      updatedAt);
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is ShellProfile &&
          other.id == this.id &&
          other.name == this.name &&
          other.shellType == this.shellType &&
          other.environmentVariables == this.environmentVariables &&
          other.aliases == this.aliases &&
          other.fontFamily == this.fontFamily &&
          other.fontSize == this.fontSize &&
          other.colorTheme == this.colorTheme &&
          other.workingDirectory == this.workingDirectory &&
          other.startupCommand == this.startupCommand &&
          other.cursorStyle == this.cursorStyle &&
          other.scrollbackLines == this.scrollbackLines &&
          other.isDefault == this.isDefault &&
          other.inheritCurrentState == this.inheritCurrentState &&
          other.createdAt == this.createdAt &&
          other.updatedAt == this.updatedAt);
}

class ShellProfilesCompanion extends UpdateCompanion<ShellProfile> {
  final Value<int> id;
  final Value<String> name;
  final Value<int> shellType;
  final Value<String> environmentVariables;
  final Value<String> aliases;
  final Value<String> fontFamily;
  final Value<double> fontSize;
  final Value<String> colorTheme;
  final Value<String> workingDirectory;
  final Value<String> startupCommand;
  final Value<int> cursorStyle;
  final Value<int> scrollbackLines;
  final Value<bool> isDefault;
  final Value<bool> inheritCurrentState;
  final Value<DateTime?> createdAt;
  final Value<DateTime?> updatedAt;
  const ShellProfilesCompanion({
    this.id = const Value.absent(),
    this.name = const Value.absent(),
    this.shellType = const Value.absent(),
    this.environmentVariables = const Value.absent(),
    this.aliases = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.colorTheme = const Value.absent(),
    this.workingDirectory = const Value.absent(),
    this.startupCommand = const Value.absent(),
    this.cursorStyle = const Value.absent(),
    this.scrollbackLines = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.inheritCurrentState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  });
  ShellProfilesCompanion.insert({
    this.id = const Value.absent(),
    required String name,
    this.shellType = const Value.absent(),
    this.environmentVariables = const Value.absent(),
    this.aliases = const Value.absent(),
    this.fontFamily = const Value.absent(),
    this.fontSize = const Value.absent(),
    this.colorTheme = const Value.absent(),
    this.workingDirectory = const Value.absent(),
    this.startupCommand = const Value.absent(),
    this.cursorStyle = const Value.absent(),
    this.scrollbackLines = const Value.absent(),
    this.isDefault = const Value.absent(),
    this.inheritCurrentState = const Value.absent(),
    this.createdAt = const Value.absent(),
    this.updatedAt = const Value.absent(),
  }) : name = Value(name);
  static Insertable<ShellProfile> custom({
    Expression<int>? id,
    Expression<String>? name,
    Expression<int>? shellType,
    Expression<String>? environmentVariables,
    Expression<String>? aliases,
    Expression<String>? fontFamily,
    Expression<double>? fontSize,
    Expression<String>? colorTheme,
    Expression<String>? workingDirectory,
    Expression<String>? startupCommand,
    Expression<int>? cursorStyle,
    Expression<int>? scrollbackLines,
    Expression<bool>? isDefault,
    Expression<bool>? inheritCurrentState,
    Expression<DateTime>? createdAt,
    Expression<DateTime>? updatedAt,
  }) {
    return RawValuesInsertable({
      if (id != null) 'id': id,
      if (name != null) 'name': name,
      if (shellType != null) 'shell_type': shellType,
      if (environmentVariables != null)
        'environment_variables': environmentVariables,
      if (aliases != null) 'aliases': aliases,
      if (fontFamily != null) 'font_family': fontFamily,
      if (fontSize != null) 'font_size': fontSize,
      if (colorTheme != null) 'color_theme': colorTheme,
      if (workingDirectory != null) 'working_directory': workingDirectory,
      if (startupCommand != null) 'startup_command': startupCommand,
      if (cursorStyle != null) 'cursor_style': cursorStyle,
      if (scrollbackLines != null) 'scrollback_lines': scrollbackLines,
      if (isDefault != null) 'is_default': isDefault,
      if (inheritCurrentState != null)
        'inherit_current_state': inheritCurrentState,
      if (createdAt != null) 'created_at': createdAt,
      if (updatedAt != null) 'updated_at': updatedAt,
    });
  }

  ShellProfilesCompanion copyWith(
      {Value<int>? id,
      Value<String>? name,
      Value<int>? shellType,
      Value<String>? environmentVariables,
      Value<String>? aliases,
      Value<String>? fontFamily,
      Value<double>? fontSize,
      Value<String>? colorTheme,
      Value<String>? workingDirectory,
      Value<String>? startupCommand,
      Value<int>? cursorStyle,
      Value<int>? scrollbackLines,
      Value<bool>? isDefault,
      Value<bool>? inheritCurrentState,
      Value<DateTime?>? createdAt,
      Value<DateTime?>? updatedAt}) {
    return ShellProfilesCompanion(
      id: id ?? this.id,
      name: name ?? this.name,
      shellType: shellType ?? this.shellType,
      environmentVariables: environmentVariables ?? this.environmentVariables,
      aliases: aliases ?? this.aliases,
      fontFamily: fontFamily ?? this.fontFamily,
      fontSize: fontSize ?? this.fontSize,
      colorTheme: colorTheme ?? this.colorTheme,
      workingDirectory: workingDirectory ?? this.workingDirectory,
      startupCommand: startupCommand ?? this.startupCommand,
      cursorStyle: cursorStyle ?? this.cursorStyle,
      scrollbackLines: scrollbackLines ?? this.scrollbackLines,
      isDefault: isDefault ?? this.isDefault,
      inheritCurrentState: inheritCurrentState ?? this.inheritCurrentState,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
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
    if (shellType.present) {
      map['shell_type'] = Variable<int>(shellType.value);
    }
    if (environmentVariables.present) {
      map['environment_variables'] =
          Variable<String>(environmentVariables.value);
    }
    if (aliases.present) {
      map['aliases'] = Variable<String>(aliases.value);
    }
    if (fontFamily.present) {
      map['font_family'] = Variable<String>(fontFamily.value);
    }
    if (fontSize.present) {
      map['font_size'] = Variable<double>(fontSize.value);
    }
    if (colorTheme.present) {
      map['color_theme'] = Variable<String>(colorTheme.value);
    }
    if (workingDirectory.present) {
      map['working_directory'] = Variable<String>(workingDirectory.value);
    }
    if (startupCommand.present) {
      map['startup_command'] = Variable<String>(startupCommand.value);
    }
    if (cursorStyle.present) {
      map['cursor_style'] = Variable<int>(cursorStyle.value);
    }
    if (scrollbackLines.present) {
      map['scrollback_lines'] = Variable<int>(scrollbackLines.value);
    }
    if (isDefault.present) {
      map['is_default'] = Variable<bool>(isDefault.value);
    }
    if (inheritCurrentState.present) {
      map['inherit_current_state'] = Variable<bool>(inheritCurrentState.value);
    }
    if (createdAt.present) {
      map['created_at'] = Variable<DateTime>(createdAt.value);
    }
    if (updatedAt.present) {
      map['updated_at'] = Variable<DateTime>(updatedAt.value);
    }
    return map;
  }

  @override
  String toString() {
    return (StringBuffer('ShellProfilesCompanion(')
          ..write('id: $id, ')
          ..write('name: $name, ')
          ..write('shellType: $shellType, ')
          ..write('environmentVariables: $environmentVariables, ')
          ..write('aliases: $aliases, ')
          ..write('fontFamily: $fontFamily, ')
          ..write('fontSize: $fontSize, ')
          ..write('colorTheme: $colorTheme, ')
          ..write('workingDirectory: $workingDirectory, ')
          ..write('startupCommand: $startupCommand, ')
          ..write('cursorStyle: $cursorStyle, ')
          ..write('scrollbackLines: $scrollbackLines, ')
          ..write('isDefault: $isDefault, ')
          ..write('inheritCurrentState: $inheritCurrentState, ')
          ..write('createdAt: $createdAt, ')
          ..write('updatedAt: $updatedAt')
          ..write(')'))
        .toString();
  }
}

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SshKeysTable sshKeys = $SshKeysTable(this);
  late final $SshHostsTable sshHosts = $SshHostsTable(this);
  late final $ShellProfilesTable shellProfiles = $ShellProfilesTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities =>
      [sshKeys, sshHosts, shellProfiles];
}

typedef $$SshKeysTableCreateCompanionBuilder = SshKeysCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> content,
  Value<String?> password,
  Value<String?> salt,
  Value<int?> algorithm,
  Value<DateTime?> createdAt,
});
typedef $$SshKeysTableUpdateCompanionBuilder = SshKeysCompanion Function({
  Value<int> id,
  Value<String?> name,
  Value<String?> content,
  Value<String?> password,
  Value<String?> salt,
  Value<int?> algorithm,
  Value<DateTime?> createdAt,
});

final class $$SshKeysTableReferences
    extends BaseReferences<_$AppDatabase, $SshKeysTable, SshKey> {
  $$SshKeysTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static MultiTypedResultKey<$SshHostsTable, List<SshHost>> _sshHostsRefsTable(
          _$AppDatabase db) =>
      MultiTypedResultKey.fromTable(db.sshHosts,
          aliasName:
              $_aliasNameGenerator(db.sshKeys.id, db.sshHosts.identityKeyId));

  $$SshHostsTableProcessedTableManager get sshHostsRefs {
    final manager = $$SshHostsTableTableManager($_db, $_db.sshHosts)
        .filter((f) => f.identityKeyId.id.sqlEquals($_itemColumn<int>('id')!));

    final cache = $_typedResult.readTableOrNull(_sshHostsRefsTable($_db));
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: cache));
  }
}

class $$SshKeysTableFilterComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  Expression<bool> sshHostsRefs(
      Expression<bool> Function($$SshHostsTableFilterComposer f) f) {
    final $$SshHostsTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sshHosts,
        getReferencedColumn: (t) => t.identityKeyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SshHostsTableFilterComposer(
              $db: $db,
              $table: $db.sshHosts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SshKeysTableOrderingComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get content => $composableBuilder(
      column: $table.content, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get algorithm => $composableBuilder(
      column: $table.algorithm, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));
}

class $$SshKeysTableAnnotationComposer
    extends Composer<_$AppDatabase, $SshKeysTable> {
  $$SshKeysTableAnnotationComposer({
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

  GeneratedColumn<String> get content =>
      $composableBuilder(column: $table.content, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<int> get algorithm =>
      $composableBuilder(column: $table.algorithm, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  Expression<T> sshHostsRefs<T extends Object>(
      Expression<T> Function($$SshHostsTableAnnotationComposer a) f) {
    final $$SshHostsTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.id,
        referencedTable: $db.sshHosts,
        getReferencedColumn: (t) => t.identityKeyId,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SshHostsTableAnnotationComposer(
              $db: $db,
              $table: $db.sshHosts,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return f(composer);
  }
}

class $$SshKeysTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SshKeysTable,
    SshKey,
    $$SshKeysTableFilterComposer,
    $$SshKeysTableOrderingComposer,
    $$SshKeysTableAnnotationComposer,
    $$SshKeysTableCreateCompanionBuilder,
    $$SshKeysTableUpdateCompanionBuilder,
    (SshKey, $$SshKeysTableReferences),
    SshKey,
    PrefetchHooks Function({bool sshHostsRefs})> {
  $$SshKeysTableTableManager(_$AppDatabase db, $SshKeysTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SshKeysTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SshKeysTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SshKeysTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<String?> salt = const Value.absent(),
            Value<int?> algorithm = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              SshKeysCompanion(
            id: id,
            name: name,
            content: content,
            password: password,
            salt: salt,
            algorithm: algorithm,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> name = const Value.absent(),
            Value<String?> content = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<String?> salt = const Value.absent(),
            Value<int?> algorithm = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              SshKeysCompanion.insert(
            id: id,
            name: name,
            content: content,
            password: password,
            salt: salt,
            algorithm: algorithm,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SshKeysTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({sshHostsRefs = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [if (sshHostsRefs) db.sshHosts],
              addJoins: null,
              getPrefetchedDataCallback: (items) async {
                return [
                  if (sshHostsRefs)
                    await $_getPrefetchedData<SshKey, $SshKeysTable, SshHost>(
                        currentTable: table,
                        referencedTable:
                            $$SshKeysTableReferences._sshHostsRefsTable(db),
                        managerFromTypedResult: (p0) =>
                            $$SshKeysTableReferences(db, table, p0)
                                .sshHostsRefs,
                        referencedItemsForCurrentItem:
                            (item, referencedItems) => referencedItems
                                .where((e) => e.identityKeyId == item.id),
                        typedResults: items)
                ];
              },
            );
          },
        ));
}

typedef $$SshKeysTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SshKeysTable,
    SshKey,
    $$SshKeysTableFilterComposer,
    $$SshKeysTableOrderingComposer,
    $$SshKeysTableAnnotationComposer,
    $$SshKeysTableCreateCompanionBuilder,
    $$SshKeysTableUpdateCompanionBuilder,
    (SshKey, $$SshKeysTableReferences),
    SshKey,
    PrefetchHooks Function({bool sshHostsRefs})>;
typedef $$SshHostsTableCreateCompanionBuilder = SshHostsCompanion Function({
  Value<int> id,
  Value<String?> host,
  Value<String?> hostname,
  Value<int?> port,
  Value<String?> username,
  Value<String?> password,
  Value<String?> salt,
  Value<int?> identityKeyId,
  Value<int?> identityType,
  Value<DateTime?> createdAt,
});
typedef $$SshHostsTableUpdateCompanionBuilder = SshHostsCompanion Function({
  Value<int> id,
  Value<String?> host,
  Value<String?> hostname,
  Value<int?> port,
  Value<String?> username,
  Value<String?> password,
  Value<String?> salt,
  Value<int?> identityKeyId,
  Value<int?> identityType,
  Value<DateTime?> createdAt,
});

final class $$SshHostsTableReferences
    extends BaseReferences<_$AppDatabase, $SshHostsTable, SshHost> {
  $$SshHostsTableReferences(super.$_db, super.$_table, super.$_typedResult);

  static $SshKeysTable _identityKeyIdTable(_$AppDatabase db) =>
      db.sshKeys.createAlias(
          $_aliasNameGenerator(db.sshHosts.identityKeyId, db.sshKeys.id));

  $$SshKeysTableProcessedTableManager? get identityKeyId {
    final $_column = $_itemColumn<int>('identity_key_id');
    if ($_column == null) return null;
    final manager = $$SshKeysTableTableManager($_db, $_db.sshKeys)
        .filter((f) => f.id.sqlEquals($_column));
    final item = $_typedResult.readTableOrNull(_identityKeyIdTable($_db));
    if (item == null) return manager;
    return ProcessedTableManager(
        manager.$state.copyWith(prefetchedData: [item]));
  }
}

class $$SshHostsTableFilterComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get hostname => $composableBuilder(
      column: $table.hostname, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get identityType => $composableBuilder(
      column: $table.identityType, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  $$SshKeysTableFilterComposer get identityKeyId {
    final $$SshKeysTableFilterComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identityKeyId,
        referencedTable: $db.sshKeys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SshKeysTableFilterComposer(
              $db: $db,
              $table: $db.sshKeys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SshHostsTableOrderingComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get host => $composableBuilder(
      column: $table.host, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get hostname => $composableBuilder(
      column: $table.hostname, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get port => $composableBuilder(
      column: $table.port, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get username => $composableBuilder(
      column: $table.username, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get password => $composableBuilder(
      column: $table.password, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get salt => $composableBuilder(
      column: $table.salt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get identityType => $composableBuilder(
      column: $table.identityType,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  $$SshKeysTableOrderingComposer get identityKeyId {
    final $$SshKeysTableOrderingComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identityKeyId,
        referencedTable: $db.sshKeys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SshKeysTableOrderingComposer(
              $db: $db,
              $table: $db.sshKeys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SshHostsTableAnnotationComposer
    extends Composer<_$AppDatabase, $SshHostsTable> {
  $$SshHostsTableAnnotationComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  GeneratedColumn<int> get id =>
      $composableBuilder(column: $table.id, builder: (column) => column);

  GeneratedColumn<String> get host =>
      $composableBuilder(column: $table.host, builder: (column) => column);

  GeneratedColumn<String> get hostname =>
      $composableBuilder(column: $table.hostname, builder: (column) => column);

  GeneratedColumn<int> get port =>
      $composableBuilder(column: $table.port, builder: (column) => column);

  GeneratedColumn<String> get username =>
      $composableBuilder(column: $table.username, builder: (column) => column);

  GeneratedColumn<String> get password =>
      $composableBuilder(column: $table.password, builder: (column) => column);

  GeneratedColumn<String> get salt =>
      $composableBuilder(column: $table.salt, builder: (column) => column);

  GeneratedColumn<int> get identityType => $composableBuilder(
      column: $table.identityType, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  $$SshKeysTableAnnotationComposer get identityKeyId {
    final $$SshKeysTableAnnotationComposer composer = $composerBuilder(
        composer: this,
        getCurrentColumn: (t) => t.identityKeyId,
        referencedTable: $db.sshKeys,
        getReferencedColumn: (t) => t.id,
        builder: (joinBuilder,
                {$addJoinBuilderToRootComposer,
                $removeJoinBuilderFromRootComposer}) =>
            $$SshKeysTableAnnotationComposer(
              $db: $db,
              $table: $db.sshKeys,
              $addJoinBuilderToRootComposer: $addJoinBuilderToRootComposer,
              joinBuilder: joinBuilder,
              $removeJoinBuilderFromRootComposer:
                  $removeJoinBuilderFromRootComposer,
            ));
    return composer;
  }
}

class $$SshHostsTableTableManager extends RootTableManager<
    _$AppDatabase,
    $SshHostsTable,
    SshHost,
    $$SshHostsTableFilterComposer,
    $$SshHostsTableOrderingComposer,
    $$SshHostsTableAnnotationComposer,
    $$SshHostsTableCreateCompanionBuilder,
    $$SshHostsTableUpdateCompanionBuilder,
    (SshHost, $$SshHostsTableReferences),
    SshHost,
    PrefetchHooks Function({bool identityKeyId})> {
  $$SshHostsTableTableManager(_$AppDatabase db, $SshHostsTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$SshHostsTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$SshHostsTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$SshHostsTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> host = const Value.absent(),
            Value<String?> hostname = const Value.absent(),
            Value<int?> port = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<String?> salt = const Value.absent(),
            Value<int?> identityKeyId = const Value.absent(),
            Value<int?> identityType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              SshHostsCompanion(
            id: id,
            host: host,
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            salt: salt,
            identityKeyId: identityKeyId,
            identityType: identityType,
            createdAt: createdAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String?> host = const Value.absent(),
            Value<String?> hostname = const Value.absent(),
            Value<int?> port = const Value.absent(),
            Value<String?> username = const Value.absent(),
            Value<String?> password = const Value.absent(),
            Value<String?> salt = const Value.absent(),
            Value<int?> identityKeyId = const Value.absent(),
            Value<int?> identityType = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
          }) =>
              SshHostsCompanion.insert(
            id: id,
            host: host,
            hostname: hostname,
            port: port,
            username: username,
            password: password,
            salt: salt,
            identityKeyId: identityKeyId,
            identityType: identityType,
            createdAt: createdAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) =>
                  (e.readTable(table), $$SshHostsTableReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: ({identityKeyId = false}) {
            return PrefetchHooks(
              db: db,
              explicitlyWatchedTables: [],
              addJoins: <
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
                      dynamic>>(state) {
                if (identityKeyId) {
                  state = state.withJoin(
                    currentTable: table,
                    currentColumn: table.identityKeyId,
                    referencedTable:
                        $$SshHostsTableReferences._identityKeyIdTable(db),
                    referencedColumn:
                        $$SshHostsTableReferences._identityKeyIdTable(db).id,
                  ) as T;
                }

                return state;
              },
              getPrefetchedDataCallback: (items) async {
                return [];
              },
            );
          },
        ));
}

typedef $$SshHostsTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $SshHostsTable,
    SshHost,
    $$SshHostsTableFilterComposer,
    $$SshHostsTableOrderingComposer,
    $$SshHostsTableAnnotationComposer,
    $$SshHostsTableCreateCompanionBuilder,
    $$SshHostsTableUpdateCompanionBuilder,
    (SshHost, $$SshHostsTableReferences),
    SshHost,
    PrefetchHooks Function({bool identityKeyId})>;
typedef $$ShellProfilesTableCreateCompanionBuilder = ShellProfilesCompanion
    Function({
  Value<int> id,
  required String name,
  Value<int> shellType,
  Value<String> environmentVariables,
  Value<String> aliases,
  Value<String> fontFamily,
  Value<double> fontSize,
  Value<String> colorTheme,
  Value<String> workingDirectory,
  Value<String> startupCommand,
  Value<int> cursorStyle,
  Value<int> scrollbackLines,
  Value<bool> isDefault,
  Value<bool> inheritCurrentState,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});
typedef $$ShellProfilesTableUpdateCompanionBuilder = ShellProfilesCompanion
    Function({
  Value<int> id,
  Value<String> name,
  Value<int> shellType,
  Value<String> environmentVariables,
  Value<String> aliases,
  Value<String> fontFamily,
  Value<double> fontSize,
  Value<String> colorTheme,
  Value<String> workingDirectory,
  Value<String> startupCommand,
  Value<int> cursorStyle,
  Value<int> scrollbackLines,
  Value<bool> isDefault,
  Value<bool> inheritCurrentState,
  Value<DateTime?> createdAt,
  Value<DateTime?> updatedAt,
});

class $$ShellProfilesTableFilterComposer
    extends Composer<_$AppDatabase, $ShellProfilesTable> {
  $$ShellProfilesTableFilterComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnFilters<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get shellType => $composableBuilder(
      column: $table.shellType, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get environmentVariables => $composableBuilder(
      column: $table.environmentVariables,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnFilters(column));

  ColumnFilters<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get colorTheme => $composableBuilder(
      column: $table.colorTheme, builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get workingDirectory => $composableBuilder(
      column: $table.workingDirectory,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<String> get startupCommand => $composableBuilder(
      column: $table.startupCommand,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get cursorStyle => $composableBuilder(
      column: $table.cursorStyle, builder: (column) => ColumnFilters(column));

  ColumnFilters<int> get scrollbackLines => $composableBuilder(
      column: $table.scrollbackLines,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnFilters(column));

  ColumnFilters<bool> get inheritCurrentState => $composableBuilder(
      column: $table.inheritCurrentState,
      builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnFilters(column));

  ColumnFilters<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnFilters(column));
}

class $$ShellProfilesTableOrderingComposer
    extends Composer<_$AppDatabase, $ShellProfilesTable> {
  $$ShellProfilesTableOrderingComposer({
    required super.$db,
    required super.$table,
    super.joinBuilder,
    super.$addJoinBuilderToRootComposer,
    super.$removeJoinBuilderFromRootComposer,
  });
  ColumnOrderings<int> get id => $composableBuilder(
      column: $table.id, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get name => $composableBuilder(
      column: $table.name, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get shellType => $composableBuilder(
      column: $table.shellType, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get environmentVariables => $composableBuilder(
      column: $table.environmentVariables,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get aliases => $composableBuilder(
      column: $table.aliases, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<double> get fontSize => $composableBuilder(
      column: $table.fontSize, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get colorTheme => $composableBuilder(
      column: $table.colorTheme, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get workingDirectory => $composableBuilder(
      column: $table.workingDirectory,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<String> get startupCommand => $composableBuilder(
      column: $table.startupCommand,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get cursorStyle => $composableBuilder(
      column: $table.cursorStyle, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<int> get scrollbackLines => $composableBuilder(
      column: $table.scrollbackLines,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get isDefault => $composableBuilder(
      column: $table.isDefault, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<bool> get inheritCurrentState => $composableBuilder(
      column: $table.inheritCurrentState,
      builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get createdAt => $composableBuilder(
      column: $table.createdAt, builder: (column) => ColumnOrderings(column));

  ColumnOrderings<DateTime> get updatedAt => $composableBuilder(
      column: $table.updatedAt, builder: (column) => ColumnOrderings(column));
}

class $$ShellProfilesTableAnnotationComposer
    extends Composer<_$AppDatabase, $ShellProfilesTable> {
  $$ShellProfilesTableAnnotationComposer({
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

  GeneratedColumn<int> get shellType =>
      $composableBuilder(column: $table.shellType, builder: (column) => column);

  GeneratedColumn<String> get environmentVariables => $composableBuilder(
      column: $table.environmentVariables, builder: (column) => column);

  GeneratedColumn<String> get aliases =>
      $composableBuilder(column: $table.aliases, builder: (column) => column);

  GeneratedColumn<String> get fontFamily => $composableBuilder(
      column: $table.fontFamily, builder: (column) => column);

  GeneratedColumn<double> get fontSize =>
      $composableBuilder(column: $table.fontSize, builder: (column) => column);

  GeneratedColumn<String> get colorTheme => $composableBuilder(
      column: $table.colorTheme, builder: (column) => column);

  GeneratedColumn<String> get workingDirectory => $composableBuilder(
      column: $table.workingDirectory, builder: (column) => column);

  GeneratedColumn<String> get startupCommand => $composableBuilder(
      column: $table.startupCommand, builder: (column) => column);

  GeneratedColumn<int> get cursorStyle => $composableBuilder(
      column: $table.cursorStyle, builder: (column) => column);

  GeneratedColumn<int> get scrollbackLines => $composableBuilder(
      column: $table.scrollbackLines, builder: (column) => column);

  GeneratedColumn<bool> get isDefault =>
      $composableBuilder(column: $table.isDefault, builder: (column) => column);

  GeneratedColumn<bool> get inheritCurrentState => $composableBuilder(
      column: $table.inheritCurrentState, builder: (column) => column);

  GeneratedColumn<DateTime> get createdAt =>
      $composableBuilder(column: $table.createdAt, builder: (column) => column);

  GeneratedColumn<DateTime> get updatedAt =>
      $composableBuilder(column: $table.updatedAt, builder: (column) => column);
}

class $$ShellProfilesTableTableManager extends RootTableManager<
    _$AppDatabase,
    $ShellProfilesTable,
    ShellProfile,
    $$ShellProfilesTableFilterComposer,
    $$ShellProfilesTableOrderingComposer,
    $$ShellProfilesTableAnnotationComposer,
    $$ShellProfilesTableCreateCompanionBuilder,
    $$ShellProfilesTableUpdateCompanionBuilder,
    (
      ShellProfile,
      BaseReferences<_$AppDatabase, $ShellProfilesTable, ShellProfile>
    ),
    ShellProfile,
    PrefetchHooks Function()> {
  $$ShellProfilesTableTableManager(_$AppDatabase db, $ShellProfilesTable table)
      : super(TableManagerState(
          db: db,
          table: table,
          createFilteringComposer: () =>
              $$ShellProfilesTableFilterComposer($db: db, $table: table),
          createOrderingComposer: () =>
              $$ShellProfilesTableOrderingComposer($db: db, $table: table),
          createComputedFieldComposer: () =>
              $$ShellProfilesTableAnnotationComposer($db: db, $table: table),
          updateCompanionCallback: ({
            Value<int> id = const Value.absent(),
            Value<String> name = const Value.absent(),
            Value<int> shellType = const Value.absent(),
            Value<String> environmentVariables = const Value.absent(),
            Value<String> aliases = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<String> colorTheme = const Value.absent(),
            Value<String> workingDirectory = const Value.absent(),
            Value<String> startupCommand = const Value.absent(),
            Value<int> cursorStyle = const Value.absent(),
            Value<int> scrollbackLines = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> inheritCurrentState = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ShellProfilesCompanion(
            id: id,
            name: name,
            shellType: shellType,
            environmentVariables: environmentVariables,
            aliases: aliases,
            fontFamily: fontFamily,
            fontSize: fontSize,
            colorTheme: colorTheme,
            workingDirectory: workingDirectory,
            startupCommand: startupCommand,
            cursorStyle: cursorStyle,
            scrollbackLines: scrollbackLines,
            isDefault: isDefault,
            inheritCurrentState: inheritCurrentState,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          createCompanionCallback: ({
            Value<int> id = const Value.absent(),
            required String name,
            Value<int> shellType = const Value.absent(),
            Value<String> environmentVariables = const Value.absent(),
            Value<String> aliases = const Value.absent(),
            Value<String> fontFamily = const Value.absent(),
            Value<double> fontSize = const Value.absent(),
            Value<String> colorTheme = const Value.absent(),
            Value<String> workingDirectory = const Value.absent(),
            Value<String> startupCommand = const Value.absent(),
            Value<int> cursorStyle = const Value.absent(),
            Value<int> scrollbackLines = const Value.absent(),
            Value<bool> isDefault = const Value.absent(),
            Value<bool> inheritCurrentState = const Value.absent(),
            Value<DateTime?> createdAt = const Value.absent(),
            Value<DateTime?> updatedAt = const Value.absent(),
          }) =>
              ShellProfilesCompanion.insert(
            id: id,
            name: name,
            shellType: shellType,
            environmentVariables: environmentVariables,
            aliases: aliases,
            fontFamily: fontFamily,
            fontSize: fontSize,
            colorTheme: colorTheme,
            workingDirectory: workingDirectory,
            startupCommand: startupCommand,
            cursorStyle: cursorStyle,
            scrollbackLines: scrollbackLines,
            isDefault: isDefault,
            inheritCurrentState: inheritCurrentState,
            createdAt: createdAt,
            updatedAt: updatedAt,
          ),
          withReferenceMapper: (p0) => p0
              .map((e) => (e.readTable(table), BaseReferences(db, table, e)))
              .toList(),
          prefetchHooksCallback: null,
        ));
}

typedef $$ShellProfilesTableProcessedTableManager = ProcessedTableManager<
    _$AppDatabase,
    $ShellProfilesTable,
    ShellProfile,
    $$ShellProfilesTableFilterComposer,
    $$ShellProfilesTableOrderingComposer,
    $$ShellProfilesTableAnnotationComposer,
    $$ShellProfilesTableCreateCompanionBuilder,
    $$ShellProfilesTableUpdateCompanionBuilder,
    (
      ShellProfile,
      BaseReferences<_$AppDatabase, $ShellProfilesTable, ShellProfile>
    ),
    ShellProfile,
    PrefetchHooks Function()>;

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SshKeysTableTableManager get sshKeys =>
      $$SshKeysTableTableManager(_db, _db.sshKeys);
  $$SshHostsTableTableManager get sshHosts =>
      $$SshHostsTableTableManager(_db, _db.sshHosts);
  $$ShellProfilesTableTableManager get shellProfiles =>
      $$ShellProfilesTableTableManager(_db, _db.shellProfiles);
}
