// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Settings → Translation. Stub from the orchestrator.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';

class TranslateScreen extends StatelessWidget {
  const TranslateScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage(
    title: 'Translation',
    children: [
      SettingsGroup(
        children: [SettingsTile(icon: Icons.translate, title: 'Offline translation')],
      ),
    ],
  );
}
