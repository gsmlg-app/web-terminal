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

abstract class _$AppDatabase extends GeneratedDatabase {
  _$AppDatabase(QueryExecutor e) : super(e);
  $AppDatabaseManager get managers => $AppDatabaseManager(this);
  late final $SshKeysTable sshKeys = $SshKeysTable(this);
  late final $SshHostsTable sshHosts = $SshHostsTable(this);
  @override
  Iterable<TableInfo<Table, Object?>> get allTables =>
      allSchemaEntities.whereType<TableInfo<Table, Object?>>();
  @override
  List<DatabaseSchemaEntity> get allSchemaEntities => [sshKeys, sshHosts];
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

class $AppDatabaseManager {
  final _$AppDatabase _db;
  $AppDatabaseManager(this._db);
  $$SshKeysTableTableManager get sshKeys =>
      $$SshKeysTableTableManager(_db, _db.sshKeys);
  $$SshHostsTableTableManager get sshHosts =>
      $$SshHostsTableTableManager(_db, _db.sshHosts);
}
