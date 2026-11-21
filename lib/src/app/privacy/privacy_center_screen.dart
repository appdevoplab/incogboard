// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. The privacy center: proof of no internet, what is stored, typing privacy,
// always-incognito apps, personal shortcuts, learned words, app lock, backup and wipe.
// Keep `const PrivacyCenterScreen()` working.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../../core/data_sections.dart';
import '../../core/seen_apps.dart';
import '../../security/app_auth.dart';
import '../../security/data_wiper.dart';
import '../../settings/myna_settings.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../routes.dart';
import 'backup_screen.dart';
import 'learned_words_screen.dart';
import 'privacy_deps.dart';
import 'privacy_format.dart';
import 'privacy_widgets.dart';
import 'shortcuts_screen.dart';

class PrivacyCenterScreen extends StatefulWidget {
  const PrivacyCenterScreen({super.key, this.authenticator});

  /// Defaults to the device's biometric or PIN. Tests pass a fake.
  final AppAuthenticator? authenticator;

  @override
  State<PrivacyCenterScreen> createState() => _PrivacyCenterScreenState();
}

/// Everything the center shows that is not in settings.
class _CenterData {
  const _CenterData({
    required this.internetPermission,
    required this.debugBuild,
    required this.blobs,
    required this.themeFiles,
    required this.themeBytes,
    required this.shortcutCount,
    required this.apps,
    required this.nowMillis,
  });

  final bool internetPermission;
  final bool debugBuild;
  final List<SecureBlobInfo> blobs;
  final int themeFiles;
  final int themeBytes;
  final int shortcutCount;
  final List<SeenApp> apps;
  final int nowMillis;

  List<String> get learnedBlobNames => [
    for (final b in blobs)
      if (b.name.startsWith(DataBlobs.learnedPrefix)) b.name,
  ];

  SecureBlobInfo? blob(String name) {
    for (final b in blobs) {
      if (b.name == name) return b;
    }
    return null;
  }
}

class _PrivacyCenterScreenState extends State<PrivacyCenterScreen> {
  AppServices? _services;
  PrivacyDeps? _deps;
  Future<_CenterData>? _future;
  late final AppAuthenticator _auth = widget.authenticator ?? LocalAuthAuthenticator();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_services != null) return;
    _services = AppScope.of(context);
    _reload();
  }

  void _reload() {
    setState(() {
      _future = _load();
    });
  }

  Future<_CenterData> _load() async {
    final services = _services!;
    final deps = _deps ??= await PrivacyDeps.load(services);
    deps.shortcuts.invalidate();
    services.seenApps.invalidate();
    final internet = await deps.platform.hasInternetPermission();
    final info = await deps.platform.getAppInfo();
    final blobs = await deps.platform.secureList();
    final themeFiles = await deps.themes.list();
    final shortcutCount = (await deps.shortcuts.list()).length;
    final apps = await services.seenApps.list();
    return _CenterData(
      internetPermission: internet,
      debugBuild: info.isDebugBuild,
      blobs: blobs,
      themeFiles: themeFiles.length,
      themeBytes: themeFiles.fold(0, (sum, f) => sum + f.sizeBytes),
      shortcutCount: shortcutCount,
      apps: apps,
      nowMillis: DateTime.now().millisecondsSinceEpoch,
    );
  }

  Future<void> _updatePrivacy(PrivacySettings Function(PrivacySettings current) change) async {
    final services = _services!;
    await services.settings.update(
      (s) => s.copyWith(privacy: change(s.privacy)),
      sections: const [SettingsSection.privacy],
    );
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    return ListenableBuilder(
      listenable: services.settings,
      builder: (context, _) => FutureBuilder<_CenterData>(
        future: _future,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return const Scaffold(body: Center(child: Text('Myna could not read its privacy data. Try again later.')));
          }
          if (!snapshot.hasData) return const Scaffold(body: Center(child: CircularProgressIndicator()));
          return SettingsPage(
            title: 'Privacy',
            header: const Padding(
              padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
              child: Align(alignment: Alignment.centerLeft, child: PrivacyMascotSlot()),
            ),
            children: _sections(snapshot.requireData, services.settings.value.privacy),
          );
        },
      ),
    );
  }

  List<Widget> _sections(_CenterData d, PrivacySettings privacy) => [
    _proof(d),
    _storedData(d),
    _typing(privacy),
    _incognitoApps(d, privacy),
    _shortcutsGroup(d, privacy),
    _learnedGroup(d),
    _appLockGroup(privacy),
    _backupGroup(),
    _wipeGroup(d),
  ];

  // ---- 1. Proof of no internet ---------------------------------------------------------

  Widget _proof(_CenterData d) {
    if (d.debugBuild) {
      return SettingsGroup(
        children: [
          PrivacyStatusCard(
            icon: Icons.developer_mode,
            text: d.internetPermission
                ? 'This is a development build. Its network permission is for development tools only.'
                : 'Development build. Myna still has no internet permission.',
          ),
        ],
      );
    }
    if (d.internetPermission) {
      return const SettingsGroup(
        children: [
          PrivacyStatusCard(
            icon: Icons.warning_amber,
            text: 'This build requests internet access. Myna should never do that. Please report it.',
            tone: PrivacyTone.bad,
          ),
        ],
      );
    }
    return const SettingsGroup(
      children: [
        PrivacyStatusCard(
          icon: Icons.verified_user_outlined,
          text: 'Myna has no internet permission. It cannot send anything.',
          tone: PrivacyTone.good,
        ),
      ],
    );
  }

  // ---- 2. What is stored ------------------------------------------------------------

  Widget _storedData(_CenterData d) {
    final nowMillis = d.nowMillis;
    final blobTiles = [
      for (final b in d.blobs)
        SettingsTile(
          icon: Icons.inventory_2_outlined,
          title: friendlyBlobName(b.name),
          subtitle: '${formatBytes(b.sizeBytes)} · changed ${timeAgo(b.modifiedMillis, nowMillis: nowMillis)}',
        ),
      if (d.themeFiles > 0)
        SettingsTile(
          icon: Icons.palette_outlined,
          title: 'Custom themes',
          subtitle: '${plural(d.themeFiles, 'file')} · ${formatBytes(d.themeBytes)}',
        ),
      if (d.blobs.isEmpty && d.themeFiles == 0)
        const SettingsTile(icon: Icons.inbox_outlined, title: 'Nothing stored yet'),
    ];
    return Column(
      children: [
        SettingsGroup(title: 'What Myna stores', children: blobTiles),
        const Padding(
          padding: EdgeInsets.fromLTRB(16, 0, 16, 20),
          child: Text(
            'Myna shows only sizes here, never what is inside. Sizes include the last saved copy, which keeps your '
            'data safe if a save is interrupted.',
          ),
        ),
      ],
    );
  }

  // ---- 3. Typing privacy --------------------------------------------------------------

  Widget _typing(PrivacySettings p) => SettingsGroup(
    title: 'Typing privacy',
    children: [
      SettingsSwitchTile(
        icon: Icons.auto_awesome_outlined,
        title: 'Learn new words',
        subtitle: 'Learn words and phrases from what you type. Never in password fields or incognito.',
        value: p.learning,
        onChanged: (v) => unawaited(_updatePrivacy((c) => c.copyWith(learning: v))),
      ),
      SettingsSwitchTile(
        icon: Icons.visibility_off_outlined,
        title: 'Incognito',
        subtitle: 'Learn and remember nothing while on. Browser incognito tabs turn this on by themselves.',
        value: p.incognito,
        onChanged: (v) => unawaited(_updatePrivacy((c) => c.copyWith(incognito: v))),
      ),
      SettingsSwitchTile(
        icon: Icons.screenshot_outlined,
        title: 'Hide from screenshots',
        subtitle:
            'Stop screenshots and screen recordings of the keyboard in every app. Password fields are always '
            'hidden.',
        value: p.hideFromScreenshots,
        onChanged: (v) => unawaited(_updatePrivacy((c) => c.copyWith(hideFromScreenshots: v))),
      ),
    ],
  );

  // ---- 4. Always-incognito apps -----------------------------------------------------

  Widget _incognitoApps(_CenterData d, PrivacySettings p) {
    final rows = <Widget>[
      const SettingsTile(
        icon: Icons.info_outline,
        title: 'Turned off automatically in these apps',
        subtitle:
            'Myna keeps app names only to fill this list. They are encrypted, never recorded while incognito, '
            'and you can clear them below.',
      ),
      if (d.apps.isEmpty)
        const SettingsTile(
          icon: Icons.apps_outlined,
          title: 'No apps yet',
          subtitle: 'Apps you type in will appear here.',
        ),
      for (final app in d.apps)
        _AppIncognitoTile(
          app: app,
          incognito: p.incognitoApps.contains(app.packageName),
          onIncognito: (v) => _setAppIncognito(app.packageName, v),
          onRemove: () => _removeApp(app.packageName),
        ),
    ];
    return SettingsGroup(title: 'Always incognito apps', children: rows);
  }

  Future<void> _setAppIncognito(String packageName, bool on) async {
    final current = _services!.settings.value.privacy.incognitoApps;
    final next = on
        ? [...current.where((p) => p != packageName), packageName]
        : current.where((p) => p != packageName).toList();
    await _updatePrivacy((c) => c.copyWith(incognitoApps: next));
  }

  Future<void> _removeApp(String packageName) async {
    final services = _services!;
    await services.seenApps.remove(packageName);
    await services.notifyDataChanged(const [DataSections.seenApps]);
    if (_services!.settings.value.privacy.incognitoApps.contains(packageName)) {
      await _setAppIncognito(packageName, false);
    }
    _reload();
  }

  // ---- 5. Personal shortcuts ----------------------------------------------------------

  Widget _shortcutsGroup(_CenterData d, PrivacySettings p) => SettingsGroup(
    title: 'Personal shortcuts',
    children: [
      SettingsSwitchTile(
        icon: Icons.keyboard_alt_outlined,
        title: 'Offer shortcuts',
        subtitle: 'Show your short forms, such as "omw", as the first suggestion.',
        value: p.personalShortcuts,
        onChanged: (v) => unawaited(_updatePrivacy((c) => c.copyWith(personalShortcuts: v))),
      ),
      SettingsTile(
        icon: Icons.edit_note,
        title: 'Edit shortcuts',
        subtitle: d.shortcutCount == 0 ? 'None yet' : plural(d.shortcutCount, 'shortcut'),
        onTap: () => unawaited(_open(const ShortcutsScreen()).then((_) => _reload())),
      ),
    ],
  );

  // ---- 6. Learned words and clipboard ---------------------------------------------------

  Widget _learnedGroup(_CenterData d) {
    final nowMillis = d.nowMillis;
    final clipboard = d.blob(DataBlobs.clipboard);
    return SettingsGroup(
      title: 'Learned words and clipboard',
      children: [
        if (d.learnedBlobNames.isEmpty)
          const SettingsTile(
            icon: Icons.text_fields,
            title: 'No words learned yet',
            subtitle: 'Words you type are learned here once Myna has seen them a few times.',
          ),
        for (final name in d.learnedBlobNames)
          SettingsTile(
            icon: Icons.menu_book_outlined,
            title: friendlyBlobName(name),
            subtitle: 'Review, remove or block words · ${timeAgo(d.blob(name)!.modifiedMillis, nowMillis: nowMillis)}',
            onTap: () => unawaited(
              _open(LearnedWordsScreen(languageId: name.substring(DataBlobs.learnedPrefix.length)))
                  .then((_) => _reload()),
            ),
          ),
        SettingsTile(
          icon: Icons.content_paste_outlined,
          title: 'Clipboard',
          subtitle: clipboard == null
              ? 'History is empty. Change clipboard settings in Panels.'
              : '${formatBytes(clipboard.sizeBytes)} in history. Change clipboard settings in Panels.',
          onTap: () => Navigator.of(context).pushNamed(MynaRoutes.panels),
        ),
      ],
    );
  }

  // ---- 7. App lock -------------------------------------------------------------------

  Widget _appLockGroup(PrivacySettings p) => SettingsGroup(
    title: 'App lock',
    children: [
      SettingsSwitchTile(
        icon: Icons.fingerprint,
        title: 'Lock Myna',
        subtitle: 'Ask for your fingerprint or device PIN when the app opens, or after it was in the background.',
        value: p.appLock,
        onChanged: (v) => unawaited(_setAppLock(v)),
      ),
      SettingsTile(
        icon: Icons.timer_outlined,
        title: 'Lock after',
        subtitle: AppLockPolicy.timeoutLabel(p.appLockTimeoutSeconds),
        enabled: p.appLock,
        onTap: p.appLock ? () => unawaited(_pickTimeout(p)) : null,
      ),
    ],
  );

  Future<void> _setAppLock(bool on) async {
    if (!on) {
      await _updatePrivacy((c) => c.copyWith(appLock: false));
      return;
    }
    if (!await _auth.isDeviceSecure()) {
      if (!mounted) return;
      await _info(
        'Set a screen lock first',
        'App lock uses your fingerprint or device PIN. Set a PIN, pattern or password in Android\'s security '
            'settings, then come back.',
      );
      return;
    }
    // Turning it on needs one successful check first, so the user knows it works.
    final outcome = await _auth.authenticate('Turn on app lock for Myna');
    if (!mounted) return;
    if (outcome == AuthOutcome.success) {
      await _updatePrivacy((c) => c.copyWith(appLock: true));
    } else if (outcome == AuthOutcome.unavailable) {
      await _info('Not available right now', 'Your device lock could not be used. App lock stays off.');
    }
  }

  Future<void> _pickTimeout(PrivacySettings p) async {
    final picked = await showDialog<int>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Lock after'),
        children: [
          RadioGroup<int>(
            groupValue: p.appLockTimeoutSeconds,
            onChanged: (v) => Navigator.of(context).pop(v),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                for (final seconds in AppLockPolicy.timeoutChoices)
                  RadioListTile<int>(value: seconds, title: Text(AppLockPolicy.timeoutLabel(seconds))),
              ],
            ),
          ),
        ],
      ),
    );
    if (picked == null) return;
    await _updatePrivacy((c) => c.copyWith(appLockTimeoutSeconds: picked));
  }

  // ---- 8. Backup ---------------------------------------------------------------------

  Widget _backupGroup() => SettingsGroup(
    title: 'Backup',
    children: [
      SettingsTile(
        icon: Icons.archive_outlined,
        title: 'Backup and restore',
        subtitle: 'An encrypted .mynabackup file you keep. You choose what goes in it.',
        onTap: () => unawaited(_open(const BackupScreen()).then((_) => _reload())),
      ),
    ],
  );

  // ---- 9. Wipe -----------------------------------------------------------------------

  Widget _wipeGroup(_CenterData d) => SettingsGroup(
    title: 'Delete data',
    children: [
      for (final c in WipeCategory.values)
        SettingsTile(
          icon: Icons.delete_outline,
          title: c.title,
          subtitle: c.detail,
          onTap: () => unawaited(_confirmWipe({c}, everything: false)),
        ),
      SettingsTile(
        icon: Icons.delete_forever_outlined,
        title: 'Erase everything',
        subtitle: 'Every category above, your custom themes, and the key that protects them.',
        onTap: () => unawaited(_confirmWipe(WipeCategory.values.toSet(), everything: true)),
      ),
    ],
  );

  Future<void> _confirmWipe(Set<WipeCategory> categories, {required bool everything}) async {
    final deps = _deps;
    if (deps == null) return;
    var resetSettings = false;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialog) => AlertDialog(
          title: Text(everything ? 'Erase everything?' : 'Delete ${categories.first.title.toLowerCase()}?'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('This will permanently delete:'),
                const SizedBox(height: 8),
                for (final c in categories)
                  Padding(padding: const EdgeInsets.only(bottom: 8), child: Text('${c.title}: ${c.detail}')),
                if (everything)
                  CheckboxListTile(
                    contentPadding: EdgeInsets.zero,
                    value: resetSettings,
                    title: const Text('Also reset all settings to their defaults'),
                    onChanged: (v) => setDialog(() => resetSettings = v ?? false),
                  ),
                const SizedBox(height: 8),
                Text(
                  'This cannot be undone.',
                  style: TextStyle(color: Theme.of(context).colorScheme.error, fontWeight: FontWeight.w600),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
            FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: Theme.of(context).colorScheme.error,
                foregroundColor: Theme.of(context).colorScheme.onError,
              ),
              onPressed: () => Navigator.of(context).pop(true),
              child: const Text('Delete'),
            ),
          ],
        ),
      ),
    );
    if (confirmed != true) return;
    try {
      if (everything) {
        await deps.wiper.wipeEverything(resetSettings: resetSettings);
      } else {
        await deps.wiper.wipe(categories);
      }
      if (mounted) showPrivacyMessage(context, 'Deleted.');
    } on Object {
      if (mounted) showPrivacyMessage(context, 'Myna could not delete everything. Try again.');
    }
    _reload();
  }

  // ---- helpers -----------------------------------------------------------------------

  Future<void> _info(String title, String body) => showDialog<void>(
    context: context,
    builder: (context) => AlertDialog(
      title: Text(title),
      content: Text(body),
      actions: [FilledButton(onPressed: () => Navigator.of(context).pop(), child: const Text('OK'))],
    ),
  );

  Future<T?> _open<T>(Widget screen) => Navigator.of(context).push<T>(MaterialPageRoute<T>(builder: (_) => screen));
}

/// One always-incognito app: a switch to turn it on, and a button to forget the app.
class _AppIncognitoTile extends StatelessWidget {
  const _AppIncognitoTile({
    required this.app,
    required this.incognito,
    required this.onIncognito,
    required this.onRemove,
  });

  final SeenApp app;
  final bool incognito;
  final ValueChanged<bool> onIncognito;
  final VoidCallback onRemove;

  @override
  Widget build(BuildContext context) {
    final label = app.label ?? app.packageName;
    return ListTile(
      leading: const Icon(Icons.apps),
      title: Text(label),
      subtitle: app.label == null ? null : Text(app.packageName),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      trailing: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Switch(value: incognito, onChanged: onIncognito),
          IconButton(tooltip: 'Remove $label from the list', onPressed: onRemove, icon: const Icon(Icons.close)),
        ],
      ),
    );
  }
}
