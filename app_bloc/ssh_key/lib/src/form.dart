import 'package:duskmoon_ui/duskmoon_ui.dart';
import 'package:app_security/app_security.dart';

import 'bloc.dart';

class SshKeyFormBloc extends FormBloc<String, String> {
  final SshKeyBloc sshKeyBloc;

  final name = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final content = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  SshKeyFormBloc(this.sshKeyBloc) {
    addFieldBlocs(
      fieldBlocs: [name, content],
    );
  }

  void setSshKey(SshKey? sshKey) {
    name.updateValue(sshKey?.name ?? '');
    content.updateValue(sshKey?.content ?? '');
  }

  @override
  void onSubmitting() async {
    try {
      final salt = StringHelper.randomString(16);
      final aes = AesHelper(appName);
      final encryptedContent = aes.encrypt64WithSalt(content.value, salt);
      sshKeyBloc.add(SshKeyAdd(
        name: name.value,
        content: encryptedContent,
        salt: salt,
        algorithm: SshKeyAlgorithm.rsa.value,
      ));
      emitSuccess(
        successResponse: 'SSH Key saved',
      );
    } catch (e) {
      emitFailure(
        failureResponse: e.toString(),
      );
    }
  }
}
