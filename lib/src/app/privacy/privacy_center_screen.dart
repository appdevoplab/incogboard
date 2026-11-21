// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. Placeholder so Wave 2-A's shell can link here; keep the
// class name and const constructor.
import 'package:material_ui/material_ui.dart';

import '../common/settings_widgets.dart';

class PrivacyCenterScreen extends StatelessWidget {
  const PrivacyCenterScreen({super.key});

  @override
  Widget build(BuildContext context) =>
      const SettingsPage(title: 'Privacy', children: [Text('Privacy center: coming in Wave 2-B.')]);
}
