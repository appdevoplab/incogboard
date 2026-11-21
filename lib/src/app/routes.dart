// SPDX-License-Identifier: GPL-3.0-or-later
//
// CONTRACT (orchestrator-owned): settings-app route names. The keyboard opens
// them with `ImeHostApi.openSettings(route)`; the app reads the launch route
// with `AppHostApi.takeLaunchRoute()` and later ones from
// `AppServices.routeRequests`. Wave 2-A's shell maps them to screens.
abstract final class MynaRoutes {
  static const String home = 'home';
  static const String onboarding = 'onboarding';
  static const String languages = 'languages';
  static const String typing = 'typing';
  static const String feel = 'feel';
  static const String panels = 'panels';
  static const String clipboard = 'clipboard';
  static const String themes = 'themes';
  static const String privacy = 'privacy';
  static const String about = 'about';

  static const List<String> all = [
    home,
    onboarding,
    languages,
    typing,
    feel,
    panels,
    clipboard,
    themes,
    privacy,
    about,
  ];
}
