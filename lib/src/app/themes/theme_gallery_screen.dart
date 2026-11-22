// SPDX-License-Identifier: GPL-3.0-or-later
//
// The theme gallery: a carousel of the presets, then My themes (custom themes, with a menu each)
// and a Create card. Selecting a card writes appearance.themeId, and the keyboard engine updates
// at once. The dark, pure black and contrast controls apply to every theme.
import 'dart:async';

import 'package:material_ui/material_ui.dart';

import '../../core/log.dart';
import '../../settings/kosha_settings.dart';
import '../../theme/custom/custom_theme_store.dart';
import '../../theme/keyboard_theme_data.dart';
import '../../theme/presets.dart';
import '../../theme/theme_spec.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import 'theme_card.dart';
import 'theme_editor_screen.dart';
import 'theme_support.dart';

enum _CardAction { edit, duplicate, rename, delete }

class ThemeGalleryScreen extends StatefulWidget {
  const ThemeGalleryScreen({super.key});

  @override
  State<ThemeGalleryScreen> createState() => _ThemeGalleryScreenState();
}

class _ThemeGalleryScreenState extends State<ThemeGalleryScreen> {
  final ThemePreviewCache _previews = ThemePreviewCache();
  AppServices? _services;
  CustomThemeStore? _store;
  List<int>? _palettes;
  List<ThemeSpec> _custom = const [];
  bool _started = false;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (_started) return;
    _started = true;
    _services = AppScope.of(context);
    unawaited(_load());
  }

  @override
  void dispose() {
    _previews.clear();
    super.dispose();
  }

  Future<void> _load() async {
    final services = _services!;
    final palettes = await _systemPalettes(services);
    final dataDir = await services.platform.getDataDirectory();
    final store = CustomThemeStore(themesDirectoryFor(dataDir));
    final custom = await store.list();
    if (!mounted) return;
    setState(() {
      _store = store;
      _palettes = palettes;
      _custom = custom;
    });
  }

  /// The wallpaper palettes, or null where the platform gives none (Android below 12).
  Future<List<int>?> _systemPalettes(AppServices services) async {
    try {
      return (await services.platform.getSystemColors())?.palettes;
    } on Object catch (e) {
      KoshaLog.w('Theme', 'system colours unavailable', e.runtimeType);
      return null;
    }
  }

  Future<void> _reloadCustom() async {
    final store = _store;
    if (store == null) return;
    final custom = await store.list();
    if (mounted) setState(() => _custom = custom);
  }

  /// Writes settings and tells the user if that fails. Appearance changes reach the keyboard engine.
  Future<void> _commit(KoshaSettings Function(KoshaSettings current) change) async {
    try {
      await _services!.settings.update(change, sections: const [SettingsSection.appearance]);
    } on Object catch (e) {
      KoshaLog.w('Theme', 'settings write failed', e.runtimeType);
      _snack('Could not save the setting.');
    }
  }

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }

  /// Selects [themeId] (a preset or `custom:<uuid>`).
  void _select(String themeId) =>
      unawaited(_commit((c) => c.copyWith(appearance: c.appearance.copyWith(themeId: themeId))));

  /// Bumps the custom theme revision so the keyboard re-reads files that changed; optionally also
  /// changes the selected theme (used when the selected custom theme is deleted).
  static KoshaSettings _bumpRevision(KoshaSettings c, {String? themeId}) => c.copyWith(
    appearance: c.appearance.copyWith(themeId: themeId, customThemeRevision: c.appearance.customThemeRevision + 1),
  );

  Future<void> _openEditor(String? themeId) async {
    // The route sits below the Navigator, which may be below AppScope, so the scope is passed in again here.
    final services = _services!;
    await Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => AppScope(
          services: services,
          child: ThemeEditorScreen(themeId: themeId),
        ),
      ),
    );
    await _reloadCustom();
  }

  Future<void> _onAction(ThemeSpec spec, _CardAction action) async {
    switch (action) {
      case _CardAction.edit:
        await _openEditor(spec.id);
      case _CardAction.duplicate:
        await _duplicate(spec);
      case _CardAction.rename:
        await _rename(spec);
      case _CardAction.delete:
        await _delete(spec);
    }
  }

  Future<void> _duplicate(ThemeSpec spec) async {
    final store = _store;
    if (store == null) return;
    try {
      await store.duplicate(spec, copyNameFor(spec.name));
      await _reloadCustom();
    } on Object catch (e) {
      KoshaLog.w('Theme', 'duplicate failed', e.runtimeType);
      _snack('Could not copy the theme.');
    }
  }

  Future<void> _rename(ThemeSpec spec) async {
    final name = await showDialog<String>(
      context: context,
      builder: (_) => _RenameDialog(initial: spec.name),
    );
    final store = _store;
    if (name == null || name == spec.name || store == null) return;
    try {
      await store.write(spec.copyWith(name: name));
      await _reloadCustom();
    } on Object catch (e) {
      KoshaLog.w('Theme', 'rename failed', e.runtimeType);
      _snack('Could not rename the theme.');
    }
  }

  Future<void> _delete(ThemeSpec spec) async {
    final inUse = _services!.settings.value.appearance.themeId == spec.id;
    final ok = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Delete "${spec.name}"?'),
        content: Text(
          inUse
              ? 'This theme is selected. Kosha Dynamic will be used instead. This cannot be undone.'
              : 'This cannot be undone.',
        ),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Cancel')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Delete')),
        ],
      ),
    );
    final store = _store;
    if (ok != true || store == null) return;
    try {
      await store.delete(spec.id);
      await _commit((c) => _bumpRevision(c, themeId: inUse ? ThemePresets.koshaDynamic.id : null));
      await _reloadCustom();
    } on Object catch (e) {
      KoshaLog.w('Theme', 'delete failed', e.runtimeType);
      _snack('Could not delete the theme.');
    }
  }

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (services == null) return const SettingsPage(title: 'Themes', children: []);
    return ListenableBuilder(
      listenable: services.settings,
      builder: (context, _) => _buildPage(context, services.settings.value),
    );
  }

  Widget _buildPage(BuildContext context, KoshaSettings settings) {
    final appearance = settings.appearance;
    final systemDark = MediaQuery.platformBrightnessOf(context) == Brightness.dark;
    final dark =
        appearance.darkMode == DarkModePreference.dark ||
        (appearance.darkMode == DarkModePreference.system && systemDark);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final palettes = _palettes;

    KeyboardThemeData themeFor(ThemeSpec spec) => _previews.resolve(
      spec,
      themesDirectory: _store?.directory,
      dark: dark,
      pureBlack: appearance.pureBlack,
      contrast: appearance.contrast,
      palettes: palettes,
      disableAnimations: reduce,
    );

    return SettingsPage(
      title: 'Themes',
      children: [
        SettingsGroup(
          title: 'Appearance',
          children: [
            _ControlTile(
              title: 'Dark mode',
              child: SegmentedButton<DarkModePreference>(
                segments: const [
                  ButtonSegment(value: DarkModePreference.system, label: Text('System')),
                  ButtonSegment(value: DarkModePreference.light, label: Text('Light')),
                  ButtonSegment(value: DarkModePreference.dark, label: Text('Dark')),
                ],
                selected: {appearance.darkMode},
                onSelectionChanged: (s) =>
                    unawaited(_commit((c) => c.copyWith(appearance: c.appearance.copyWith(darkMode: s.first)))),
              ),
            ),
            SettingsSwitchTile(
              title: 'Pure black',
              subtitle: dark ? 'Black background in dark mode' : 'Only in dark mode',
              icon: Icons.dark_mode_outlined,
              value: appearance.pureBlack,
              onChanged: dark
                  ? (v) => unawaited(_commit((c) => c.copyWith(appearance: c.appearance.copyWith(pureBlack: v))))
                  : null,
            ),
            _ControlTile(
              title: 'Contrast',
              child: SegmentedButton<ContrastPreference>(
                segments: const [
                  ButtonSegment(value: ContrastPreference.standard, label: Text('Standard')),
                  ButtonSegment(value: ContrastPreference.medium, label: Text('Medium')),
                  ButtonSegment(value: ContrastPreference.high, label: Text('High')),
                ],
                selected: {appearance.contrast},
                onSelectionChanged: (s) =>
                    unawaited(_commit((c) => c.copyWith(appearance: c.appearance.copyWith(contrast: s.first)))),
              ),
            ),
            if (palettes != null)
              const SettingsTile(
                title: 'Kosha Dynamic follows your wallpaper',
                subtitle: 'Its colours update when the wallpaper changes',
                icon: Icons.wallpaper_outlined,
              ),
          ],
        ),
        const _SectionTitle('Presets'),
        SizedBox(
          height: 268,
          child: CarouselView(
            itemExtent: 232,
            itemSnapping: true,
            // The cards handle their own taps (and menus); the default splash layer would cover them.
            enableSplash: false,
            children: [
              for (final preset in ThemePresets.all)
                ThemeCard(
                  theme: themeFor(preset),
                  settings: settings,
                  name: preset.name,
                  selected: appearance.themeId == preset.id,
                  demoPress: appearance.themeId == preset.id,
                  onTap: () => _select(preset.id),
                ),
            ],
          ),
        ),
        const _SectionTitle('My themes'),
        SizedBox(
          height: 268,
          child: CarouselView(
            itemExtent: 232,
            itemSnapping: true,
            // The cards handle their own taps (and menus); the default splash layer would cover them.
            enableSplash: false,
            children: [
              for (final spec in _custom)
                ThemeCard(
                  theme: themeFor(spec),
                  settings: settings,
                  name: spec.name,
                  selected: appearance.themeId == spec.id,
                  onTap: () => _select(spec.id),
                  menu: PopupMenuButton<_CardAction>(
                    tooltip: 'Options for ${spec.name}',
                    onSelected: (a) => unawaited(_onAction(spec, a)),
                    itemBuilder: (_) => const [
                      PopupMenuItem(value: _CardAction.edit, child: Text('Edit')),
                      PopupMenuItem(value: _CardAction.duplicate, child: Text('Duplicate')),
                      PopupMenuItem(value: _CardAction.rename, child: Text('Rename')),
                      PopupMenuItem(value: _CardAction.delete, child: Text('Delete')),
                    ],
                  ),
                ),
              CreateThemeCard(onTap: () => unawaited(_openEditor(null))),
            ],
          ),
        ),
        const SizedBox(height: 16),
        const _SectionTitle('Try typing'),
        const TextField(
          decoration: InputDecoration(
            labelText: 'Type here to try the theme',
            helperText: 'The keyboard appears here when Kosha is selected.',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 24),
      ],
    );
  }
}

class _SectionTitle extends StatelessWidget {
  const _SectionTitle(this.text);

  final String text;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 8, 16, 8),
    child: Text(
      text,
      style: Theme.of(context).textTheme.titleSmall?.copyWith(color: Theme.of(context).colorScheme.primary),
    ),
  );
}

/// A row with a title and a control under it (used for segmented buttons).
class _ControlTile extends StatelessWidget {
  const _ControlTile({required this.title, required this.child});

  final String title;
  final Widget child;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [Text(title), const SizedBox(height: 8), child],
    ),
  );
}

class _RenameDialog extends StatefulWidget {
  const _RenameDialog({required this.initial});

  final String initial;

  @override
  State<_RenameDialog> createState() => _RenameDialogState();
}

class _RenameDialogState extends State<_RenameDialog> {
  late final TextEditingController _controller = TextEditingController(text: widget.initial);

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final name = _controller.text.trim();
    return AlertDialog(
      title: const Text('Rename theme'),
      content: TextField(
        controller: _controller,
        autofocus: true,
        maxLength: kThemeNameMax,
        onChanged: (_) => setState(() {}),
        decoration: const InputDecoration(labelText: 'Name'),
      ),
      actions: [
        TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Cancel')),
        FilledButton(onPressed: name.isEmpty ? null : () => Navigator.of(context).pop(name), child: const Text('Save')),
      ],
    );
  }
}
