import 'dart:io';
import 'package:path/path.dart' as p;

void main() {
  final schemasPath = p.join('tbdex', 'hosted', 'json-schemas');
  final outputDir = Directory('lib/src/protocol/json_schemas')
    ..createSync(recursive: true);

  Directory(schemasPath)
      .listSync()
      .whereType<File>()
      .where((file) => file.path.endsWith('.json'))
      .forEach((file) {
    final json = file.readAsStringSync();
    final dartCode = _generateCode(file.path, json);

    File(p.join(outputDir.path, '${_getFileName(file.path)}.dart'))
        .writeAsStringSync(dartCode);
  });
}

String _generateCode(String filePath, String jsonString) => '''
class ${_getClassName(filePath)} {
  static const String json = r\'\'\'
  $jsonString\'\'\';
}''';

String _getFileName(String filePath) {
  var segments = p.split(filePath);
  final index = segments.indexOf('json-schemas');
  final baseName = segments[index + 1].split('.').first;

  return '${_toSnakeCase(baseName)}_schema';
}

String _getClassName(String filePath) {
  var segments = p.split(filePath);
  final index = segments.indexOf('json-schemas');
  final baseName = segments[index + 1].split('.').first;

  return '${_toCamelCase(baseName)}Schema';
}

String _toSnakeCase(String input) => input.replaceAll('-', '_').toLowerCase();

String _toCamelCase(String input) => input
    .split(RegExp('[_-]'))
    .map(
      (str) => str.isEmpty
          ? ''
          : str[0].toUpperCase() + str.substring(1).toLowerCase(),
    )
    .join();
