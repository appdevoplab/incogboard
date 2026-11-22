// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 4-A. Chinese typing options (route KoshaRoutes.chinese). Writes the `chinese`
// settings section. Stub from the orchestrator; keep the class name.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';

class ChineseScreen extends StatelessWidget {
  const ChineseScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage(
    title: 'Chinese',
    children: [
      SettingsGroup(
        children: [SettingsTile(icon: Icons.construction_outlined, title: 'Coming in Wave 4')],
      ),
    ],
  );
}
