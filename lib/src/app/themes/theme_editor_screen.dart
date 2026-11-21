// SPDX-License-Identifier: GPL-3.0-or-later
//
// The theme editor. A static keyboard preview stays pinned at the top and updates as values change.
// Saving writes `<themes>/<uuid>.json` (and its photo), selects a new theme, and bumps
// appearance.customThemeRevision so a theme in use is re-read at once. Leaving with unsaved changes
// asks first, and discards any photo that was only drafted.
import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:image_picker/image_picker.dart';
import 'package:material_ui/material_ui.dart';

import '../../core/log.dart';
import '../../keyboard/preview/keyboard_preview.dart';
import '../../keyboard/view/keyboard_metrics.dart';
import '../../settings/myna_settings.dart';
import '../../theme/custom/background_image.dart';
import '../../theme/custom/custom_theme_store.dart';
import '../../theme/presets.dart';
import '../../theme/scheme_builder.dart';
import '../../theme/theme_spec.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import 'color_picker_dialog.dart';
import 'photo_crop_screen.dart';
import 'theme_support.dart';

/// Motion presets and the press-animation intensity each maps to (see [ThemeSpec.motionIntensity]).
const List<(String, double)> _motionChoices = [('Off', 0), ('Subtle', 0.5), ('Standard', 1), ('Bouncy', 2)];

const List<(ThemeSchemeVariant, String)> _variantChoices = [
  (ThemeSchemeVariant.tonalSpot, 'Tonal spot'),
  (ThemeSchemeVariant.vibrant, 'Vibrant'),
  (ThemeSchemeVariant.expressive, 'Expressive'),
  (ThemeSchemeVariant.fidelity, 'Fidelity'),
  (ThemeSchemeVariant.content, 'Content'),
  (ThemeSchemeVariant.monochrome, 'Monochrome'),
  (ThemeSchemeVariant.neutral, 'Neutral'),
  (ThemeSchemeVariant.rainbow, 'Rainbow'),
  (ThemeSchemeVariant.fruitSalad, 'Fruit salad'),
];

/// Edits a custom theme. [themeId] null starts a new one.
class ThemeEditorScreen extends StatefulWidget {
  const ThemeEditorScreen({super.key, this.themeId});

  final String? themeId;

  @override
  State<ThemeEditorScreen> createState() => _ThemeEditorScreenState();
}

class _ThemeEditorScreenState extends State<ThemeEditorScreen> {
  final ThemePreviewCache _previews = ThemePreviewCache();
  final TextEditingController _nameController = TextEditingController();

  AppServices? _services;
  CustomThemeStore? _store;
  String? _themesDir;
  List<int>? _palettes;
  String? _loadError;
  bool _started = false;
  bool _loaded = false;

  /// The theme as last saved (or the defaults for a new one).
  late ThemeSpec _saved;

  /// The working copy.
  late ThemeSpec _draft;
  late String _uuid;
  bool _isNew = true;

  /// Photos created in this visit that are not saved yet. Discarded with the draft.
  final Set<String> _draftPhotos = {};

  /// The photo as picked, kept so the crop can be opened again without picking.
  Uint8List? _photoBytes;

  // Global settings this screen also edits. They are written on save.
  DarkModePreference _darkMode = DarkModePreference.system;
  bool _pureBlack = false;
  ContrastPreference _contrast = ContrastPreference.standard;
  double _heightScale = 1;
  bool _hintLabels = true;
  bool _trailOn = true;
  double _trailWidth = 6;
  int _trailFade = 300;

  bool _dirty = false;
  bool _saving = false;
  bool _closing = false;

  @override
  void initState() {
    super.initState();
    _nameController.addListener(_onNameChanged);
  }

  /// Only typing counts as an edit: loading the name sets it while [_loaded] is still false.
  void _onNameChanged() {
    if (!_loaded) return;
    setState(() => _dirty = true);
  }

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
    _nameController.dispose();
    _previews.clear();
    super.dispose();
  }

  Future<void> _load() async {
    final services = _services!;
    final settings = services.settings.value;
    _darkMode = settings.appearance.darkMode;
    _pureBlack = settings.appearance.pureBlack;
    _contrast = settings.appearance.contrast;
    _heightScale = settings.appearance.heightScale;
    _hintLabels = settings.typing.hintLabels;
    _trailOn = settings.swipe.showTrail;
    _trailWidth = settings.swipe.trailWidth;
    _trailFade = settings.swipe.trailFadeMs;
    try {
      _palettes = (await services.platform.getSystemColors())?.palettes;
    } on Object catch (e) {
      MynaLog.w('Theme', 'system colours unavailable', e.runtimeType);
    }
    final dataDir = await services.platform.getDataDirectory();
    _themesDir = themesDirectoryFor(dataDir);
    _store = CustomThemeStore(_themesDir!);

    ThemeSpec? stored;
    final id = widget.themeId;
    if (id != null) {
      stored = await _store!.read(id);
      if (stored == null) {
        if (mounted) setState(() => _loadError = 'This theme could not be opened.');
        return;
      }
    }
    final spec = stored ?? _newSpec();
    final uuid = CustomThemeIds.uuidOf(spec.id);
    if (uuid == null) {
      if (mounted) setState(() => _loadError = 'This theme could not be opened.');
      return;
    }
    if (!mounted) return;
    setState(() {
      _saved = spec;
      _draft = spec;
      _uuid = uuid;
      _isNew = stored == null;
      _nameController.text = spec.name;
      _loaded = true;
    });
  }

  /// Defaults for a new theme: the brand seed, tonal spot, a pill-shaped key style.
  ThemeSpec _newSpec() => ThemeSpec(
    id: newCustomThemeId(),
    name: 'My theme',
    colorSource: ThemeColorSource.seed,
    seedColor: mynaYellow,
    variant: ThemeSchemeVariant.tonalSpot,
  );

  // ---------------------------------------------------------------------------
  // Editing helpers
  // ---------------------------------------------------------------------------

  void _edit(void Function() change) => setState(() {
    change();
    _dirty = true;
  });

  void _setDraft(ThemeSpec Function(ThemeSpec d) change) => _edit(() => _draft = change(_draft));

  bool _isDark(BuildContext context) =>
      _darkMode == DarkModePreference.dark ||
      (_darkMode == DarkModePreference.system && MediaQuery.platformBrightnessOf(context) == Brightness.dark);

  double get _contrastLevel => switch (_contrast) {
    ContrastPreference.standard => 0,
    ContrastPreference.medium => 0.5,
    ContrastPreference.high => 1,
  };

  /// The colour scheme the draft gives for [dark], including custom roles and pure black.
  ColorScheme _scheme(bool dark) => buildColorScheme(
    _draft,
    dark ? Brightness.dark : Brightness.light,
    palettes: _palettes,
    contrastLevel: _contrastLevel,
    pureBlack: _pureBlack,
  );

  /// The global settings as the draft would leave them (the preview uses these).
  MynaSettings _settingsDraft(MynaSettings base) => base.copyWith(
    appearance: base.appearance.copyWith(
      darkMode: _darkMode,
      pureBlack: _pureBlack,
      contrast: _contrast,
      heightScale: _heightScale,
    ),
    typing: base.typing.copyWith(hintLabels: _hintLabels),
    swipe: base.swipe.copyWith(showTrail: _trailOn, trailWidth: _trailWidth, trailFadeMs: _trailFade),
  );

  void _snack(String message) {
    if (!mounted) return;
    ScaffoldMessenger.maybeOf(context)?.showSnackBar(SnackBar(content: Text(message)));
  }

  // ---------------------------------------------------------------------------
  // Leaving and saving
  // ---------------------------------------------------------------------------

  Future<void> _leave([ThemeSpec? result]) async {
    // The rebuild that lets PopScope allow the pop happens within a frame; the short delay waits for it.
    setState(() => _closing = true);
    await Future<void>.delayed(const Duration(milliseconds: 100));
    if (mounted) Navigator.of(context).pop(result);
  }

  Future<void> _requestClose() async {
    if (!_dirty) {
      await _leave();
      return;
    }
    final discard = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Discard changes?'),
        content: const Text('Your changes to this theme will be lost.'),
        actions: [
          TextButton(onPressed: () => Navigator.of(context).pop(false), child: const Text('Keep editing')),
          FilledButton(onPressed: () => Navigator.of(context).pop(true), child: const Text('Discard')),
        ],
      ),
    );
    if (discard != true) return;
    await _discardDrafts();
    await _leave();
  }

  Future<void> _discardDrafts() async {
    final store = _store;
    if (store == null) return;
    for (final photo in _draftPhotos) {
      await store.deleteImage(photo);
    }
    _draftPhotos.clear();
  }

  Future<void> _save() async {
    final services = _services;
    final store = _store;
    final name = _nameController.text.trim();
    if (services == null || store == null || name.isEmpty || _saving) return;
    setState(() => _saving = true);
    final spec = _draft.copyWith(id: CustomThemeIds.idFor(_uuid), name: name);
    try {
      final newPhoto = CustomThemeStore.photoUuidOf(spec.background.imagePath);
      final oldPhoto = CustomThemeStore.photoUuidOf(_saved.background.imagePath);
      await store.write(spec);
      if (oldPhoto != null && oldPhoto != newPhoto) await store.deleteImage(oldPhoto);
      for (final photo in _draftPhotos) {
        if (photo != newPhoto) await store.deleteImage(photo);
      }
      _draftPhotos.clear();
      final wasNew = _isNew;
      await services.settings.update(
        (c) => c.copyWith(
          appearance: c.appearance.copyWith(
            themeId: wasNew ? spec.id : null,
            darkMode: _darkMode,
            pureBlack: _pureBlack,
            contrast: _contrast,
            heightScale: _heightScale,
            customThemeRevision: c.appearance.customThemeRevision + 1,
          ),
          typing: c.typing.copyWith(hintLabels: _hintLabels),
          swipe: c.swipe.copyWith(showTrail: _trailOn, trailWidth: _trailWidth, trailFadeMs: _trailFade),
        ),
        sections: const [SettingsSection.appearance, SettingsSection.typing, SettingsSection.swipe],
      );
      _saved = spec;
      _isNew = false;
      _dirty = false;
    } on Object catch (e) {
      MynaLog.w('Theme', 'save failed', e.runtimeType);
      if (mounted) setState(() => _saving = false);
      _snack('Could not save the theme.');
      return;
    }
    if (mounted) setState(() => _saving = false);
    await _leave(spec);
  }

  // ---------------------------------------------------------------------------
  // Photo background
  // ---------------------------------------------------------------------------

  Future<void> _choosePhoto() async {
    final store = _store;
    if (store == null) return;
    final XFile? picked;
    try {
      picked = await ImagePicker().pickImage(source: ImageSource.gallery);
    } on Object catch (e) {
      MynaLog.w('Theme', 'photo picker failed', e.runtimeType);
      _snack('The photo picker could not open.');
      return;
    }
    if (picked == null) return;
    final bytes = await picked.readAsBytes();
    try {
      await probePhotoSize(bytes);
    } on PhotoRejected catch (e) {
      _snack(e.reason);
      return;
    }
    _photoBytes = bytes;
    await _openCrop(bytes, _draft.background.blur);
  }

  Future<void> _openCrop(Uint8List bytes, double blur) async {
    final store = _store;
    final services = _services;
    if (store == null || services == null || !mounted) return;
    final size = MediaQuery.sizeOf(context);
    final photoUuid = CustomThemeIds.newUuid();
    final frameHeight = KeyboardMetrics.contentHeight(_settingsDraft(services.settings.value), landscape: false);
    final result = await Navigator.of(context).push<PhotoCropResult>(
      MaterialPageRoute<PhotoCropResult>(
        builder: (_) => PhotoCropScreen(
          photo: bytes,
          store: store,
          photoUuid: photoUuid,
          frameWidth: size.width,
          frameHeight: frameHeight,
          devicePixelRatio: MediaQuery.devicePixelRatioOf(context),
          initialBlur: blur,
        ),
      ),
    );
    if (result == null || !mounted) return;
    final previous = CustomThemeStore.photoUuidOf(_draft.background.imagePath);
    _edit(() {
      _draftPhotos.add(result.uuid);
      _draft = _draft.copyWith(
        background: _draft.background.copyWith(
          type: ThemeBackgroundType.image,
          imagePath: CustomThemeStore.imageRelativePath(result.uuid),
          blur: result.blur,
        ),
      );
    });
    // A photo drafted in this visit that is now replaced can go at once. A saved one waits for Save.
    if (previous != null && _draftPhotos.remove(previous)) await store.deleteImage(previous);
  }

  // ---------------------------------------------------------------------------
  // Build
  // ---------------------------------------------------------------------------

  @override
  Widget build(BuildContext context) {
    final services = _services;
    if (!_loaded || services == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Theme')),
        body: Center(
          child: _loadError != null
              ? Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(_loadError!, textAlign: TextAlign.center),
                )
              : const CircularProgressIndicator(),
        ),
      );
    }
    final dark = _isDark(context);
    final reduce = MediaQuery.disableAnimationsOf(context);
    final previewSettings = _settingsDraft(services.settings.value);
    final theme = _previews.resolve(
      _draft,
      themesDirectory: _themesDir,
      dark: dark,
      pureBlack: _pureBlack,
      contrast: _contrast,
      palettes: _palettes,
      disableAnimations: reduce,
    );
    final scheme = _scheme(dark);
    final canSave = _nameController.text.trim().isNotEmpty && !_saving;
    final previewExtent = KeyboardMetrics.contentHeight(previewSettings, landscape: false) + 16;

    return PopScope(
      canPop: !_dirty || _closing,
      onPopInvokedWithResult: (didPop, _) {
        if (!didPop) unawaited(_requestClose());
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text(_isNew ? 'New theme' : 'Edit theme'),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: FilledButton(onPressed: canSave ? _save : null, child: const Text('Save')),
            ),
          ],
        ),
        body: CustomScrollView(
          slivers: [
            SliverPersistentHeader(
              pinned: true,
              delegate: _PreviewHeaderDelegate(
                extent: previewExtent,
                child: Padding(
                  padding: const EdgeInsets.all(8),
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: KeyboardPreview(theme: theme, settings: previewSettings),
                  ),
                ),
              ),
            ),
            SliverPadding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 40),
              sliver: SliverList.list(
                children: _sections(context, services, dark: dark, scheme: scheme),
              ),
            ),
          ],
        ),
      ),
    );
  }

  List<Widget> _sections(
    BuildContext context,
    AppServices services, {
    required bool dark,
    required ColorScheme scheme,
  }) {
    final draft = _draft;
    final dynamicSource = draft.colorSource == ThemeColorSource.dynamic;
    final hasPalettes = _palettes != null;
    final bg = draft.background;
    final photoUuid = CustomThemeStore.photoUuidOf(bg.imagePath);
    final store = _store;
    final photoPath = photoUuid == null || store == null ? null : store.imageFileFor(photoUuid);
    final hasPhoto = photoPath != null && File(photoPath).existsSync();

    return [
      SettingsGroup(
        title: 'Name',
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
            child: TextField(
              controller: _nameController,
              maxLength: kThemeNameMax,
              decoration: InputDecoration(
                labelText: 'Theme name',
                errorText: _nameController.text.trim().isEmpty ? 'A name is required' : null,
              ),
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Look',
        children: [
          _ControlTile(
            title: 'Dark mode',
            child: SegmentedButton<DarkModePreference>(
              segments: const [
                ButtonSegment(value: DarkModePreference.system, label: Text('System')),
                ButtonSegment(value: DarkModePreference.light, label: Text('Light')),
                ButtonSegment(value: DarkModePreference.dark, label: Text('Dark')),
              ],
              selected: {_darkMode},
              onSelectionChanged: (s) => _edit(() => _darkMode = s.first),
            ),
          ),
          SettingsSwitchTile(
            title: 'Pure black',
            subtitle: dark ? 'Black background' : 'Only in dark mode',
            icon: Icons.dark_mode_outlined,
            value: _pureBlack,
            onChanged: dark ? (v) => _edit(() => _pureBlack = v) : null,
          ),
          _ControlTile(
            title: 'Contrast',
            child: SegmentedButton<ContrastPreference>(
              segments: const [
                ButtonSegment(value: ContrastPreference.standard, label: Text('Standard')),
                ButtonSegment(value: ContrastPreference.medium, label: Text('Medium')),
                ButtonSegment(value: ContrastPreference.high, label: Text('High')),
              ],
              selected: {_contrast},
              onSelectionChanged: (s) => _edit(() => _contrast = s.first),
            ),
          ),
          _SliderRow(
            label: 'Keyboard height',
            value: _heightScale,
            min: 0.7,
            max: 1.5,
            valueText: '${(_heightScale * 100).round()}%',
            onChanged: (v) => _edit(() => _heightScale = v),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Colours',
        children: [
          _ControlTile(
            title: 'Source',
            child: SegmentedButton<ThemeColorSource>(
              segments: [
                ButtonSegment(value: ThemeColorSource.dynamic, enabled: hasPalettes, label: const Text('Wallpaper')),
                const ButtonSegment(value: ThemeColorSource.seed, label: Text('Seed')),
                const ButtonSegment(value: ThemeColorSource.custom, label: Text('Per role')),
              ],
              selected: {dynamicSource && !hasPalettes ? ThemeColorSource.seed : draft.colorSource},
              onSelectionChanged: (s) => _setDraft((d) => d.copyWith(colorSource: s.first)),
            ),
          ),
          if (!hasPalettes)
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('Wallpaper colours need Android 12 or newer.'),
            ),
          if (!dynamicSource) ...[
            _ControlTile(
              title: 'Seed colour',
              child: _SeedSwatches(
                selected: draft.seedColor,
                onPick: (argb) => _setDraft((d) => d.copyWith(seedColor: argb)),
                onCustom: () async {
                  final argb = await showColorPicker(context, initial: draft.seedColor, title: 'Seed colour');
                  if (argb != null) _setDraft((d) => d.copyWith(seedColor: argb));
                },
              ),
            ),
            _ControlTile(
              title: 'Scheme',
              child: Wrap(
                spacing: 8,
                runSpacing: 8,
                children: [
                  for (final (variant, label) in _variantChoices)
                    ChoiceChip(
                      label: Text(label),
                      selected: draft.variant == variant,
                      onSelected: (_) => _setDraft((d) => d.copyWith(variant: variant)),
                    ),
                ],
              ),
            ),
          ],
          if (draft.colorSource == ThemeColorSource.custom)
            ExpansionTile(
              title: const Text('Colour roles'),
              subtitle: Text(dark ? 'Editing the dark colours' : 'Editing the light colours'),
              children: [
                for (final role in kEditorRoles)
                  _RoleTile(
                    label: _roleLabel(role),
                    color: roleColor(scheme, role),
                    overridden: (dark ? (draft.customRolesDark ?? draft.customRoles) : draft.customRoles).containsKey(
                      role,
                    ),
                    onPick: () async {
                      final argb = await showColorPicker(
                        context,
                        initial: roleColor(scheme, role)?.toARGB32() ?? 0xFF000000,
                        title: _roleLabel(role),
                      );
                      if (argb != null) _setRole(role, argb, dark: dark);
                    },
                    onReset: () => _setRole(role, null, dark: dark),
                  ),
                TextButton(
                  onPressed: () => _setDraft((d) => d.copyWith(customRoles: const {}, customRolesDark: null)),
                  child: const Text('Reset all roles'),
                ),
              ],
            ),
        ],
      ),
      SettingsGroup(
        title: 'Keys',
        children: [
          _SliderRow(
            label: 'Shape',
            value: 1 - draft.keyRadius * 2,
            min: 0,
            max: 1,
            valueText: _shapeName(draft.keyRadius),
            leftHint: 'Pill',
            rightHint: 'Square',
            onChanged: (v) => _setDraft((d) {
              final radius = (1 - v) * 0.5;
              return d.copyWith(keyRadius: radius, fontRoundness: radius * 200);
            }),
          ),
          SettingsSwitchTile(
            title: 'Key borders',
            value: draft.borderWidth > 0,
            onChanged: (on) => _setDraft((d) => d.copyWith(borderWidth: on ? 1.0 : 0.0)),
          ),
          if (draft.borderWidth > 0)
            _SliderRow(
              label: 'Border width',
              value: draft.borderWidth,
              min: 1,
              max: 4,
              divisions: 6,
              valueText: '${draft.borderWidth.toStringAsFixed(1)} dp',
              onChanged: (v) => _setDraft((d) => d.copyWith(borderWidth: v)),
            ),
          _SliderRow(
            label: 'Key gap',
            value: draft.keyGap,
            min: 0,
            max: 16,
            valueText: '${draft.keyGap.round()} dp',
            onChanged: (v) => _setDraft((d) => d.copyWith(keyGap: v)),
          ),
          _SliderRow(
            label: 'Font weight',
            value: draft.labelWeight.toDouble(),
            min: 100,
            max: 900,
            divisions: 16,
            valueText: '${draft.labelWeight}',
            onChanged: (v) => _setDraft((d) => d.copyWith(labelWeight: v.round())),
          ),
          _SliderRow(
            label: 'Font size',
            value: draft.labelScale,
            min: 0.7,
            max: 1.5,
            valueText: '${(draft.labelScale * 100).round()}%',
            onChanged: (v) => _setDraft((d) => d.copyWith(labelScale: v)),
          ),
          SettingsSwitchTile(
            title: 'Hint characters',
            subtitle: 'Small characters on long press',
            value: _hintLabels,
            onChanged: (v) => _edit(() => _hintLabels = v),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Background',
        children: [
          _ControlTile(
            title: 'Type',
            child: SegmentedButton<ThemeBackgroundType>(
              segments: const [
                ButtonSegment(value: ThemeBackgroundType.solid, label: Text('Solid')),
                ButtonSegment(value: ThemeBackgroundType.gradient, label: Text('Gradient')),
                ButtonSegment(value: ThemeBackgroundType.image, label: Text('Photo')),
              ],
              selected: {bg.type},
              onSelectionChanged: (s) => _setDraft((d) => d.copyWith(background: _backgroundOf(d, s.first))),
            ),
          ),
          if (bg.type == ThemeBackgroundType.gradient) ..._gradientControls(bg),
          if (bg.type == ThemeBackgroundType.image) ...[
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 4, 16, 8),
              child: hasPhoto
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Image.file(
                        File(photoPath),
                        height: 96,
                        width: double.infinity,
                        fit: BoxFit.cover,
                        errorBuilder: (_, _, _) => const SizedBox(height: 96),
                      ),
                    )
                  : const Text('No photo yet. Choose one to crop it to the keyboard.'),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Wrap(
                spacing: 8,
                children: [
                  FilledButton.tonal(onPressed: _choosePhoto, child: const Text('Choose photo')),
                  if (_photoBytes != null && hasPhoto)
                    OutlinedButton(
                      onPressed: () => unawaited(_openCrop(_photoBytes!, bg.blur)),
                      child: const Text('Edit crop and blur'),
                    ),
                ],
              ),
            ),
            _SliderRow(
              label: 'Dim',
              value: bg.dim,
              min: 0,
              max: 0.8,
              valueText: '${(bg.dim * 100).round()}%',
              onChanged: (v) => _setDraft((d) => d.copyWith(background: d.background.copyWith(dim: v))),
            ),
          ],
        ],
      ),
      SettingsGroup(
        title: 'Popups and trail',
        children: [
          SettingsSwitchTile(
            title: 'Solid popups',
            subtitle: dynamicSource ? 'Not with wallpaper colours' : 'Popups in the primary colour',
            value: draft.accents.popupFill != null,
            onChanged: dynamicSource
                ? null
                : (on) => _setDraft((d) => d.copyWith(accents: _solidPopups(d, on, scheme))),
          ),
          SettingsSwitchTile(title: 'Swipe trail', value: _trailOn, onChanged: (v) => _edit(() => _trailOn = v)),
          if (_trailOn) ...[
            _SliderRow(
              label: 'Trail width',
              value: _trailWidth,
              min: 2,
              max: 16,
              valueText: '${_trailWidth.round()} dp',
              onChanged: (v) => _edit(() => _trailWidth = v),
            ),
            _SliderRow(
              label: 'Trail fade',
              value: _trailFade.toDouble(),
              min: 0,
              max: 2000,
              divisions: 20,
              valueText: _trailFade == 0 ? 'Instant' : '$_trailFade ms',
              onChanged: (v) => _edit(() => _trailFade = v.round()),
            ),
          ],
          _ControlTile(
            title: 'Trail colours',
            child: Row(
              children: [
                _ColorChip(
                  label: 'Start',
                  color: Color(draft.accents.trailStart ?? scheme.primary.toARGB32()),
                  onTap: () async {
                    final argb = await showColorPicker(
                      context,
                      initial: draft.accents.trailStart ?? scheme.primary.toARGB32(),
                      title: 'Trail start',
                    );
                    if (argb != null) {
                      _setDraft((d) => d.copyWith(accents: d.accents.copyWith(trailStart: argb)));
                    }
                  },
                ),
                const SizedBox(width: 12),
                _ColorChip(
                  label: 'End',
                  color: Color(draft.accents.trailEnd ?? scheme.tertiary.toARGB32()),
                  onTap: () async {
                    final argb = await showColorPicker(
                      context,
                      initial: draft.accents.trailEnd ?? scheme.tertiary.toARGB32(),
                      title: 'Trail end',
                    );
                    if (argb != null) {
                      _setDraft((d) => d.copyWith(accents: d.accents.copyWith(trailEnd: argb)));
                    }
                  },
                ),
                const Spacer(),
                TextButton(
                  onPressed: () => _setDraft((d) => d.copyWith(accents: d.accents.copyWith(clearTrail: true))),
                  child: const Text('Automatic'),
                ),
              ],
            ),
          ),
        ],
      ),
      SettingsGroup(
        title: 'Motion',
        children: [
          _ControlTile(
            title: 'Key press animation',
            child: SegmentedButton<double>(
              segments: [for (final (label, value) in _motionChoices) ButtonSegment(value: value, label: Text(label))],
              selected: {_nearestMotion(draft.motionIntensity)},
              onSelectionChanged: (s) => _setDraft((d) => d.copyWith(motionIntensity: s.first)),
            ),
          ),
          if (MediaQuery.disableAnimationsOf(context))
            const Padding(
              padding: EdgeInsets.fromLTRB(16, 0, 16, 12),
              child: Text('Remove animations is on in system settings, so keys do not animate.'),
            ),
        ],
      ),
    ];
  }

  List<Widget> _gradientControls(ThemeBackgroundSpec bg) {
    final stops = bg.gradientColors.isEmpty ? const [0xFFFFE08C, 0xFFF5B700] : bg.gradientColors;
    void setStops(List<int> next) =>
        _setDraft((d) => d.copyWith(background: d.background.copyWith(gradientColors: next)));
    return [
      _ControlTile(
        title: 'Colours',
        child: Wrap(
          spacing: 12,
          runSpacing: 8,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            for (var i = 0; i < stops.length; i++)
              _ColorChip(
                label: 'Stop ${i + 1}',
                color: Color(stops[i]),
                onTap: () async {
                  final argb = await showColorPicker(context, initial: stops[i], title: 'Stop ${i + 1}');
                  if (argb == null) return;
                  final next = [...stops]..[i] = argb;
                  setStops(next);
                },
              ),
            if (stops.length < 3)
              TextButton.icon(
                onPressed: () => setStops([...stops, stops.last]),
                icon: const Icon(Icons.add),
                label: const Text('Add stop'),
              ),
            if (stops.length > 2)
              TextButton.icon(
                onPressed: () => setStops(stops.sublist(0, stops.length - 1)),
                icon: const Icon(Icons.remove),
                label: const Text('Remove stop'),
              ),
          ],
        ),
      ),
      _SliderRow(
        label: 'Angle',
        value: bg.gradientAngle,
        min: 0,
        max: 360,
        valueText: '${bg.gradientAngle.round()}°',
        onChanged: (v) => _setDraft((d) => d.copyWith(background: d.background.copyWith(gradientAngle: v))),
      ),
    ];
  }

  /// The background for a new [type], keeping what makes sense for it.
  ThemeBackgroundSpec _backgroundOf(ThemeSpec d, ThemeBackgroundType type) {
    final bg = d.background;
    return bg.copyWith(
      type: type,
      gradientColors: type == ThemeBackgroundType.gradient && bg.gradientColors.length < 2
          ? const [0xFFFFE08C, 0xFFF5B700]
          : bg.gradientColors,
    );
  }

  ThemeAccentOverrides _solidPopups(ThemeSpec d, bool on, ColorScheme s) => on
      ? d.accents.copyWith(
          popupFill: s.primary.toARGB32(),
          popupLabel: s.onPrimary.toARGB32(),
          popupSelectedFill: s.tertiary.toARGB32(),
          popupSelectedLabel: s.onTertiary.toARGB32(),
        )
      : d.accents.copyWith(clearPopup: true);

  void _setRole(String role, int? argb, {required bool dark}) => _setDraft((d) {
    final base = dark ? (d.customRolesDark ?? d.customRoles) : d.customRoles;
    final roles = Map<String, int>.of(base);
    if (argb == null) {
      roles.remove(role);
    } else {
      roles[role] = argb;
    }
    return dark ? d.copyWith(customRolesDark: roles) : d.copyWith(customRoles: roles);
  });

  double _nearestMotion(double v) {
    var best = _motionChoices.first.$2;
    for (final (_, value) in _motionChoices) {
      if ((value - v).abs() < (best - v).abs()) best = value;
    }
    return best;
  }

  static String _shapeName(double keyRadius) {
    if (keyRadius >= 0.42) return 'Pill';
    if (keyRadius >= 0.16) return 'Rounded';
    return 'Square';
  }

  /// `surfaceContainerHighest` becomes "Surface container highest".
  static String _roleLabel(String role) {
    final words = role.replaceAllMapped(RegExp(r'([A-Z])'), (m) => ' ${m.group(1)!.toLowerCase()}');
    return words.isEmpty ? role : '${words[0].toUpperCase()}${words.substring(1)}';
  }
}

class _PreviewHeaderDelegate extends SliverPersistentHeaderDelegate {
  _PreviewHeaderDelegate({required this.extent, required this.child});

  final double extent;
  final Widget child;

  @override
  double get minExtent => extent;

  @override
  double get maxExtent => extent;

  @override
  Widget build(BuildContext context, double shrinkOffset, bool overlapsContent) => SizedBox.expand(child: child);

  @override
  bool shouldRebuild(covariant _PreviewHeaderDelegate oldDelegate) => true;
}

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

/// A slider that updates the draft while it moves (the preview follows the finger).
class _SliderRow extends StatelessWidget {
  const _SliderRow({
    required this.label,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.valueText,
    this.leftHint,
    this.rightHint,
  });

  final String label;
  final double value;
  final double min;
  final double max;
  final int? divisions;
  final String? valueText;
  final String? leftHint;
  final String? rightHint;
  final ValueChanged<double> onChanged;

  @override
  Widget build(BuildContext context) {
    final text = Theme.of(context).textTheme;
    final scheme = Theme.of(context).colorScheme;
    final shown = valueText ?? value.toStringAsFixed(2);
    return Padding(
      padding: const EdgeInsets.fromLTRB(16, 8, 16, 4),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(child: Text(label)),
              Text(shown, style: text.labelLarge?.copyWith(color: scheme.primary)),
            ],
          ),
          Semantics(
            slider: true,
            label: label,
            value: shown,
            child: Slider(
              value: value.clamp(min, max),
              min: min,
              max: max,
              divisions: divisions,
              label: shown,
              onChanged: onChanged,
            ),
          ),
          if (leftHint != null || rightHint != null)
            Row(
              children: [
                Text(leftHint ?? '', style: text.bodySmall),
                const Spacer(),
                Text(rightHint ?? '', style: text.bodySmall),
              ],
            ),
        ],
      ),
    );
  }
}

class _SeedSwatches extends StatelessWidget {
  const _SeedSwatches({required this.selected, required this.onPick, required this.onCustom});

  final int selected;
  final ValueChanged<int> onPick;
  final VoidCallback onCustom;

  @override
  Widget build(BuildContext context) {
    final inList = kSeedSwatches.contains(selected);
    return Wrap(
      spacing: 10,
      runSpacing: 10,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        for (final argb in kSeedSwatches)
          _Swatch(color: Color(argb), selected: argb == selected, label: '#${hexOf(argb)}', onTap: () => onPick(argb)),
        _Swatch(
          color: Color(selected),
          selected: !inList,
          label: inList ? 'Custom colour' : 'Custom colour #${hexOf(selected)}',
          icon: Icons.colorize,
          onTap: onCustom,
        ),
      ],
    );
  }
}

class _Swatch extends StatelessWidget {
  const _Swatch({required this.color, required this.selected, required this.label, required this.onTap, this.icon});

  final Color color;
  final bool selected;
  final String label;
  final VoidCallback onTap;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    return Semantics(
      button: true,
      selected: selected,
      label: label,
      child: InkResponse(
        onTap: onTap,
        radius: 28,
        child: SizedBox.square(
          dimension: 48,
          child: Center(
            child: Container(
              width: 36,
              height: 36,
              decoration: BoxDecoration(
                color: color,
                shape: BoxShape.circle,
                border: Border.all(color: selected ? scheme.onSurface : scheme.outlineVariant, width: selected ? 3 : 1),
              ),
              child: icon == null
                  ? null
                  : Icon(
                      icon,
                      size: 18,
                      color: color.computeLuminance() > 0.5 ? const Color(0xFF000000) : const Color(0xFFFFFFFF),
                    ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ColorChip extends StatelessWidget {
  const _ColorChip({required this.label, required this.color, required this.onTap});

  final String label;
  final Color color;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => Semantics(
    button: true,
    label: '$label colour, #${hexOf(color.toARGB32())}',
    child: ActionChip(
      avatar: CircleAvatar(backgroundColor: color, radius: 10),
      label: Text(label),
      onPressed: onTap,
    ),
  );
}

class _RoleTile extends StatelessWidget {
  const _RoleTile({
    required this.label,
    required this.color,
    required this.overridden,
    required this.onPick,
    required this.onReset,
  });

  final String label;
  final Color? color;
  final bool overridden;
  final VoidCallback onPick;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) => ListTile(
    dense: true,
    minVerticalPadding: 8,
    leading: CircleAvatar(backgroundColor: color ?? const Color(0xFF000000), radius: 12),
    title: Text(label),
    subtitle: Text(overridden ? 'Set' : 'From the scheme'),
    trailing: overridden
        ? IconButton(
            tooltip: 'Use the scheme colour for $label',
            onPressed: onReset,
            icon: const Icon(Icons.restart_alt),
          )
        : null,
    onTap: onPick,
  );
}
