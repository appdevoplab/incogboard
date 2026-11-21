// SPDX-License-Identifier: GPL-3.0-or-later
//
// OWNER: Wave 2-A. About: version, the GPL-3.0 licence, the source code link (selectable text;
// no browser intent, the app never uses the network), and every licence.
import 'dart:async';

import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';

import '../../bridge/messages.g.dart';
import '../app_services.dart';
import '../common/settings_widgets.dart';
import '../onboarding/myna_mascot.dart';
import 'notices.dart';

class AboutScreen extends StatefulWidget {
  const AboutScreen({super.key});

  @override
  State<AboutScreen> createState() => _AboutScreenState();
}

class _AboutScreenState extends State<AboutScreen> {
  Future<AppInfoMessage>? _info;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _info ??= AppScope.of(context).platform.getAppInfo();
  }

  @override
  Widget build(BuildContext context) => FutureBuilder<AppInfoMessage>(
    future: _info,
    builder: (context, snapshot) {
      final info = snapshot.data;
      final version = info == null
          ? 'Reading version…'
          : 'Version ${info.versionName} (${info.versionCode})${info.isDebugBuild ? ' · debug build' : ''}';
      return SettingsPage(
        title: 'About',
        header: SettingsHero(mascot: const MynaMascot(size: 72), title: 'Myna', subtitle: version),
        children: [
          SettingsGroup(
            title: 'Privacy',
            children: const [
              SettingsTile(
                icon: Icons.wifi_off_outlined,
                title: 'Myna cannot use the internet',
                subtitle: 'Release builds have no internet permission, so nothing you type leaves this phone.',
              ),
            ],
          ),
          SettingsGroup(
            title: 'Licence',
            children: [
              SettingsTile(
                icon: Icons.gavel_outlined,
                title: 'GNU General Public Licence v3 or later',
                subtitle: 'Myna is free software. You may study, change and share it under the GPL.',
                onTap: () => _openNotice(context, MynaNotices.all.first),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Source code',
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 16),
                child: mynaSourceCodeUrl.isEmpty
                    ? Text(
                        'Myna is GPL-3.0-or-later. Its source code is available from the project page.',
                        style: Theme.of(context).textTheme.bodyMedium,
                      )
                    : SelectableText(mynaSourceCodeUrl, style: Theme.of(context).textTheme.bodyLarge),
              ),
            ],
          ),
          SettingsGroup(
            title: 'Licences',
            children: [
              SettingsTile(
                icon: Icons.article_outlined,
                title: 'Open-source licences',
                subtitle: 'Flutter, material_ui and every package Myna uses',
                onTap: () =>
                    showLicensePage(context: context, applicationName: 'Myna', applicationVersion: info?.versionName),
              ),
              for (final notice in MynaNotices.all.skip(1))
                SettingsTile(
                  icon: Icons.description_outlined,
                  title: notice.title,
                  onTap: () => _openNotice(context, notice),
                ),
            ],
          ),
        ],
      );
    },
  );

  void _openNotice(BuildContext context, MynaNotice notice) {
    unawaited(
      Navigator.of(context).push(
        MaterialPageRoute<void>(
          builder: (_) => NoticeTextPage(title: notice.title, asset: notice.asset),
        ),
      ),
    );
  }
}

/// The full text of one licence or notice file, selectable.
class NoticeTextPage extends StatelessWidget {
  const NoticeTextPage({super.key, required this.title, required this.asset});

  final String title;
  final String asset;

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(title)),
    body: FutureBuilder<String>(
      future: rootBundle.loadString(asset),
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Center(child: Text('This text could not be loaded.'));
        }
        final text = snapshot.data;
        if (text == null) return const Center(child: CircularProgressIndicator());
        return SingleChildScrollView(
          padding: const EdgeInsets.fromLTRB(16, 8, 16, 32),
          child: SelectableText(text, style: Theme.of(context).textTheme.bodySmall),
        );
      },
    ),
  );
}
