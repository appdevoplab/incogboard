// SPDX-License-Identifier: GPL-3.0-or-later
//
// Builds and signs a .koshapack model pack (format: android/.../packs/PackStore.kt).
// OWNER: orchestrator. Needs `openssl` on PATH (Git for Windows ships it).
//
//   dart run tool/make_pack.dart --dir <staging folder> --id translate-en-es --kind translation \
//     --name "English → Spanish" --languages en,es --engine opus-mt-onnx --license CC-BY-4.0 \
//     [--version 1] [--key %USERPROFILE%/.kosha/keys/pack-dev.pem] --out build/packs/translate-en-es.koshapack
//
// Every file under --dir goes into the pack, with its path relative to --dir ('/' separators).
// --key defaults to the dev key (%USERPROFILE%/.kosha/keys/pack-dev.pem), which lives outside the repo.
import 'dart:convert';
import 'dart:io';
import 'dart:typed_data';

Future<void> main(List<String> argv) async {
  final args = _parse(argv);
  String need(String k) => args[k] ?? (throw ArgumentError('missing --$k'));
  final dir = Directory(need('dir'));
  final out = File(need('out'));
  final home = Platform.environment['USERPROFILE'] ?? Platform.environment['HOME'] ?? '.';
  final keyPath = args['key'] ?? '$home/.kosha/keys/pack-dev.pem';

  final files = dir.listSync(recursive: true).whereType<File>().toList()..sort((a, b) => a.path.compareTo(b.path));
  if (files.isEmpty) throw StateError('no files in ${dir.path}');
  final entries = <Map<String, Object>>[];
  for (final f in files) {
    final rel = f.path.substring(dir.path.length + 1).replaceAll(r'\', '/');
    entries.add({'path': rel, 'size': f.lengthSync(), 'sha256': await _sha256(f.path)});
    stdout.writeln('  $rel  ${f.lengthSync()} bytes');
  }
  final manifest = utf8.encode(
    jsonEncode({
      'id': need('id'),
      'kind': need('kind'),
      'name': need('name'),
      'version': int.parse(args['version'] ?? '1'),
      'languages': need('languages').split(','),
      'engine': need('engine'),
      'license': need('license'),
      'files': entries,
    }),
  );
  out.parent.createSync(recursive: true);
  final tmp = Directory.systemTemp.createTempSync('koshapack');
  try {
    final manifestFile = File('${tmp.path}/manifest.json')..writeAsBytesSync(manifest);
    final sigFile = File('${tmp.path}/manifest.sig');
    final r = await Process.run('openssl', [
      'dgst',
      '-sha256',
      '-sign',
      keyPath,
      '-out',
      sigFile.path,
      manifestFile.path,
    ]);
    if (r.exitCode != 0) throw StateError('openssl sign failed: ${r.stderr}');
    final sig = sigFile.readAsBytesSync();

    final sink = out.openWrite();
    Uint8List u32(int v) => Uint8List(4)..buffer.asByteData().setUint32(0, v);
    sink
      ..add(ascii.encode('KOSHAPAK'))
      ..add(u32(1))
      ..add(u32(manifest.length))
      ..add(manifest)
      ..add(u32(sig.length))
      ..add(sig);
    for (final f in files) {
      await sink.addStream(f.openRead());
    }
    await sink.close();
    stdout.writeln('wrote ${out.path} (${out.lengthSync()} bytes, ${files.length} files)');
  } finally {
    tmp.deleteSync(recursive: true);
  }
}

Future<String> _sha256(String path) async {
  final r = await Process.run('openssl', ['dgst', '-sha256', '-r', path]);
  if (r.exitCode != 0) throw StateError('openssl hash failed: ${r.stderr}');
  return (r.stdout as String).split(' ').first.trim().toLowerCase();
}

Map<String, String> _parse(List<String> argv) {
  final out = <String, String>{};
  for (var i = 0; i + 1 < argv.length; i += 2) {
    if (!argv[i].startsWith('--')) throw ArgumentError('unexpected ${argv[i]}');
    out[argv[i].substring(2)] = argv[i + 1];
  }
  return out;
}
