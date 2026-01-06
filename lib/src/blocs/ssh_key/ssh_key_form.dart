part of 'ssh_key_bloc.dart';

class SshKeyFormBloc extends FormBloc<String, String> {
  final ObjectBox objectBox;

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

  SshKeyFormBloc(this.objectBox) {
    addFieldBlocs(
      fieldBlocs: [name, content],
    );
  }

  setSshKey(SshKey? sshKey) {
    name.updateValue(sshKey?.name ?? '');
    content.updateValue(sshKey?.content ?? '');
  }

  @override
  void onSubmitting() async {
    try {
      final salt = StringHelper.randomString(16);
      final aes = AesHelper(Constant.appName);
      final content = aes.encrypt64WithSalt(this.content.value, salt);
      Box<SshKey> hostBox = objectBox.store.box<SshKey>();
      final sshKey = SshKey()
        ..algorithm = SshKeyAlgorithm.rsa
        ..name = name.value
        ..salt = salt
        ..content = content;
      final id = await hostBox.putAsync(sshKey);
      if (id == 0) {
        throw Exception('Failed to save ssh key');
      }
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
