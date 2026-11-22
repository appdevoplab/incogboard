// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. Encrypted backup: choose sections, set a passphrase, save a .koshabackup file;
// or open one, check the counts, then merge or replace. Shown with FLAG_SECURE.
//
// PRIVACY: passphrases, contents and file names are never logged or shown outside this screen.
import 'dart:async';

import 'package:flutter/services.dart' show PlatformException;
import 'package:material_ui/material_ui.dart';

import '../../security/app_auth.dart';
import '../../security/backup/backup_collect.dart';
import '../../security/backup/backup_payload.dart';
import '../../security/backup/backup_restore.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import 'privacy_deps.dart';
import 'privacy_format.dart';
import 'privacy_widgets.dart';

class BackupScreen extends StatefulWidget {
  const BackupScreen({super.key});

  @override
  State<BackupScreen> createState() => _BackupScreenState();
}

class _BackupScreenState extends State<BackupScreen> {
  AppServices? _services;
  PrivacyDeps? _deps;
  Future<BackupSummary?>? _summary;
  final Set<BackupSection> _include = {
    BackupSection.settings,
    BackupSection.learned,
    BackupSection.shortcuts,
    BackupSection.emoji,
    BackupSection.themes,
  };
  bool _themeImages = false;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    SecureScreenGuard.instance.acquire();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    final services = _services = AppScope.of(context);
    _summary = _loadSummary(services);
  }

  @override
  void dispose() {
    SecureScreenGuard.instance.release();
    super.dispose();
  }

  /// Counts for the export checkboxes. Null when something is locked right now.
  Future<BackupSummary?> _loadSummary(AppServices services) async {
    try {
      final deps = _deps ??= await PrivacyDeps.load(services);
      final contents = await deps.collector.collect(include: BackupSection.values.toSet());
      return contents.summary();
    } on BackupLockedException {
      return null;
    } on Object {
      return null;
    }
  }

  void _setBusy(bool busy) {
    if (mounted) setState(() => _busy = busy);
  }

  void _message(String text) {
    if (mounted) showPrivacyMessage(context, text);
  }

  // ---- export -------------------------------------------------------------------

  Future<void> _export() async {
    final services = _services!;
    final deps = _deps ??= await PrivacyDeps.load(services);
    _setBusy(true);
    try {
      final contents = await deps.collector.collect(include: _include, includeThemeImages: _themeImages);
      final info = await services.platform.getAppInfo();
      final plain = BackupPayload(
        createdAt: DateTime.now().toUtc(),
        appVersion: '${info.versionName}+${info.versionCode}',
        contents: contents,
      ).encode();

      if (!mounted) return;
      final passphrase = await _askPassphrase(create: true);
      if (passphrase == null) return;

      final sealed = await services.app.sealBackup(plain, passphrase);
      final uri = await services.app.createDocument(_fileName(), 'application/octet-stream');
      if (uri == null) return; // The user cancelled the save dialog.
      await services.app.writeDocument(uri, sealed);
      _message('Backup saved (${formatBytes(sealed.length)}). Keep your passphrase safe.');
    } on BackupLockedException {
      _message('Unlock your phone, then try again. Nothing was saved.');
    } on PlatformException {
      _message('The backup could not be saved. Nothing was changed.');
    } finally {
      _setBusy(false);
    }
  }

  String _fileName() {
    final now = DateTime.now();
    String two(int v) => v.toString().padLeft(2, '0');
    return 'kosha-${now.year}${two(now.month)}${two(now.day)}.koshabackup';
  }

  // ---- import -------------------------------------------------------------------

  Future<void> _import() async {
    final services = _services!;
    final deps = _deps ??= await PrivacyDeps.load(services);
    _setBusy(true);
    try {
      final uri = await services.app.openDocument(const ['application/octet-stream', 'application/x-koshabackup']);
      if (uri == null) return;
      final bytes = await services.app.readDocument(uri, kMaxBackupBytes);
      if (!mounted) return;
      final passphrase = await _askPassphrase(create: false);
      if (passphrase == null) return;

      final plain = await services.app.openBackup(bytes, passphrase);
      if (plain == null) {
        _message('Wrong passphrase, or the file is damaged. Nothing was changed.');
        return;
      }
      final BackupPayload payload;
      try {
        payload = BackupPayload.decode(plain);
      } on BackupFormatException {
        _message('This file is not a valid Kosha backup. Nothing was changed.');
        return;
      }
      if (!mounted) return;
      await _previewAndRestore(payload, deps);
    } on PlatformException catch (e) {
      _message(switch (e.code) {
        'too_large' => 'This file is too large to be a Kosha backup.',
        'unsupported_version' => 'This backup was made by a newer version of Kosha. Update Kosha to restore it.',
        'busy' => 'Finish the other file window first, then try again.',
        _ => 'The backup could not be opened. Nothing was changed.',
      });
    } finally {
      _setBusy(false);
    }
  }

  Future<void> _previewAndRestore(BackupPayload payload, PrivacyDeps deps) async {
    final contents = payload.contents;
    final present = contents.present.toList()..sort((a, b) => a.index.compareTo(b.index));
    if (present.isEmpty) {
      _message('This backup has nothing in it.');
      return;
    }
    final chosen = {...present};
    var mode = RestoreMode.merge;
    final summary = contents.summary();
    final result = await showDialog<({Set<BackupSection> include, RestoreMode mode})>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: const Text('Restore backup'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Made ${_date(payload.createdAt)} by Kosha ${payload.appVersion}.'),
                const SizedBox(height: 12),
                for (final section in present)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: chosen.contains(section),
                    title: Text(section.label),
                    subtitle: Text(_countText(section, summary, restoring: true)),
                    onChanged: (v) => setDialog(() {
                      if (v ?? false) {
                        chosen.add(section);
                      } else {
                        chosen.remove(section);
                      }
                    }),
                  ),
                const Divider(),
                RadioGroup<RestoreMode>(
                  groupValue: mode,
                  onChanged: (v) => setDialog(() => mode = v ?? RestoreMode.merge),
                  child: const Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      RadioListTile<RestoreMode>(
                        contentPadding: EdgeInsets.zero,
                        value: RestoreMode.merge,
                        title: Text('Merge'),
                        subtitle: Text('Keep what is on this phone and add what is in the backup.'),
                      ),
                      RadioListTile<RestoreMode>(
                        contentPadding: EdgeInsets.zero,
                        value: RestoreMode.replace,
                        title: Text('Replace'),
                        subtitle: Text('Make the chosen sections match the backup. Data here is deleted first.'),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
            FilledButton(
              onPressed: chosen.isEmpty ? null : () => Navigator.of(context).pop((include: {...chosen}, mode: mode)),
              child: const Text('Continue'),
            ),
          ],
        ),
      ),
    );
    if (result == null || !mounted) return;
    if (result.mode == RestoreMode.replace) {
      final sure = await showDialog<bool>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Replace data on this phone?'),
          content: const Text('The chosen sections on this phone are deleted and replaced. This cannot be undone.'),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Replace')),
          ],
        ),
      );
      if (sure != true) return;
    }
    try {
      final report = await deps.restorer.apply(contents, include: result.include, mode: result.mode);
      _message(_reportText(report));
      if (mounted) {
        setState(() {
          _summary = _loadSummary(_services!);
        });
      }
    } on RestoreLockedException {
      _message('Unlock your phone, then try again. Nothing was changed.');
    } on PlatformException {
      _message('Kosha could not finish the restore. Some data may not have been written.');
    }
  }

  String _reportText(RestoreReport r) {
    final parts = <String>[
      if (r.learnedLanguages > 0) 'learned words for ${plural(r.learnedLanguages, 'language')}',
      if (r.shortcutsAdded > 0) plural(r.shortcutsAdded, 'shortcut'),
      if (r.clipboardAdded > 0) plural(r.clipboardAdded, 'clipboard item'),
      if (r.themesAdded > 0) plural(r.themesAdded, 'theme file'),
      if (r.settingsApplied) 'settings',
    ];
    final skipped = <String>[
      if (r.shortcutsSkipped > 0) '${r.shortcutsSkipped} shortcuts already here',
      if (r.themesSkipped > 0) '${r.themesSkipped} theme files already here',
      if (r.clipboardSkipped) 'clipboard left alone (unknown layout)',
      if (r.emojiKept) 'emoji recents kept',
    ];
    final added = parts.isEmpty ? 'Restored nothing new.' : 'Restored ${parts.join(', ')}.';
    return skipped.isEmpty ? added : '$added Skipped: ${skipped.join(', ')}.';
  }

  String _date(DateTime t) {
    final local = t.toLocal();
    String two(int v) => v.toString().padLeft(2, '0');
    return '${local.year}-${two(local.month)}-${two(local.day)}';
  }

  /// [restoring]: the restore dialog ticks every section the file holds, so the export-only note on
  /// the clipboard (off by default) does not apply there.
  String _countText(BackupSection section, BackupSummary? s, {bool restoring = false}) {
    if (s == null) return 'Unlock your phone to see the count';
    return switch (section) {
      BackupSection.settings => 'Theme, languages, typing and privacy choices',
      BackupSection.learned => '${plural(s.learnedWords, 'word')} in ${plural(s.learnedLanguages, 'language')}',
      BackupSection.shortcuts => plural(s.shortcuts, 'shortcut'),
      BackupSection.clipboard =>
        restoring
            ? plural(s.clipboardItems, 'pinned item')
            : '${plural(s.clipboardItems, 'pinned item')}. Off unless you turn it on.',
      BackupSection.emoji => s.emojiBytes == 0 ? 'Nothing yet' : formatBytes(s.emojiBytes),
      BackupSection.themes => '${plural(s.themes, 'file')} · ${formatBytes(s.themeBytes)}',
    };
  }

  Future<String?> _askPassphrase({required bool create}) => showDialog<String>(
    context: context,
    barrierDismissible: false,
    builder: (context) => _PassphraseDialog(create: create),
  );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Backup and restore')),
      body: FutureBuilder<BackupSummary?>(
        future: _summary,
        builder: (context, snapshot) {
          final summary = snapshot.data;
          final waiting = snapshot.connectionState != ConnectionState.done;
          return ScreenBody(
            children: [
              const PrivacyStatusCard(
                icon: Icons.lock_outline,
                text:
                    'A backup is one file, encrypted with a passphrase you choose. Only that passphrase opens it. '
                    'If you forget the passphrase, nobody can recover the backup, including Kosha.',
              ),
              const SizedBox(height: 20),
              if (waiting)
                const Center(
                  child: Padding(padding: EdgeInsets.all(16), child: CircularProgressIndicator()),
                ),
              SettingsGroup(
                title: 'Make a backup',
                children: [
                  for (final section in BackupSection.values)
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: Text(section.label),
                      subtitle: Text(_countText(section, summary)),
                      value: _include.contains(section),
                      onChanged: _busy
                          ? null
                          : (v) => setState(() {
                              if (v) {
                                _include.add(section);
                              } else {
                                _include.remove(section);
                              }
                            }),
                    ),
                  if (_include.contains(BackupSection.themes))
                    SwitchListTile(
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
                      title: const Text('Include background images'),
                      subtitle: const Text('Photos make the file much larger.'),
                      value: _themeImages,
                      onChanged: _busy ? null : (v) => setState(() => _themeImages = v),
                    ),
                ],
              ),
              FilledButton.icon(
                onPressed: _busy || _include.isEmpty ? null : () => unawaited(_export()),
                icon: const Icon(Icons.save_alt),
                label: const Text('Create encrypted backup'),
              ),
              const SizedBox(height: 28),
              SettingsGroup(
                title: 'Restore',
                children: [
                  SettingsTile(
                    icon: Icons.restore,
                    title: 'Restore from a backup file',
                    subtitle: 'Open a .koshabackup file, check what is in it, then merge or replace.',
                    onTap: _busy ? null : () => unawaited(_import()),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}

/// Asks for a passphrase. With [create], it asks twice and shows a strength meter.
class _PassphraseDialog extends StatefulWidget {
  const _PassphraseDialog({required this.create});

  final bool create;

  @override
  State<_PassphraseDialog> createState() => _PassphraseDialogState();
}

class _PassphraseDialogState extends State<_PassphraseDialog> {
  final _pass = TextEditingController();
  final _again = TextEditingController();

  @override
  void dispose() {
    _pass.dispose();
    _again.dispose();
    super.dispose();
  }

  bool get _canSave {
    if (!widget.create) return _pass.text.isNotEmpty;
    return PassphraseRules.strength(_pass.text) != PassphraseStrength.tooShort && _pass.text == _again.text;
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return AlertDialog(
      title: Text(widget.create ? 'Choose a passphrase' : 'Enter the passphrase'),
      content: ListenableBuilder(
        listenable: Listenable.merge([_pass, _again]),
        builder: (context, _) {
          final strength = PassphraseRules.strength(_pass.text);
          final mismatch = widget.create && _again.text.isNotEmpty && _again.text != _pass.text;
          return SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (widget.create) const Text('Write it down somewhere safe. A lost passphrase cannot be recovered.'),
                const SizedBox(height: 12),
                TextField(
                  controller: _pass,
                  obscureText: true,
                  autofocus: true,
                  enableSuggestions: false,
                  autocorrect: false,
                  decoration: const InputDecoration(labelText: 'Passphrase', border: OutlineInputBorder()),
                  onChanged: (_) => setState(() {}),
                ),
                if (widget.create) ...[
                  const SizedBox(height: 12),
                  TextField(
                    controller: _again,
                    obscureText: true,
                    enableSuggestions: false,
                    autocorrect: false,
                    decoration: InputDecoration(
                      labelText: 'Type it again',
                      border: const OutlineInputBorder(),
                      errorText: mismatch ? 'The passphrases do not match' : null,
                    ),
                    onChanged: (_) => setState(() {}),
                  ),
                  const SizedBox(height: 12),
                  Semantics(
                    label: 'Passphrase strength: ${strength.label}',
                    child: LinearProgressIndicator(value: strength.fraction, color: scheme.primary),
                  ),
                  const SizedBox(height: 4),
                  Text(strength.label, style: Theme.of(context).textTheme.bodySmall),
                ],
              ],
            ),
          );
        },
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        ListenableBuilder(
          listenable: Listenable.merge([_pass, _again]),
          builder: (context, _) => FilledButton(
            onPressed: _canSave ? () => Navigator.of(context).pop(_pass.text) : null,
            child: Text(widget.create ? 'Continue' : 'Open'),
          ),
        ),
      ],
    );
  }
}
