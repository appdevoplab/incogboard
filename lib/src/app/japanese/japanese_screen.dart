// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-B. Japanese typing options (route KoshaRoutes.japanese). Writes the `japanese`
// settings section. Stub from the orchestrator; keep the class name.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';

class JapaneseScreen extends StatelessWidget {
  const JapaneseScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage(
    title: 'Japanese',
    children: [
      SettingsGroup(
        children: [SettingsTile(icon: Icons.construction_outlined, title: 'Coming in Wave 4')],
      ),
    ],
  );
}
