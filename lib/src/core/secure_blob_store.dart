// SPDX-License-Identifier: GPL-3.0-or-later
//
// CONTRACT (Wave 0). Encrypted storage for anything derived from typing:
// learned words, n-grams, clipboard history, personal shortcuts.
import 'dart:typed_data';

import '../bridge/messages.g.dart';

abstract interface class SecureBlobStore {
  /// Returns null when missing, or when it cannot be decrypted (for example
  /// while the phone is locked). Callers must treat null as "no data yet".
  Future<Uint8List?> read(String name);

  Future<void> write(String name, Uint8List data);
  Future<void> delete(String name);

  /// Deletes every blob and destroys the encryption key.
  Future<void> wipeAll();
}

/// AES-256-GCM via the Android Keystore (Kotlin SecureStore).
class PlatformSecureBlobStore implements SecureBlobStore {
  PlatformSecureBlobStore(this._api);

  final PlatformHostApi _api;

  @override
  Future<Uint8List?> read(String name) async {
    try {
      return await _api.secureRead(name);
    } on Object {
      return null;
    }
  }

  @override
  Future<void> write(String name, Uint8List data) => _api.secureWrite(name, data);

  @override
  Future<void> delete(String name) => _api.secureDelete(name);

  @override
  Future<void> wipeAll() => _api.secureWipeAll();
}

/// For tests and previews.
class InMemorySecureBlobStore implements SecureBlobStore {
  final Map<String, Uint8List> _blobs = {};

  @override
  Future<Uint8List?> read(String name) async => _blobs[name];

  @override
  Future<void> write(String name, Uint8List data) async => _blobs[name] = Uint8List.fromList(data);

  @override
  Future<void> delete(String name) async => _blobs.remove(name);

  @override
  Future<void> wipeAll() async => _blobs.clear();
}
