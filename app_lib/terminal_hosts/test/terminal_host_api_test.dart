import 'package:flutter_test/flutter_test.dart';
import 'package:ssh_host_bloc/ssh_host_bloc.dart';
import 'package:terminal_core/terminal_core.dart';
import 'package:terminal_hosts/terminal_hosts.dart';

void main() {
  group('Terminal Host API Tests', () {
    group('LocalConnector', () {
      test('creates with no environment variables', () {
        final connector = LocalConnector();

        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with environment variables', () {
        final connector = LocalConnector(
          environment: {
            'TERM': 'xterm-256color',
            'SHELL': '/bin/bash',
            'PATH': '/usr/local/bin:/usr/bin:/bin',
          },
        );

        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['SHELL'], '/bin/bash');
        expect(connector.environment['PATH'], '/usr/local/bin:/usr/bin:/bin');
        expect(connector.environment.length, 3);
      });

      test('creates with init commands', () {
        final connector = LocalConnector(
          initCommands: 'cd /home/user && source ~/.bashrc',
        );

        expect(connector.initCommands, 'cd /home/user && source ~/.bashrc');
      });

      test('creates with both environment and init commands', () {
        final connector = LocalConnector(
          environment: {'LANG': 'en_US.UTF-8'},
          initCommands: 'export PS1="\\u@\\h:\\w\\$ "',
        );

        expect(connector.environment['LANG'], 'en_US.UTF-8');
        expect(connector.initCommands, contains('PS1'));
      });

      test('is a HostConnector<LocalHost>', () {
        final connector = LocalConnector();

        expect(connector, isA<HostConnector>());
        expect(connector, isA<HostConnector<LocalHost>>());
      });

      test('environment map is mutable', () {
        final env = <String, String>{'A': '1'};
        final connector = LocalConnector(environment: env);

        expect(connector.environment['A'], '1');
        env['B'] = '2';
        expect(connector.environment['B'], '2');
      });

      test('handles special characters in environment values', () {
        final connector = LocalConnector(
          environment: {
            'SPECIAL': 'value with spaces and "quotes"',
            'PATH': '/usr/bin:/usr/local/bin',
          },
        );

        expect(connector.environment['SPECIAL'], contains('quotes'));
        expect(connector.environment['PATH'], contains(':'));
      });

      test('handles empty environment map', () {
        final connector = LocalConnector(environment: {});

        expect(connector.environment, isEmpty);
        expect(connector.environment, isA<Map<String, String>>());
      });

      test('handles empty init commands', () {
        final connector = LocalConnector(initCommands: '');

        expect(connector.initCommands, isEmpty);
        expect(connector.initCommands, isNot(isNull));
      });

      test('handles multiline init commands', () {
        final connector = LocalConnector(
          initCommands: '''
            cd /workspace
            source .env
            echo "Ready"
          ''',
        );

        expect(connector.initCommands, contains('cd /workspace'));
        expect(connector.initCommands, contains('source .env'));
        expect(connector.initCommands, contains('echo "Ready"'));
      });

      test('createHost returns Future<LocalHost>', () {
        final connector = LocalConnector();

        expect(connector.createHost(), isA<Future<LocalHost>>());
      });
    });

    group('AndroidConnector', () {
      test('creates with no environment variables', () {
        final connector = AndroidConnector();

        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with environment variables', () {
        final connector = AndroidConnector(
          environment: {
            'TERM': 'xterm-256color',
            'HOME': '/data/data/com.example.app',
            'PATH': '/system/bin:/system/xbin',
          },
        );

        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['HOME'], contains('/data/data'));
        expect(connector.environment['PATH'], contains('/system/bin'));
        expect(connector.environment.length, 3);
      });

      test('creates with init commands', () {
        final connector = AndroidConnector(
          initCommands: 'cd /sdcard && ls',
        );

        expect(connector.initCommands, 'cd /sdcard && ls');
      });

      test('creates with both environment and init commands', () {
        final connector = AndroidConnector(
          environment: {'TMPDIR': '/data/local/tmp'},
          initCommands: 'export LD_LIBRARY_PATH=/data/local/lib',
        );

        expect(connector.environment['TMPDIR'], '/data/local/tmp');
        expect(connector.initCommands, contains('LD_LIBRARY_PATH'));
      });

      test('is a HostConnector<AndroidHost>', () {
        final connector = AndroidConnector();

        expect(connector, isA<HostConnector>());
        expect(connector, isA<HostConnector<AndroidHost>>());
      });

      test('handles Android-specific paths', () {
        final connector = AndroidConnector(
          environment: {
            'ANDROID_ROOT': '/system',
            'ANDROID_DATA': '/data',
            'EXTERNAL_STORAGE': '/sdcard',
          },
        );

        expect(connector.environment['ANDROID_ROOT'], '/system');
        expect(connector.environment['ANDROID_DATA'], '/data');
        expect(connector.environment['EXTERNAL_STORAGE'], '/sdcard');
      });

      test('handles busybox commands in init', () {
        final connector = AndroidConnector(
          initCommands: 'busybox ls -la',
        );

        expect(connector.initCommands, contains('busybox'));
      });

      test('createHost is available', () {
        final connector = AndroidConnector();

        expect(connector.createHost, isA<Function>());
      });
    });

    group('IosConnector', () {
      test('creates with no environment variables', () {
        final connector = IosConnector();

        expect(connector.environment, isEmpty);
        expect(connector.initCommands, isNull);
      });

      test('creates with environment variables', () {
        final connector = IosConnector(
          environment: {
            'TERM': 'xterm-256color',
            'HOME': '/var/mobile',
            'PATH': '/usr/bin:/bin:/usr/sbin:/sbin',
          },
        );

        expect(connector.environment['TERM'], 'xterm-256color');
        expect(connector.environment['HOME'], '/var/mobile');
        expect(connector.environment['PATH'], contains('/usr/bin'));
        expect(connector.environment.length, 3);
      });

      test('creates with init commands', () {
        final connector = IosConnector(
          initCommands: 'cd ~/Documents',
        );

        expect(connector.initCommands, 'cd ~/Documents');
      });

      test('creates with both environment and init commands', () {
        final connector = IosConnector(
          environment: {'LANG': 'en_US.UTF-8'},
          initCommands: 'source ~/.profile',
        );

        expect(connector.environment['LANG'], 'en_US.UTF-8');
        expect(connector.initCommands, contains('.profile'));
      });

      test('is a HostConnector<IosHost>', () {
        final connector = IosConnector();

        expect(connector, isA<HostConnector>());
        expect(connector, isA<HostConnector<IosHost>>());
      });

      test('handles iOS-specific paths', () {
        final connector = IosConnector(
          environment: {
            'HOME': '/var/mobile',
            'TMPDIR': '/var/mobile/Containers/Data/Application/tmp',
            'CFFIXED_USER_HOME': '/var/mobile',
          },
        );

        expect(connector.environment['HOME'], '/var/mobile');
        expect(connector.environment['TMPDIR'], contains('Containers'));
        expect(connector.environment['CFFIXED_USER_HOME'], '/var/mobile');
      });

      test('createHost is available', () {
        final connector = IosConnector();

        expect(connector.createHost, isA<Function>());
      });
    });

    group('LocalHostSpec', () {
      test('creates with default name', () {
        final spec = LocalHostSpec();

        expect(spec.name, 'Local Shell');
      });

      test('creates with custom environment', () {
        final spec = LocalHostSpec(
          environment: {'FOO': 'bar'},
        );

        expect(spec.createConnector().environment['FOO'], 'bar');
      });

      test('creates with init commands', () {
        final spec = LocalHostSpec(
          initCommands: 'echo "Starting local shell"',
        );

        expect(
          spec.createConnector().initCommands,
          contains('Starting local shell'),
        );
      });

      test('createConnector returns LocalConnector', () {
        final spec = LocalHostSpec();
        final connector = spec.createConnector();

        expect(connector, isA<LocalConnector>());
        expect(connector, isA<HostConnector<LocalHost>>());
      });

      test('implements HostSpec interface', () {
        final spec = LocalHostSpec();

        expect(spec, isA<HostSpec>());
      });

      test('passes through environment to connector', () {
        final env = {'KEY1': 'VALUE1', 'KEY2': 'VALUE2'};
        final spec = LocalHostSpec(environment: env);
        final connector = spec.createConnector();

        expect(connector.environment, env);
      });

      test('passes through init commands to connector', () {
        const initCmd = 'cd /workspace && ls';
        final spec = LocalHostSpec(initCommands: initCmd);
        final connector = spec.createConnector();

        expect(connector.initCommands, initCmd);
      });
    });

    group('AndroidHostSpec', () {
      test('creates with default name', () {
        final spec = AndroidHostSpec();

        expect(spec.name, 'Android Shell');
      });

      test('creates with custom environment', () {
        final spec = AndroidHostSpec(
          environment: {'ANDROID_DATA': '/data'},
        );

        expect(
          spec.createConnector().environment['ANDROID_DATA'],
          '/data',
        );
      });

      test('creates with init commands', () {
        final spec = AndroidHostSpec(
          initCommands: 'busybox echo "Android ready"',
        );

        expect(
          spec.createConnector().initCommands,
          contains('Android ready'),
        );
      });

      test('createConnector returns AndroidConnector', () {
        final spec = AndroidHostSpec();
        final connector = spec.createConnector();

        expect(connector, isA<AndroidConnector>());
        expect(connector, isA<HostConnector<AndroidHost>>());
      });

      test('implements HostSpec interface', () {
        final spec = AndroidHostSpec();

        expect(spec, isA<HostSpec>());
      });
    });

    group('IosHostSpec', () {
      test('creates with default name', () {
        final spec = IosHostSpec();

        expect(spec.name, 'iOS Shell');
      });

      test('creates with custom environment', () {
        final spec = IosHostSpec(
          environment: {'HOME': '/var/mobile'},
        );

        expect(
          spec.createConnector().environment['HOME'],
          '/var/mobile',
        );
      });

      test('creates with init commands', () {
        final spec = IosHostSpec(
          initCommands: 'cd ~/Documents && pwd',
        );

        expect(
          spec.createConnector().initCommands,
          contains('Documents'),
        );
      });

      test('createConnector returns IosConnector', () {
        final spec = IosHostSpec();
        final connector = spec.createConnector();

        expect(connector, isA<IosConnector>());
        expect(connector, isA<HostConnector<IosHost>>());
      });

      test('implements HostSpec interface', () {
        final spec = IosHostSpec();

        expect(spec, isA<HostSpec>());
      });
    });

    group('HostConnector type hierarchy', () {
      test('all connectors implement HostConnector', () {
        final local = LocalConnector();
        final android = AndroidConnector();
        final ios = IosConnector();
        final ssh = SSHConnector(
          SshHost(
            id: 1,
            host: 'test',
            hostname: 'test.com',
            port: 22,
            username: 'user',
            password: 'pass',
            salt: null,
            identityType: 1,
            identityKeyId: null,
            createdAt: DateTime.now(),
          ),
        );

        expect(local, isA<HostConnector>());
        expect(android, isA<HostConnector>());
        expect(ios, isA<HostConnector>());
        expect(ssh, isA<HostConnector>());
      });

      test('connectors have correct generic types', () {
        final local = LocalConnector();
        final android = AndroidConnector();
        final ios = IosConnector();

        expect(local, isA<HostConnector<LocalHost>>());
        expect(android, isA<HostConnector<AndroidHost>>());
        expect(ios, isA<HostConnector<IosHost>>());
      });
    });

    group('Edge cases and boundary conditions', () {
      test('handles very long environment variable values', () {
        final longValue = 'x' * 10000;
        final connector = LocalConnector(
          environment: {'LONG_VAR': longValue},
        );

        expect(connector.environment['LONG_VAR']?.length, 10000);
      });

      test('handles very long init commands', () {
        final longCommand = 'echo ${'test ' * 1000}';
        final connector = LocalConnector(initCommands: longCommand);

        expect(connector.initCommands?.length, greaterThan(5000));
      });

      test('handles environment with many variables', () {
        final manyVars = <String, String>{};
        for (var i = 0; i < 100; i++) {
          manyVars['VAR_$i'] = 'value_$i';
        }

        final connector = LocalConnector(environment: manyVars);

        expect(connector.environment.length, 100);
        expect(connector.environment['VAR_0'], 'value_0');
        expect(connector.environment['VAR_99'], 'value_99');
      });

      test('handles environment variable with newlines', () {
        final connector = LocalConnector(
          environment: {'MULTILINE': 'line1\nline2\nline3'},
        );

        expect(connector.environment['MULTILINE'], contains('\n'));
      });

      test('handles environment variable with null bytes would fail in practice', () {
        // Note: In practice, null bytes in environment variables cause issues
        // This test documents the expected behavior
        final connector = LocalConnector(
          environment: {'WITH_NULL': 'before\x00after'},
        );

        expect(connector.environment['WITH_NULL'], contains('\x00'));
      });

      test('handles Unicode in environment variables', () {
        final connector = LocalConnector(
          environment: {
            'UNICODE': 'Hello 世界 🌍',
            'EMOJI': '😀😁😂',
          },
        );

        expect(connector.environment['UNICODE'], contains('世界'));
        expect(connector.environment['EMOJI'], contains('😀'));
      });

      test('handles Unicode in init commands', () {
        final connector = LocalConnector(
          initCommands: 'echo "Hello 世界"',
        );

        expect(connector.initCommands, contains('世界'));
      });

      test('handles empty strings in environment keys', () {
        // Empty keys are technically allowed but not recommended
        final connector = LocalConnector(
          environment: {'': 'empty_key_value'},
        );

        expect(connector.environment[''], 'empty_key_value');
      });

      test('handles multiple connectors with same environment reference', () {
        final sharedEnv = {'SHARED': 'value'};
        final connector1 = LocalConnector(environment: sharedEnv);
        final connector2 = LocalConnector(environment: sharedEnv);

        sharedEnv['MODIFIED'] = 'new_value';

        expect(connector1.environment['MODIFIED'], 'new_value');
        expect(connector2.environment['MODIFIED'], 'new_value');
      });

      test('handles init commands with shell special characters', () {
        final connector = LocalConnector(
          initCommands: r'echo "test" && cd /path || exit 1; ls | grep "pattern"',
        );

        expect(connector.initCommands, contains('&&'));
        expect(connector.initCommands, contains('||'));
        expect(connector.initCommands, contains('|'));
        expect(connector.initCommands, contains(';'));
      });

      test('handles init commands with quotes', () {
        final connector = LocalConnector(
          initCommands: '''echo "double quotes" && echo 'single quotes' ''',
        );

        expect(connector.initCommands, contains('"double quotes"'));
        expect(connector.initCommands, contains("'single quotes'"));
      });

      test('handles PATH-like environment variables', () {
        final connector = LocalConnector(
          environment: {
            'PATH': '/usr/local/bin:/usr/bin:/bin:/usr/sbin:/sbin',
            'CLASSPATH': '.:/usr/local/lib/*:/opt/lib/*',
          },
        );

        expect(connector.environment['PATH']?.split(':').length, 5);
        expect(connector.environment['CLASSPATH'], contains('*'));
      });
    });

    group('Host interface expectations', () {
      test('LocalConnector createHost returns correct type', () {
        final connector = LocalConnector();
        final hostFuture = connector.createHost();

        expect(hostFuture, isA<Future<LocalHost>>());
        expect(hostFuture, isA<Future<Host>>());
      });

      test('AndroidConnector createHost has correct signature', () {
        final connector = AndroidConnector();

        expect(connector.createHost, isA<Function>());
      });

      test('IosConnector createHost has correct signature', () {
        final connector = IosConnector();

        expect(connector.createHost, isA<Function>());
      });
    });
  });
}
