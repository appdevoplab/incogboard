// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 3-T. Model packs (voice and translation): installed packs with sizes, import a
// .mynapack file (Storage Access Framework), delete. Stub from the orchestrator.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';

class PacksScreen extends StatelessWidget {
  const PacksScreen({super.key});

  @override
  Widget build(BuildContext context) => const SettingsPage(
    title: 'Model packs',
    children: [
      SettingsGroup(
        children: [SettingsTile(icon: Icons.download_for_offline_outlined, title: 'No packs installed')],
      ),
    ],
  );
}
