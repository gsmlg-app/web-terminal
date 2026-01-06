part of 'ssh_host_bloc.dart';

class SshHostFormBloc extends FormBloc<String, String> {
  final ObjectBox objectBox;

  final host = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final hostname = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final port = TextFieldBloc<int>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final username = TextFieldBloc<String>(
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final identityType = SelectFieldBloc<IdentityType, dynamic>(
    items: IdentityType.values,
    validators: [
      FieldBlocValidators.required,
    ],
  );

  final password = TextFieldBloc<String>(validators: [
    (pwd) {
      // if (identityType.value == IdentityType.password) {
      //   if (pwd.isEmpty) {
      //     return 'Required';
      //   }
      // }
      return null;
    },
  ]);

  final identityKeyId = SelectFieldBloc<SshKey, dynamic>(validators: [
    (key) {
      // if (identityType.value == IdentityType.key) {
      //   if (key.isEmpty) {
      //     return 'Required';
      //   }
      // }
      return null;
    },
  ]);

  SshHostFormBloc(this.objectBox) {
    addFieldBlocs(
      fieldBlocs: [
        host,
        hostname,
        port,
        username,
        identityType,
        password,
        identityKeyId
      ],
    );
  }

  void setSshHost(SshHost? sshHost) {
    host.updateValue(sshHost?.host ?? '');
    hostname.updateValue(sshHost?.hostname ?? '');
    port.updateValue((sshHost?.port ?? 22).toString());
    username.updateValue(sshHost?.username ?? '');
    identityType.updateValue(sshHost?.identityType);
    password.updateValue('');
    final sshKeyBox = objectBox.store.box<SshKey>();
    final sshKeys = sshKeyBox.getAll();
    identityKeyId.updateItems(sshKeys);
    if (sshHost?.identityKeyId != null) {
      final sshKey = sshKeyBox.get(sshHost!.identityKeyId!);
      identityKeyId.updateValue(sshKey);
    }
  }

  @override
  void onSubmitting() async {
    try {
      final sshHostBox = objectBox.store.box<SshHost>();
      final sshHost = SshHost()
        ..host = host.value
        ..hostname = hostname.value
        ..port = int.parse(port.value)
        ..username = username.value
        ..identityType = identityType.value;
      if (identityType.value == IdentityType.password) {
        sshHost.password = password.value;
      } else {
        sshHost.identityKeyId = identityKeyId.value?.id;
      }
      final id = await sshHostBox.putAsync(sshHost);
      if (id == 0) {
        throw Exception('Failed to save host');
      }
      emitSuccess(
        successResponse: 'Host created',
      );
    } catch (e) {
      emitFailure(
        failureResponse: e.toString(),
      );
    }
  }
}
