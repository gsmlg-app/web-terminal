import 'package:objectbox/objectbox.dart';

enum IdentityType {
  password(1),
  key(2);

  const IdentityType(this.value);
  final int value;
  static byValue(int int) {
    return IdentityType.values.firstWhere((e) => e.value == int);
  }
}

@Entity()
class SshHost {
  @Id()
  int id = 0;

  String? host;

  String? hostname;

  int? port;

  @Transient()
  IdentityType? identityType;

  int? get dbIdentityType {
    return identityType?.value;
  }

  set dbIdentityType(int? value) {
    if (value == null) {
      identityType = null;
    } else {
      identityType =
          IdentityType.byValue(value); // throwing a [StateError] if not found
    }
  }

  String? username;

  String? password;

  String? salt;

  int? identityKeyId;

  @Property(type: PropertyType.date) // Store as int in milliseconds
  DateTime? createdAt = DateTime.now();
}
