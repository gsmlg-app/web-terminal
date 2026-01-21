import 'package:app_ssh/src/sftp/sftp_client.dart';
import 'package:app_ssh/src/sftp/sftp_errors.dart';
import 'package:app_ssh/src/sftp/sftp_file_attrs.dart';
import 'package:app_ssh/src/sftp/sftp_file_open_mode.dart';
import 'package:app_ssh/src/sftp/sftp_name.dart';
import 'package:app_ssh/src/sftp/sftp_packet.dart';
import 'package:app_ssh/src/sftp/sftp_statvfs.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  group('SFTP API Tests', () {
    group('SftpFileOpenMode', () {
      test('read mode has correct flags', () {
        expect(SftpFileOpenMode.read.value, 1);
        expect(SftpFileOpenMode.read.toString(), contains('read'));
      });

      test('write mode has correct flags', () {
        expect(SftpFileOpenMode.write.value, 2);
        expect(SftpFileOpenMode.write.toString(), contains('write'));
      });

      test('append mode has correct flags', () {
        expect(SftpFileOpenMode.append.value, 4);
        expect(SftpFileOpenMode.append.toString(), contains('append'));
      });

      test('create mode has correct flags', () {
        expect(SftpFileOpenMode.create.value, 8);
        expect(SftpFileOpenMode.create.toString(), contains('create'));
      });

      test('truncate mode has correct flags', () {
        expect(SftpFileOpenMode.truncate.value, 16);
        expect(SftpFileOpenMode.truncate.toString(), contains('truncate'));
      });

      test('exclusive mode has correct flags', () {
        expect(SftpFileOpenMode.exclusive.value, 32);
        expect(SftpFileOpenMode.exclusive.toString(), contains('exclusive'));
      });

      test('modes can be combined with OR operator', () {
        final combined = SftpFileOpenMode.write | SftpFileOpenMode.create;
        expect(combined.value, 10); // 2 | 8 = 10
      });

      test('read-write mode combination', () {
        final readWrite = SftpFileOpenMode.read | SftpFileOpenMode.write;
        expect(readWrite.value, 3); // 1 | 2 = 3
      });

      test('write-create-truncate combination', () {
        final mode = SftpFileOpenMode.write |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate;
        expect(mode.value, 26); // 2 | 8 | 16 = 26
      });

      test('create-exclusive combination', () {
        final mode = SftpFileOpenMode.create | SftpFileOpenMode.exclusive;
        expect(mode.value, 40); // 8 | 32 = 40
      });

      test('all modes combined', () {
        final all = SftpFileOpenMode.read |
            SftpFileOpenMode.write |
            SftpFileOpenMode.append |
            SftpFileOpenMode.create |
            SftpFileOpenMode.truncate |
            SftpFileOpenMode.exclusive;
        expect(all.value, 63); // 1+2+4+8+16+32 = 63
      });
    });

    group('SftpFileAttrs', () {
      test('creates empty attributes', () {
        final attrs = SftpFileAttrs();

        expect(attrs.size, isNull);
        expect(attrs.userId, isNull);
        expect(attrs.groupId, isNull);
        expect(attrs.permissions, isNull);
        expect(attrs.accessTime, isNull);
        expect(attrs.modifyTime, isNull);
      });

      test('creates attributes with size', () {
        final attrs = SftpFileAttrs(size: 1024);

        expect(attrs.size, 1024);
        expect(attrs.userId, isNull);
      });

      test('creates attributes with permissions', () {
        final attrs = SftpFileAttrs(permissions: 0o644);

        expect(attrs.permissions, 0o644);
        expect(attrs.size, isNull);
      });

      test('creates attributes with user and group IDs', () {
        final attrs = SftpFileAttrs(userId: 1000, groupId: 1000);

        expect(attrs.userId, 1000);
        expect(attrs.groupId, 1000);
      });

      test('creates attributes with timestamps', () {
        final now = DateTime.now();
        final attrs = SftpFileAttrs(
          accessTime: now,
          modifyTime: now,
        );

        expect(attrs.accessTime, now);
        expect(attrs.modifyTime, now);
      });

      test('creates attributes with all fields', () {
        final now = DateTime.now();
        final attrs = SftpFileAttrs(
          size: 2048,
          userId: 1001,
          groupId: 1001,
          permissions: 0o755,
          accessTime: now,
          modifyTime: now,
        );

        expect(attrs.size, 2048);
        expect(attrs.userId, 1001);
        expect(attrs.groupId, 1001);
        expect(attrs.permissions, 0o755);
        expect(attrs.accessTime, now);
        expect(attrs.modifyTime, now);
      });

      test('handles large file sizes', () {
        final attrs = SftpFileAttrs(size: 9223372036854775807); // max int64

        expect(attrs.size, 9223372036854775807);
      });

      test('handles zero size', () {
        final attrs = SftpFileAttrs(size: 0);

        expect(attrs.size, 0);
      });

      test('handles common permission patterns', () {
        final readOnly = SftpFileAttrs(permissions: 0o444);
        final readWrite = SftpFileAttrs(permissions: 0o666);
        final executable = SftpFileAttrs(permissions: 0o755);
        final restricted = SftpFileAttrs(permissions: 0o600);

        expect(readOnly.permissions, 0o444);
        expect(readWrite.permissions, 0o666);
        expect(executable.permissions, 0o755);
        expect(restricted.permissions, 0o600);
      });
    });

    group('SftpName', () {
      test('creates with filename only', () {
        final name = SftpName(filename: 'test.txt', attrs: SftpFileAttrs());

        expect(name.filename, 'test.txt');
        expect(name.longname, isNull);
        expect(name.attrs, isNotNull);
      });

      test('creates with filename and longname', () {
        final name = SftpName(
          filename: 'test.txt',
          longname: '-rw-r--r-- 1 user group 1024 Jan 01 12:00 test.txt',
          attrs: SftpFileAttrs(),
        );

        expect(name.filename, 'test.txt');
        expect(name.longname, contains('test.txt'));
        expect(name.longname, contains('rw-r--r--'));
      });

      test('creates with attributes', () {
        final attrs = SftpFileAttrs(size: 1024, permissions: 0o644);
        final name = SftpName(filename: 'file.txt', attrs: attrs);

        expect(name.attrs.size, 1024);
        expect(name.attrs.permissions, 0o644);
      });

      test('handles directory entries', () {
        final dir = SftpName(
          filename: 'mydir',
          longname: 'drwxr-xr-x 5 user group 4096 Jan 01 12:00 mydir',
          attrs: SftpFileAttrs(permissions: 0o755),
        );

        expect(dir.filename, 'mydir');
        expect(dir.longname, startsWith('d'));
      });

      test('handles symlink entries', () {
        final link = SftpName(
          filename: 'link',
          longname: 'lrwxrwxrwx 1 user group 10 Jan 01 12:00 link -> target',
          attrs: SftpFileAttrs(),
        );

        expect(link.filename, 'link');
        expect(link.longname, startsWith('l'));
        expect(link.longname, contains('->'));
      });

      test('handles filenames with special characters', () {
        final name = SftpName(
          filename: 'file with spaces.txt',
          attrs: SftpFileAttrs(),
        );

        expect(name.filename, 'file with spaces.txt');
      });

      test('handles hidden files', () {
        final hidden = SftpName(
          filename: '.hidden',
          attrs: SftpFileAttrs(),
        );

        expect(hidden.filename, '.hidden');
        expect(hidden.filename, startsWith('.'));
      });

      test('handles parent directory reference', () {
        final parent = SftpName(
          filename: '..',
          attrs: SftpFileAttrs(permissions: 0o755),
        );

        expect(parent.filename, '..');
      });

      test('handles current directory reference', () {
        final current = SftpName(
          filename: '.',
          attrs: SftpFileAttrs(permissions: 0o755),
        );

        expect(current.filename, '.');
      });
    });

    group('SftpError', () {
      test('creates generic SFTP error', () {
        final error = SftpError('Something went wrong');

        expect(error.message, 'Something went wrong');
        expect(error.toString(), contains('Something went wrong'));
      });

      test('creates with empty message', () {
        final error = SftpError('');

        expect(error.message, isEmpty);
      });
    });

    group('SftpStatusError', () {
      test('creates from status packet with EOF', () {
        final packet = SftpStatusPacket(
          requestId: 1,
          code: SftpStatusCode.eof,
          message: 'End of file',
          languageTag: 'en',
        );

        final error = SftpStatusError.fromStatus(packet);

        expect(error.code, SftpStatusCode.eof);
        expect(error.message, 'End of file');
      });

      test('creates from status packet with NO_SUCH_FILE', () {
        final packet = SftpStatusPacket(
          requestId: 1,
          code: SftpStatusCode.noSuchFile,
          message: 'File not found',
          languageTag: 'en',
        );

        final error = SftpStatusError.fromStatus(packet);

        expect(error.code, SftpStatusCode.noSuchFile);
        expect(error.message, 'File not found');
      });

      test('creates from status packet with PERMISSION_DENIED', () {
        final packet = SftpStatusPacket(
          requestId: 1,
          code: SftpStatusCode.permissionDenied,
          message: 'Permission denied',
          languageTag: 'en',
        );

        final error = SftpStatusError.fromStatus(packet);

        expect(error.code, SftpStatusCode.permissionDenied);
        expect(error.message, 'Permission denied');
      });

      test('creates with direct code and message', () {
        final error = SftpStatusError(
          SftpStatusCode.failure,
          'Operation failed',
        );

        expect(error.code, SftpStatusCode.failure);
        expect(error.message, 'Operation failed');
      });

      test('toString includes code and message', () {
        final error = SftpStatusError(
          SftpStatusCode.badMessage,
          'Invalid message',
        );

        final str = error.toString();
        expect(str, contains('badMessage'));
        expect(str, contains('Invalid message'));
      });

      test('check method throws on error status', () {
        final errorPacket = SftpStatusPacket(
          requestId: 1,
          code: SftpStatusCode.failure,
          message: 'Failed',
          languageTag: 'en',
        );

        expect(
          () => SftpStatusError.check(errorPacket),
          throwsA(isA<SftpStatusError>()),
        );
      });

      test('check method does not throw on OK status', () {
        final okPacket = SftpStatusPacket(
          requestId: 1,
          code: SftpStatusCode.ok,
          message: 'Success',
          languageTag: 'en',
        );

        expect(() => SftpStatusError.check(okPacket), returnsNormally);
      });

      test('handles all status codes', () {
        final codes = [
          SftpStatusCode.ok,
          SftpStatusCode.eof,
          SftpStatusCode.noSuchFile,
          SftpStatusCode.permissionDenied,
          SftpStatusCode.failure,
          SftpStatusCode.badMessage,
          SftpStatusCode.noConnection,
          SftpStatusCode.connectionLost,
          SftpStatusCode.opUnsupported,
        ];

        for (final code in codes) {
          final error = SftpStatusError(code, 'Test error');
          expect(error.code, code);
        }
      });
    });

    group('SftpStatVfs', () {
      test('creates with all filesystem statistics', () {
        final statvfs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000000,
          blocksFree: 500000,
          blocksAvailable: 400000,
          files: 100000,
          filesFree: 50000,
          filesAvailable: 45000,
          sid: 12345,
          flag: 0,
          namemax: 255,
        );

        expect(statvfs.blockSize, 4096);
        expect(statvfs.fragmentSize, 4096);
        expect(statvfs.blocks, 1000000);
        expect(statvfs.blocksFree, 500000);
        expect(statvfs.blocksAvailable, 400000);
        expect(statvfs.files, 100000);
        expect(statvfs.filesFree, 50000);
        expect(statvfs.filesAvailable, 45000);
        expect(statvfs.sid, 12345);
        expect(statvfs.flag, 0);
        expect(statvfs.namemax, 255);
      });

      test('calculates total space', () {
        final statvfs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000,
          blocksFree: 500,
          blocksAvailable: 400,
          files: 100,
          filesFree: 50,
          filesAvailable: 45,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        // Total space = blocks * blockSize = 1000 * 4096 = 4096000
        expect(statvfs.blocks * statvfs.blockSize, 4096000);
      });

      test('calculates free space', () {
        final statvfs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000,
          blocksFree: 500,
          blocksAvailable: 400,
          files: 100,
          filesFree: 50,
          filesAvailable: 45,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        // Free space = blocksFree * blockSize = 500 * 4096 = 2048000
        expect(statvfs.blocksFree * statvfs.blockSize, 2048000);
      });

      test('calculates available space', () {
        final statvfs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000,
          blocksFree: 500,
          blocksAvailable: 400,
          files: 100,
          filesFree: 50,
          filesAvailable: 45,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        // Available = blocksAvailable * blockSize = 400 * 4096 = 1638400
        expect(statvfs.blocksAvailable * statvfs.blockSize, 1638400);
      });

      test('handles read-only filesystem flag', () {
        final readOnlyFs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000,
          blocksFree: 0,
          blocksAvailable: 0,
          files: 100,
          filesFree: 0,
          filesAvailable: 0,
          sid: 1,
          flag: 1, // Read-only flag
          namemax: 255,
        );

        expect(readOnlyFs.flag, 1);
        expect(readOnlyFs.blocksFree, 0);
        expect(readOnlyFs.blocksAvailable, 0);
      });

      test('handles large filesystem sizes', () {
        final largeFs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 9223372036854775807, // max int64
          blocksFree: 4611686018427387903,
          blocksAvailable: 4611686018427387903,
          files: 1000000000,
          filesFree: 500000000,
          filesAvailable: 500000000,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        expect(largeFs.blocks, 9223372036854775807);
      });

      test('handles different block sizes', () {
        final smallBlock = SftpStatVfs(
          blockSize: 512,
          fragmentSize: 512,
          blocks: 1000,
          blocksFree: 500,
          blocksAvailable: 400,
          files: 100,
          filesFree: 50,
          filesAvailable: 45,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        final largeBlock = SftpStatVfs(
          blockSize: 8192,
          fragmentSize: 8192,
          blocks: 1000,
          blocksFree: 500,
          blocksAvailable: 400,
          files: 100,
          filesFree: 50,
          filesAvailable: 45,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        expect(smallBlock.blockSize, 512);
        expect(largeBlock.blockSize, 8192);
      });
    });

    group('SFTP operations edge cases', () {
      test('handles empty filename', () {
        final name = SftpName(filename: '', attrs: SftpFileAttrs());
        expect(name.filename, isEmpty);
      });

      test('handles maximum filename length', () {
        final longName = 'a' * 255;
        final name = SftpName(filename: longName, attrs: SftpFileAttrs());
        expect(name.filename.length, 255);
      });

      test('handles zero-byte files', () {
        final attrs = SftpFileAttrs(size: 0);
        expect(attrs.size, 0);
      });

      test('handles filesystem with zero free space', () {
        final fullFs = SftpStatVfs(
          blockSize: 4096,
          fragmentSize: 4096,
          blocks: 1000,
          blocksFree: 0,
          blocksAvailable: 0,
          files: 100,
          filesFree: 0,
          filesAvailable: 0,
          sid: 1,
          flag: 0,
          namemax: 255,
        );

        expect(fullFs.blocksFree, 0);
        expect(fullFs.blocksAvailable, 0);
      });

      test('handles permissions with all bits set', () {
        final attrs = SftpFileAttrs(permissions: 0o7777);
        expect(attrs.permissions, 0o7777);
      });

      test('handles permissions with no bits set', () {
        final attrs = SftpFileAttrs(permissions: 0o0000);
        expect(attrs.permissions, 0o0000);
      });

      test('handles special file types in permissions', () {
        // Directory: 040000
        // Regular file: 0100000
        // Symbolic link: 0120000
        // Socket: 0140000
        // Character device: 0020000
        // Block device: 0060000
        // FIFO: 0010000

        final dirPerms = SftpFileAttrs(permissions: 0o040755);
        final filePerms = SftpFileAttrs(permissions: 0o100644);
        final linkPerms = SftpFileAttrs(permissions: 0o120777);

        expect(dirPerms.permissions, 0o040755);
        expect(filePerms.permissions, 0o100644);
        expect(linkPerms.permissions, 0o120777);
      });

      test('handles file modification times in the past', () {
        final past = DateTime(2000, 1, 1);
        final attrs = SftpFileAttrs(modifyTime: past);

        expect(attrs.modifyTime, past);
        expect(attrs.modifyTime!.isBefore(DateTime.now()), isTrue);
      });

      test('handles file modification times in the future', () {
        final future = DateTime(2100, 1, 1);
        final attrs = SftpFileAttrs(modifyTime: future);

        expect(attrs.modifyTime, future);
        expect(attrs.modifyTime!.isAfter(DateTime.now()), isTrue);
      });
    });
  });
}
