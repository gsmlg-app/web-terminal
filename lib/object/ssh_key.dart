import 'package:gsmlg_security/gsmlg_security.dart';
import 'package:objectbox/objectbox.dart';
import 'package:web_terminal/constant.dart';

enum SshKeyAlgorithm {
  rsa(1),
  dsa(2),
  ecdsa(3),
  ed25519(4);

  const SshKeyAlgorithm(this.value);
  final int value;
  static byValue(int int) {
    return SshKeyAlgorithm.values.firstWhere((e) => e.value == int);
  }
}

@Entity()
class SshKey {
  @Id()
  int id = 0;

  @Transient()
  SshKeyAlgorithm? algorithm;

  int? get dbAlgorithm {
    return algorithm?.value;
  }

  set dbAlgorithm(int? value) {
    if (value == null) {
      algorithm = null;
    } else {
      algorithm = SshKeyAlgorithm.byValue(
          value); // throwing a [StateError] if not found
    }
  }

  String? salt;

  String? name;

  String? content;

  String? password;

  @Property(type: PropertyType.date) // Store as int in milliseconds
  DateTime? createdAt = DateTime.now();

  String getPrivateKeyPem() {
    final aesHelper = AesHelper(Constant.appName);
    print(content);
    print(salt);
    final keyPem = aesHelper.decrypt64WithSalt('$content', '$salt');

    return keyPem;
  }

  String getPublicKeyPem() {
    final keyPem = getPrivateKeyPem();
    final rsaKeyHelper = RsaKeyHelper();
    return rsaKeyHelper.getSshPublicKey(keyPem);
  }
}
