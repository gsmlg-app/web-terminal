import 'package:flutter_test/flutter_test.dart';
import 'package:terminal_core/terminal_core.dart';

void main() {
  group('FileSystemEntityType', () {
    test('has all expected values', () {
      expect(FileSystemEntityType.values, hasLength(6));
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.file));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.directory),
      );
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.link));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.socket),
      );
      expect(FileSystemEntityType.values, contains(FileSystemEntityType.pipe));
      expect(
        FileSystemEntityType.values,
        contains(FileSystemEntityType.unknown),
      );
    });

    test('file type has correct name', () {
      expect(FileSystemEntityType.file.name, 'file');
    });

    test('directory type has correct name', () {
      expect(FileSystemEntityType.directory.name, 'directory');
    });

    test('link type has correct name', () {
      expect(FileSystemEntityType.link.name, 'link');
    });
  });

  group('FileMode', () {
    test('has all expected values', () {
      expect(FileMode.values, hasLength(5));
      expect(FileMode.values, contains(FileMode.read));
      expect(FileMode.values, contains(FileMode.write));
      expect(FileMode.values, contains(FileMode.append));
      expect(FileMode.values, contains(FileMode.writeOnly));
      expect(FileMode.values, contains(FileMode.writeOnlyAppend));
    });

    test('read mode has correct name', () {
      expect(FileMode.read.name, 'read');
    });

    test('write mode has correct name', () {
      expect(FileMode.write.name, 'write');
    });

    test('append mode has correct name', () {
      expect(FileMode.append.name, 'append');
    });
  });

  group('FileStat', () {
    test('creates with required parameters', () {
      final now = DateTime.now();
      final stat = FileStat(
        changed: now,
        modified: now,
        accessed: now,
        type: FileSystemEntityType.file,
        size: 1024,
      );

      expect(stat.changed, now);
      expect(stat.modified, now);
      expect(stat.accessed, now);
      expect(stat.type, FileSystemEntityType.file);
      expect(stat.size, 1024);
    });

    test('stores different timestamps', () {
      final changed = DateTime(2025, 1, 1);
      final modified = DateTime(2025, 1, 2);
      final accessed = DateTime(2025, 1, 3);

      final stat = FileStat(
        changed: changed,
        modified: modified,
        accessed: accessed,
        type: FileSystemEntityType.directory,
        size: 4096,
      );

      expect(stat.changed, changed);
      expect(stat.modified, modified);
      expect(stat.accessed, accessed);
    });

    test('can represent zero size', () {
      final stat = FileStat(
        changed: DateTime.now(),
        modified: DateTime.now(),
        accessed: DateTime.now(),
        type: FileSystemEntityType.file,
        size: 0,
      );

      expect(stat.size, 0);
    });

    test('can represent large file size', () {
      final largeSize = 1024 * 1024 * 1024 * 100; // 100 GB
      final stat = FileStat(
        changed: DateTime.now(),
        modified: DateTime.now(),
        accessed: DateTime.now(),
        type: FileSystemEntityType.file,
        size: largeSize,
      );

      expect(stat.size, largeSize);
    });

    test('stores all entity types', () {
      for (final type in FileSystemEntityType.values) {
        final stat = FileStat(
          changed: DateTime.now(),
          modified: DateTime.now(),
          accessed: DateTime.now(),
          type: type,
          size: 0,
        );
        expect(stat.type, type);
      }
    });
  });

  group('FileSystemEvent', () {
    test('create constant has correct value', () {
      expect(FileSystemEvent.create, 1 << 0);
      expect(FileSystemEvent.create, 1);
    });

    test('modify constant has correct value', () {
      expect(FileSystemEvent.modify, 1 << 1);
      expect(FileSystemEvent.modify, 2);
    });

    test('delete constant has correct value', () {
      expect(FileSystemEvent.delete, 1 << 2);
      expect(FileSystemEvent.delete, 4);
    });

    test('move constant has correct value', () {
      expect(FileSystemEvent.move, 1 << 3);
      expect(FileSystemEvent.move, 8);
    });

    test('all combines all event types', () {
      final expectedAll =
          FileSystemEvent.create |
          FileSystemEvent.modify |
          FileSystemEvent.delete |
          FileSystemEvent.move;

      expect(FileSystemEvent.all, expectedAll);
      expect(FileSystemEvent.all, 15);
    });

    test('creates with all parameters', () {
      final event = FileSystemEvent(
        FileSystemEvent.create,
        '/path/to/file',
        false,
      );

      expect(event.type, FileSystemEvent.create);
      expect(event.path, '/path/to/file');
      expect(event.isDirectory, false);
    });

    test('creates directory event', () {
      final event = FileSystemEvent(
        FileSystemEvent.delete,
        '/path/to/dir',
        true,
      );

      expect(event.type, FileSystemEvent.delete);
      expect(event.path, '/path/to/dir');
      expect(event.isDirectory, true);
    });

    test('event types can be combined with OR', () {
      final createOrModify = FileSystemEvent.create | FileSystemEvent.modify;
      expect(createOrModify, 3);

      final allExceptMove =
          FileSystemEvent.create |
          FileSystemEvent.modify |
          FileSystemEvent.delete;
      expect(allExceptMove, 7);
    });
  });

  group('FileSystemException', () {
    test('creates with message and path', () {
      final exception = FileSystemException('File not found', '/path/to/file');

      expect(exception.message, 'File not found');
      expect(exception.path, '/path/to/file');
    });

    test('toString includes message and path', () {
      final exception = FileSystemException('Permission denied', '/etc/passwd');
      final str = exception.toString();

      expect(str, contains('FileSystemException'));
      expect(str, contains('Permission denied'));
      expect(str, contains('/etc/passwd'));
    });

    test('handles empty message', () {
      final exception = FileSystemException('', '/path');
      expect(exception.message, '');
    });

    test('handles empty path', () {
      final exception = FileSystemException('Error', '');
      expect(exception.path, '');
    });

    test('handles special characters in path', () {
      final exception = FileSystemException(
        'Error',
        '/path/with spaces/and "quotes"',
      );
      expect(exception.path, '/path/with spaces/and "quotes"');
    });
  });
}
