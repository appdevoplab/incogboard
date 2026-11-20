// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-C (gesture typing). Wave 0 placeholder decodes nothing.
import '../contracts.dart';

GestureDecoder createGestureDecoder({required LexiconSource lexicons}) => _NoopGestureDecoder();

class _NoopGestureDecoder implements GestureDecoder {
  @override
  Future<void> prepare({
    required KeyboardGeometry geometry,
    required List<LanguageId> languages,
    Iterable<LexiconEntry> extraWords = const [],
  }) async {}

  @override
  Future<List<Suggestion>> decode(
    GesturePath path, {
    List<String> previousWords = const [],
    int maxResults = 6,
  }) async => const [];

  @override
  Future<String?> preview(GesturePath partialPath) async => null;

  @override
  void trimMemory() {}

  @override
  void dispose() {}
}
