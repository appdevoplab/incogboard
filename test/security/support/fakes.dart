// SPDX-License-Identifier: GPL-3.0-or-later
//
// Test doubles for the security layer: an encrypted-store fake that can pretend the phone is
// locked, and mocktail mocks for the platform host APIs.
import 'dart:typed_data';

import 'package:mocktail/mocktail.dart';
import 'package:kosha/src/bridge/messages.g.dart';
import 'package:kosha/src/core/secure_blob_store.dart';

/// Keeps blobs in memory. Names in [locked] read as null, as they do while the phone is locked,
/// but still show up in [PlatformHostApi.secureList] (see [MockPlatform]).
class FakeBlobStore implements SecureBlobStore {
  final Map<String, Uint8List> blobs = {};
  final Set<String> locked = {};
  int writes = 0;

  @override
  Future<Uint8List?> read(String name) async => locked.contains(name) ? null : blobs[name];

  @override
  Future<void> write(String name, Uint8List data) async {
    writes++;
    blobs[name] = Uint8List.fromList(data);
  }

  @override
  Future<void> delete(String name) async => blobs.remove(name);

  @override
  Future<void> wipeAll() async => blobs.clear();
}

class MockPlatform extends Mock implements PlatformHostApi {}

class MockAppHost extends Mock implements AppHostApi {}

/// The blob list the platform reports for [store], locked or not.
List<SecureBlobInfo> blobInfos(FakeBlobStore store) => [
  for (final name in {...store.blobs.keys, ...store.locked}.toList()..sort())
    SecureBlobInfo(name: name, sizeBytes: (store.blobs[name]?.length ?? 16), modifiedMillis: 0),
];

/// Stubs the calls the security code makes on [platform] for a store.
void stubPlatform(MockPlatform platform, FakeBlobStore store, {String dataDirectory = '/unused'}) {
  when(() => platform.secureList()).thenAnswer((_) async => blobInfos(store));
  when(() => platform.getDataDirectory()).thenAnswer((_) async => dataDirectory);
  when(() => platform.hasInternetPermission()).thenAnswer((_) async => false);
  when(() => platform.getAppInfo()).thenAnswer(
    (_) async => AppInfoMessage(
      packageName: 'app.kosha.keyboard',
      versionName: '1.0.0',
      versionCode: 1,
      sdkInt: 36,
      isDebugBuild: false,
    ),
  );
}

void registerSecurityFallbacks() {
  registerFallbackValue(<String>[]);
}

/// Stubs the settings-app host API and the change notification every screen sends.
void stubApp(MockAppHost app, MockPlatform platform) {
  when(() => app.setSecureScreen(any())).thenAnswer((_) async {});
  when(() => platform.notifySettingsChanged(any())).thenAnswer((_) async {});
}
