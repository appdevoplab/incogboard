// SPDX-License-Identifier: GPL-3.0-or-later
//
// The real channel path: the keyboard's route request (AppFlutterApi.onOpenRoute) reaches the
// shell and opens the screen. Uses AppServices.create() with the platform channels answered by
// test handlers, because the request has to come in through the pigeon FlutterApi.
import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:myna/src/app/app.dart';
import 'package:myna/src/app/app_services.dart';

const StandardMessageCodec _codec = StandardMessageCodec();

TestDefaultBinaryMessenger get _messenger => TestDefaultBinaryMessengerBinding.instance.defaultBinaryMessenger;

/// Answers a pigeon call on [channel] with [value].
void _answer(String channel, Object? value) {
  _messenger.setMockMessageHandler(channel, (_) async => _codec.encodeMessage(<Object?>[value]));
}

const String _host = 'dev.flutter.pigeon.myna.';

void main() {
  late Directory dir;

  setUp(() {
    dir = Directory.systemTemp.createTempSync('myna_route_test');
    _answer('${_host}PlatformHostApi.getDataDirectory', dir.path);
    _answer('${_host}PlatformHostApi.getSystemColors', null);
    _answer('${_host}PlatformHostApi.hasInternetPermission', false);
    _answer('${_host}PlatformHostApi.notifySettingsChanged', null);
    _answer('${_host}AppHostApi.takeLaunchRoute', 'home');
    _answer('${_host}AppHostApi.isMynaEnabled', true);
    _answer('${_host}AppHostApi.isMynaSelected', true);
  });

  tearDown(() {
    for (final name in [
      'PlatformHostApi.getDataDirectory',
      'PlatformHostApi.getSystemColors',
      'PlatformHostApi.hasInternetPermission',
      'PlatformHostApi.notifySettingsChanged',
      'AppHostApi.takeLaunchRoute',
      'AppHostApi.isMynaEnabled',
      'AppHostApi.isMynaSelected',
    ]) {
      _messenger.setMockMessageHandler('$_host$name', null);
    }
    _messenger.setMockMessageHandler('${_host}AppFlutterApi.onOpenRoute', null);
    dir.deleteSync(recursive: true);
  });

  testWidgets('a route request from the keyboard opens that screen on top of home', (tester) async {
    final services = await tester.runAsync(AppServices.create);
    expect(services, isNotNull);
    await tester.pumpWidget(AppScope(services: services!, child: const MynaSettingsApp()));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey<String>('route:home')), findsOneWidget);

    await tester.runAsync(
      () => _messenger.handlePlatformMessage(
        '${_host}AppFlutterApi.onOpenRoute',
        _codec.encodeMessage(<Object?>['themes'])!,
        (_) {},
      ),
    );
    await tester.pumpAndSettle();

    expect(find.byKey(const ValueKey<String>('route:themes')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(() => services.dispose());
  });
}
