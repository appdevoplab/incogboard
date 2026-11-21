// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-B. Wave 2-A wraps the whole settings app in AppLockGate; when
// app lock is on it asks for a fingerprint or the device PIN on start and after
// the timeout. Keep the class name and constructor.
import 'package:material_ui/material_ui.dart';

class AppLockGate extends StatelessWidget {
  const AppLockGate({super.key, required this.child});

  final Widget child;

  @override
  Widget build(BuildContext context) => child;
}
