// SPDX-License-Identifier: GPL-3.0-or-later
//
// Fakes for the settings app's widget tests: mocked host APIs (mocktail) and a mocked settings
// store, so no file or platform channel is touched.
import 'package:flutter/widgets.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:mocktail/mocktail.dart';
import 'package:myna/src/app/app_services.dart';
import 'package:myna/src/bridge/messages.g.dart';
import 'package:myna/src/core/secure_blob_store.dart';
import 'package:myna/src/settings/myna_settings.dart';
import 'package:myna/src/settings/settings_store.dart';

class MockAppHost extends Mock implements AppHostApi {}

class MockPlatformHost extends Mock implements PlatformHostApi {}

class MockSettingsStore extends Mock implements SettingsStore {}

/// Services whose host calls answer from the given values.
class AppFakes {
  AppFakes({
    MynaSettings settings = const MynaSettings(),
    this.launchRoute,
    bool enabled = true,
    bool selected = true,
    bool internet = false,
  }) {
    registerFallbackValue((MynaSettings s) => s);
    registerFallbackValue(<String>[]);
    app = MockAppHost();
    platform = MockPlatformHost();
    store = MockSettingsStore();

    when(() => app.isMynaEnabled()).thenAnswer((_) async => enabled);
    when(() => app.isMynaSelected()).thenAnswer((_) async => selected);
    when(() => app.takeLaunchRoute()).thenAnswer((_) async => launchRoute);
    when(() => app.openInputMethodSettings()).thenAnswer((_) async {});
    when(() => app.showInputMethodPicker()).thenAnswer((_) async {});

    when(() => platform.getSystemColors()).thenAnswer((_) async => null);
    when(() => platform.hasInternetPermission()).thenAnswer((_) async => internet);
    when(() => platform.getAppInfo()).thenAnswer(
      (_) async => AppInfoMessage(
        packageName: 'app.myna.keyboard',
        versionName: '1.0.0',
        versionCode: 1,
        sdkInt: 36,
        isDebugBuild: true,
      ),
    );
    when(() => platform.notifySettingsChanged(any())).thenAnswer((_) async {});

    when(() => store.value).thenReturn(settings);
    when(() => store.update(any(), sections: any(named: 'sections'))).thenAnswer((_) async {});

    services = AppServices(settings: store, secureStore: InMemorySecureBlobStore(), platform: platform, app: app);
  }

  final String? launchRoute;
  late final MockAppHost app;
  late final MockPlatformHost platform;
  late final MockSettingsStore store;
  late final AppServices services;
}

/// Pumps [child] with the services above it.
Future<void> pumpWithServices(WidgetTester tester, AppServices services, Widget child) async {
  tester.view.devicePixelRatio = 1;
  tester.view.physicalSize = const Size(800, 1600);
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(AppScope(services: services, child: child));
  await tester.pumpAndSettle();
}

/// Scrolls [text] into view inside the page's only scrollable, then taps it.
Future<void> tapText(WidgetTester tester, String text) async {
  final finder = find.text(text);
  await tester.scrollUntilVisible(finder, 200, scrollable: find.byType(Scrollable).first);
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

/// The settings function passed to the last `update` call for [section].
MynaSettings Function(MynaSettings) capturedUpdate(MockSettingsStore store, String section) {
  final captured = verify(() => store.update(captureAny(), sections: [section])).captured;
  return captured.last as MynaSettings Function(MynaSettings);
}
