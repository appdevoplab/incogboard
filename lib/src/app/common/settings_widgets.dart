// SPDX-License-Identifier: GPL-3.0-or-later
//
// Shared building blocks for every settings screen (Wave 2-A, B and C).
// OWNER: Wave 2-A, who may restyle them (M3 Expressive grouped containers,
// large headers, shape morphing) but must keep these constructors and
// parameters working, because Wave 2-B and 2-C build on them in parallel.
import 'package:material_ui/material_ui.dart';

/// A screen with a large collapsing header and a scrolling body.
class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key, required this.title, required this.children, this.actions, this.header});

  final String title;
  final List<Widget> children;
  final List<Widget>? actions;

  /// Optional illustration or summary shown under the header (for example the Myna mascot).
  final Widget? header;

  @override
  Widget build(BuildContext context) => Scaffold(
    body: CustomScrollView(
      slivers: [
        SliverAppBar.large(title: Text(title), actions: actions),
        if (header != null) SliverToBoxAdapter(child: header),
        SliverPadding(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          sliver: SliverList.list(children: children),
        ),
      ],
    ),
  );
}

/// A titled group of tiles drawn as one rounded container with thin gaps between the tiles.
class SettingsGroup extends StatelessWidget {
  const SettingsGroup({super.key, this.title, required this.children});

  final String? title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;
    final text = Theme.of(context).textTheme;
    return Padding(
      padding: const EdgeInsets.only(bottom: 20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (title != null)
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 0, 16, 8),
              child: Text(title!, style: text.titleSmall?.copyWith(color: scheme.primary)),
            ),
          for (var i = 0; i < children.length; i++)
            Padding(
              padding: EdgeInsets.only(bottom: i == children.length - 1 ? 0 : 2),
              child: ClipRRect(
                borderRadius: BorderRadius.vertical(
                  top: Radius.circular(i == 0 ? 24 : 6),
                  bottom: Radius.circular(i == children.length - 1 ? 24 : 6),
                ),
                child: Material(color: scheme.surfaceContainer, child: children[i]),
              ),
            ),
        ],
      ),
    );
  }
}

class SettingsTile extends StatelessWidget {
  const SettingsTile({
    super.key,
    required this.title,
    this.subtitle,
    this.icon,
    this.trailing,
    this.onTap,
    this.enabled = true,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final Widget? trailing;
  final VoidCallback? onTap;
  final bool enabled;

  @override
  Widget build(BuildContext context) => ListTile(
    enabled: enabled,
    leading: icon == null ? null : Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    trailing: trailing ?? (onTap == null ? null : const Icon(Icons.chevron_right)),
    onTap: onTap,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class SettingsSwitchTile extends StatelessWidget {
  const SettingsSwitchTile({
    super.key,
    required this.title,
    required this.value,
    required this.onChanged,
    this.subtitle,
    this.icon,
  });

  final String title;
  final String? subtitle;
  final IconData? icon;
  final bool value;

  /// Null disables the switch.
  final ValueChanged<bool>? onChanged;

  @override
  Widget build(BuildContext context) => SwitchListTile(
    secondary: icon == null ? null : Icon(icon),
    title: Text(title),
    subtitle: subtitle == null ? null : Text(subtitle!),
    value: value,
    onChanged: onChanged,
    contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
  );
}

class SettingsSliderTile extends StatelessWidget {
  const SettingsSliderTile({
    super.key,
    required this.title,
    required this.value,
    required this.min,
    required this.max,
    required this.onChanged,
    this.divisions,
    this.valueLabel,
    this.icon,
  });

  final String title;
  final double value;
  final double min;
  final double max;
  final int? divisions;

  /// Called when the user lets go (settings writes should not happen on every drag frame).
  final ValueChanged<double> onChanged;
  final String Function(double value)? valueLabel;
  final IconData? icon;

  @override
  Widget build(BuildContext context) => _SliderTile(widget: this);
}

class _SliderTile extends StatefulWidget {
  const _SliderTile({required this.widget});

  final SettingsSliderTile widget;

  @override
  State<_SliderTile> createState() => _SliderTileState();
}

class _SliderTileState extends State<_SliderTile> {
  double? _dragging;

  @override
  Widget build(BuildContext context) {
    final w = widget.widget;
    final v = (_dragging ?? w.value).clamp(w.min, w.max);
    return ListTile(
      leading: w.icon == null ? null : Icon(w.icon),
      title: Text(w.title),
      trailing: w.valueLabel == null ? null : Text(w.valueLabel!(v)),
      subtitle: Slider(
        value: v,
        min: w.min,
        max: w.max,
        divisions: w.divisions,
        label: w.valueLabel?.call(v),
        onChanged: (x) => setState(() => _dragging = x),
        onChangeEnd: (x) {
          setState(() => _dragging = null);
          w.onChanged(x);
        },
      ),
      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
    );
  }
}
