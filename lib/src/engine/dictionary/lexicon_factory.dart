// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 1-B (dictionary engine). Wave 0 placeholder returns a tiny
// in-memory English lexicon so the rest of the keyboard can run end to end.
import '../../packs/pack_repository.dart';
import '../contracts.dart';
import '../in_memory_lexicon.dart';

LexiconSource createLexiconSource({required PackRepository packs}) =>
    InMemoryLexiconSource({'en': InMemoryLexicon('en', kStarterEnglishWords)});
